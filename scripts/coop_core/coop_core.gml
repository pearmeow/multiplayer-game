#macro COOP_MAX_MOTION_SECONDS 0.05

function coop_step_seconds() {
    return max(0, delta_time / 1000000);
}

function coop_motion_seconds(_seconds) {
    return clamp(_seconds, 0, COOP_MAX_MOTION_SECONDS);
}

function coop_proximity(_distance, _range) {
    return clamp(1 - _distance / max(1, _range), 0, 1);
}

function coop_wall_distance(_probe, _x, _y, _angle, _range, _ignore = noone) {
    var _dx = lengthdir_x(1, _angle);
    var _dy = lengthdir_y(1, _angle);
    var _distance = -1;
    with (_probe) {
        for (var _step = 0; _step <= ceil(_range); _step++) {
            var _at = min(_step, _range);
            var _sample_x = _x + _dx * _at;
            var _sample_y = _y + _dy * _at;
            if (!place_meeting(_sample_x, _sample_y, obj_wall)) continue;
            // Doors inherit obj_wall, so only the selected door may be ignored.
            if (_ignore != noone && place_meeting(_sample_x, _sample_y, _ignore)) {
                var _other_wall = false;
                for (var _i = 0; _i < instance_number(obj_wall); _i++) {
                    var _wall = instance_find(obj_wall, _i);
                    if (_wall != _ignore && place_meeting(_sample_x, _sample_y, _wall)) {
                        _other_wall = true;
                        break;
                    }
                }
                if (!_other_wall) continue;
            }
            _distance = _at;
            break;
        }
    }
    return _distance;
}

function coop_shot_hit(_probe, _x, _y, _angle, _range) {
    var _dx = lengthdir_x(1, _angle);
    var _dy = lengthdir_y(1, _angle);
    var _hit = {distance: _range, enemy: noone, wall: false};
    with (_probe) {
        for (var _step = 0; _step <= ceil(_range); _step++) {
            var _at = min(_step, _range);
            var _sample_x = _x + _dx * _at;
            var _sample_y = _y + _dy * _at;
            if (place_meeting(_sample_x, _sample_y, obj_wall)) {
                _hit.distance = _at;
                _hit.wall = true;
                break;
            }
            if (!place_meeting(_sample_x, _sample_y, par_enemy)) continue;
            for (var _i = 0; _i < instance_number(par_enemy); _i++) {
                var _enemy = instance_find(par_enemy, _i);
                if (_enemy.targetable && place_meeting(_sample_x, _sample_y, _enemy)) {
                    _hit.distance = _at;
                    _hit.enemy = _enemy;
                    break;
                }
            }
            if (_hit.enemy != noone) break;
        }
    }
    return _hit;
}

function coop_hunter_sees(_body, _target) {
    var _aim = _body.aim_controller;
    if (!instance_exists(_aim)) return false;
    var _distance = point_distance(_body.x, _body.y, _target.x, _target.y);
    if (_distance > _aim.get_hunter_vision_range()) return false;
    var _angle = point_direction(_body.x, _body.y, _target.x, _target.y);
    return abs(angle_difference(_aim.aim_angle, _angle)) <= _aim.cone_width / 2
        && coop_wall_distance(_aim, _body.x, _body.y, _angle, _distance, _target) == -1;
}

function coop_light_wall_at(_probe, _x, _y) {
    var _blocked = false;
    with (_probe) {
        if (place_meeting(_x, _y, obj_wall)) {
            if (!place_meeting(_x, _y, obj_door)) {
                _blocked = true;
            } else {
                // A door can overlap a wall, which should still block light.
                for (var _i = 0; _i < instance_number(obj_wall); _i++) {
                    var _wall = instance_find(obj_wall, _i);
                    if (_wall.object_index == obj_door || object_is_ancestor(_wall.object_index, obj_door)) continue;
                    if (place_meeting(_x, _y, _wall)) {
                        _blocked = true;
                        break;
                    }
                }
            }
        }
    }
    return _blocked;
}

function coop_wall_view_distance(_probe, _x, _y, _angle, _range, _depth) {
    var _dx = lengthdir_x(1, _angle);
    var _dy = lengthdir_y(1, _angle);
    var _distance = -1;
    for (var _step = 0; _step <= ceil(_range); _step++) {
        var _at = min(_step, _range);
        if (coop_light_wall_at(_probe, _x + _dx * _at, _y + _dy * _at)) {
            _distance = _at;
            break;
        }
    }
    if (_distance == -1) return _range;
    var _visible = _distance;
    for (var _step = _distance + 1; _step <= min(_range, _distance + _depth); _step++) {
        if (!coop_light_wall_at(_probe, _x + _dx * _step, _y + _dy * _step)) break;
        _visible = _step;
    }
    return _visible;
}


function coop_game_manager() {
    var _manager = instance_find(obj_game_manager, 0);
    if (_manager == noone) _manager = instance_create_depth(0, 0, 0, obj_game_manager);
    return _manager;
}
