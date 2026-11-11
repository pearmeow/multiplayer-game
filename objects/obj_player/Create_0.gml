san_change_per_second = 0;
damage_cooldown = 0;
footstep_distance = 0;
footstep_index = 0;

play_hit_sound = function() {
    if (hurt_sound != -1) audio_play_sound(hurt_sound, 3, false, hurt_gain);
};

fail_run = function(_sanity) {
    if (!_sanity) hp = 0;
    var _manager = coop_game_manager();
    _manager.start_failure(_sanity);
};

take_damage = function(_damage) {
    if (hp <= 0 || _damage <= 0 || damage_cooldown > 0) return false;
    play_hit_sound();
    hp = max(0, hp - _damage);
    damage_cooldown = contact_damage_interval;
    if (hp == 0) fail_run(false);
    return true;
};

get_max_health = function() {
    return health_max + team.stat_bonus.max_health;
};

get_max_sanity = function() {
    return san_max + team.stat_bonus.max_sanity;
};

get_sanity_fraction = function() {
    return clamp(san / max(1, get_max_sanity()), 0, 1);
};

get_vision_range = function(_base_range) {
    var _scale = clamp((san - san_vision_floor_threshold) / max(1, get_max_sanity() - san_vision_floor_threshold), 0, 1);
    return _base_range * team.stat_bonus.vision * lerp(san_vision_min_fraction, 1, _scale);
};

get_move_speed = function() {
    return move_speed * team.stat_bonus.move_speed;
};

update_sanity = function(_seconds) {
    var _chase_drain = 0;
    for (var _i = 0; _i < instance_number(par_enemy); _i++) {
        var _enemy = instance_find(par_enemy, _i);
        if (coop_hunter_sees(id, _enemy)) {
            _chase_drain = san_chase_drain_near;
            break;
        }
        if (_enemy.state != 1) continue;
        var _distance = point_distance(x, y, _enemy.x, _enemy.y);
        if (_distance > san_chase_range) continue;
        var _near = coop_proximity(_distance - san_chase_full_range, san_chase_range - san_chase_full_range);
        _chase_drain = max(_chase_drain, lerp(san_chase_drain_far, san_chase_drain_near, _near));
    }
    var _drain = san_floor_drain;
    if (_chase_drain > 0) _drain += min(san_chase_drain_near, _chase_drain + team.san_pressure);
    san_change_per_second = _drain > 0 ? -_drain : san_recovery_per_second;
    san = clamp(san + san_change_per_second * max(0, _seconds), 0, get_max_sanity());
    if (san == 0) fail_run(true);
};

shot_time = 0;
door_notice_time = 0;
fire_cooldown = 0;
moving = false;
facing_row = 0;
animation_frame = 0;
image_speed = 0;
mask_index = spr_player_idle;
shot_x = x;
shot_y = y;
shot_source_x = x;
shot_source_y = y;
interaction_target = noone;
action_effect_colour = interact_effect_colour;
team = instance_find(obj_team, 0);
if (team == noone) team = instance_create_depth(0, 0, -1000, obj_team);
hp = get_max_health();
san = get_max_sanity();
aim_controller = instance_create_depth(x, y, depth + 1, obj_aim);
aim_controller.owner_body = id;

show_action_effect = function(_target_x, _target_y, _colour, _source_x = x, _source_y = y) {
    shot_source_x = _source_x;
    shot_source_y = _source_y;
    action_effect_colour = _colour;
    shot_x = _target_x;
    shot_y = _target_y;
    shot_time = action_effect_duration;
};

fire_shot = function() {
    if (!instance_exists(team) || !instance_exists(aim_controller) || fire_cooldown > 0) return false;
    var _weapon = team.weapon;
    if (is_undefined(_weapon)) return false;
    if (!team.try_spend(_weapon.energy_cost)) {
        team.notify("Not enough energy to fire");
        return false;
    }

    var _angle = aim_controller.aim_angle;
    if (aim_controller.ghost_offset_x != 0 || aim_controller.ghost_offset_y != 0) {
        _angle = point_direction(0, 0, aim_controller.ghost_offset_x, aim_controller.ghost_offset_y);
    }
    if (moving) _angle += random_range(-move_spread, move_spread);
    for (var _i = 0; _i < _weapon.pellets; _i++) {
        var _heading = _angle;
        if (_weapon.pellets > 1) {
            _heading += lerp(-_weapon.pellet_spread, _weapon.pellet_spread, _i / (_weapon.pellets - 1));
        }
        instance_create_depth(x, y, depth, obj_bullet, {
            heading: _heading,
            shooter: id,
            damage: team.weapon_damage,
            projectile_speed: _weapon.projectile_speed,
            range_left: _weapon.range
        });
    }

    fire_cooldown = _weapon.cooldown;
    return true;
};
