var horizontal_movement = keyboard_check(ord("D")) - keyboard_check(ord("A"))
var vertical_movement = keyboard_check(ord("S")) - keyboard_check(ord("W"))
var cone_movement = keyboard_check(vk_right) - keyboard_check(vk_left)

cone_start_degree += cone_movement * 1
cone_end_degree += cone_movement * 1
show_debug_message(cone_start_degree)

x += horizontal_movement * spd
y += vertical_movement * spd