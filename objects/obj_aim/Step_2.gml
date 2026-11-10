if (!instance_exists(owner_body)) exit;
clamp_ghost_position();
var _cost = slow_cost * max(0, delta_time / 1000000);
slow_active = false;
if(keyboard_check(slow_key)){
	slow_active = owner_body.team.try_spend(_cost);
}
owner_body.update_sanity(max(0, delta_time / 1000000));
if (owner_body.san == 0) exit;
update_interaction(interaction_pressed,
    keyboard_check_pressed(vk_right) - keyboard_check_pressed(vk_left),
    keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up));
interaction_pressed = false;

