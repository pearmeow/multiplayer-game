if (!instance_exists(owner_body)) exit;
clamp_ghost_position();
update_interaction(interaction_pressed);
interaction_pressed = false;
