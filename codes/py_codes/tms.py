import numpy as np

def TMS(step, params):
    """
    Integer-index TMS waveform.
    Avoids floating-point mod boundary problems.
    Stimulation interval is [onset, onset + Duration), excluding the endpoint.
    """

    dt = params.deltat

    # MATLAB-style convention
    t = (step - 1) * dt

    if t < params.onset:
        return 0.0

    # Integer samples since onset
    k = int(round((t - params.onset) / dt))

    duration_steps = int(round(params.Duration / dt))

    # IMPORTANT: exclude k == duration_steps
    if k < 0 or k >= duration_steps:
        return 0.0

    pulse_width_steps  = int(round(params.width / dt))
    pulse_period_steps = int(round((1.0 / params.freq) / dt))
    burst_period_steps = int(round((1.0 / params.oscillation_freq) / dt))

    if params.off == 0:
        k_in_on = k
    else:
        on_steps    = int(round(params.on / dt))
        cycle_steps = int(round((params.on + params.off) / dt))

        k_cycle = k % cycle_steps

        if k_cycle >= on_steps:
            return 0.0

        k_in_on = k_cycle

    k_in_burst = k_in_on % burst_period_steps

    pulse_idx  = k_in_burst // pulse_period_steps
    k_in_pulse = k_in_burst - pulse_idx * pulse_period_steps

    if pulse_idx < params.bursts and k_in_pulse < pulse_width_steps:
        return params.amp

    return 0.0