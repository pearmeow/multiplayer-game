function enemy_nav_radius(_enemy) {
    var _radius = max(0, _enemy.hit_radius);
    if (_enemy.sprite_index != -1 || _enemy.mask_index != -1) {
        var _left = abs(_enemy.bbox_left - _enemy.x);
        var _right = abs(_enemy.bbox_right - _enemy.x);
        var _top = abs(_enemy.bbox_top - _enemy.y);
        var _bottom = abs(_enemy.bbox_bottom - _enemy.y);
        _radius = max(_radius, _left);
        _radius = max(_radius, _right);
        _radius = max(_radius, _top);
        _radius = max(_radius, _bottom);
    }
    return _radius + max(0, _enemy.wall_margin);
}

function enemy_nav_position_clear(_enemy, _x, _y) {
    var _radius = enemy_nav_radius(_enemy);
    if (_x - _radius < 0) {
        return false;
    }
    if (_y - _radius < 0) {
        return false;
    }
    if (_x + _radius >= room_width) {
        return false;
    }
    if (_y + _radius >= room_height) {
        return false;
    }

    var _left = floor(_x - _radius);
    var _right = ceil(_x + _radius);
    var _top = floor(_y - _radius);
    var _bottom = ceil(_y + _radius);
    var _wall = collision_rectangle(_left, _top, _right, _bottom, obj_wall, false, true);
    if (_wall != noone) {
        return false;
    }
    return true;
}

function enemy_nav_segment_clear(_enemy, _x1, _y1, _x2, _y2) {
    var _distance = point_distance(_x1, _y1, _x2, _y2);
    var _steps = max(1, ceil(_distance));
    for (var _step = 0; _step <= _steps; _step++) {
        var _amount = _step / _steps;
        var _x = lerp(_x1, _x2, _amount);
        var _y = lerp(_y1, _y2, _amount);
        if (!enemy_nav_position_clear(_enemy, _x, _y)) {
            return false;
        }
    }
    return true;
}

function enemy_nav_plan(_enemy, _goal_x, _goal_y) {
    _enemy.nav_points = [];
    _enemy.nav_point_index = 0;
    _enemy.nav_goal_reachable = false;
    _enemy.nav_clearance = enemy_nav_radius(_enemy);

    var _cell_size = max(4, floor(_enemy.nav_cell_size));
    var _columns = ceil(room_width / _cell_size);
    var _rows = ceil(room_height / _cell_size);
    var _resize_grid = false;
    if (_enemy.nav_grid == -1) {
        _resize_grid = true;
    }
    if (_enemy.nav_columns != _columns) {
        _resize_grid = true;
    }
    if (_enemy.nav_rows != _rows) {
        _resize_grid = true;
    }
    if (_resize_grid) {
        if (_enemy.nav_grid != -1) {
            ds_grid_destroy(_enemy.nav_grid);
        }
        _enemy.nav_grid = ds_grid_create(_columns, _rows);
        _enemy.nav_columns = _columns;
        _enemy.nav_rows = _rows;
    }

    var _grid = _enemy.nav_grid;
    ds_grid_clear(_grid, -1); // -1 unvisited, 0 visited, 1 blocked
    var _radius = _enemy.nav_clearance;

    for (var _index = 0; _index < instance_number(obj_wall); _index++) {
        var _wall = instance_find(obj_wall, _index);
        var _left = max(0, floor((_wall.bbox_left - _radius) / _cell_size));
        var _right = min(_columns - 1, floor((_wall.bbox_right + _radius) / _cell_size));
        var _top = max(0, floor((_wall.bbox_top - _radius) / _cell_size));
        var _bottom = min(_rows - 1, floor((_wall.bbox_bottom + _radius) / _cell_size));
        if (_left <= _right && _top <= _bottom) {
            ds_grid_set_region(_grid, _left, _top, _right, _bottom, 1);
        }
    }

    for (var _column = 0; _column < _columns; _column++) {
        for (var _row = 0; _row < _rows; _row++) {
            var _x = (_column + 0.5) * _cell_size;
            var _y = (_row + 0.5) * _cell_size;
            if (_x - _radius < 0 || _y - _radius < 0) {
                ds_grid_set(_grid, _column, _row, 1);
            }
            if (_x + _radius >= room_width || _y + _radius >= room_height) {
                ds_grid_set(_grid, _column, _row, 1);
            }
        }
    }

    if (!enemy_nav_position_clear(_enemy, _enemy.x, _enemy.y)) {
        _enemy.nav_status = "blocked_spawn";
        return false;
    }

    var _enemy_column = clamp(floor(_enemy.x / _cell_size), 0, _columns - 1);
    var _enemy_row = clamp(floor(_enemy.y / _cell_size), 0, _rows - 1);
    var _start_column = -1;
    var _start_row = -1;
    var _closest_distance = infinity;

    for (var _offset_x = -2; _offset_x <= 2; _offset_x++) {
        for (var _offset_y = -2; _offset_y <= 2; _offset_y++) {
            var _column = _enemy_column + _offset_x;
            var _row = _enemy_row + _offset_y;
            if (_column < 0 || _column >= _columns) {
                continue;
            }
            if (_row < 0 || _row >= _rows) {
                continue;
            }
            if (ds_grid_get(_grid, _column, _row) != -1) {
                continue;
            }

            var _x = (_column + 0.5) * _cell_size;
            var _y = (_row + 0.5) * _cell_size;
            var _distance = point_distance(_enemy.x, _enemy.y, _x, _y);
            if (_distance >= _closest_distance) {
                continue;
            }
            if (!enemy_nav_segment_clear(_enemy, _enemy.x, _enemy.y, _x, _y)) {
                continue;
            }

            _closest_distance = _distance;
            _start_column = _column;
            _start_row = _row;
        }
    }

    if (_start_column == -1) {
        _enemy.nav_status = "no_safe_start";
        return false;
    }

    var _goal_column = clamp(floor(_goal_x / _cell_size), 0, _columns - 1);
    var _goal_row = clamp(floor(_goal_y / _cell_size), 0, _rows - 1);
    var _parent_column = ds_grid_create(_columns, _rows);
    var _parent_row = ds_grid_create(_columns, _rows);
    ds_grid_clear(_parent_column, -1);
    ds_grid_clear(_parent_row, -1);

    var _queue = ds_queue_create();
    ds_queue_enqueue(_queue, _start_column);
    ds_queue_enqueue(_queue, _start_row);
    ds_grid_set(_grid, _start_column, _start_row, 0);

    var _best_column = _start_column;
    var _best_row = _start_row;
    var _best_distance = infinity;

    while (!ds_queue_empty(_queue)) {
        var _column = ds_queue_dequeue(_queue);
        var _row = ds_queue_dequeue(_queue);
        var _x = (_column + 0.5) * _cell_size;
        var _y = (_row + 0.5) * _cell_size;
        var _distance = point_distance(_x, _y, _goal_x, _goal_y);
        if (_distance < _best_distance) {
            _best_distance = _distance;
            _best_column = _column;
            _best_row = _row;
        }
        if (_column == _goal_column && _row == _goal_row) {
            _best_column = _column;
            _best_row = _row;
            _enemy.nav_goal_reachable = true;
            break;
        }

        for (var _direction = 0; _direction < 4; _direction++) {
            var _next_column = _column;
            var _next_row = _row;
            if (_direction == 0) {
                _next_column++;
            } else if (_direction == 1) {
                _next_row++;
            } else if (_direction == 2) {
                _next_column--;
            } else {
                _next_row--;
            }

            if (_next_column < 0 || _next_column >= _columns) {
                continue;
            }
            if (_next_row < 0 || _next_row >= _rows) {
                continue;
            }
            if (ds_grid_get(_grid, _next_column, _next_row) != -1) {
                continue;
            }

            ds_grid_set(_grid, _next_column, _next_row, 0);
            ds_grid_set(_parent_column, _next_column, _next_row, _column);
            ds_grid_set(_parent_row, _next_column, _next_row, _row);
            ds_queue_enqueue(_queue, _next_column);
            ds_queue_enqueue(_queue, _next_row);
        }
    }
    ds_queue_destroy(_queue);

    var _reverse_points = [];
    var _column = _best_column;
    var _row = _best_row;
    while (_column != -1) {
        var _x = (_column + 0.5) * _cell_size;
        var _y = (_row + 0.5) * _cell_size;
        array_push(_reverse_points, {x: _x, y: _y});

        var _previous_column = ds_grid_get(_parent_column, _column, _row);
        var _previous_row = ds_grid_get(_parent_row, _column, _row);
        _column = _previous_column;
        _row = _previous_row;
    }
    ds_grid_destroy(_parent_column);
    ds_grid_destroy(_parent_row);

    var _points = [];
    for (var _index = array_length(_reverse_points) - 1; _index >= 0; _index--) {
        array_push(_points, _reverse_points[_index]);
    }
    var _last_point = _points[array_length(_points) - 1];
    if (enemy_nav_segment_clear(_enemy, _last_point.x, _last_point.y, _goal_x, _goal_y)) {
        array_push(_points, {x: _goal_x, y: _goal_y});
        _enemy.nav_goal_reachable = true;
    }

    _enemy.nav_points = _points;
    if (_enemy.nav_goal_reachable) {
        _enemy.nav_status = "following";
    } else {
        _enemy.nav_status = "nearest_reachable";
    }
    return _enemy.nav_goal_reachable;
}

function enemy_nav_follow(_enemy, _distance_left) {
    if (_enemy.state == 1) {
        if (enemy_nav_touching_player(_enemy)) {
            _enemy.nav_status = "touching_player";
            _enemy.nav_repath_timer = 0;
            _enemy.nav_points = [];
            return;
        }
    }

    while (_distance_left > 0 && _enemy.nav_point_index < array_length(_enemy.nav_points)) {
        var _point = _enemy.nav_points[_enemy.nav_point_index];
        var _distance = point_distance(_enemy.x, _enemy.y, _point.x, _point.y);
        if (_distance < 0.001) {
            _enemy.nav_point_index++;
            continue;
        }

        var _step = min(1, _distance_left, _distance);
        var _direction_x = (_point.x - _enemy.x) / _distance;
        var _direction_y = (_point.y - _enemy.y) / _distance;
        var _next_x = _enemy.x + _direction_x * _step;
        var _next_y = _enemy.y + _direction_y * _step;
        if (!enemy_nav_position_clear(_enemy, _next_x, _next_y)) {
            _enemy.nav_status = "blocked_replan";
            _enemy.nav_repath_timer = 0;
            _enemy.nav_points = [];
            return;
        }

        _enemy.x = _next_x;
        _enemy.y = _next_y;
        _distance_left -= _step;

        if (_enemy.state == 1) {
            if (enemy_nav_touching_player(_enemy)) {
                _enemy.nav_status = "touching_player";
                _enemy.nav_repath_timer = 0;
                _enemy.nav_points = [];
                return;
            }
        }
    }
}

function enemy_nav_touching_player(_enemy) {
    var _left = _enemy.x - _enemy.hit_radius;
    var _right = _enemy.x + _enemy.hit_radius;
    var _top = _enemy.y - _enemy.hit_radius;
    var _bottom = _enemy.y + _enemy.hit_radius;

    if (_enemy.sprite_index != -1 || _enemy.mask_index != -1) {
        _left = _enemy.bbox_left;
        _right = _enemy.bbox_right;
        _top = _enemy.bbox_top;
        _bottom = _enemy.bbox_bottom;
    }

    var _player = collision_rectangle(_left, _top, _right, _bottom, obj_player, false, true);
    if (_player != noone) {
        return true;
    }
    return false;
}
