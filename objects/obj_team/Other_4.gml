changing_room = false;
var _body = instance_find(obj_player, 0);
if (!instance_exists(_body)) {
    var _spawn_x = room_width * 0.5;
    var _spawn_y = room_height * 0.5;
    var _best = infinity;
    for (var _x = 64; _x <= room_width - 64; _x += 32) {
        for (var _y = 64; _y <= room_height - 64; _y += 32) {
            if (collision_rectangle(_x - 18, _y - 18, _x + 18, _y + 18, obj_wall, false, true) != noone) continue;
            var _distance = point_distance(_x, _y, room_width * 0.5, room_height * 0.5);
            if (_distance < _best) {
                _best = _distance;
                _spawn_x = _x;
                _spawn_y = _y;
            }
        }
    }
    if (_best != infinity) {
        _body = instance_create_depth(_spawn_x, _spawn_y, 0, obj_player);
    } else {
        notify("No safe player spawn in this room");
    }
}
if (instance_exists(_body)) {
    if (instance_exists(_body.aim_controller)) {
        _body.aim_controller.aim_angle = saved_aim_angle;
        _body.aim_controller.cone_width = saved_cone_width;
    }
}
if (camera_id != -1) camera_destroy(camera_id);
camera_id = camera_create_view(0, 0, min(camera_width, room_width), min(camera_height, room_height), 0, -1, -1, -1, 0, 0);
view_enabled = true;
view_visible[0] = true;
view_camera[0] = camera_id;
view_xport[0] = 0;
view_yport[0] = 0;
view_wport[0] = 960;
view_hport[0] = 540;
update_camera(true);
