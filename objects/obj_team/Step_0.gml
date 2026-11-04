var _dt = max(0, delta_time / 1000000);
advance_energy(_dt);
feedback_time = max(0, feedback_time - _dt);

if (keyboard_check_pressed(vk_f11)) window_set_fullscreen(!window_get_fullscreen());

if (keyboard_check_pressed(ord("H"))) show_help = !show_help;
