var _body = instance_place(x, y, obj_player);
if (instance_exists(_body) && _body.hp > 0) {
    _body.play_hit_sound();
    _body.fail_run(false);
}

var _multiplier = 1;
var _ghost = instance_find(obj_aim, 0);
if (instance_exists(_ghost) && _ghost.slow_active
    && point_distance(x, y, _ghost.x, _ghost.y) <= _ghost.slow_range) {
    _multiplier = _ghost.slow_rate;
}

// Move in the direction of the spike's image angle.
x += spd * _multiplier * dcos(image_angle + 90);
y -= spd * _multiplier * dsin(image_angle + 90);
