targetable = true;
footstep_distance = 0;
footstep_index = 0;
alert_sounded = false;
if (sprite_index == -1 && mask_index == -1) {
    mask_index = spr_enemy;
    image_xscale = hit_radius * 2 / sprite_get_width(spr_enemy);
    image_yscale = hit_radius * 2 / sprite_get_height(spr_enemy);
}
hp = health_max;
defeat = function() {
    var _body = instance_find(obj_player, 0);
    if (instance_exists(_body)) {
        _body.san = _body.get_max_sanity();
        _body.team.san_pressure += _body.san_kill_pressure;
    }
    instance_destroy();
};

receive_shot = function(_attacker, _damage) {
    if (_damage <= 0) return;
    hp = max(0, hp - _damage);
    if (hp == 0) {
        defeat();
        return;
    }
    pursue_hunter();
};

state = 0; // 0 idle, 1 chase
ai_enabled = true;
nav_repath_timer = 0;
nav_grid = -1;
nav_path = path_add();
nav_point_index = 0;
chase_animation = false;
get_slow_multiplier = function() {
    var _ghost = instance_find(obj_aim, 0);
    if (instance_exists(_ghost) && _ghost.slow_active
        && point_distance(x, y, _ghost.x, _ghost.y) <= _ghost.slow_range) {
        return _ghost.slow_rate;
    }
    return 1;
};
pursue_hunter = function() {
    state = 1;
    nav_repath_timer = 0;
};

update_pursuit = function(_hunter) {
    if (!instance_exists(_hunter)) {
        state = 0;
        return false;
    }
    if (state == 0 && point_distance(x, y, _hunter.x, _hunter.y) <= notice_distance
        && collision_line(x, y, _hunter.x, _hunter.y, obj_wall, true, true) == noone) {
        pursue_hunter();
    }
    return state == 1;
};

get_chase_speed = function(_hunter) {
    return _hunter.get_move_speed() * hunter_speed_multiplier * get_slow_multiplier();
};

ai_update = function(_seconds) {
    if (!ai_enabled) return;
    var _dt = coop_motion_seconds(_seconds);
    var _hunter = instance_nearest(x, y, obj_player);
    var _chasing = update_pursuit(_hunter);
    if (_hunter != noone && _hunter.x != x) image_xscale = sign(_hunter.x - x) * abs(image_xscale);

    var _first_frame = _chasing ? chase_first_frame : idle_first_frame;
    var _last_frame = _chasing ? chase_last_frame : idle_last_frame;
    if (_chasing != chase_animation || image_index >= _last_frame) image_index = _first_frame;
    chase_animation = _chasing;

    if (!_chasing) return;
    if (place_meeting(x, y, _hunter)) {
        nav_repath_timer = 0;
        return;
    }
    nav_repath_timer -= _dt;
    if (nav_repath_timer <= 0) {
        enemy_nav_plan(id, _hunter.x, _hunter.y);
        nav_repath_timer = nav_repath_interval;
    }
    enemy_nav_follow(id, get_chase_speed(_hunter) * _dt);
};
