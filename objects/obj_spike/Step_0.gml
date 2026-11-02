if (place_meeting(x, y, obj_player)) {
	instance_destroy(obj_player.id)
}

// rotate based on image angle
x += spd * dcos(image_angle + 90)
y -= spd * dsin(image_angle + 90)