var _body = instance_find(obj_player, 0);
if (!instance_exists(_body)) show_error("TEST FAIL: missing player", true);
var _team = _body.team;
var _aim = _body.aim_controller;
if (instance_number(obj_team) != 1) show_error("TEST FAIL: duplicate team", true);

var _capacity = _team.energy_max;
_team.advance_energy(_capacity / _team.energy_regen_per_second + 1);
if (_team.energy != _capacity) show_error("TEST FAIL: energy cap", true);

var _cost = _team.weapon.energy_cost;
var _pellets = _team.weapon.pellets;
if (!_body.fire_shot()) show_error("TEST FAIL: shot rejected", true);
if (_team.energy != _capacity - _cost || instance_number(obj_bullet) != _pellets) {
    show_error("TEST FAIL: shot cost or projectile count", true);
}

_aim.ghost_offset_x = _aim.ghost_move_radius * 2;
_aim.ghost_offset_y = 0;
_aim.clamp_ghost_position();
if (abs(_aim.ghost_offset_x - _aim.ghost_move_radius) > 0.01) {
    show_error("TEST FAIL: ghost tether", true);
}
show_debug_message("COOP TESTS PASSED");
