shot_time = 0;
shot_x = x;
shot_y = y;
interaction_target = noone;
action_effect_colour = shoot_effect_colour;
team = instance_find(obj_team, 0);
if (team == noone) team = instance_create_depth(0, 0, -1000, obj_team);
aim_controller = instance_create_depth(x, y, depth + 1, obj_aim);
aim_controller.owner_body = id;

show_action_effect = function(_target_x, _target_y, _colour) {
    action_effect_colour = _colour;
    shot_x = _target_x;
    shot_y = _target_y;
    shot_time = action_effect_duration;
};

fire_shot = function() {
    if (!instance_exists(team) || !instance_exists(aim_controller)) return false;
    if (team.try_spend(team.action_energy_cost)) {
        var _angle = aim_controller.aim_angle;
        var _distance = coop_wall_distance(x, y, _angle, shoot_range);
        var _dx = lengthdir_x(1, _angle);
        var _dy = lengthdir_y(1, _angle);
        var _nearest = noone;
        var _hit_distance = _distance;

        for (var _i = 0; _i < instance_number(par_enemy); ++_i) {
            var _enemy = instance_find(par_enemy, _i);
            if (!instance_exists(_enemy)) continue;
            if (!_enemy.targetable) continue;
            var _hit = coop_ray_circle(x, y, _dx, _dy, _enemy.x, _enemy.y, _enemy.hit_radius);
            if (_hit >= 0 && _hit < _hit_distance) {
                _hit_distance = _hit;
                _nearest = _enemy;
            }
        }
        show_action_effect(x + _dx * _hit_distance, y + _dy * _hit_distance, shoot_effect_colour);
        if (_nearest != noone) _nearest.receive_shot(id);
        return true;
    } else {
        team.notify("Not enough shared energy (need " + string(team.action_energy_cost) + ")");
        return false;
    }
};
