draw_set_alpha(1);
draw_set_colour(c_white);
draw_self();
if (shot_time > 0) {
    draw_set_colour(action_effect_colour);
    draw_line_width(x, y, shot_x, shot_y, action_effect_width);
}
draw_set_colour(c_white);
