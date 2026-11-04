var _old_x = x;
var _old_y = y;
var _dt = min(0.05, max(0, delta_time / 1000000));
fire_cooldown = max(0, fire_cooldown - _dt);
damage_cooldown = max(0, damage_cooldown - _dt);
var _enemy = instance_place(x, y, par_enemy);
if (_enemy != noone && take_damage(_enemy.contact_damage) && hp == 0) exit;

var _mx = keyboard_check(ord("D")) - keyboard_check(ord("A"));
var _my = keyboard_check(ord("S")) - keyboard_check(ord("W"));
var _length = point_distance(0, 0, _mx, _my);
if (_length > 0) {
    var _speed = move_speed + team.stat_bonus.move_speed;
    _mx = _mx / _length * _speed * _dt;
    _my = _my / _length * _speed * _dt;
	
    var _steps = max(1, ceil(max(abs(_mx), abs(_my))));
    repeat (_steps) {
        if (!place_meeting(x + _mx / _steps, y, obj_wall)) x += _mx / _steps;
        if (!place_meeting(x, y + _my / _steps, obj_wall)) y += _my / _steps;
    }
}

var _margin = max(sprite_get_width(sprite_index), sprite_get_height(sprite_index)) / 2;
x = clamp(x, min(_margin, room_width * 0.5), max(room_width * 0.5, room_width - _margin));
y = clamp(y, min(_margin, room_height * 0.5), max(room_height * 0.5, room_height - _margin));
shot_time = max(0, shot_time - _dt);
door_notice_time = max(0, door_notice_time - _dt);
if (!instance_exists(team) || !instance_exists(aim_controller)) exit;

moving = x != _old_x || y != _old_y;
if (moving) {
    aim_controller.aim_angle = point_direction(_old_x, _old_y, x, y);
} else if (aim_controller.ghost_offset_x != 0 || aim_controller.ghost_offset_y != 0) {
    aim_controller.aim_angle = point_direction(0, 0, aim_controller.ghost_offset_x, aim_controller.ghost_offset_y);
}

if (!is_undefined(team.weapon)) {
    var _fire = team.weapon.automatic ? keyboard_check(vk_space) : keyboard_check_pressed(vk_space);
    if (_fire) fire_shot();
}
