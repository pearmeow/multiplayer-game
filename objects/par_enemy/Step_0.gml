var _old_x = x;
var _old_y = y;
ai_update(coop_step_seconds());

if (state == 1) {
    if (!alert_sounded && alert_sound != -1) audio_play_sound(alert_sound, 2, false, alert_gain);
    alert_sounded = true;
} else {
    alert_sounded = false;
}

var _body = instance_find(obj_player, 0);
if (instance_exists(_body)) {
    var _near = coop_proximity(point_distance(x, y, _body.x, _body.y), footstep_hearing_range);
    coop_update_footsteps(point_distance(_old_x, _old_y, x, y), _near);
}
