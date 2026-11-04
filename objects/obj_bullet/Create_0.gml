mask_index = spr_wall;
image_xscale = 1 / sprite_get_width(mask_index);
image_yscale = 1 / sprite_get_height(mask_index);

advance = function(_seconds) {
    var _distance = min(range_left, projectile_speed * _seconds);
    var _hit = coop_shot_hit(id, x, y, heading, _distance);
    if (instance_exists(_hit.enemy)) _hit.enemy.receive_shot(shooter, damage);
    if (_hit.wall || _hit.enemy != noone) {
        instance_destroy();
        return;
    }

    x += lengthdir_x(_distance, heading);
    y += lengthdir_y(_distance, heading);
    range_left -= _distance;
    if (range_left <= 0) instance_destroy();
};
