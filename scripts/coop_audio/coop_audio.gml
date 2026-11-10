function coop_audio_proximity(_distance, _range) {
    return clamp(1 - _distance / max(1, _range), 0, 1);
}

function coop_update_footsteps(_distance, _proximity) {
    var _count = array_length(footstep_sounds);
    if (_distance <= 0 || footstep_spacing <= 0 || _count == 0) return;
    footstep_distance += _distance;
    if (footstep_distance < footstep_spacing) return;
    footstep_distance = footstep_distance mod footstep_spacing;
    if (_proximity <= 0) return;
    audio_play_sound(footstep_sounds[footstep_index], 1, false, footstep_gain * _proximity);
    footstep_index = (footstep_index + 1) mod _count;
}

function team_stop_room_audio() {
    if (bgm_voice != -1) audio_stop_sound(bgm_voice);
    if (heartbeat_voice != -1) audio_stop_sound(heartbeat_voice);
    bgm_voice = -1;
    heartbeat_voice = -1;
}

function team_start_room_audio(_track) {
    team_stop_room_audio();
    heartbeat_gain = heartbeat_idle_gain;
    if (_track != -1) bgm_voice = audio_play_sound(_track, 0, true, bgm_gain);
    if (heartbeat_sound != -1) heartbeat_voice = audio_play_sound(heartbeat_sound, 1, true, heartbeat_gain);
}

function team_update_heartbeat(_seconds) {
    if (heartbeat_voice == -1) return;
    var _target = heartbeat_idle_gain;
    var _body = instance_find(obj_player, 0);
    if (instance_exists(_body)) {
        var _enemy = instance_nearest(_body.x, _body.y, par_enemy);
        if (instance_exists(_enemy)) {
            var _near = coop_audio_proximity(point_distance(_body.x, _body.y, _enemy.x, _enemy.y), heartbeat_range);
            _target = lerp(heartbeat_idle_gain, heartbeat_peak_gain, _near);
        }
    }
    var _rate = _target > heartbeat_gain ? heartbeat_attack : heartbeat_release;
    heartbeat_gain = lerp(heartbeat_gain, _target, 1 - exp(-max(0, _rate) * max(0, _seconds)));
    audio_sound_gain(heartbeat_voice, heartbeat_gain, 0);
}
