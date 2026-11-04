if (object_index == obj_door_trigger) {
    if (target_link == 0) exit;
    draw_set_colour(c_yellow);
    draw_set_alpha(activations > 0 ? plate_alpha * 0.5 : plate_alpha);
    draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, false);
    draw_set_alpha(1);
    draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
    draw_set_colour(c_white);
    exit;
}
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
