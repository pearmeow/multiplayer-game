function team_get_indicator() {
    var _body = instance_find(obj_player, 0);
    if (!instance_exists(_body)) return undefined;
    var _enemy = instance_nearest(_body.x, _body.y, par_enemy);
    if (!instance_exists(_enemy)) return undefined;
    var _distance = point_distance(_body.x, _body.y, _enemy.x, _enemy.y);
    return {angle: point_direction(_body.x, _body.y, _enemy.x, _enemy.y),
        size: lerp(indicator_max_size, indicator_min_size, clamp(_distance / indicator_far_distance, 0, 1))};
}
function team_draw_vision_mesh(_rays, _x, _y, _sx, _sy, _range, _colour, _alpha) {
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
}
function team_draw_vision() {
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
        var _range = coop_wall_view_distance(_aim, _body.x, _body.y, _angle, _aim.vision_range, vision_wall_reveal);
        var _edge = clamp((_aim.cone_width / 2 - abs(_offset)) / vision_edge_fade_angle, 0, 1);
        array_push(_rays, {angle: _angle, range: _range, edge: _edge});
    }
    var _ghost_range = _aim.get_ghost_vision_range();
    var _ghost_x = (_aim.x - camera_get_view_x(camera_id)) * _scale_x;
    var _ghost_y = (_aim.y - camera_get_view_y(camera_id)) * _scale_y;
    var _ghost_rays = [];
    for (var _i = 0; _i <= vision_rays; _i++) {
        var _angle = 360 * _i / vision_rays;
        var _range = coop_wall_view_distance(_aim, _aim.x, _aim.y, _angle, _ghost_range, vision_wall_reveal);
        array_push(_ghost_rays, {angle: _angle, range: _range, edge: 1});
    }
    if (!surface_exists(vision_mask)) vision_mask = surface_create(display_get_gui_width(), display_get_gui_height());
    surface_set_target(vision_mask);
    draw_clear_alpha(c_black, 1);
    gpu_set_blendmode_ext(bm_zero, bm_inv_src_alpha);
    draw_set_alpha(1);
    team_draw_vision_mesh(_rays, _x, _y, _scale_x, _scale_y, _aim.vision_range, c_white, vision_brightness * hunter_vision_multiplier);
    team_draw_vision_mesh(_ghost_rays, _ghost_x, _ghost_y, _scale_x, _scale_y, _ghost_range, c_white, vision_brightness);
    gpu_set_blendmode(bm_normal);
    surface_reset_target();
    draw_surface(vision_mask, 0, 0);
    team_draw_vision_mesh(_rays, _x, _y, _scale_x, _scale_y, _aim.vision_range, vision_tint_colour, vision_tint_alpha);
    team_draw_vision_mesh(_ghost_rays, _ghost_x, _ghost_y, _scale_x, _scale_y, _ghost_range, vision_tint_colour, vision_tint_alpha);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}
function team_draw_own_players() {
    var _body = instance_find(obj_player, 0);
    if (!instance_exists(_body) || camera_id == -1) return;
    var _camera_x = camera_get_view_x(camera_id);
    var _camera_y = camera_get_view_y(camera_id);
    var _sx = display_get_gui_width() / camera_get_view_width(camera_id);
    var _sy = display_get_gui_height() / camera_get_view_height(camera_id);
    var _aim = _body.aim_controller;
    if (!instance_exists(_aim)) return;
    draw_sprite_ext(_body.sprite_index, _body.image_index, (_body.x - _camera_x) * _sx, (_body.y - _camera_y) * _sy, _sx, _sy, 0, c_white, 1);
    draw_sprite_ext(spr_ghost, 0, (_aim.x - _camera_x) * _sx, (_aim.y - _camera_y) * _sy, _sx, _sy, 0, c_white, _body.aim_controller.ghost_alpha);
}
function team_draw_indicator() {
    var _info = team_get_indicator();
    if (is_undefined(_info) || camera_id == -1) return;
    var _body = instance_find(obj_player, 0);
    var _x = (_body.x - camera_get_view_x(camera_id)) * display_get_gui_width() / camera_get_view_width(camera_id);
    var _y = (_body.y - camera_get_view_y(camera_id)) * display_get_gui_height() / camera_get_view_height(camera_id);
    var _angle = _info.angle;
    var _size = _info.size;
    var _radius = indicator_radius;
    team_draw_pointer(_x, _y, _angle, _size, _radius, c_red);
}

function team_draw_pointer(_x, _y, _angle, _size, _radius, _colour) {
    var _front_x = _x + lengthdir_x(_radius + _size, _angle);
    var _front_y = _y + lengthdir_y(_radius + _size, _angle);
    var _back_x = _x + lengthdir_x(_radius - _size, _angle);
    var _back_y = _y + lengthdir_y(_radius - _size, _angle);
    draw_set_alpha(1);
    draw_set_colour(_colour);
    draw_triangle(_front_x, _front_y,
        _back_x + lengthdir_x(_size * 0.7, _angle + 90), _back_y + lengthdir_y(_size * 0.7, _angle + 90),
        _back_x + lengthdir_x(_size * 0.7, _angle - 90), _back_y + lengthdir_y(_size * 0.7, _angle - 90), false);
    draw_set_colour(c_white);
}

function team_get_plate_target(_aim) {
    var _nearest = noone;
    var _distance = infinity;
    for (var _i = 0; _i < instance_number(obj_door_trigger); _i++) {
        var _plate = instance_find(obj_door_trigger, _i);
        if (_plate.activations > 0 || _plate.target_link == 0) continue;
        var _d = point_distance(_aim.x, _aim.y, _plate.x, _plate.y);
        if (_d >= _distance) continue;
        _distance = _d;
        _nearest = _plate;
    }
    return _nearest;
}

function team_draw_plate_indicator(_aim) {
    var _plate = team_get_plate_target(_aim);
    if (!instance_exists(_plate)) return;
    var _x = (_aim.x - camera_get_view_x(camera_id)) * display_get_gui_width() / camera_get_view_width(camera_id);
    var _y = (_aim.y - camera_get_view_y(camera_id)) * display_get_gui_height() / camera_get_view_height(camera_id);
    var _angle = point_direction(_aim.x, _aim.y, (_plate.bbox_left + _plate.bbox_right) / 2,
        (_plate.bbox_top + _plate.bbox_bottom) / 2);
    team_draw_pointer(_x, _y, _angle, plate_indicator_size, plate_indicator_radius, c_yellow);
}


function team_draw_interaction_halo(_target) {
    var _x = _target.x;
    var _y = _target.y;
    var _sprite = _target.sprite_index;
    if (_target.object_index == obj_door && _target.is_open) _sprite = _target.open_sprite;
    if (_sprite != -1) {
        var _ox = (sprite_get_width(_sprite) / 2 - sprite_get_xoffset(_sprite)) * _target.image_xscale;
        var _oy = (sprite_get_height(_sprite) / 2 - sprite_get_yoffset(_sprite)) * _target.image_yscale;
        _x += _ox * dcos(_target.image_angle) + _oy * dsin(_target.image_angle);
        _y += _oy * dcos(_target.image_angle) - _ox * dsin(_target.image_angle);
    }

    var _sx = display_get_gui_width() / camera_get_view_width(camera_id);
    var _sy = display_get_gui_height() / camera_get_view_height(camera_id);
    _x = (_x - camera_get_view_x(camera_id)) * _sx;
    _y = (_y - camera_get_view_y(camera_id)) * _sy;
    var _radii = [interaction_halo_radius * 0.5, interaction_halo_radius, interaction_halo_radius * 1.8];
    var _alpha = [0, interaction_halo_alpha, 0];

    for (var _band = 0; _band < 2; _band++) {
        draw_primitive_begin(pr_trianglestrip);
        for (var _i = 0; _i <= vision_rays; _i++) {
            var _angle = 360 * _i / vision_rays;
            for (var _side = 0; _side < 2; _side++) {
                var _ring = _band + _side;
                draw_vertex_colour(_x + lengthdir_x(_radii[_ring], _angle) * _sx,
                    _y + lengthdir_y(_radii[_ring], _angle) * _sy, c_yellow, _alpha[_ring]);
            }
        }
        draw_primitive_end();
    }
}


function team_draw_hud_text(_x, _y, _text) {
    draw_text_transformed(_x, _y, _text, hud_text_scale, hud_text_scale, 0);
}

function team_draw_status_bar(_x, _y, _width, _height, _value, _maximum, _colour, _label) {
    draw_set_colour(make_colour_rgb(35, 40, 50));
    draw_rectangle(_x, _y, _x + _width, _y + _height, false);
    draw_set_colour(_colour);
    if (_value > 0) draw_rectangle(_x, _y, _x + _width * clamp(_value / max(1, _maximum), 0, 1), _y + _height, false);
    draw_set_colour(c_white);
    draw_rectangle(_x, _y, _x + _width, _y + _height, true);
    team_draw_hud_text(_x + 5, _y + 1, _label + ": " + string(round(_value * 100) / 100) + "/" + string(round(_maximum * 100) / 100));
}
