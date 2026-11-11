if (keyboard_check(ord("1"))) {
	room_goto(rm_01)
}
if (keyboard_check(ord("2"))) {
	room_goto(rm_02)
}
if (keyboard_check(ord("3"))) {
	room_goto(rm_03)
}
if (keyboard_check(ord("4"))) {
	room_goto(rm_04)
}

if (!ending_active) {
    if (keyboard_check_pressed(ord("R"))) room_restart();
    exit;
}

if (!ending_frozen) {
    audio_stop_all();
    audio_master_gain(1);
    var _sound = victory ? victory_sound : failure_sound;
    if (_sound != -1) audio_play_sound(_sound, 3, false, ending_sound_gain);
    instance_deactivate_all(true);
    ending_frozen = true;
    exit;
}

if (!victory && failure_time < scare_hold_seconds + scare_fade_seconds) {
    failure_time += coop_step_seconds();
    exit;
}

if (keyboard_check_pressed(vk_enter)) {
    finish_ending(true);
} else if (keyboard_check_pressed(vk_escape)) {
    finish_ending(false);
}
