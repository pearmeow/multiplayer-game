enabled = trigger_kind == 0;
if (trigger_kind == 1) {
    var _body = instance_find(obj_player, 0);
    var _inside = instance_exists(_body) && place_meeting(x, y, _body);
    if (_inside && !was_inside) {
        activate_targets();
        _body.show_action_effect(x, y, _body.interact_effect_colour);
    }
    was_inside = _inside;
}
