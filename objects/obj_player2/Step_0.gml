var horizontal_movement = keyboard_check(ord("D")) - keyboard_check(ord("A"))
var vertical_movement = keyboard_check(ord("S")) - keyboard_check(ord("W"))
x += horizontal_movement * spd
y += vertical_movement * spd