// Movement control
var _dt = min(0.05, max(0, delta_time / 1000000));
var _mx = keyboard_check(ord("D")) - keyboard_check(ord("A"));
var _my = keyboard_check(ord("S")) - keyboard_check(ord("W"));
var _length = point_distance(0, 0, _mx, _my);
if (_length > 0) {
    _mx = _mx / _length * move_speed * _dt;
    _my = _my / _length * move_speed * _dt;
	
    var _steps = max(1, ceil(max(abs(_mx), abs(_my))));
    repeat (_steps) {
        if (!place_meeting(x + _mx / _steps, y, obj_wall)) x += _mx / _steps;
        if (!place_meeting(x, y + _my / _steps, obj_wall)) y += _my / _steps;
    }
}

var _gap = instance_exists(aim_controller) ? aim_controller.ghost_gap : 6;
var _margin = ceil(point_distance(0, 0, 16, 16) + _gap + 12 + point_distance(0, 0, 12, 12));
x = clamp(x, min(_margin, room_width * 0.5), max(room_width * 0.5, room_width - _margin));
y = clamp(y, min(_margin, room_height * 0.5), max(room_height * 0.5, room_height - _margin));
shot_time = max(0, shot_time - _dt);
if (!instance_exists(team) || !instance_exists(aim_controller)) exit;

if (keyboard_check_pressed(vk_space)) fire_shot();

interaction_target = noone;
var _best = interact_range + 1;
for (var _j = 0; _j < instance_number(par_interactable); ++_j) {
    var _item = instance_find(par_interactable, _j);
    var _d = point_distance(x, y, _item.x, _item.y);
    if (_item.enabled && _d <= interact_range && _d < _best
        && coop_visible(id, _item.x, _item.y)) {
        interaction_target = _item;
        _best = _d;
    }
}
if (keyboard_check_pressed(ord("E")) && instance_exists(interaction_target)) {
    interaction_target.interact(id);
}
