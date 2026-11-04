var _previous_font = draw_get_font();
var _manager = instance_find(obj_game_manager, 0);
if (instance_exists(_manager)) draw_set_font(_manager.font);

team_draw_vision();

var _body = instance_find(obj_player, 0);
if (camera_id != -1 && instance_exists(_body) && instance_exists(_body.interaction_target)) {
    team_draw_interaction_halo(_body.interaction_target);
}
team_draw_own_players();
team_draw_indicator();
if (camera_id != -1 && instance_exists(_body) && instance_exists(_body.aim_controller)) {
    team_draw_plate_indicator(_body.aim_controller);
}

var _left = hud_margin;
var _top = hud_margin;
var _width = min(hud_width, max(1, display_get_gui_width() - _left * 2));
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
var _line = ceil(string_height("HP") * hud_text_scale) + 4;
var _bar_height = _line - 3;
team_draw_status_bar(_left, _top, _width, _bar_height, energy, energy_max, c_teal, "ENERGY");
if (instance_exists(_body)) {
    team_draw_status_bar(_left, _top + _line, _width, _bar_height, _body.hp, _body.health_max + stat_bonus.max_health, c_maroon, "HP");
    team_draw_status_bar(_left, _top + _line * 2, _width, _bar_height, floor(_body.san), _body.san_max, c_purple, "SAN");
} else {
    team_draw_hud_text(_left, _top + _line, "Hunter down - R to restart room");
}

var _row = _top + _line * 3;
team_draw_hud_text(_left, _row, "LUCK: " + string(luck));
_row += _line;
if (!is_undefined(weapon)) {
    team_draw_hud_text(_left, _row, weapon.name + " (-" + string(weapon.energy_cost) + " energy)");
    _row += _line;
}
team_draw_hud_text(_left, _row, show_help ? "H: Hide controls" : "H: Show controls");
_row += _line;

if (show_help) {
    var _shoot = !is_undefined(weapon) && weapon.automatic ? "HOLD SPACE: Fire" : "SPACE: Fire";
    team_draw_hud_text(_left, _row, "WASD: Move | " + _shoot);
    team_draw_hud_text(_left, _row + _line, "ARROWS: Move ghost / select | ENTER: Interact");
    team_draw_hud_text(_left, _row + _line * 2, "R: Restart | F11: Fullscreen");
    _row += _line * 3;
}

if (run_complete) {
    team_draw_hud_text(_left, _row, "Escaped! All floors cleared.");
} else if (instance_exists(_body)) {
    var _remaining_enemies = instance_number(par_enemy);
    if (_remaining_enemies > 0) {
        team_draw_hud_text(_left, _row, "Objective: Clear the floor (" + string(_remaining_enemies) + " left)");
    } else {
        team_draw_hud_text(_left, _row, "Objective: Return to the starting point and enter the portal");
    }
}
if (feedback_time > 0) team_draw_hud_text(_left, _row + _line, feedback);

if (camera_id != -1 && instance_exists(_body) && instance_exists(_body.interaction_target)) {
    var _target = _body.interaction_target;
    var _world_x = _target.x - sign(_target.x - _body.x) * prompt_offset_x;
    var _world_y = _target.y - prompt_offset_y;
    var _prompt_x = (_world_x - camera_get_view_x(camera_id)) * display_get_gui_width() / camera_get_view_width(camera_id);
    var _prompt_y = (_world_y - camera_get_view_y(camera_id)) * display_get_gui_height() / camera_get_view_height(camera_id);
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_colour(c_black);
    team_draw_hud_text(_prompt_x + 1, _prompt_y + 1, "[ENTER] " + _target.prompt);
    draw_set_colour(c_white);
    team_draw_hud_text(_prompt_x, _prompt_y, "[ENTER] " + _target.prompt);
}


if (camera_id != -1 && instance_exists(_body) && _body.door_notice_time > 0) {
    var _remaining = _body.door_notice_time / _body.door_notice_duration;
    var _x = (_body.x - camera_get_view_x(camera_id)) * display_get_gui_width() / camera_get_view_width(camera_id);
    var _y = (_body.bbox_top - camera_get_view_y(camera_id)) * display_get_gui_height() / camera_get_view_height(camera_id);
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_alpha(_remaining);
    team_draw_hud_text(_x, _y - _line * (1 - _remaining), "A door at somewhere is opened");
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

draw_set_font(_previous_font);
