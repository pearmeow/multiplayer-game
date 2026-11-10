if (!instance_exists(owner_body)) exit;
clamp_ghost_position();
var _dt = coop_step_seconds();
slow_active = keyboard_check(slow_key) && owner_body.team.try_spend(slow_cost * _dt);
owner_body.update_sanity(_dt);
if (owner_body.san == 0) exit;
update_interaction(interaction_pressed,
    keyboard_check_pressed(vk_right) - keyboard_check_pressed(vk_left),
    keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up));
interaction_pressed = false;

