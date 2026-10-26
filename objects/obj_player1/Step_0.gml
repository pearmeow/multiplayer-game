var horizontal_movement = keyboard_check(vk_right) - keyboard_check(vk_left)
var vertical_movement = keyboard_check(vk_down) - keyboard_check(vk_up)
x += horizontal_movement * spd
y += vertical_movement * spd