event_inherited();
prompt = "Open reward chest (free)";
interaction_free = true;
reward_key = reward_id;
if (reward_key == "") reward_key = room_get_name(room) + ":" + string(id);

mark_open = function() {
    enabled = false;
    sprite_index = spr_reward_chest_open;
};

interact = function(_actor) {
    if (!enabled || !instance_exists(_actor.team)) return false;
    var _team = _actor.team;
    if (_team.has_reward(reward_key)) {
        mark_open();
        return false;
    }
    if (!_team.claim_reward(reward_key, weapon_reward, reward_pool, _actor)) return false;
    mark_open();
    return true;
};
