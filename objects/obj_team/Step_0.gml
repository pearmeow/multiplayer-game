// Manage tick
var _dt = max(0, delta_time / 1000000);
advance_energy(_dt);
feedback_time = max(0, feedback_time - _dt);
