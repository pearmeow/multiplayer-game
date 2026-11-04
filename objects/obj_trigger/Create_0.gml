event_inherited();
was_inside = false;
activations = 0;
enabled = trigger_kind == 0 && object_index != obj_door_trigger; // 0 ghost interaction, 1 body contact
prompt = "Toggle";
activate_targets = function() {
    if (target_link == 0) return false;
    var _opened = false;
    activations++;
    with (obj_door) {
        if (link_id != other.target_link) continue;
        if (other.object_index == obj_door_trigger) {
            if (!is_open && toggle()) _opened = true;
        } else {
            toggle();
        }
    }
    if (object_index == obj_door_trigger) return _opened;
    with (obj_trap) {
        if (link_id == other.target_link) activate();
    }
    return false;
};
interact = function(_actor) {
    if (enabled) activate_targets();
};
