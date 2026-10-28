if (!instance_exists(owner_body)) exit;
var _pose = get_ghost_pose();
draw_sprite_ext(spr_ghost, 0, _pose.x, _pose.y, 1, 1, 0, c_white, ghost_alpha);
