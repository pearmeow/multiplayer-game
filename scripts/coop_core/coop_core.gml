function coop_wall_distance(_x, _y, _angle, _range) {
    var _dx = lengthdir_x(1, _angle);
    var _dy = lengthdir_y(1, _angle);
    if (collision_line(_x, _y, _x + _dx * _range, _y + _dy * _range, obj_wall, false, true) == noone) return _range;
    var _low = 0;
    var _high = _range;
    repeat (14) {
        var _mid = (_low + _high) * 0.5;
        if (collision_line(_x, _y, _x + _dx * _mid, _y + _dy * _mid, obj_wall, false, true) != noone) _high = _mid;
        else _low = _mid;
    }
    return _low;
}

function coop_ray_circle(_x, _y, _dx, _dy, _cx, _cy, _radius) {
    var _ox = _cx - _x;
    var _oy = _cy - _y;
    var _projection = _ox * _dx + _oy * _dy;
    var _distance_sq = _ox * _ox + _oy * _oy;
    if (_distance_sq <= _radius * _radius) return 0;
    if (_projection < 0) return -1;
    var _perp_sq = max(0, _distance_sq - _projection * _projection);
    if (_perp_sq > _radius * _radius) return -1;
    return max(0, _projection - sqrt(_radius * _radius - _perp_sq));
}

function coop_visible(_body, _target_x, _target_y, _target = noone) {
    if (!instance_exists(_body)) return false;
    var _aim = _body.aim_controller;
    if (!instance_exists(_aim)) return false;
    if (point_distance(_body.x, _body.y, _target_x, _target_y) > _aim.vision_range) return false;
    if (abs(angle_difference(_aim.aim_angle, point_direction(_body.x, _body.y, _target_x, _target_y))) > _aim.cone_width * 0.5) return false;
    var _walls = ds_list_create();
    collision_line_list(_body.x, _body.y, _target_x, _target_y, obj_wall, false, true, _walls, false);
    var _clear = true;
    for (var _i = 0; _i < ds_list_size(_walls); _i++) {
        if (_walls[| _i] != _target) _clear = false;
    }
    ds_list_destroy(_walls);
    return _clear;
}

function coop_wall_view_distance(_x, _y, _angle, _range, _depth) {
    var _nearest = _range;
    var _visible = _range;
    for (var _i = 0; _i < instance_number(obj_wall); _i++) {
        var _wall = instance_find(obj_wall, _i);
        if (_wall.sprite_index == -1) continue;
        var _sprite = _wall.sprite_index;
        if (_wall.mask_index != -1) _sprite = _wall.mask_index;
        var _cos = dcos(_wall.image_angle);
        var _sin = dsin(_wall.image_angle);
        var _origin_x = (_x - _wall.x) * _cos - (_y - _wall.y) * _sin;
        var _origin_y = (_x - _wall.x) * _sin + (_y - _wall.y) * _cos;
        var _dx = lengthdir_x(1, _angle - _wall.image_angle);
        var _dy = lengthdir_y(1, _angle - _wall.image_angle);
        var _x1 = (sprite_get_bbox_left(_sprite) - sprite_get_xoffset(_sprite)) * _wall.image_xscale;
        var _x2 = (sprite_get_bbox_right(_sprite) + 1 - sprite_get_xoffset(_sprite)) * _wall.image_xscale;
        var _y1 = (sprite_get_bbox_top(_sprite) - sprite_get_yoffset(_sprite)) * _wall.image_yscale;
        var _y2 = (sprite_get_bbox_bottom(_sprite) + 1 - sprite_get_yoffset(_sprite)) * _wall.image_yscale;
        var _left = min(_x1, _x2);
        var _right = max(_x1, _x2);
        var _top = min(_y1, _y2);
        var _bottom = max(_y1, _y2);
        var _near_x = -infinity;
        var _far_x = infinity;
        var _near_y = -infinity;
        var _far_y = infinity;
        if (_dx == 0) {
            if (_origin_x < _left || _origin_x > _right) continue;
        } else {
            var _a = (_left - _origin_x) / _dx;
            var _b = (_right - _origin_x) / _dx;
            _near_x = min(_a, _b);
            _far_x = max(_a, _b);
        }
        if (_dy == 0) {
            if (_origin_y < _top || _origin_y > _bottom) continue;
        } else {
            var _a = (_top - _origin_y) / _dy;
            var _b = (_bottom - _origin_y) / _dy;
            _near_y = min(_a, _b);
            _far_y = max(_a, _b);
        }
        var _entry = max(0, _near_x, _near_y);
        var _exit = min(_far_x, _far_y, _range);
        if (_entry > _exit || _entry >= _nearest) continue;
        var _normal = abs(_dy);
        if (_near_x >= _near_y) _normal = abs(_dx);
        if (_normal == 0) continue;
        _nearest = _entry;
        _visible = min(_entry + _depth / _normal, _exit);
    }
    return _visible;
}
