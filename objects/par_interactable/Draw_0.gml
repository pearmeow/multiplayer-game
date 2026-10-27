var _body = instance_find(obj_player, 0);
if (!enabled || !coop_visible(_body, x, y)) exit;
draw_set_alpha(1);
draw_set_colour(c_lime);
draw_rectangle(x - 8, y - 8, x + 8, y + 8, true);
draw_set_colour(c_white);
