checks = 0;
check = function(_ok, _label) {
    if (!_ok) show_error("FAIL: " + _label, true);
    checks++;
    show_debug_message("PASS: " + _label);
};
var _body = instance_find(obj_player, 0);
with (obj_wall) instance_destroy();
with (par_enemy) instance_destroy();
_body.x = 300; _body.y = 100;
var _enemy = instance_create_depth(100, 100, 0, par_enemy);
_enemy.sprite_index = -1;
check(_enemy.notice_distance==220, "initial notice distance retained");
check(enemy_nav_radius(_enemy)==18, "14px body plus 4px wall margin");
var _wall = instance_create_depth(200,32,0,obj_wall);
_wall.image_yscale=8;
check(enemy_nav_plan(_enemy,300,100), "route around tall wall exists");
var _points=_enemy.nav_points;
var _length=0;
for (var _i=1;_i<array_length(_points);++_i) {
    _length+=point_distance(_points[_i-1].x,_points[_i-1].y,_points[_i].x,_points[_i].y);
}
check(abs(_length-632)<0.01, "shortest four-way detour is exactly 632px");
var _clear=true;
for (var _i=0;_i<array_length(_points);++_i) {
    if (!enemy_nav_position_clear(_enemy,_points[_i].x,_points[_i].y)) _clear=false;
    if (_i>0 && !enemy_nav_segment_clear(_enemy,_points[_i-1].x,_points[_i-1].y,_points[_i].x,_points[_i].y)) _clear=false;
}
check(_clear,"all waypoints and connecting segments respect clearance");
var _safe=true;
for (var _frame=0;_frame<200;++_frame) {
    _enemy.ai_update(0.05);
    if (!enemy_nav_position_clear(_enemy,_enemy.x,_enemy.y)) _safe=false;
}
check(_safe,"200 simulated chase frames never touch padded walls");
check(enemy_nav_touching_player(_enemy),"enemy reaches actual player collision box around wall");
check(_enemy.state==1,"hunter enters chase state");
check(_enemy.nav_status=="touching_player","enemy stops only on actual player contact");
instance_destroy(_wall);

_enemy.x=100;_enemy.y=100;
_wall=instance_create_depth(200,0,0,obj_wall);_wall.image_yscale=room_height/32;
check(!enemy_nav_plan(_enemy,300,100),"sealed region reported unreachable");
enemy_nav_follow(_enemy,10000);
check(abs(_enemy.x-172)<0.01 && abs(_enemy.y-100)<0.01,"unreachable target approaches nearest reachable cell");
check(enemy_nav_position_clear(_enemy,_enemy.x,_enemy.y),"unreachable fallback never pushes into wall");
instance_destroy(_wall);

_enemy.x=100;_enemy.y=180;
var _upper=instance_create_depth(200,0,0,obj_wall);_upper.image_yscale=5;
var _lower=instance_create_depth(200,192,0,obj_wall);_lower.image_yscale=(room_height-192)/32;
check(!enemy_nav_plan(_enemy,300,180),"rejects narrow 32px opening");
instance_destroy(_upper);instance_destroy(_lower);

_enemy.x=100;_enemy.y=100;
check(enemy_nav_plan(_enemy,300,100),"open room route exists");
_wall=instance_create_depth(132,84,0,obj_wall);
enemy_nav_follow(_enemy,100);
show_debug_message("DYNAMIC WALL X: "+string(_enemy.x)+" CLEAR: "+string(enemy_nav_position_clear(_enemy,_enemy.x,_enemy.y)));
check(_enemy.x<=114.001 && enemy_nav_position_clear(_enemy,_enemy.x,_enemy.y),"new wall cannot be tunnelled through");
check(_enemy.nav_status=="blocked_replan" && _enemy.nav_repath_timer==0,"new wall requests immediate replan");
check(enemy_nav_plan(_enemy,300,100),"replan routes around newly added wall");
instance_destroy(_wall);
check(enemy_nav_plan(_enemy,300,100),"removed wall opens route again");

_wall=instance_create_depth(90,90,0,obj_wall);_enemy.x=100;_enemy.y=100;
check(!enemy_nav_plan(_enemy,300,100) && _enemy.nav_status=="blocked_spawn","overlapping spawn safely rejected");
check(_enemy.x==100 && _enemy.y==100,"invalid spawn is never teleported");
instance_destroy(_wall);
_enemy.sprite_index=spr_wall;_enemy.image_xscale=2;
check(enemy_nav_radius(_enemy)>=67,"scaled off-centre collision mask expands clearance");
_enemy.sprite_index=-1;_enemy.image_xscale=1;
_enemy.x=100;_enemy.y=100;_enemy.state=1;
_body.x=600;_body.y=100;
_enemy.ai_update(0);
check(_enemy.state==1,"enemy keeps chasing a distant player");
_enemy.state=2;
_enemy.start_x=_enemy.x;_enemy.start_y=_enemy.y;
_enemy.ai_update(0);
check(_enemy.state==0,"hunter waits when back home");
_body.x=300;
_enemy.ai_update(0);
check(_enemy.state==1,"hunter notices player again");
var _grid=_enemy.nav_grid;
instance_destroy(_enemy);
check(!ds_exists(_grid,ds_type_grid),"cleanup frees per-enemy navigation grid");

_body.x=100;_body.y=100;_body.aim_controller.aim_angle=0;
_enemy=instance_create_depth(200,100,0,par_enemy);
_body.team.energy=100;
check(_body.fire_shot() && !instance_exists(_enemy),"AI enemies still die from one shot");
check(_body.team.energy==95,"shooting an AI enemy still costs five energy");

_enemy=instance_create_depth(100,100,0,par_enemy);_enemy.state=1;
instance_destroy(_body);
_enemy.ai_update(0.05);
check(_enemy.state==2,"missing player transitions to returning state");
instance_destroy(_enemy);
show_debug_message("ENEMY AI TESTS PASSED: "+string(checks));
game_end();
