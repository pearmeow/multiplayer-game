function enemy_nav_radius(_enemy) {
    var _radius = _enemy.hit_radius;
    if (_enemy.sprite_index != -1) {
        _radius = max(_radius, abs(_enemy.bbox_left - _enemy.x), abs(_enemy.bbox_right - _enemy.x));
        _radius = max(_radius, abs(_enemy.bbox_top - _enemy.y), abs(_enemy.bbox_bottom - _enemy.y));
    }
    return _radius + _enemy.wall_margin;
}

function enemy_nav_position_clear(_enemy, _x, _y) {
    var _radius = enemy_nav_radius(_enemy);
    if (_x < _radius || _y < _radius || _x >= room_width - _radius || _y >= room_height - _radius) return false;
    var _clear = false;
    with (_enemy) _clear = !place_meeting(_x, _y, obj_wall);
    return _clear;
}

function enemy_nav_plan(_enemy, _goal_x, _goal_y) {
    var _cell = _enemy.nav_cell_size;
    if (_enemy.nav_grid == -1) {
        _enemy.nav_grid = mp_grid_create(0, 0, ceil(room_width / _cell), ceil(room_height / _cell), _cell, _cell);
    }
    mp_grid_clear_all(_enemy.nav_grid);
    var _radius = enemy_nav_radius(_enemy);
    for (var _i = 0; _i < instance_number(obj_wall); _i++) {
        var _wall = instance_find(obj_wall, _i);
        if (_wall.sprite_index == -1) continue;
        mp_grid_add_rectangle(_enemy.nav_grid, _wall.bbox_left - _radius, _wall.bbox_top - _radius, _wall.bbox_right + _radius, _wall.bbox_bottom + _radius);
    }
    _enemy.nav_point_index = 0;
    path_clear_points(_enemy.nav_path);
    return mp_grid_path(_enemy.nav_grid, _enemy.nav_path, _enemy.x, _enemy.y, _goal_x, _goal_y, false);
}

function enemy_nav_touching_player(_enemy) {
    var _touching = false;
    with (_enemy) _touching = place_meeting(x, y, obj_player);
    return _touching;
}

function enemy_nav_follow(_enemy, _distance_left) {
    while (_distance_left > 0 && _enemy.nav_point_index < path_get_number(_enemy.nav_path)) {
        if (_enemy.state == 1 && enemy_nav_touching_player(_enemy)) {
            _enemy.nav_repath_timer = 0;
            return;
        }
        var _x = path_get_point_x(_enemy.nav_path, _enemy.nav_point_index);
        var _y = path_get_point_y(_enemy.nav_path, _enemy.nav_point_index);
        var _distance = point_distance(_enemy.x, _enemy.y, _x, _y);
        if (_distance < 0.01) {
            _enemy.nav_point_index++;
            continue;
        }
        var _step = min(1, _distance_left, _distance);
        _x = _enemy.x + (_x - _enemy.x) / _distance * _step;
        _y = _enemy.y + (_y - _enemy.y) / _distance * _step;
        if (!enemy_nav_position_clear(_enemy, _x, _y)) {
            _enemy.nav_repath_timer = 0;
            return;
        }
        _enemy.x = _x;
        _enemy.y = _y;
        _distance_left -= _step;
    }
}
