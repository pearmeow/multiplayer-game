var _old_x = x;
var _old_y = y;
var _dt = coop_motion_seconds(coop_step_seconds());
fire_cooldown = max(0, fire_cooldown - _dt);
damage_cooldown = max(0, damage_cooldown - _dt);
var _enemy = instance_place(x, y, par_enemy);
if (_enemy != noone && take_damage(_enemy.contact_damage)) {
    _enemy.pursue_hunter();
    if (hp == 0) exit;
}

var _mx = keyboard_check(ord("D")) - keyboard_check(ord("A"));
var _my = keyboard_check(ord("S")) - keyboard_check(ord("W"));
var _length = point_distance(0, 0, _mx, _my);
if (_length > 0) {
    var _speed = get_move_speed();
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
if (moving) coop_update_footsteps(point_distance(_old_x, _old_y, x, y), 1);
if (moving) {
    var _dx = x - _old_x;
    var _dy = y - _old_y;
    // There are no straight left/right rows; retain the previous vertical facing.
    var _face_up = _dy < 0 || (_dy == 0 && facing_row >= 2 && facing_row <= 4);
    if (_dx < 0) {
        facing_row = _face_up ? 2 : 1;
    } else if (_dx > 0) {
        facing_row = _face_up ? 4 : 5;
    } else {
        facing_row = _dy < 0 ? 3 : 0;
    }
}

var _player_sprite = moving ? spr_player_walk : spr_player_idle;
if (sprite_index != _player_sprite) {
    sprite_index = _player_sprite;
    animation_frame = 0;
}
var _frames = max(1, floor(image_number / max(1, animation_directions)));
animation_frame = (animation_frame + animation_fps * _dt) mod _frames;
image_index = facing_row * _frames + floor(animation_frame);

if (moving) {
    aim_controller.aim_angle = point_direction(_old_x, _old_y, x, y);
} else if (aim_controller.ghost_offset_x != 0 || aim_controller.ghost_offset_y != 0) {
    aim_controller.aim_angle = point_direction(0, 0, aim_controller.ghost_offset_x, aim_controller.ghost_offset_y);
}

if (!is_undefined(team.weapon)) {
    var _fire = team.weapon.automatic ? keyboard_check(vk_space) : keyboard_check_pressed(vk_space);
    if (_fire) fire_shot();
}
