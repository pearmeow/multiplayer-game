var _body = instance_find(obj_player, 0);
if (!instance_exists(_body)) exit;
if (!place_meeting(x, y, _body)) {
    armed = true;
    exit;
}
if (!armed) exit;
var _team = _body.team;
var _next = room_next(room);
if (_body.final_floor || _next == -1) {
    var _manager = coop_game_manager();
    _manager.start_victory();
    instance_destroy();
} else {
    _team.change_room(_next);
}
