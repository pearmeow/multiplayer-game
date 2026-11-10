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
    enemy_proximity = 0;
    audio_master_gain(1);
    if (_track != -1) bgm_voice = audio_play_sound(_track, 0, true, bgm_gain);
    if (heartbeat_sound != -1) heartbeat_voice = audio_play_sound(heartbeat_sound, 1, true, heartbeat_idle_gain);
}

function team_update_room_audio(_seconds) {
    var _body = instance_find(obj_player, 0);
    if (!instance_exists(_body)) return;

    var _target = 0;
    var _enemy = instance_nearest(_body.x, _body.y, par_enemy);
    if (instance_exists(_enemy)) {
        _target = coop_proximity(point_distance(_body.x, _body.y, _enemy.x, _enemy.y), heartbeat_range);
    }
    var _rate = _target > enemy_proximity ? heartbeat_attack : heartbeat_release;
    enemy_proximity = lerp(enemy_proximity, _target, 1 - exp(-max(0, _rate) * _seconds));

    audio_master_gain(lerp(san_audio_min_gain, 1, _body.get_sanity_fraction()));
    if (bgm_voice != -1) audio_sound_gain(bgm_voice, bgm_gain * lerp(1, bgm_near_multiplier, enemy_proximity), 0);
    if (heartbeat_voice != -1) audio_sound_gain(heartbeat_voice, lerp(heartbeat_idle_gain, heartbeat_peak_gain, enemy_proximity), 0);
}
