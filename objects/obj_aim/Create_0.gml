owner_body = noone;
aim_angle = 90;
ghost_offset_x = 0;
ghost_offset_y = 0;
// The drawn ghost is separate; use a one-pixel mask to sample walls and enemies.
mask_index = spr_wall;
image_xscale = 1 / sprite_get_width(spr_wall);
image_yscale = 1 / sprite_get_height(spr_wall);

get_ghost_pose = function() {
    return {x: x, y: y, rotation: 0};
};

clamp_ghost_position = function() {
    var _distance = point_distance(0, 0, ghost_offset_x, ghost_offset_y);

    if (_distance > ghost_move_radius) {
        ghost_offset_x = ghost_offset_x / _distance * ghost_move_radius;
        ghost_offset_y = ghost_offset_y / _distance * ghost_move_radius;
    }

    x = owner_body.x + ghost_offset_x;
    y = owner_body.y + ghost_offset_y;
};

interaction_pressed = false;
interaction_was_down = false;
read_interaction_input = function(_down) {
    var _pressed = _down && !interaction_was_down;
    interaction_was_down = _down;
    return _pressed;
};
update_interaction = function(_pressed) {
    var _body = owner_body;
    if (!instance_exists(_body)) return false;
    _body.interaction_target = noone;
    var _best = max(_body.interact_range, ghost_interact_range) + 1;
    var _target_point = undefined;
    var _target_is_door = false;
    var _groups = [par_interactable, obj_door];
    for (var _group = 0; _group < array_length(_groups); _group++) {
        var _object = _groups[_group];
        for (var _i = 0; _i < instance_number(_object); _i++) {
            var _item = instance_find(_object, _i);
            if (!_item.enabled) continue;
            var _is_door = _object == obj_door;
            var _point = {x: _item.x, y: _item.y};
            var _distance;
            if (_is_door) {
                if (!_item.can_interact()) continue;
                _point = _item.get_interaction_point(id);
                _distance = point_distance(x, y, _point.x, _point.y);
                if (_distance > ghost_interact_range) continue;
                var _angle = point_direction(x, y, _point.x, _point.y);
                if (coop_wall_distance(id, x, y, _angle, _distance, _item) != -1) continue;
            } else {
                _distance = point_distance(_body.x, _body.y, _point.x, _point.y);
                if (_distance > _body.interact_range) continue;
                if (!coop_visible(_body, _point.x, _point.y, _item)) continue;
            }
            if (_distance >= _best) continue;
            _body.interaction_target = _item;
            _best = _distance;
            _target_point = _point;
            _target_is_door = _is_door;
        }
    }
    if (!_pressed || !instance_exists(_body.interaction_target)) return false;
    if (!_body.team.try_spend(_body.team.action_energy_cost)) {
        _body.team.notify("Not enough energy to interact");
        return false;
    }
    _body.interaction_target.interact(_target_is_door ? id : _body);
    if (_target_is_door) {
        _body.show_action_effect(_target_point.x, _target_point.y, _body.interact_effect_colour, x, y);
    } else {
        _body.show_action_effect(_target_point.x, _target_point.y, _body.interact_effect_colour);
    }
    return true;
};
