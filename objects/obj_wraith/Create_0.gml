event_inherited();

ai_update = function(_seconds) {
    if (!ai_enabled) return;
    var _hunter = instance_nearest(x, y, obj_player);
    if (!update_pursuit(_hunter)) return;

    var _distance = point_distance(x, y, _hunter.x, _hunter.y);

    if (_hunter.x != x) image_xscale = -sign(_hunter.x - x) * abs(image_xscale);
    if (place_meeting(x, y, _hunter)) return;

    var _step = min(_distance, get_chase_speed(_hunter) * coop_motion_seconds(_seconds));
    var _direction = point_direction(x, y, _hunter.x, _hunter.y);
    x += lengthdir_x(_step, _direction);
    y += lengthdir_y(_step, _direction);
};
