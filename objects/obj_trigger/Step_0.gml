var _plate = object_index == obj_door_trigger;
enabled = trigger_kind == 0 && !_plate;
if (_plate || trigger_kind == 1) {
    var _body = instance_find(obj_player, 0);
    var _inside = instance_exists(_body) && place_meeting(x, y, _body);
    if (_inside && !was_inside && (!_plate || activations == 0)) {
        var _opened = activate_targets();
        if (_plate) {
            if (_opened) _body.door_notice_time = _body.door_notice_duration;
        } else {
            _body.show_action_effect(x, y, _body.interact_effect_colour);
        }
    }
    was_inside = _inside;
}
