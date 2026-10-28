var _enemy = instance_find(par_enemy, 0);
var _player = instance_find(obj_player, 0);
if (!instance_exists(_enemy) || !instance_exists(_player)) {
    show_debug_message("Place an enemy and a player in the room before running this check.");
    exit;
}
var _found = enemy_nav_plan(_enemy, _player.x, _player.y);
if (_found) {
    if (!path_exists(_enemy.nav_path)) show_error("Navigation path missing", true);
    if (array_length(_enemy.nav_points) == 0) show_error("Navigation points missing", true);
    show_debug_message("Navigation path found for this room.");
} else {
    show_debug_message("No route in the current layout.");
}
