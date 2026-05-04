function phi_x = TMS(step, params)

    % Convert step index to time
    t = (step-1) * params.deltat;

    % Stop entirely if beyond simulation Duration
    if t > (params.Duration+params.onset) || t<params.onset
        phi_x = 0;
        return;
    end

    % Determine cycle length
    cycle_len = params.on + params.off;

    % Handle special case: cTBS (off=0)
    if params.off == 0
        in_on_phase = true;  % always in "on" state
        t_in_cycle = t;      % just the running time
    else
        t_in_cycle = mod(t, cycle_len);
        in_on_phase = (t_in_cycle < params.on);
    end

    % Default: no stimulation
    phi_x = 0;

    if in_on_phase
        % Within burst cycle
        burst_period = 1 / params.oscillation_freq;   % seconds per burst
        pulse_period = 1 / params.freq;               % seconds between pulses
        burst_idx    = floor(t_in_cycle / burst_period);
        t_in_burst   = mod(t_in_cycle, burst_period);

        % Only deliver 'params.bursts' pulses per burst
        if t_in_burst < params.bursts * pulse_period
            pulse_idx   = floor(t_in_burst / pulse_period);
            pulse_start = pulse_idx * pulse_period;
            if (t_in_burst >= pulse_start) && (t_in_burst < pulse_start + params.width)
                %phi_x = params.amp * ones(Nnodes,1);
                phi_x = params.amp;
            end
        end
    end
end
