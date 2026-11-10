function team_gui_projection() {
    return {
        x: camera_get_view_x(camera_id),
        y: camera_get_view_y(camera_id),
        sx: display_get_gui_width() / camera_get_view_width(camera_id),
        sy: display_get_gui_height() / camera_get_view_height(camera_id)
    };
}

function team_gui_point(_projection, _x, _y) {
    return {x: (_x - _projection.x) * _projection.sx, y: (_y - _projection.y) * _projection.sy};
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
    if (!instance_exists(_aim)) return;
    var _projection = team_gui_projection();
    var _hunter = team_gui_point(_projection, _body.x, _body.y);
    var _hunter_range = _aim.get_hunter_vision_range();
    var _rays = [];
    for (var _i = 0; _i <= vision_rays; _i++) {
        var _offset = -_aim.cone_width / 2 + _aim.cone_width * _i / vision_rays;
        var _angle = _aim.aim_angle + _offset;
        var _range = coop_wall_view_distance(_aim, _body.x, _body.y, _angle, _hunter_range, vision_wall_reveal);
        var _edge = clamp((_aim.cone_width / 2 - abs(_offset)) / vision_edge_fade_angle, 0, 1);
        array_push(_rays, {angle: _angle, range: _range, edge: _edge});
    }
    var _ghost_range = _aim.get_ghost_vision_range();
    var _ghost = team_gui_point(_projection, _aim.x, _aim.y);
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
    team_draw_vision_mesh(_rays, _hunter.x, _hunter.y, _projection.sx, _projection.sy, _hunter_range, c_white, vision_brightness * hunter_vision_multiplier);
    team_draw_vision_mesh(_ghost_rays, _ghost.x, _ghost.y, _projection.sx, _projection.sy, _ghost_range, c_white, vision_brightness);
    gpu_set_blendmode(bm_normal);
    surface_reset_target();
    draw_surface(vision_mask, 0, 0);
    team_draw_vision_mesh(_rays, _hunter.x, _hunter.y, _projection.sx, _projection.sy, _hunter_range, vision_tint_colour, vision_tint_alpha);
    team_draw_vision_mesh(_ghost_rays, _ghost.x, _ghost.y, _projection.sx, _projection.sy, _ghost_range, vision_tint_colour, vision_tint_alpha);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}
function team_draw_own_players() {
    var _body = instance_find(obj_player, 0);
    if (!instance_exists(_body) || camera_id == -1) return;
    var _aim = _body.aim_controller;
    if (!instance_exists(_aim)) return;
    var _projection = team_gui_projection();
    var _hunter = team_gui_point(_projection, _body.x, _body.y);
    var _ghost = team_gui_point(_projection, _aim.x, _aim.y);
    draw_sprite_ext(_body.sprite_index, _body.image_index, _hunter.x, _hunter.y, _projection.sx, _projection.sy, 0, c_white, 1);
    draw_sprite_ext(spr_ghost, 0, _ghost.x, _ghost.y, _projection.sx, _projection.sy, 0, c_white, _aim.ghost_alpha);
}
function team_draw_indicator() {
    if (camera_id == -1) return;
    var _body = instance_find(obj_player, 0);
    if (!instance_exists(_body) || !instance_exists(_body.aim_controller)) return;
    var _aim = _body.aim_controller;
    var _point = team_gui_point(team_gui_projection(), _aim.x, _aim.y);
    for (var _i = 0; _i < instance_number(par_enemy); _i++) {
        var _enemy = instance_find(par_enemy, _i);
        if (_enemy.state != 1) continue;
        var _distance = point_distance(_aim.x, _aim.y, _enemy.x, _enemy.y);
        var _size = lerp(indicator_min_size, indicator_max_size, coop_proximity(_distance, indicator_far_distance));
        team_draw_pointer(_point.x, _point.y, point_direction(_aim.x, _aim.y, _enemy.x, _enemy.y), _size,
            max(plate_indicator_radius, max(sprite_get_width(spr_ghost), sprite_get_height(spr_ghost)) / 2 + _size), c_red);
    }
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
    var _point = team_gui_point(team_gui_projection(), _aim.x, _aim.y);
    var _angle = point_direction(_aim.x, _aim.y, (_plate.bbox_left + _plate.bbox_right) / 2,
        (_plate.bbox_top + _plate.bbox_bottom) / 2);
    team_draw_pointer(_point.x, _point.y, _angle, plate_indicator_size, plate_indicator_radius, c_yellow);
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

    var _projection = team_gui_projection();
    var _point = team_gui_point(_projection, _x, _y);
    var _radii = [interaction_halo_radius * 0.5, interaction_halo_radius, interaction_halo_radius * 1.8];
    var _alpha = [0, interaction_halo_alpha, 0];

    for (var _band = 0; _band < 2; _band++) {
        draw_primitive_begin(pr_trianglestrip);
        for (var _i = 0; _i <= vision_rays; _i++) {
            var _angle = 360 * _i / vision_rays;
            for (var _side = 0; _side < 2; _side++) {
                var _ring = _band + _side;
                draw_vertex_colour(_point.x + lengthdir_x(_radii[_ring], _angle) * _projection.sx,
                    _point.y + lengthdir_y(_radii[_ring], _angle) * _projection.sy, c_yellow, _alpha[_ring]);
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

function team_draw_slow_range(_ghost) {
    if (!instance_exists(_ghost) || !_ghost.slow_active) return;

    var _projection = team_gui_projection();
    var _point = team_gui_point(_projection, _ghost.x, _ghost.y);
    var _rx = _ghost.slow_range * _projection.sx;
    var _ry = _ghost.slow_range * _projection.sy;

    draw_set_colour(_ghost.slow_colour);
    draw_set_alpha(_ghost.slow_alpha);

    draw_ellipse(
        _point.x - _rx,
        _point.y - _ry,
        _point.x + _rx,
        _point.y + _ry,
        false
    );

    draw_set_alpha(1);
    draw_set_colour(c_white);
}