draw_vision();
draw_own_players();
draw_indicator();

var _left = 24;
var _top = 24;
var _width = min(300, max(100, display_get_gui_width() - 48));
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_colour(make_colour_rgb(35, 40, 50));
draw_rectangle(_left, _top, _left + _width, _top + 20, false);
draw_set_colour(energy >= action_energy_cost ? c_aqua : c_red);
if (energy > 0) draw_rectangle(_left, _top, _left + _width * energy / energy_max, _top + 20, false);
draw_set_colour(c_white);
draw_rectangle(_left, _top, _left + _width, _top + 20, true);
draw_text(_left, _top + 28, "ENERGY: " + string(energy) + "/" + string(energy_max));
draw_text(_left, _top + 50, "BODY: WASD to move, SPACE to fire (-" + string(action_energy_cost) + ")");
draw_text(_left, _top + 70, "GHOST: LEFT/RIGHT to aim, ENTER interact (-" + string(action_energy_cost) + ")");
if (feedback_time > 0) draw_text(_left, _top + 94, feedback);

var _body = instance_find(obj_player, 0);
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
