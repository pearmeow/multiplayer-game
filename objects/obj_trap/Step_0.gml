if (active) {
    active_timer -= delta_time / 1000000;
    if (active_timer <= 0) active = false;
    var _enemy = collision_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, par_enemy, false, true);
    if (_enemy != noone) instance_destroy(_enemy);
}
