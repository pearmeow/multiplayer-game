if (variable_instance_exists(id, "camera_id") && camera_id != -1) {
    if (view_camera[0] == camera_id) view_camera[0] = -1;
    camera_destroy(camera_id);
    camera_id = -1;
}
