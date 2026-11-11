spawn_timer += 1;
if (spawn_timer >= max(1, interval)) {
    spawn_timer = 0;
    var _spike = instance_create_depth(x, y, depth, obj_spike);
    _spike.image_angle = image_angle;
    _spike.spd = spike_speed;
	_spike.collidable = collidable
}
