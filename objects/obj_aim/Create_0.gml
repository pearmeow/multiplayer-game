owner_body = noone;
aim_angle = 90;
ghost_offset_x = 0;
ghost_offset_y = 0;
slow_active = false;
slow_key = vk_rshift;
// The drawn ghost is separate; use a one-pixel mask to sample walls and enemies.
mask_index = spr_wall;
image_xscale = 1 / sprite_get_width(spr_wall);
image_yscale = 1 / sprite_get_height(spr_wall);

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
get_hunter_vision_range = function() {
    return owner_body.get_vision_range(vision_range);
};

get_ghost_vision_range = function() {
    return owner_body.get_vision_range(ghost_vision_range, owner_body.team.stat_bonus.ghost_vision);
};

update_interaction = function(_pressed, _dx = 0, _dy = 0) {
    var _body = owner_body;
    if (!instance_exists(_body)) return false;
    var _current = _body.interaction_target;
    var _nearest = undefined;
    var _locked = undefined;
    var _directional = undefined;
    var _range = get_ghost_vision_range();
    if (_range <= 0) {
        _body.interaction_target = noone;
        return false;
    }
    var _groups = [par_interactable, obj_door];

    for (var _group = 0; _group < array_length(_groups); _group++) {
        var _object = _groups[_group];
        for (var _i = 0; _i < instance_number(_object); _i++) {
            var _item = instance_find(_object, _i);
            if (!_item.enabled) continue;
            var _point = {x: _item.x, y: _item.y};
            if (_object == obj_door) {
                if (!_item.can_interact()) continue;
                _point = _item.get_interaction_point(id);
            }
            var _distance = point_distance(x, y, _point.x, _point.y);
            if (_distance > _range) continue;
            if (coop_wall_distance(id, x, y, point_direction(x, y, _point.x, _point.y), _distance, _item) != -1) continue;

            var _candidate = {item: _item, point: _point, distance: _distance, door: _object == obj_door};
            if (is_undefined(_nearest) || _distance < _nearest.distance) _nearest = _candidate;
            if (_item == _current) _locked = _candidate;
            if ((_dx != 0 || _dy != 0) && instance_exists(_current)) {
                var _off_x = _item.x - _current.x;
                var _off_y = _item.y - _current.y;
                if (_off_x * _dx + _off_y * _dy <= 0) continue;
                _candidate.switch_distance = point_distance(0, 0, _off_x, _off_y);
                if (is_undefined(_directional) || _candidate.switch_distance < _directional.switch_distance) {
                    _directional = _candidate;
                }
            }
        }
    }

    if (!is_undefined(_locked)) {
        _nearest = _locked;
        if (!is_undefined(_directional)) _nearest = _directional;
    }
    _body.interaction_target = noone;
    if (is_undefined(_nearest)) return false;
    _body.interaction_target = _nearest.item;
    if (!_pressed) return false;

    var _team = _body.team;
    if ((_nearest.door || !_nearest.item.interaction_free) && !_team.try_spend(_team.get_action_cost())) {
        _team.notify("Not enough energy to interact");
        return false;
    }
    _nearest.item.interact(_nearest.door ? id : _body);
    _body.show_action_effect(_nearest.point.x, _nearest.point.y, _body.interact_effect_colour, x, y);
    if (!instance_exists(_nearest.item) || !_nearest.item.enabled) _body.interaction_target = noone;
    return true;
};
