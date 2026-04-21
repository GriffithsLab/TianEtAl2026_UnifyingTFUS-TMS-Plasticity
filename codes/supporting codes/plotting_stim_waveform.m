function plotting_stim_waveform(params, Tplot)
% plotting_stim_waveform
%   Plot stimulus waveform where the x-axis starts at stim onset.
%
% Meaning:
%   Tplot is the duration (seconds) measured FROM params.onset.
%
% Example:
%   plotting_stim_waveform(params, 2.0)   % plots [onset, onset+2s]

    deltat = params.deltat;

    nsteps = round(Tplot / deltat);
    t_rel = (0:nsteps-1) * deltat;         % time since onset (for x-axis)
    t_abs = params.onset + t_rel;          % absolute simulation time

    s = zeros(1, nsteps);

    % Convert absolute time to step index consistent with stim_waveform:
    % stim_waveform uses: t = (step-1)*deltat
    % => step = round(t/dt) + 1
    for k = 1:nsteps
        step_abs = round(t_abs(k) / deltat) + 1;
        s(k) = stim_waveform(step_abs, params);
    end

    figure;
    plot(t_rel, s, 'LineWidth', 1.2);
    xlabel('Time since stim onset (s)');
    ylabel('\phi_x (stimulus)');
    title('Stimulus waveform (time shifted to onset)');
    grid on;

    % annotate duty if continuous
    if isfield(params,'stim') && isfield(params.stim,'mode') && strcmpi(params.stim.mode,'continuous')
        c = params.stim.cont;
        duty = c.pulse_duration_s * c.prf_hz * 100;
        subtitle(sprintf('Mode: continuous | PRF=%.3g Hz | pulse=%.3g ms | duty=%.2f%% | sin=%.3g Hz', ...
            c.prf_hz, c.pulse_duration_s*1e3, duty, c.sin_freq_hz));
    else
        subtitle('Mode: burst/pulse (existing)');
    end
end
