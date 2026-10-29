owner_body = noone;
aim_angle = 90;
// The drawn ghost is separate; use a one-pixel mask to sample walls and enemies.
mask_index = spr_wall;
image_xscale = 1 / sprite_get_width(spr_wall);
image_yscale = 1 / sprite_get_height(spr_wall);

get_ghost_pose = function() {
    var _dx = lengthdir_x(1, aim_angle);
    var _dy = lengthdir_y(1, aim_angle);
    var _body_space = abs(_dx) * sprite_get_width(owner_body.sprite_index) / 2 + abs(_dy) * sprite_get_height(owner_body.sprite_index) / 2;
    var _ghost_space = abs(_dx) * sprite_get_width(spr_ghost) / 2 + abs(_dy) * sprite_get_height(spr_ghost) / 2;
    var _distance = _body_space + ghost_gap + _ghost_space;
    return {x: owner_body.x - _dx * _distance, y: owner_body.y - _dy * _distance,
        rotation: 0, body_extent: _body_space, ghost_front: _ghost_space};
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
    var _best = _body.interact_range + 1;
    var _target_point = undefined;
    var _groups = [par_interactable, obj_door];
    for (var _group = 0; _group < array_length(_groups); _group++) {
        var _object = _groups[_group];
        for (var _i = 0; _i < instance_number(_object); _i++) {
            var _item = instance_find(_object, _i);
            if (!_item.enabled) continue;
            var _point = {x: _item.x, y: _item.y};
            if (_object == obj_door) {
                if (!_item.can_interact()) continue;
                _point = _item.get_interaction_point(_body);
            }
            var _distance = point_distance(_body.x, _body.y, _point.x, _point.y);
            if (_distance > _body.interact_range || _distance >= _best) continue;
            if (!coop_visible(_body, _point.x, _point.y, _item)) continue;
            _body.interaction_target = _item;
            _best = _distance;
            _target_point = _point;
        }
    }
    if (!_pressed || !instance_exists(_body.interaction_target)) return false;
    if (!_body.team.try_spend(_body.team.action_energy_cost)) {
        _body.team.notify("Not enough energy to interact");
        return false;
    }
    _body.interaction_target.interact(_body);
    _body.show_action_effect(_target_point.x, _target_point.y, _body.interact_effect_colour);
    return true;
};
