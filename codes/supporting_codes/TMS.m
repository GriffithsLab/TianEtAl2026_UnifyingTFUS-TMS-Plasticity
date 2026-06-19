function phi_x = TMS(step, params)
% TMS
%   Integer-index TMS waveform to avoid floating-point mod artifacts that 
    % cause different num of indices in pulses
%
%   step follows your existing convention:
%       t = (step - 1) * params.deltat

    dt = params.deltat;

    % Convert to absolute time, preserving your original convention
    t = (step - 1) * dt;

    % Before onset: no stimulation
    if t < params.onset
        phi_x = 0;
        return;
    end

    % Integer sample index since onset
    k = round((t - params.onset) / dt);

    % Duration in integer samples
    duration_steps = round(params.Duration / dt);

    % After stimulation duration: no stimulation
    if k < 0 || k >= duration_steps
        phi_x = 0;
        return;
    end

    % Convert waveform timing to integer samples
    pulse_width_steps  = round(params.width / dt);
    pulse_period_steps = round((1 / params.freq) / dt);
    burst_period_steps = round((1 / params.oscillation_freq) / dt);

    % Handle on/off cycling
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

    % Position inside current burst
    k_in_burst = mod(k_in_on, burst_period_steps);

    % Which pulse within burst?
    pulse_idx  = floor(k_in_burst / pulse_period_steps); % 0-based
    k_in_pulse = k_in_burst - pulse_idx * pulse_period_steps;

    % Deliver only params.bursts pulses per burst
    if pulse_idx < params.bursts && k_in_pulse < pulse_width_steps
        phi_x = params.amp;
    else
        phi_x = 0;
    end
end