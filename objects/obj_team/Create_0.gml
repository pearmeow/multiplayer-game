if (instance_number(obj_team) > 1) { instance_destroy(); exit; }
energy = energy_max;
reward_keys = [];
weapon_catalog = {};
if (file_exists("weapons.json")) {
    var _file = file_text_open_read("weapons.json");
    var _json = "";
    while (!file_text_eof(_file)) {
        _json += file_text_read_string(_file);
        file_text_readln(_file);
    }
    file_text_close(_file);
    weapon_catalog = json_parse(_json);
}
weapon = variable_struct_get(weapon_catalog, starting_weapon);
weapon_damage = is_undefined(weapon) ? 0 : weapon.damage;

has_reward = function(_key) {
    for (var _i = 0; _i < array_length(reward_keys); _i++) {
        if (reward_keys[_i] == _key) return true;
    }
    return false;
};

claim_reward = function(_key, _weapon_id) {
    if (has_reward(_key)) return false;
    var _next = variable_struct_get(weapon_catalog, _weapon_id);
    if (is_undefined(_next)) {
        notify("Weapon reward is not configured");
        return false;
    }
    if (!is_undefined(weapon) && _next.rank <= weapon.rank) {
        notify("Already equipped with a weapon of this tier or higher");
        return false;
    }

    var _bonus = random_range(0, clamp(luck / 100, 0, 1) * max(0, luck_bonus_max));
    weapon = _next;
    weapon_damage = round(weapon.damage * (1 + _bonus) * 100) / 100;
    array_push(reward_keys, _key);
    notify("Equipped " + weapon.name + " / Damage " + string(weapon_damage));
    return true;
};

get_action_cost = function() {
    return max(1, action_energy_cost);
};

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
    draw_vision_mesh(_rays, _x, _y, _scale_x, _scale_y, _aim.vision_range, c_white, vision_brightness * 0.6);
    draw_vision_mesh(_ghost_rays, _ghost_x, _ghost_y, _scale_x, _scale_y, _ghost_range, c_white, vision_brightness);
    gpu_set_blendmode(bm_normal);
    surface_reset_target();
    draw_surface(vision_mask, 0, 0);
    draw_vision_mesh(_rays, _x, _y, _scale_x, _scale_y, _aim.vision_range, vision_tint_colour, vision_tint_alpha);
    draw_vision_mesh(_ghost_rays, _ghost_x, _ghost_y, _scale_x, _scale_y, _ghost_range, vision_tint_colour, vision_tint_alpha);
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
    var _radius = indicator_radius;
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


draw_interaction_halo = function(_target) {
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
};


draw_status_bar = function(_x, _y, _width, _value, _maximum, _colour, _label) {
    draw_set_colour(make_colour_rgb(35, 40, 50));
    draw_rectangle(_x, _y, _x + _width, _y + 20, false);
    draw_set_colour(_colour);
    if (_value > 0) draw_rectangle(_x, _y, _x + _width * clamp(_value / max(1, _maximum), 0, 1), _y + 20, false);
    draw_set_colour(c_white);
    draw_rectangle(_x, _y, _x + _width, _y + 20, true);
    draw_text(_x + 5, _y + 2, _label + ": " + string(round(_value * 100) / 100) + "/" + string(_maximum));
};
