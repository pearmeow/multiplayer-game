function draw_ending_image(_sprite, _width, _top, _height, _alpha, _left = 0) {
    if (!sprite_exists(_sprite) || _height <= 0) return;
    var _sprite_width = sprite_get_width(_sprite);
    var _sprite_height = sprite_get_height(_sprite);
    var _scale = min(_width / _sprite_width, _height / _sprite_height);
    draw_sprite_ext(_sprite, 0, _left + (_width - _sprite_width * _scale) / 2,
        _top + (_height - _sprite_height * _scale) / 2, _scale, _scale, 0, c_white, _alpha);
}

if (!ending_active) exit;

var _width = display_get_gui_width();
var _height = display_get_gui_height();
var _previous_colour = draw_get_colour();
var _previous_alpha = draw_get_alpha();
draw_set_colour(c_black);
draw_set_alpha(1);
draw_rectangle(0, 0, _width, _height, false);

if (!victory && failure_time < scare_hold_seconds + scare_fade_seconds) {
    var _alpha = 1;
    if (failure_time > scare_hold_seconds) {
        _alpha = 1 - (failure_time - scare_hold_seconds) / scare_fade_seconds;
    }
    draw_ending_image(failure_sprite, _width, 0, _height, _alpha);
} else {
    var _previous_font = draw_get_font();
    var _previous_halign = draw_get_halign();
    var _previous_valign = draw_get_valign();
    var _x = _width / 2;
    var _y = _height / 2;
    draw_set_font(font);
    var _line = string_height("Retry?");
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_colour(c_white);
    if (victory) {
        draw_text_transformed(_x, _line * 2, "CONGRATULATIONS!", 2, 2, 0);
        draw_ending_image(victory_image, _width - _line * 2, _line * 4, _height - _line * 7, 1, _line);
        draw_text(_x, _height - _line * 1.5, "[ENTER] Play again   [ESC] Quit");
    } else {
        draw_text_transformed(_x, _y - _line * 2, "YOU ARE DEAD", 2.5, 2.5, 0);
        if (sanity_failure) draw_text(_x, _y, "BAD END: SANITY LOST");
        draw_text(_x, _y + _line * 2, "Try again?  [ENTER] Yes   [ESC] Quit");
    }
    draw_set_font(_previous_font);
    draw_set_halign(_previous_halign);
    draw_set_valign(_previous_valign);
}

draw_set_alpha(_previous_alpha);
draw_set_colour(_previous_colour);
