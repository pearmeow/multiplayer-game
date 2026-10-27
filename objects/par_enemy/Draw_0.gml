var _body = instance_find(obj_player, 0);
if (!coop_visible(_body, x, y)) exit;
// Placeholder only; child enemies can replace this with their own sprite.
draw_set_alpha(1);
draw_set_colour(c_red);
draw_circle(x, y, hit_radius, false);
draw_set_colour(c_white);
