// Example enemy
hit_radius = 14;
targetable = true;
receive_shot = function(_attacker) {
    // Every valid hit kills this enemy immediately, regardless of future HP.
    instance_destroy();
};
