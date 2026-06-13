import numpy as np


def continuous_stim_waveform(step, params):
    """
    Python translation of continuous_stim_waveform.m.

    Sinusoidal carrier that is ON only during a pulse window repeated at PRF.

    Important MATLAB convention from continuous_stim_waveform.m:
        step is treated as 0-based, and t = step * params.deltat.

    Returns a scalar phi_x.
    """
    dt = params.deltat
    t = step * dt
    c = params.stim.cont

    # Off before onset or after total duration: [onset, onset + Duration)
    if t < params.onset or t >= (params.onset + params.Duration):
        return 0.0

    Tprf = 1.0 / c.prf_hz
    tau = t - params.onset

    # Same formula as MATLAB: tau - floor(tau/Tprf)*Tprf.
    # This avoids depending directly on np.mod near boundaries.
    tau_in_period = tau - np.floor(tau / Tprf) * Tprf

    if tau_in_period >= c.pulse_duration_s:
        return 0.0

    phase_rad = getattr(c, 'phase_rad', 0.0)
    phi_x = c.mean + c.amp * np.sin(2.0 * np.pi * c.sin_freq_hz * tau + phase_rad)
    return float(phi_x)
