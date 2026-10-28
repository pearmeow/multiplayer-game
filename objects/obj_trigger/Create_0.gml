event_inherited();
was_inside = false;
activations = 0;
enabled = trigger_kind == 0; // 0 ghost interaction, 1 body contact
prompt = "Toggle";
activate_targets = function() {
    if (target_link == 0) return;
    activations++;
    with (obj_door) {
        if (link_id == other.target_link) toggle();
    }
    with (obj_trap) {
        if (link_id == other.target_link) activate();
    }
};
interact = function(_actor) {
    if (trigger_kind == 0) activate_targets();
};
