draw_set_alpha(1);
draw_set_colour(c_aqua);
if (trigger_kind == 1) draw_set_colour(c_orange);
draw_circle(x, y, 13, false);
draw_set_colour(c_black);
if (trigger_kind == 0) {
    draw_line_width(x - 6, y, x + 6, y, 3);
} else {
    draw_rectangle(x - 7, y - 5, x + 7, y - 1, false);
    draw_rectangle(x - 7, y + 3, x + 7, y + 6, false);
}
draw_set_colour(c_white);
