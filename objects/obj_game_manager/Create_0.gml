font = font_add("Smile\ Moon.otf", 16, false, false, 32, 128)
font_enable_sdf(font, true)
font_enable_effects(font, true, {
    outlineEnable: true,
    outlineDistance: 2,
    outlineColour: c_black
});
draw_set_font(font)