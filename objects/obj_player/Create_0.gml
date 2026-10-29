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
        var _hit = coop_shot_hit(aim_controller, x, y, _angle, shoot_range);
        var _dx = lengthdir_x(1, _angle);
        var _dy = lengthdir_y(1, _angle);
        show_action_effect(x + _dx * _hit.distance, y + _dy * _hit.distance, shoot_effect_colour);
        if (_hit.enemy != noone) _hit.enemy.receive_shot(id);
        return true;
    } else {
        team.notify("Not enough shared energy (need " + string(team.action_energy_cost) + ")");
        return false;
    }
};
