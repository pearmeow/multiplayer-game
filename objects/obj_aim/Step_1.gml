if (!instance_exists(owner_body)) { instance_destroy(); exit; }
var _dt = min(0.05, max(0, delta_time / 1000000));
var _turn = keyboard_check(vk_left) - keyboard_check(vk_right);
aim_angle = (aim_angle + _turn * turn_speed * _dt + 360) mod 360;
x = owner_body.x;
y = owner_body.y;

interaction_pressed = read_interaction_input(keyboard_check(interaction_key));
