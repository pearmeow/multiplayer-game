if (instance_number(obj_team) > 1) { instance_destroy(); exit; }
energy_max = 100;
energy = energy_max;
energy_regen_per_second = 1;
shot_cost = 5;
regen_elapsed = 0;
feedback = "";
feedback_time = 0;
try_spend = function(_cost) {
    if (_cost < 0 || energy < _cost) return false;
    energy = clamp(energy - _cost, 0, energy_max);
    return true;
};
notify = function(_message) {
    feedback = _message;
    feedback_time = 1.5;
};

advance_energy = function(_seconds) {
    var _dt = max(0, _seconds);
    energy = clamp(energy, 0, energy_max);
if (energy < energy_max) {
    regen_elapsed += _dt;
    var _ticks = floor(regen_elapsed);
    if (_ticks > 0) {
        energy = min(energy_max, energy + _ticks * energy_regen_per_second);
        regen_elapsed -= _ticks;
    }
}

if (energy >= energy_max) regen_elapsed = 0;

};

changing_room = false;
camera_id = -1;
camera_smoothing = 0.1;
camera_width = 960;
camera_height = 540;
saved_aim_angle = 90;
saved_cone_width = 60;
window_set_size(960, 540);
display_set_gui_size(960, 540);

change_room = function(_target) {
    if (changing_room) {
        return false;
    }
    if (_target == room) {
        return false;
    }

    var _valid_room = false;
    if (_target == rm_01) {
        _valid_room = true;
    }
    if (_target == rm_02) {
        _valid_room = true;
    }
    if (_target == rm_03) {
        _valid_room = true;
    }
    if (!_valid_room) {
        return false;
    }

    var _body = instance_find(obj_player, 0);
    if (instance_exists(_body)) {
        if (instance_exists(_body.aim_controller)) {
            saved_aim_angle = _body.aim_controller.aim_angle;
            saved_cone_width = _body.aim_controller.cone_width;
        }
    }

    changing_room = true;
    room_goto(_target);
    return true;
};

update_camera = function(_snap) {
    if (camera_id == -1) {
        return;
    }
    var _body = instance_find(obj_player, 0);
    if (!instance_exists(_body)) {
        return;
    }

    var _view_width = camera_get_view_width(camera_id);
    var _view_height = camera_get_view_height(camera_id);
    var _limit_x = max(0, room_width - _view_width);
    var _limit_y = max(0, room_height - _view_height);
    var _target_x = clamp(_body.x - _view_width / 2, 0, _limit_x);
    var _target_y = clamp(_body.y - _view_height / 2, 0, _limit_y);

    var _new_x = _target_x;
    var _new_y = _target_y;
    if (!_snap) {
        var _old_x = camera_get_view_x(camera_id);
        var _old_y = camera_get_view_y(camera_id);
        _new_x = lerp(_old_x, _target_x, camera_smoothing);
        _new_y = lerp(_old_y, _target_y, camera_smoothing);
    }

    _new_x = clamp(_new_x, 0, _limit_x);
    _new_y = clamp(_new_y, 0, _limit_y);
    camera_set_view_pos(camera_id, _new_x, _new_y);
};
