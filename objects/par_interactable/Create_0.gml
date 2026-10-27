enabled = true;
prompt = "Interact";
interact = function(_actor) {
    // Override in child objects for doors, pickups, switches, etc.
    if (instance_exists(_actor.team)) _actor.team.notify("Interaction confirmed (placeholder)");
};
