owner_body = noone;
aim_angle = 90;
cone_width = 60;
vision_range = 700;
turn_speed = 120;
cone_speed = 45;

ghost_gap = 6;
ghost_alpha = 0.60;

get_ghost_pose = function() {
    var _dx = lengthdir_x(1, aim_angle);
    var _dy = lengthdir_y(1, aim_angle);
    var _side_x = (_dx >= 0) ? owner_body.x - owner_body.bbox_left : owner_body.bbox_right - owner_body.x;
    var _side_y = (_dy >= 0) ? owner_body.y - owner_body.bbox_top : owner_body.bbox_bottom - owner_body.y;
    var _body_extent = abs(_dx) * _side_x + abs(_dy) * _side_y;
    var _ghost_front = sprite_get_bbox_bottom(spr_ghost) - sprite_get_yoffset(spr_ghost);
    var _distance = _body_extent + ghost_gap + _ghost_front;
    return {
        x: owner_body.x - _dx * _distance,
        y: owner_body.y - _dy * _distance,
        rotation: (aim_angle - 270 + 360) mod 360,
        body_extent: _body_extent,
        ghost_front: _ghost_front
    };
};
