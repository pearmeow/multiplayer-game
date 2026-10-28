hit_radius = 14;
targetable = true;
receive_shot = function(_attacker) {

    instance_destroy();
};

notice_distance = 220;
home_tolerance = 16;
start_x = x;
start_y = y;
state = 0; // 0 idle, 1 chase, 2 return home
move_speed = 120;
ai_enabled = true;
wall_margin = 4;
nav_cell_size = 8;
nav_repath_interval = 0.35;
nav_repath_timer = 0;
nav_grid = -1;
nav_columns = 0;
nav_rows = 0;
nav_points = [];
nav_point_index = 0;
nav_goal_reachable = false;
nav_status = "idle";
nav_clearance = hit_radius + wall_margin;
ai_update = function(_seconds) {
    if (!ai_enabled) return;
    var _dt = clamp(_seconds, 0, 0.05);
    var _player = instance_nearest(x, y, obj_player);
    var _player_distance = instance_exists(_player) ? point_distance(x, y, _player.x, _player.y) : infinity;
    var _old_state = state;
    if (state == 0) {
        if (_player_distance < notice_distance) state = 1;
    } else if (state == 1) {
        if (!instance_exists(_player)) state = 2;
    } else {
        if (point_distance(x, y, start_x, start_y) < home_tolerance) state = 0;
        if (_player_distance < notice_distance) state = 1;
    }
    if (_old_state != state) nav_repath_timer = 0;
    if (state == 0) { nav_status = "idle"; nav_points = []; return; }
    if (state == 1) {
        if (enemy_nav_touching_player(id)) {
            nav_status = "touching_player";
            nav_points = [];
            nav_repath_timer = 0;
            return;
        }
    }
    var _goal_x = state == 1 ? _player.x : start_x;
    var _goal_y = state == 1 ? _player.y : start_y;
    nav_repath_timer -= _dt;
    if (nav_repath_timer <= 0) {
        enemy_nav_plan(id, _goal_x, _goal_y);
        nav_repath_timer = nav_repath_interval;
    }
    enemy_nav_follow(id, move_speed * _dt);
};
