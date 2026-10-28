draw_set_alpha(1);
draw_set_colour(c_orange);
draw_rectangle(x - 15, y - 15, x + 15, y + 15, !active);
if (active) {
    draw_set_colour(c_red);
    for (var _i = -1; _i <= 1; _i++) {
        var _x = x + _i * 10;
        draw_triangle(_x - 5, y + 10, _x, y - 11, _x + 5, y + 10, false);
    }
}
draw_set_colour(c_white);
