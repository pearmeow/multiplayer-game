if (changing_room) exit;
update_camera();
team_update_heartbeat(delta_time / 1000000);
if (is_undefined(level_spawn)) exit;
if (!instance_exists(obj_player) || instance_exists(obj_exit_portal) || instance_number(par_enemy) > 0) exit;
instance_create_depth(level_spawn.x, level_spawn.y, level_spawn.depth, obj_exit_portal);
