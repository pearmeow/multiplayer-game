if (!ending_active) {
    if (keyboard_check_pressed(ord("R"))) room_restart();
    exit;
}

if (!ending_frozen) {
    var _team = instance_find(obj_team, 0);
    if (instance_exists(_team)) with (_team) team_stop_room_audio();
    instance_deactivate_all(true);
    ending_frozen = true;
    exit;
}

if (!victory && failure_time < scare_hold_seconds + scare_fade_seconds) {
    failure_time += max(0, delta_time / 1000000);
    exit;
}

if (keyboard_check_pressed(vk_enter)) {
    finish_ending(true);
} else if (keyboard_check_pressed(vk_escape)) {
    finish_ending(false);
}
