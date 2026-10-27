// One physical body, two independent local keyboard control roles
move_speed = 300;
shoot_range = 700;
interact_range = 64;
shot_time = 0;
shot_x = x;
shot_y = y;
interaction_target = noone;
team = instance_find(obj_team, 0);
if (team == noone) team = instance_create_depth(0, 0, -1000, obj_team);
aim_controller = instance_create_depth(x, y, depth + 1, obj_aim);
aim_controller.owner_body = id;


fire_shot = function() {
    if (!instance_exists(team) || !instance_exists(aim_controller)) return false;
    if (team.try_spend(team.shot_cost)) {
        var _angle = aim_controller.aim_angle;
        var _distance = coop_wall_distance(x, y, _angle, shoot_range);
        var _dx = lengthdir_x(1, _angle);
        var _dy = lengthdir_y(1, _angle);
        var _nearest = noone;
        var _hit_distance = _distance;
        // No piercing rn
        for (var _i = 0; _i < instance_number(par_enemy); ++_i) {
            var _enemy = instance_find(par_enemy, _i);
            if (!_enemy.targetable) continue;
            var _hit = coop_ray_circle(x, y, _dx, _dy, _enemy.x, _enemy.y, _enemy.hit_radius);
            if (_hit >= 0 && _hit < _hit_distance) {
                _hit_distance = _hit;
                _nearest = _enemy;
            }
        }
        shot_x = x + _dx * _hit_distance;
        shot_y = y + _dy * _hit_distance;
        shot_time = 0.1;
        if (_nearest != noone) _nearest.receive_shot(id);
        return true;
    } else {
        team.notify("Not enough shared energy (need 5)");
        return false;
    }
};
