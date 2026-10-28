draw_set_alpha(1);
draw_set_colour(c_white);
if (is_open) {
    draw_sprite_ext(open_sprite, image_index, x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
} else {
    draw_self();
}
