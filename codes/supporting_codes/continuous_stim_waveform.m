function phi_x = continuous_stim_waveform(step, params)
% continuous_stim_waveform
%   Sinusoidal carrier that is ON only during a "pulse window" repeated at PRF.
%
% Time conventions:
%   step is 0-based (same as TMS(step-1,...))
%   t = step * params.deltat
%
% Required fields (recommended under params.stim.cont):
%   params.stim.cont.prf_hz                 % pulse repetition frequency
%   params.stim.cont.pulse_duration_s       % pulse ON duration each PRF period
%   params.stim.cont.sin_freq_hz            % sinusoidal frequency inside pulse
%   params.stim.cont.amp                    % sinusoidal amplitude
%   params.stim.cont.mean                   % DC mean added during pulse
%   params.stim.cont.phase_rad              % optional, default 0
%
% Returns:
%   scalar phi_x

    dt = params.deltat;
    t  = step * dt;

    c = params.stim.cont;

    % Off before onset or after total duration
    if t < params.onset || t >= (params.onset + params.Duration)
        phi_x = 0;
        return;
    end

    % PRF period and time within current PRF cycle
    Tprf = 1 / c.prf_hz;
    tau  = t - params.onset;
    tau_in_period = tau - floor(tau / Tprf) * Tprf;  % modulo without mod() fp quirks

    % Gate: ON only within pulse_duration
    if tau_in_period >= c.pulse_duration_s
        phi_x = 0;
        return;
    end

    % Sinusoid during ON window
    if ~isfield(c,'phase_rad'), c.phase_rad = 0; end
    phi_x = c.mean + c.amp * sin(2*pi*c.sin_freq_hz * tau + c.phase_rad);
end
