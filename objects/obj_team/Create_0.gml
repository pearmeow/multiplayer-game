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
    energy = clamp(energy, 0, energy_max);
    if (energy < energy_max) {
        regen_elapsed += max(0, _seconds);
        energy = min(energy_max, energy + floor(regen_elapsed) * energy_regen_per_second);
        regen_elapsed -= floor(regen_elapsed);
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

    if (!room_exists(_target)) return false;

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
    var _body = instance_find(obj_player, 0);
    if (camera_id == -1 || !instance_exists(_body)) return;
    var _x = max(0, room_width - camera_get_view_width(camera_id));
    var _y = max(0, room_height - camera_get_view_height(camera_id));
    var _target_x = clamp(_body.x - camera_get_view_width(camera_id) / 2, 0, _x);
    var _target_y = clamp(_body.y - camera_get_view_height(camera_id) / 2, 0, _y);
    if (!_snap) {
        _target_x = lerp(camera_get_view_x(camera_id), _target_x, camera_smoothing);
        _target_y = lerp(camera_get_view_y(camera_id), _target_y, camera_smoothing);
    }
    camera_set_view_pos(camera_id, clamp(_target_x, 0, _x), clamp(_target_y, 0, _y));
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
draw_vision_mesh = function(_rays, _x, _y, _sx, _sy, _range, _colour, _alpha) {
    for (var _i = 0; _i < array_length(_rays) - 1; _i++) {
        draw_primitive_begin(pr_trianglestrip);
        for (var _step = 0; _step <= vision_fade_steps; _step++) {
            for (var _side = 0; _side < 2; _side++) {
                var _ray = _rays[_i + _side];
                var _distance = _ray.range * _step / vision_fade_steps;
                var _fade = clamp((_range - _distance) / vision_distance_fade, 0, 1) * _ray.edge;
                draw_vertex_colour(_x + lengthdir_x(_distance, _ray.angle) * _sx,
                    _y + lengthdir_y(_distance, _ray.angle) * _sy, _colour, _fade * _alpha);
            }
        }
        draw_primitive_end();
    }
};
draw_vision = function() {
    if (camera_id == -1) return;
    var _body = instance_find(obj_player, 0);
    if (!instance_exists(_body)) return;
    var _aim = _body.aim_controller;
    var _scale_x = display_get_gui_width() / camera_get_view_width(camera_id);
    var _scale_y = display_get_gui_height() / camera_get_view_height(camera_id);
    var _x = (_body.x - camera_get_view_x(camera_id)) * _scale_x;
    var _y = (_body.y - camera_get_view_y(camera_id)) * _scale_y;
    var _rays = [];
    for (var _i = 0; _i <= vision_rays; _i++) {
        var _offset = -_aim.cone_width / 2 + _aim.cone_width * _i / vision_rays;
        var _angle = _aim.aim_angle + _offset;
        var _range = coop_wall_view_distance(_body.x, _body.y, _angle, _aim.vision_range, vision_wall_reveal);
        var _edge = clamp((_aim.cone_width / 2 - abs(_offset)) / vision_edge_fade_angle, 0, 1);
        array_push(_rays, {angle: _angle, range: _range, edge: _edge});
    }
    if (!surface_exists(vision_mask)) vision_mask = surface_create(display_get_gui_width(), display_get_gui_height());
    surface_set_target(vision_mask);
    draw_clear_alpha(c_black, 1);
    gpu_set_blendmode_ext(bm_zero, bm_inv_src_alpha);
    draw_set_alpha(1);
    draw_vision_mesh(_rays, _x, _y, _scale_x, _scale_y, _aim.vision_range, c_white, vision_brightness);
    gpu_set_blendmode(bm_normal);
    surface_reset_target();
    draw_surface(vision_mask, 0, 0);
    draw_vision_mesh(_rays, _x, _y, _scale_x, _scale_y, _aim.vision_range, vision_tint_colour, vision_tint_alpha);
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
