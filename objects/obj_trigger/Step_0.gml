enabled = trigger_kind == 0;
if (trigger_kind == 1) {
    var _inside = place_meeting(x, y, obj_player);
    if (_inside && !was_inside) {
        activate_targets();
        var _body = instance_place(x, y, obj_player);
        _body.show_action_effect(x, y, _body.interact_effect_colour);
    }
    was_inside = _inside;
}
