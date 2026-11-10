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
        _body.san = _body.san_max;
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
    state = 1;
    nav_repath_timer = 0;
};

start_img_ind = 0
end_img_ind = 5

start_x = x;
start_y = y;
state = 0; // 0 idle, 1 chase, 2 return home
ai_enabled = true;
nav_repath_timer = 0;
nav_grid = -1;
nav_path = path_add();
nav_point_index = 0;
get_slow_multiplier = function() {
    var _ghost = instance_find(obj_aim, 0);
    if (instance_exists(_ghost) && _ghost.slow_active
        && point_distance(x, y, _ghost.x, _ghost.y) <= _ghost.slow_range) {
        return _ghost.slow_rate;
    }
    return 1;
};
ai_update = function(_seconds) {
    if (!ai_enabled) return;
    var _dt = clamp(_seconds, 0, 0.05);
    var _player = instance_nearest(x, y, obj_player);
	if (_player != noone && _player.x < x) {
		if (image_xscale > 0) {
			image_xscale *= -1
		}
	} else if (_player != noone) {
		if (image_xscale < 0) {
			image_xscale *= -1
		}
	}
    var _player_distance = instance_exists(_player) ? point_distance(x, y, _player.x, _player.y) : infinity;
    var _old_state = state;
    if (state == 0) {
        if (_player_distance < notice_distance) state = 1;
    } else if (state == 1) {
        if (!instance_exists(_player)) state = 0;
    }
    if (_old_state != state) {
		if (state == 0) {
			start_img_ind = 0
			end_img_ind = 5
		} else {
			start_img_ind = 8
			end_img_ind = 14
		}
		nav_repath_timer = 0;
		image_index = start_img_ind
	}
	if (image_index >= end_img_ind) {
		image_index = start_img_ind
	}
    if (state == 0) return;
    if (state == 1 && enemy_nav_touching_player(id)) {
        nav_repath_timer = 0;
        return;
    }
    nav_repath_timer -= _dt;
    if (nav_repath_timer <= 0) {
        enemy_nav_plan(id, state == 1 ? _player.x : start_x, state == 1 ? _player.y : start_y);
        nav_repath_timer = nav_repath_interval;
    }
    enemy_nav_follow(id, move_speed * get_slow_multiplier() * _dt);
};
