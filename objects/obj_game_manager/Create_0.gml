font = font_add("Smile\ Moon.otf", 16, false, false, 32, 128)
font_enable_sdf(font, true)
font_enable_effects(font, true, {
    outlineEnable: true,
    outlineDistance: 2,
    outlineColour: c_black
});

randomize();
ending_active = false;
victory = false;
failure_sprite = -1;
failure_time = 0;
ending_frozen = false;
sanity_failure = false;

start_failure = function(_sanity) {
    if (ending_active) return;
    ending_active = true;
    failure_sprite = scare_images[irandom(array_length(scare_images) - 1)];
    failure_time = 0;
    sanity_failure = _sanity;
};

start_victory = function() {
    if (ending_active) return;
    ending_active = true;
    victory = true;
};

finish_ending = function(_retry) {
    instance_activate_all();
    if (_retry) game_restart();
    else game_end();
};
