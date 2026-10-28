changing_room = false;
var _body = instance_find(obj_player, 0);
if (instance_exists(_body) && instance_exists(_body.aim_controller)) {
    _body.aim_controller.aim_angle = saved_aim_angle;
}
if (camera_id != -1) camera_destroy(camera_id);
camera_id = camera_create_view(0, 0, min(camera_width, room_width), min(camera_height, room_height), 0, -1, -1, -1, 0, 0);
view_enabled = true;
view_visible[0] = true;
view_camera[0] = camera_id;
view_xport[0] = 0;
view_yport[0] = 0;
view_wport[0] = camera_width;
view_hport[0] = camera_height;
update_camera(true);
