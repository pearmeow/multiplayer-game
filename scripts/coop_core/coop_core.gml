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

function coop_visible(_body, _target_x, _target_y) {
    if (!instance_exists(_body)) return false;
    var _aim = _body.aim_controller;
    if (!instance_exists(_aim)) return false;
    if (point_distance(_body.x, _body.y, _target_x, _target_y) > _aim.vision_range) return false;
    if (abs(angle_difference(_aim.aim_angle, point_direction(_body.x, _body.y, _target_x, _target_y))) > _aim.cone_width * 0.5) return false;
    return collision_line(_body.x, _body.y, _target_x, _target_y, obj_wall, false, true) == noone;
}

function coop_enemy_visible(_enemy) {
    if (!instance_exists(_enemy)) return false;
    var _body = instance_find(obj_player, 0);
    var _x = _enemy.x;
    var _y = _enemy.y;
    if (_enemy.sprite_index != -1) {
        _x = (_enemy.bbox_left + _enemy.bbox_right) * 0.5;
        _y = (_enemy.bbox_top + _enemy.bbox_bottom) * 0.5;
    }
    return coop_visible(_body, _x, _y);
}
