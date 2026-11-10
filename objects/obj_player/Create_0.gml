san = san_max;
san_change_per_second = 0;
damage_cooldown = 0;

take_damage = function(_damage) {
    if (_damage <= 0 || damage_cooldown > 0) return false;
    hp = max(0, hp - _damage);
    damage_cooldown = contact_damage_interval;
    if (hp == 0) instance_destroy();
    return true;
};

get_sanity_vision_scale = function() {
    return clamp((san - san_blind_threshold) / max(1, san_max - san_blind_threshold), 0, 1);
};

update_sanity = function(_seconds) {
    var _visible = false;
    var _chased = false;
    for (var _i = 0; _i < instance_number(par_enemy); _i++) {
        var _enemy = instance_find(par_enemy, _i);
        if (_enemy.state == 1) _chased = true;
        if (coop_visible(id, _enemy.x, _enemy.y, _enemy)) _visible = true;
    }
    var _drain = san_floor_drain;
    if (_visible) _drain += san_drain_per_second;
    if (_chased) _drain += san_chase_drain;
    if (_drain > 0) {
        san_change_per_second = -(_drain + team.san_pressure);
    } else {
        san_change_per_second = san_recovery_per_second;
    }
    san = clamp(san + san_change_per_second * max(0, _seconds), 0, san_max);
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
hp = health_max + team.stat_bonus.max_health;
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
