// Shared energy pool
if (instance_number(obj_team) > 1) { instance_destroy(); exit; }
energy_max = 100;
energy = energy_max;
energy_regen_per_second = 1;
shot_cost = 5;
regen_elapsed = 0;
feedback = "";
feedback_time = 0;
try_spend = function(_cost) {
    if (_cost < 0 || energy < _cost) return false;
    energy = clamp(energy - _cost, 0, energy_max);
    return true;
};
notify = function(_message) {
    feedback = _message;
    feedback_time = 1.5;
};

advance_energy = function(_seconds) {
    var _dt = max(0, _seconds);
    energy = clamp(energy, 0, energy_max);
if (energy < energy_max) {
    regen_elapsed += _dt;
    var _ticks = floor(regen_elapsed);
    if (_ticks > 0) {
        energy = min(energy_max, energy + _ticks * energy_regen_per_second);
        regen_elapsed -= _ticks;
    }
}

if (energy >= energy_max) regen_elapsed = 0;

};
