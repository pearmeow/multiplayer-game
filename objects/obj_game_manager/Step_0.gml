if (failure_sprite == -1) {
    if (keyboard_check_pressed(ord("R"))) room_restart();
    exit;
}

if (!failure_frozen) {
    var _team = instance_find(obj_team, 0);
    if (instance_exists(_team)) with (_team) team_stop_room_audio();
    instance_deactivate_all(true);
    failure_frozen = true;
    exit;
}

if (failure_time < scare_hold_seconds + scare_fade_seconds) {
    failure_time += max(0, delta_time / 1000000);
    exit;
}

if (keyboard_check_pressed(vk_enter)) {
    finish_failure(true);
} else if (keyboard_check_pressed(vk_escape)) {
    finish_failure(false);
}
