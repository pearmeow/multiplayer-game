event_inherited();

ai_update = function(_seconds) {
    if (!ai_enabled) return;
    var _hunter = instance_nearest(x, y, obj_player);
    if (_hunter == noone) {
        state = 0;
        return;
    }

    var _distance = point_distance(x, y, _hunter.x, _hunter.y);
    if (state == 0 && _distance <= notice_distance) state = 1;
    if (state != 1) return;

    if (_hunter.x != x) image_xscale = -sign(_hunter.x - x) * abs(image_xscale);
    if (place_meeting(x, y, _hunter)) return;

    var _speed = _hunter.get_move_speed() * hunter_speed_multiplier;
    var _step = min(_distance, _speed * get_slow_multiplier() * coop_motion_seconds(_seconds));
    var _direction = point_direction(x, y, _hunter.x, _hunter.y);
    x += lengthdir_x(_step, _direction);
    y += lengthdir_y(_step, _direction);
};
