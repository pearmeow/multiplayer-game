if (!instance_exists(owner_body)) { instance_destroy(); exit; }
var _dt = min(0.05, max(0, delta_time / 1000000));
var _mx = keyboard_check(vk_right) - keyboard_check(vk_left);
var _my = keyboard_check(vk_down) - keyboard_check(vk_up);
var _length = point_distance(0, 0, _mx, _my);
if (_length > 0) {
    x += _mx / _length * ghost_move_speed * _dt;
    y += _my / _length * ghost_move_speed * _dt;
}
clamp_ghost_position();
interaction_pressed = read_interaction_input(keyboard_check(interaction_key));
