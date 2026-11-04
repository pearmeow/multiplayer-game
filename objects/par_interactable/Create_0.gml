enabled = true;
interaction_free = false;
prompt = "Interact";
interact = function(_actor) {
    if (instance_exists(_actor.team)) _actor.team.notify("Interaction confirmed (placeholder)");
};