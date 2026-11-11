if (instance_number(obj_team) > 1) { instance_destroy(); exit; }
energy = energy_max;
bgm_voice = -1;
heartbeat_voice = -1;
enemy_proximity = 0;
reward_keys = [];
reward_counts = {};
san_pressure = 0;
opened_reward_rooms = {};
load_reward_data = function(_path) {
    if (!file_exists(_path)) return {};
    var _file = file_text_open_read(_path);
    var _json = "";
    while (!file_text_eof(_file)) {
        _json += file_text_read_string(_file);
        file_text_readln(_file);
    }
    file_text_close(_file);
    return json_parse(_json);
};

weapon_catalog = load_reward_data("weapons.json");
reward_pools = load_reward_data("reward_pools.json");
stat_bonus = {move_speed: 1, vision: 1, max_health: 0, max_sanity: 0};

weapon = variable_struct_get(weapon_catalog, starting_weapon);
weapon_damage = is_undefined(weapon) ? 0 : weapon.damage;

has_reward = function(_key) {
    for (var _i = 0; _i < array_length(reward_keys); _i++) {
        if (reward_keys[_i] == _key) return true;
    }
    return false;
};

get_next_weapon = function(_preferred) {
    var _next_rank = is_undefined(weapon) ? 0 : weapon.rank + 1;
    var _choices = [];
    var _ids = variable_struct_get_names(weapon_catalog);
    for (var _i = 0; _i < array_length(_ids); _i++) {
        var _candidate = variable_struct_get(weapon_catalog, _ids[_i]);
        if (_candidate.rank != _next_rank) continue;
        if (_ids[_i] == _preferred) return _candidate;
        array_push(_choices, _candidate);
    }
    if (array_length(_choices) == 0) return undefined;
    return _choices[irandom(array_length(_choices) - 1)];
};

get_reward_count = function(_id) {
    if (!variable_struct_exists(reward_counts, _id)) return 0;
    return variable_struct_get(reward_counts, _id);
};

roll_reward_amount = function(_amount) {
    var _bonus = random_range(0, clamp(luck / 100, 0, 1) * max(0, luck_bonus_max));
    return round(_amount * (1 + _bonus) * 100) / 100;
};

pick_chest_reward = function(_pool, _next_weapon) {
    if (!is_array(_pool)) return undefined;
    var _choices = [];
    var _weight = 0;
    for (var _i = 0; _i < array_length(_pool); _i++) {
        var _entry = _pool[_i];
        if (_entry.weight <= 0 || get_reward_count(_entry.id) >= reward_pools.max_per_upgrade) continue;
        if (_entry.id == "weapon" && is_undefined(_next_weapon)) continue;
        _weight += _entry.weight;
        array_push(_choices, {entry: _entry, threshold: _weight});
    }
    if (_weight <= 0) return undefined;
    var _roll = random(_weight);
    for (var _i = 0; _i < array_length(_choices); _i++) {
        if (_roll < _choices[_i].threshold) return _choices[_i].entry;
    }
    return _choices[array_length(_choices) - 1].entry;
};

claim_reward = function(_key, _weapon_id, _pool_id, _body) {
    if (has_reward(_key)) return false;
    var _room_key = room_get_name(room);
    var _first = !variable_struct_exists(opened_reward_rooms, _room_key);
    var _next_weapon = undefined;
    if (get_reward_count("weapon") < reward_pools.max_per_upgrade) _next_weapon = get_next_weapon(_weapon_id);

    var _entry = undefined;
    if (_first && !is_undefined(_next_weapon)) {
        _entry = {id: "weapon"};
    } else {
        _entry = pick_chest_reward(variable_struct_get(reward_pools, _pool_id), _next_weapon);
    }
    if (is_undefined(_entry)) {
        notify("No upgrades remaining");
        return false;
    }

    if (_entry.id == "weapon") {
        weapon = _next_weapon;
        weapon_damage = roll_reward_amount(weapon.damage);
        notify("Equipped " + weapon.name + " / Damage " + string(weapon_damage));
    } else {
        var _previous = variable_struct_get(stat_bonus, _entry.id);
        var _updated = variable_struct_exists(_entry, "fraction")
            ? _previous * (1 + _entry.fraction) : _previous + _entry.amount;
        variable_struct_set(stat_bonus, _entry.id, _updated);
        if (_entry.id == "max_health") _body.hp = min(_body.get_max_health(), _body.hp + _entry.amount);
        notify(_entry.label);
    }

    variable_struct_set(reward_counts, _entry.id, get_reward_count(_entry.id) + 1);
    array_push(reward_keys, _key);
    variable_struct_set(opened_reward_rooms, _room_key, true);
    return true;
};

get_action_cost = function() {
    return max(1, action_energy_cost);
};

regen_elapsed = 0;
feedback = "";
feedback_time = 0;
try_spend = function(_cost) {
    if (_cost < 0 || energy < _cost) return false;
    energy = clamp(energy - _cost, 0, energy_max);
    return true;
};
notify = function(_message) {
    feedback = _message;
    feedback_time = hud_feedback_duration;
};

advance_energy = function(_seconds) {
    energy = clamp(energy, 0, energy_max);
    if (energy < energy_max) {
        regen_elapsed += max(0, _seconds);
        energy = min(energy_max, energy + floor(regen_elapsed) * energy_regen_per_second);
        regen_elapsed -= floor(regen_elapsed);
    }
    if (energy >= energy_max) regen_elapsed = 0;
};

changing_room = false;
level_spawn = undefined;
camera_id = -1;
saved_aim_angle = 90;
window_set_size(camera_width, camera_height);
display_set_gui_size(camera_width, camera_height);

change_room = function(_target) {
    var _manager = instance_find(obj_game_manager, 0);
    if (instance_exists(_manager) && _manager.ending_active) return false;
    if (changing_room || _target == room || !room_exists(_target)) return false;

    var _body = instance_find(obj_player, 0);
    if (instance_exists(_body) && instance_exists(_body.aim_controller)) {
        saved_aim_angle = _body.aim_controller.aim_angle;
    }

    changing_room = true;
    room_goto(_target);
    return true;
};

update_camera = function() {
    var _body = instance_find(obj_player, 0);
    if (camera_id == -1 || !instance_exists(_body)) return;
    camera_set_view_pos(camera_id,
        _body.x - camera_get_view_width(camera_id) / 2,
        _body.y - camera_get_view_height(camera_id) / 2);
};

vision_mask = -1;
