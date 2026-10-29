if (active) {
    active_timer -= delta_time / 1000000;
    if (active_timer <= 0) active = false;
    with (par_enemy) {
        if (place_meeting(x, y, other)) instance_destroy();
    }
}
