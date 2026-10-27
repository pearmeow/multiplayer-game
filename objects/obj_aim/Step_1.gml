// Begin Step runs before the body's firing Step, avoiding a one-frame aim delay.
if (!instance_exists(owner_body)) { instance_destroy(); exit; }
var _dt = min(0.05, max(0, delta_time / 1000000));
var _turn = keyboard_check(vk_left) - keyboard_check(vk_right);
aim_angle = (aim_angle + _turn * turn_speed * _dt + 360) mod 360;
var _width_input = keyboard_check(vk_down) - keyboard_check(vk_up);
cone_width = clamp(cone_width + _width_input * cone_speed * _dt, 30, 100);
x = owner_body.x;
y = owner_body.y;
