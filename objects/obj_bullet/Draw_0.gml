// The collision mask is scaled to one pixel; draw the sprite at its own size.
draw_sprite(sprite_index, image_index,
    x - sprite_get_width(sprite_index) * 0.5 + sprite_get_xoffset(sprite_index),
    y - sprite_get_height(sprite_index) * 0.5 + sprite_get_yoffset(sprite_index));
