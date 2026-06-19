function phi_x = stim_waveform(step, params)
% stim waveform generator.
% Default: legacy burst/pulse iTBS/cTBS logic (your existing implementation).
% Optional: continuous sinusoidal pulse-train when params.stim.mode = 'continuous'.

    % Convert step index to time 
    t = (step-1) * params.deltat;

    % -------------------------------
    % NEW: continuous mode (early return)
    % -------------------------------
    if isfield(params,'stim') && isfield(params.stim,'mode') ...
            && strcmpi(params.stim.mode,'continuous')

        % Use dedicated helper. This must return a SCALAR.
        phi_x = continuous_stim_waveform(step, params);

        % IMPORTANT: return now so legacy burst logic cannot overwrite it
        return;
    end

    % -------------------------------
    % Legacy burst/pulse mode (UNCHANGED)
    % -------------------------------

    if strcmp(params.stim_mode, 'intermittent')

        dt = params.deltat;
        t  = (step - 1) * dt;

        if t < params.onset
            phi_x = 0;
            return;
        end

        % Integer sample index since onset
        k = round((t - params.onset) / dt);

        duration_steps = round(params.Duration / dt);

        % Use [onset, onset + Duration), excluding endpoint
        if k < 0 || k >= duration_steps
            phi_x = 0;
            return;
        end

        pulse_width_steps  = round(params.width / dt);
        pulse_period_steps = round((1 / params.freq) / dt);
        burst_period_steps = round((1 / params.oscillation_freq) / dt);

        if params.off == 0
            k_in_on = k;
        else
            on_steps    = round(params.on / dt);
            cycle_steps = round((params.on + params.off) / dt);

            k_cycle = mod(k, cycle_steps);

            if k_cycle >= on_steps
                phi_x = 0;
                return;
            end

            k_in_on = k_cycle;
        end

        k_in_burst = mod(k_in_on, burst_period_steps);

        pulse_idx  = floor(k_in_burst / pulse_period_steps);
        k_in_pulse = k_in_burst - pulse_idx * pulse_period_steps;

        if pulse_idx < params.bursts && k_in_pulse < pulse_width_steps
            phi_x = params.amp;
        else
            phi_x = 0;
        end

        return;
    end

    error('Unknown params.stim_mode: %s', params.stim_mode);
end