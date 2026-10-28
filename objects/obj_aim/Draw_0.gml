if (!instance_exists(owner_body)) exit;

var _x = owner_body.x;
var _y = owner_body.y;
var _segments = 40;
var _start = aim_angle - cone_width * 0.5;
draw_set_colour(c_aqua);
draw_set_alpha(0.12);
draw_primitive_begin(pr_trianglefan);
draw_vertex(_x, _y);
for (var _i = 0; _i <= _segments; ++_i) {
    var _angle = _start + cone_width * _i / _segments;
    var _range = coop_wall_distance(_x, _y, _angle, vision_range);
    draw_vertex(_x + lengthdir_x(_range, _angle), _y + lengthdir_y(_range, _angle));
}
draw_primitive_end();
draw_set_alpha(0.75);
var _aim_range = coop_wall_distance(_x, _y, aim_angle, vision_range);
draw_line(_x, _y, _x + lengthdir_x(_aim_range, aim_angle), _y + lengthdir_y(_aim_range, aim_angle));
var _cx = _x + lengthdir_x(min(100, _aim_range), aim_angle);
var _cy = _y + lengthdir_y(min(100, _aim_range), aim_angle);
draw_circle(_cx, _cy, 5, true);
draw_set_alpha(1);
draw_set_colour(c_white);

var _pose = get_ghost_pose();
draw_sprite_ext(spr_ghost, 0, _pose.x, _pose.y, 1, 1, 0, c_white, ghost_alpha);

var _dx = lengthdir_x(1, aim_angle);
var _dy = lengthdir_y(1, aim_angle);
draw_set_colour(c_aqua);
draw_set_alpha(0.25);
draw_line(_pose.x + _dx * _pose.ghost_front, _pose.y + _dy * _pose.ghost_front,
    _x - _dx * _pose.body_extent, _y - _dy * _pose.body_extent);
draw_set_alpha(1);
draw_set_colour(c_white);
