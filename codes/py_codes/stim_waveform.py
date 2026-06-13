import numpy as np
from continuous_stim_waveform import continuous_stim_waveform


def stim_waveform(step, params):
    """
    Python translation of stim_waveform.m.

    If params.stim.mode == 'continuous', this calls continuous_stim_waveform()
    and returns immediately.

    Otherwise, it uses integer-index intermittent/burst pulse logic to avoid
    floating-point boundary artifacts. This is the corrected replacement for
    the legacy MATLAB floating-time/mod pulse logic.
    """
    stim = getattr(params, 'stim', None)
    if stim is not None and getattr(stim, 'mode', '').lower() == 'continuous':
        return continuous_stim_waveform(step, params)

    return intermittent_stim_waveform_integer(step, params)


def intermittent_stim_waveform_integer(step, params):
    """
    Corrected intermittent/burst waveform using integer sample indices.

    This branch keeps the old TMS/stim convention:
        t = (step - 1) * params.deltat

    Stimulation is active on [onset, onset + Duration), excluding the endpoint.
    Therefore no one-sample trailing pulse is generated at onset + Duration.
    """
    dt = params.deltat
    t = (step - 1) * dt

    if t < params.onset:
        return 0.0

    k = int(round((t - params.onset) / dt))
    duration_steps = int(round(params.Duration / dt))

    if k < 0 or k >= duration_steps:
        return 0.0

    pulse_width_steps = int(round(params.width / dt))
    pulse_period_steps = int(round((1.0 / params.freq) / dt))
    burst_period_steps = int(round((1.0 / params.oscillation_freq) / dt))

    if getattr(params, 'off', 0.0) == 0:
        k_in_on = k
    else:
        on_steps = int(round(params.on / dt))
        cycle_steps = int(round((params.on + params.off) / dt))
        k_cycle = k % cycle_steps
        if k_cycle >= on_steps:
            return 0.0
        k_in_on = k_cycle

    k_in_burst = k_in_on % burst_period_steps
    pulse_idx = k_in_burst // pulse_period_steps
    k_in_pulse = k_in_burst - pulse_idx * pulse_period_steps

    if pulse_idx < params.bursts and k_in_pulse < pulse_width_steps:
        return float(params.amp)

    return 0.0
