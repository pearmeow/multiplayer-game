draw_vision();

var _body = instance_find(obj_player, 0);
if (camera_id != -1 && instance_exists(_body) && instance_exists(_body.interaction_target)) {
    draw_interaction_halo(_body.interaction_target);
}
draw_own_players();
draw_indicator();

var _left = 24;
var _top = 24;
var _width = min(300, max(100, display_get_gui_width() - 48));
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_status_bar(_left, _top, _width, energy, energy_max, c_teal, "ENERGY");
if (instance_exists(_body)) {
    draw_status_bar(_left, _top + 24, _width, _body.hp, _body.health_max, c_maroon, "HP");
    draw_status_bar(_left, _top + 48, _width, floor(_body.san), _body.san_max, c_purple, "SAN");
} else {
    draw_text(_left, _top + 25, "Hunter down - R to restart room");
}
draw_text(_left, _top + 74, "LUCK: " + string(luck));
var _weapon_label = "Unarmed";
if (!is_undefined(weapon)) {
    _weapon_label = weapon.name + " | SPACE (-" + string(weapon.energy_cost) + ")";
}
draw_text(_left, _top + 96, "WASD to move | " + _weapon_label);
draw_text(_left, _top + 116, "GHOST: ARROWS to move / select, ENTER interact");
draw_text(_left, _top + 136, "R to restart room");
if (feedback_time > 0) draw_text(_left, _top + 156, feedback);

if (camera_id != -1 && instance_exists(_body) && instance_exists(_body.interaction_target)) {
    var _target = _body.interaction_target;
    var _world_x = _target.x - sign(_target.x - _body.x) * 16;
    var _world_y = _target.y - 20;
    var _prompt_x = (_world_x - camera_get_view_x(camera_id)) * display_get_gui_width() / camera_get_view_width(camera_id);
    var _prompt_y = (_world_y - camera_get_view_y(camera_id)) * display_get_gui_height() / camera_get_view_height(camera_id);
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_colour(c_black);
    draw_text(_prompt_x + 1, _prompt_y + 1, "[ENTER] " + _target.prompt);
    draw_set_colour(c_white);
    draw_text(_prompt_x, _prompt_y, "[ENTER] " + _target.prompt);
}
