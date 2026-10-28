if (instance_number(obj_team) > 1) { instance_destroy(); exit; }
energy = energy_max;
regen_elapsed = 0;
feedback = "";
feedback_time = 0;
try_spend = function(_cost) {
    if (_cost < 0 || energy < _cost) return false;
    energy = clamp(energy - _cost, 0, energy_max);
    return true;
};
notify = function(_message) {
    feedback = _message;
    feedback_time = 1.5;
};

advance_energy = function(_seconds) {
    var _dt = max(0, _seconds);
    energy = clamp(energy, 0, energy_max);
if (energy < energy_max) {
    regen_elapsed += _dt;
    var _ticks = floor(regen_elapsed);
    if (_ticks > 0) {
        energy = min(energy_max, energy + _ticks * energy_regen_per_second);
        regen_elapsed -= _ticks;
    }
}

if (energy >= energy_max) regen_elapsed = 0;

};

changing_room = false;
camera_id = -1;
saved_aim_angle = 90;
window_set_size(camera_width, camera_height);
display_set_gui_size(camera_width, camera_height);

change_room = function(_target) {
    if (changing_room) {
        return false;
    }
    if (_target == room) {
        return false;
    }

    var _valid_room = false;
    if (_target == rm_01) {
        _valid_room = true;
    }
    if (_target == rm_02) {
        _valid_room = true;
    }
    if (_target == rm_03) {
        _valid_room = true;
    }
    if (!_valid_room) {
        return false;
    }

    var _body = instance_find(obj_player, 0);
    if (instance_exists(_body)) {
        if (instance_exists(_body.aim_controller)) {
            saved_aim_angle = _body.aim_controller.aim_angle;
        }
    }

    changing_room = true;
    room_goto(_target);
    return true;
};

update_camera = function(_snap) {
    if (camera_id == -1) {
        return;
    }
    var _body = instance_find(obj_player, 0);
    if (!instance_exists(_body)) {
        return;
    }

    var _view_width = camera_get_view_width(camera_id);
    var _view_height = camera_get_view_height(camera_id);
    var _limit_x = max(0, room_width - _view_width);
    var _limit_y = max(0, room_height - _view_height);
    var _target_x = clamp(_body.x - _view_width / 2, 0, _limit_x);
    var _target_y = clamp(_body.y - _view_height / 2, 0, _limit_y);

    var _new_x = _target_x;
    var _new_y = _target_y;
    if (!_snap) {
        var _old_x = camera_get_view_x(camera_id);
        var _old_y = camera_get_view_y(camera_id);
        _new_x = lerp(_old_x, _target_x, camera_smoothing);
        _new_y = lerp(_old_y, _target_y, camera_smoothing);
    }

    _new_x = clamp(_new_x, 0, _limit_x);
    _new_y = clamp(_new_y, 0, _limit_y);
    camera_set_view_pos(camera_id, _new_x, _new_y);
};

vision_mask = -1;
get_indicator = function() {
    var _body = instance_find(obj_player, 0);
    if (!instance_exists(_body)) return undefined;
    var _enemy = instance_nearest(_body.x, _body.y, par_enemy);
    if (!instance_exists(_enemy)) return undefined;
    var _distance = point_distance(_body.x, _body.y, _enemy.x, _enemy.y);
    return {enemy: _enemy, angle: point_direction(_body.x, _body.y, _enemy.x, _enemy.y),
        size: lerp(indicator_max_size, indicator_min_size, clamp(_distance / indicator_far_distance, 0, 1))};
};
draw_vision = function() {
    if (camera_id == -1) return;
    var _body = instance_find(obj_player, 0);
    if (!instance_exists(_body)) return;
    var _aim = _body.aim_controller;
    var _camera_x = camera_get_view_x(camera_id);
    var _camera_y = camera_get_view_y(camera_id);
    var _scale_x = display_get_gui_width() / camera_get_view_width(camera_id);
    var _scale_y = display_get_gui_height() / camera_get_view_height(camera_id);
    var _x = (_body.x - _camera_x) * _scale_x;
    var _y = (_body.y - _camera_y) * _scale_y;
    var _rays = [];
    for (var _i = 0; _i <= vision_rays; _i++) {
        var _offset = -_aim.cone_width / 2 + _aim.cone_width * _i / vision_rays;
        var _angle = _aim.aim_angle + _offset;
        var _range = coop_wall_view_distance(_body.x, _body.y, _angle, _aim.vision_range, vision_wall_reveal);
        var _edge = clamp((_aim.cone_width / 2 - abs(_offset)) / vision_edge_fade_angle, 0, 1);
        array_push(_rays, {angle: _angle, range: _range, edge: _edge});
    }
    var _vertices = [];
    for (var _i = 0; _i < array_length(_rays) - 1; _i++) {
        var _strip = [];
        for (var _step = 0; _step <= vision_fade_steps; _step++) {
            for (var _side = 0; _side < 2; _side++) {
                var _ray = _rays[_i + _side];
                var _distance = _ray.range * _step / vision_fade_steps;
                var _fade = clamp((_aim.vision_range - _distance) / vision_distance_fade, 0, 1) * _ray.edge;
                array_push(_strip, {x: _x + lengthdir_x(_distance, _ray.angle) * _scale_x,
                    y: _y + lengthdir_y(_distance, _ray.angle) * _scale_y, fade: _fade});
            }
        }
        array_push(_vertices, _strip);
    }
    if (!surface_exists(vision_mask)) vision_mask = surface_create(display_get_gui_width(), display_get_gui_height());
    surface_set_target(vision_mask);
    draw_clear_alpha(c_black, 1);
    gpu_set_blendmode_ext(bm_zero, bm_inv_src_alpha);
    draw_set_alpha(1);
    for (var _i = 0; _i < array_length(_vertices); _i++) {
        var _strip = _vertices[_i];
        draw_primitive_begin(pr_trianglestrip);
        for (var _j = 0; _j < array_length(_strip); _j++) {
            var _point = _strip[_j];
            draw_vertex_colour(_point.x, _point.y, c_white, _point.fade * vision_brightness);
        }
        draw_primitive_end();
    }
    gpu_set_blendmode(bm_normal);
    surface_reset_target();
    draw_surface(vision_mask, 0, 0);
    for (var _i = 0; _i < array_length(_vertices); _i++) {
        var _strip = _vertices[_i];
        draw_primitive_begin(pr_trianglestrip);
        for (var _j = 0; _j < array_length(_strip); _j++) {
            var _point = _strip[_j];
            draw_vertex_colour(_point.x, _point.y, vision_tint_colour, _point.fade * vision_tint_alpha);
        }
        draw_primitive_end();
    }
    draw_set_alpha(1);
    draw_set_colour(c_white);
};
draw_own_players = function() {
    var _body = instance_find(obj_player, 0);
    if (!instance_exists(_body) || camera_id == -1) return;
    var _camera_x = camera_get_view_x(camera_id);
    var _camera_y = camera_get_view_y(camera_id);
    var _sx = display_get_gui_width() / camera_get_view_width(camera_id);
    var _sy = display_get_gui_height() / camera_get_view_height(camera_id);
    var _pose = _body.aim_controller.get_ghost_pose();
    draw_sprite_ext(_body.sprite_index, _body.image_index, (_body.x - _camera_x) * _sx, (_body.y - _camera_y) * _sy, _sx, _sy, 0, c_white, 1);
    draw_sprite_ext(spr_ghost, 0, (_pose.x - _camera_x) * _sx, (_pose.y - _camera_y) * _sy, _sx, _sy, 0, c_white, _body.aim_controller.ghost_alpha);
};
draw_indicator = function() {
    var _info = get_indicator();
    if (is_undefined(_info) || camera_id == -1) return;
    var _body = instance_find(obj_player, 0);
    var _x = (_body.x - camera_get_view_x(camera_id)) * display_get_gui_width() / camera_get_view_width(camera_id);
    var _y = (_body.y - camera_get_view_y(camera_id)) * display_get_gui_height() / camera_get_view_height(camera_id);
    var _angle = _info.angle;
    var _size = _info.size;
    var _pose = _body.aim_controller.get_ghost_pose();
    var _ghost_edge = point_distance(_body.x, _body.y, _pose.x, _pose.y) + max(sprite_get_width(spr_ghost), sprite_get_height(spr_ghost)) / 2;
    var _radius = max(indicator_radius, _ghost_edge + _size);
    var _front_x = _x + lengthdir_x(_radius + _size, _angle);
    var _front_y = _y + lengthdir_y(_radius + _size, _angle);
    var _back_x = _x + lengthdir_x(_radius - _size, _angle);
    var _back_y = _y + lengthdir_y(_radius - _size, _angle);
    draw_set_alpha(1);
    draw_set_colour(c_red);
    draw_triangle(_front_x, _front_y,
        _back_x + lengthdir_x(_size * 0.7, _angle + 90), _back_y + lengthdir_y(_size * 0.7, _angle + 90),
        _back_x + lengthdir_x(_size * 0.7, _angle - 90), _back_y + lengthdir_y(_size * 0.7, _angle - 90), false);
    draw_set_colour(c_white);
};
