draw_set_alpha(1);
draw_set_colour(c_white);
if (sprite_index != -1) {
    draw_self();
} else {
    draw_set_colour(c_red);
    draw_circle(x, y, hit_radius, false);
}
draw_set_colour(c_white);
