owner_body = noone;
aim_angle = 90;
cone_width = 60;
vision_range = 700;
turn_speed = 120;
cone_speed = 45;

ghost_gap = 6;
ghost_alpha = 0.60;

get_ghost_pose = function() {
    var _dx = lengthdir_x(1, aim_angle);
    var _dy = lengthdir_y(1, aim_angle);
    var _side_x = (_dx >= 0) ? owner_body.x - owner_body.bbox_left : owner_body.bbox_right - owner_body.x;
    var _side_y = (_dy >= 0) ? owner_body.y - owner_body.bbox_top : owner_body.bbox_bottom - owner_body.y;
    var _body_extent = abs(_dx) * _side_x + abs(_dy) * _side_y;

    var _ghost_side_x = 0;
    if (_dx >= 0) {
        _ghost_side_x = sprite_get_bbox_right(spr_ghost) - sprite_get_xoffset(spr_ghost);
    } else {
        _ghost_side_x = sprite_get_xoffset(spr_ghost) - sprite_get_bbox_left(spr_ghost);
    }

    var _ghost_side_y = 0;
    if (_dy >= 0) {
        _ghost_side_y = sprite_get_bbox_bottom(spr_ghost) - sprite_get_yoffset(spr_ghost);
    } else {
        _ghost_side_y = sprite_get_yoffset(spr_ghost) - sprite_get_bbox_top(spr_ghost);
    }
    var _ghost_front = abs(_dx) * _ghost_side_x + abs(_dy) * _ghost_side_y;
    var _distance = _body_extent + ghost_gap + _ghost_front;
    return {
        x: owner_body.x - _dx * _distance,
        y: owner_body.y - _dy * _distance,
        rotation: 0,
        body_extent: _body_extent,
        ghost_front: _ghost_front
    };
};

interaction_pressed = false;
interaction_was_down = false;
read_interaction_input = function(_right_shift_down) {
    var _pressed = false;
    if (_right_shift_down) {
        if (!interaction_was_down) {
            _pressed = true;
        }
    }
    interaction_was_down = _right_shift_down;
    return _pressed;
};

update_interaction = function(_pressed) {
    var _body = owner_body;
    if (!instance_exists(_body)) {
        return false;
    }

    _body.interaction_target = noone;
    var _closest_distance = _body.interact_range + 1;

    for (var _index = 0; _index < instance_number(par_interactable); _index++) {
        var _item = instance_find(par_interactable, _index);
        if (!instance_exists(_item)) {
            continue;
        }
        if (!_item.enabled) {
            continue;
        }

        var _distance = point_distance(_body.x, _body.y, _item.x, _item.y);
        if (_distance > _body.interact_range) {
            continue;
        }
        if (_distance >= _closest_distance) {
            continue;
        }
        if (!coop_visible(_body, _item.x, _item.y)) {
            continue;
        }

        _body.interaction_target = _item;
        _closest_distance = _distance;
    }

    if (!_pressed) {
        return false;
    }
    var _target = _body.interaction_target;
    if (!instance_exists(_target)) {
        return false;
    }

    _target.interact(_body);
    return true;
};
