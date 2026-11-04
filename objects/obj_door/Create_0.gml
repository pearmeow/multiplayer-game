is_open = false;
closed_sprite = sprite_index;
toggle = function() {
    if (!is_open && link_id != 0) {
        for (var _i = 0; _i < instance_number(obj_door_trigger); _i++) {
            var _plate = instance_find(obj_door_trigger, _i);
            if (_plate.target_link == link_id && _plate.activations == 0) return false;
        }
    }
    sprite_index = closed_sprite;
    if (is_open) {
        if (place_meeting(x, y, obj_player) || place_meeting(x, y, par_enemy)) {
            sprite_index = -1;
            return false;
        }
    }
    is_open = !is_open;
    solid = !is_open;
    if (is_open) sprite_index = -1;
    return true;
};

enabled = true;
can_interact = function() {
    return link_id == 0;
};
get_interaction_point = function(_actor) {
    var _left = x - sprite_get_xoffset(closed_sprite) * image_xscale;
    var _top = y - sprite_get_yoffset(closed_sprite) * image_yscale;
    var _right = _left + sprite_get_width(closed_sprite) * image_xscale;
    var _bottom = _top + sprite_get_height(closed_sprite) * image_yscale;
    return {x: clamp(_actor.x, _left, _right), y: clamp(_actor.y, _top, _bottom)};
};
interact = function(_actor) {
    if (instance_exists(_actor) && _actor.object_index == obj_aim && can_interact()) return toggle();
    return false;
};
