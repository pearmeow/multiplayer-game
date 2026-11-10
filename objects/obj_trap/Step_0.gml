if (active) {
    active_timer -= coop_step_seconds();
    if (active_timer <= 0) active = false;
    with (par_enemy) {
        if (place_meeting(x, y, other)) defeat();
    }
}
