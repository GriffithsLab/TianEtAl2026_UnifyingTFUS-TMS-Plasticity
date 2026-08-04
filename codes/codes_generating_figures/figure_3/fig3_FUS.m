% duration = 40; cTB_TFUS_40s
% duration = 80; cTB_TFUS_80s


function [nu_ee, nutil_ee, Ca_ee,pct_change_nu_ee] = fig3_FUS(duration)


    %% --- Grid and time ---
    Nx = 1; Ny = 1;      % single node of Nx=Ny=1
    T = 350 + duration;             % 600; simulation time [s]
    deltat = 1e-4;
    params.deltat = deltat;
    boundary = 'torus';  % boundary form of wave grids (not active if Nx=Ny=1)
    %nu_unit = 1e-3; % 1e-3: change unit of nu (coupling strengths) from mV*s
    %to uV*s (used in Fung papers)

    nu_unit = 1; % "nu_unit=1" means that the unit of nu (coupling strengths) is mV*s,
    % which is consistent with Wilson papers

    % warm-up duration and steps
    % (warm-up is needed to exclude the initial artifact in voltage simulation)

    T_warmup    = 5;                         % seconds of voltage warm-up
    nsteps_warm = round(T_warmup/deltat);    % number of warm-up steps
    T = T - T_warmup; % sim time after warm-up
    nsteps = round(T/deltat);
    %

    %% --- Wave constants ---
    L = 0.5;
    longside = max(Nx,Ny);
    deltax = L / longside;
    range = 0.086; gamma = 116;
    params.range = range; params.gamma = gamma;

    dt2on12 = (deltat^2)/12;
    dfact = dt2on12 * gamma^2;
    dt2ondx2 = (deltat^2)/(deltax^2);
    p2 = dt2ondx2 * (range^2) * gamma^2;
    params.dfact = dfact;
    params.p2 = p2;
    params.tenminus4p2 = 10 - 4*p2;
    params.twominus4p2 = 2 - 4*p2;
    params.expfactneg = exp(-deltat*gamma);
    params.expfactpos = exp( deltat*gamma);

    %% --- neural params ---
    params.alpha = 83.333333;
    params.beta  = 769.230769;
    params.Lambda = 150e-6;
    params.tGlu = 30e-3;
    params.tCa = 50e-3;
    params.t_BCM = 7;
    params.t_rec = 1000;
    params.glu_0 = 200e-6;
    params.gnmda_0 = 2e-3;
    params.B_0 = 30e3;
    params.z = 0.01;
    params.sig = @sig;
    params.Q_max = 340;
    params.theta = 13e-3;
    params.sigma = 3.8e-3;
    params.V_r = 195e-3;
    params.Mg0 = 45.5e-3;
    params.H0  = 62;

    %% --- Plasticity thresholds; omega function in CaDP ---

    % params.dth = 0.25e-6; %o
    % params.pth = 0.45e-6; %o

    % params.dth = 0.1e-6; %
    % params.pth = 0.2e-6; %

    params.dth = 0.2e-6; % 26 Jan 2 2
    params.pth = 0.336e-6; % 26 Jan 2 2

    params.xth = 1e-4;
    % params.yth = params.xth * (params.nu_max_yth-params.nu_yth)/params.nu_yth;
    % Don't use the above line; yth will be updated per-dendrite in model_equations
    %
    % params.ltp = 2.3e-2; % x1 in Fung 2013
    % params.ltd = 2e-2; % used in Fung

    % params.ltp = 1e-2; %
    % params.ltd = 5e-2; %

    params.ltp = 1e-2; %
    params.ltd = 5e-2; %


    params.x2 = 4e7;
    params.y2 = 4e7;


    %% --- Connectivity ---
    % ***CAVEAT***:
    % 1. set conn_scale(i,j) = 0 if there is no dendrite connection i←j
    %    and keep nu_0_mx(i,j)&nu_max_mx(i,j) at default (which is multiplied by 0 as a placeholder, so is not effective)
    % 2. nftsim sets conn_scale(i,j) = 1 if there is dendrite connection i←j
    %    and the specification of strength ("nu" for each dendrite ("Coupling")) is through nu_0_mx(i,j)

    Npop = 4;
    params.conn_scale = zeros(Npop,Npop);
    % conn_scale(i,j) is the scaling of conn strength i←j

    % params.conn_scale(1,1) = 1; % Fung

    % % Sorenza's para - Robinson model
    % params.conn_scale(1,1) = 3.03; % e←e
    % params.conn_scale(1,2) = -6; % e←i
    % params.conn_scale(1,3) = 2.06; % e←s
    % params.conn_scale(1,4) = 0; % e←r
    % params.conn_scale(2,1) = 3.03; % i←e
    % params.conn_scale(2,2) = -6; % i←i
    % params.conn_scale(2,3) = 2.06; % i←s
    % params.conn_scale(2,4) = 0; % i←r
    % params.conn_scale(3,1) = 2.18; % s←e
    % params.conn_scale(3,2) = 0; % s←i
    % params.conn_scale(3,3) = 0; % s←s
    % params.conn_scale(3,4) = -0.83; % s←r
    % params.conn_scale(4,1) = 0.33; % r←e
    % params.conn_scale(4,2) = 0; % r←i
    % params.conn_scale(4,3) = 0.03; % r←s
    % params.conn_scale(4,4) = 0; % r←r

    % % general conn structure
    params.conn_scale(1,1) = 1; % e←e
    params.conn_scale(1,2) = 1; % e←i
    params.conn_scale(1,3) = 1; % e←s
    params.conn_scale(1,4) = 0; % e←r
    params.conn_scale(2,1) = 1; % i←e
    params.conn_scale(2,2) = 1; % i←i
    params.conn_scale(2,3) = 1; % i←s
    params.conn_scale(2,4) = 0; % i←r
    params.conn_scale(3,1) = 1; % s←e
    params.conn_scale(3,2) = 0; % s←i
    params.conn_scale(3,3) = 0; % s←s
    params.conn_scale(3,4) = 1; % s←r
    params.conn_scale(4,1) = 1; % r←e
    params.conn_scale(4,2) = 0; % r←i
    params.conn_scale(4,3) = 1; % r←s
    params.conn_scale(4,4) = 0; % r←r

    % params.conn_scale = params.conn_scale.*nu_unit;


    % NOTE ON DECOUPLED DENDRITES:
    % nu_0_mx(i,j) (or nu_max_mx(i,j)) will only be effective
    % if the corresponding conn_scale(i,j) is non-zero, i.e., the dendrite exists.
    % Thus, no need to change them from default if conn_scale(i,j)=0

    default_nu = 13e-6;
    params.nu_0_mx = default_nu*ones(Npop,Npop);

    % Fung
    % params.nu_0_mx(1,2) = -default_nu; % e←i
    % params.nu_0_mx(2,2) = -default_nu; % i←i
    % params.nu_0_mx(3,4) = -default_nu; % s←r

    % Kevin
    params.nu_0_mx(1,1) = 0.001200; % e←e
    params.nu_0_mx(1,2) = -0.009839; % e←i
    params.nu_0_mx(1,3) = 0.009732; % e←s
    params.nu_0_mx(2,1) = 0.001532; % i←e
    params.nu_0_mx(2,2) = -0.009639; % i←i
    params.nu_0_mx(2,3) = 0.009732; % i←s
    params.nu_0_mx(3,1) = 0.001135; % s←e
    params.nu_0_mx(3,4) = -0.001222; % s←r
    params.nu_0_mx(4,1) = 0.000143; % r←e
    params.nu_0_mx(4,3) = 0.000058; % r←s

    params.nu_0_mx = params.nu_0_mx.*nu_unit;

    default_nu_max = 80e-6;
    params.nu_max_mx  = default_nu_max*ones(Npop,Npop);

    % Fung
    % params.nu_max_mx(1,2) = -default_nu_max; % e←i
    % params.nu_max_mx(2,2) = -default_nu_max; % i←i
    % params.nu_max_mx(3,4) = -default_nu_max; % s←r

    % Kevin
    params.nu_max_mx(1,1) = 1e-2; % e←e
    params.nu_max_mx(1,2) = -1e-1; % e←i
    params.nu_max_mx(1,3) = 1e-1; % e←s
    params.nu_max_mx(2,1) = 1e-2; % i←e
    params.nu_max_mx(2,2) = -1e-1; % i←i
    params.nu_max_mx(2,3) = 1e-1; % i←s
    params.nu_max_mx(3,1) = 1e-2; % s←e
    params.nu_max_mx(3,4) = -1e-2; % s←r
    params.nu_max_mx(4,1) = 1e-2; % r←e
    params.nu_max_mx(4,3) = 1e-2; % r←s

    params.nu_max_mx = params.nu_max_mx.*nu_unit;

    %% --- Per-pop Q_ini (initial firing rates) ---
    Q_ini_vec = zeros(Npop,1);
    Q_ini_vec(1) = 6.985843; % e
    Q_ini_vec(2) = 6.985843; % i
    Q_ini_vec(3) = 5.638257; % s
    Q_ini_vec(4) = 15.346630; % r


    %% --- Axonal delays Tau(i,j) ---
    % axonal transduction delays may be considered for corticothalamic connections

    params.Tau = zeros(Npop,Npop); % no delay
    % params.Tau_sec(1,3) = 0.0425;  % e←s
    % params.Tau_sec(2,3) = 0.0425;  % i←s
    % params.Tau_sec(3,1) = 0.0425;  % s←e
    % params.Tau_sec(4,1) = 0.0425;  % r←e

    params.Tau_steps = round(params.Tau / deltat); % time steps
    max_tau = max(params.Tau_steps,[],'all'); if isempty(max_tau), max_tau=0; end


    %% --- External Stim (directly impact pop 1 (cortical excitatory)) ---

    %  choose waveform mode ----
    params.stim.mode = 'continuous';   % 'burst' (default) or 'continuous'

    params.TMS_scale_x = 1;

    params.nu_x = 0.008222; %Kevin

    params.onset = 50; %stim starting time
    params.Duration = duration; %total stim time


    % % ---- bursts: intermittent (classical) pulse-train config ----

    % params.amp = 5;
    % params.width = 0.5e-3;
    %
    % params.bursts = 3; params.freq = 50; params.oscillation_freq = 5;
    % params.on = 2; params.off = 0;
    %
    % params.width = 1/params.freq; % this will fill the gap between pulses, and make the stimuli "continuous"!


    % ---- Continuous sinusoidal pulse-train config ----
    params.stim.cont.prf_hz           = 5;       % PRF: 5 Hz
    duty_cycle = 0.1;
    params.stim.cont.pulse_duration_s = duty_cycle*(1/params.stim.cont.prf_hz);   % pulse window

    params.stim.cont.sin_freq_hz      = 500;      % sinusoid frequency inside pulse;
                               % (max=2500 if dt=1e-4: 5 sampling points for one cycle)

    %params.stim.cont.mean             = 3*sqrt(5)*sqrt((20e-3)/(params.stim.cont.pulse_duration_s));       % DC mean during pulse
                                                  % equiv value in energy (if
                                                  % amp=mean), compared with
                                                  % cTBS-TMS(3,5)(amp=30)  with pulse
                                                  % with = 0.5ms
    
    r_a_m = 0.3; % the ratio "osci amp"/"osci mean"



    % TMS paras based on which the FUS paras are computed for equivalent energy
    amp_TMS = 40; % 26 Jan 2
    n_TMS = 3; % number of pulses in one TMS burst
    p_TMS = 0.5e-3; %s, TMS pulse width

    params.stim.cont.mean             = amp_TMS*sqrt((2*n_TMS*p_TMS)/((params.stim.cont.pulse_duration_s)*(2+r_a_m^2))); % DC mean during pulse
    
    %params.stim.cont.mean             = mean_vec(jj);   % cTBS(3,5) with pulse_width=0.5ms  

    params.stim.cont.amp              = r_a_m*params.stim.cont.mean;       % oscillatory amp ("=0" means constant)     
    %params.stim.cont.amp              = 0;
    params.stim.cont.phase_rad        = 0;


    %% --- White-noise (added to one pop), optional ---
    params.noise.enabled  = true;
    %params.noise.enabled  = false;
    params.noise.target_i = 3;
    params.noise.mean     = 0.48;%
    params.noise.asd      = 5e-3;
    params.noise.ranseed  = 0;
    params.noise_scale    = 1; %
    %params.nu_noise       = 0.008222*nu_unit;
    params.nu_noise       = 0.008222;

    %% --- Output interval ---
    output_interval = 1e-3;
    output_interval_steps = round(output_interval/deltat);
    nsteps_out = floor(nsteps/output_interval_steps);
    tvec_out   = (0:nsteps_out-1)*output_interval;

    %% --- State vector layout (per node) ---
    % Per dendrite i<-j: [V, W, nutil, nu, dnudt, gNMDA, Ca] (7 states)
    N_bs    = 7; Ndend = Npop*Npop*N_bs;
    NTMS  = 2;  % (Vx,Wx)
    NNOI  = 2;  % (Vw,Ww)
    Nglu  = Npop;
    Nstate= Ndend + NTMS + NNOI + Nglu;

    % Full grid state
    Y = zeros(Nstate, Ny, Nx);

    % initial conditions
    for i = 1:Npop
        for j = 1:Npop
            idx0 = ((i-1)*Npop + (j-1))*7;
            Y(idx0+1,:,:) = 0;                   % V_ij
            Y(idx0+2,:,:) = 0;                   % W_ij
            Y(idx0+3,:,:) = params.nu_0_mx(i,j);  % nutil_ij
            Y(idx0+4,:,:) = params.nu_0_mx(i,j);  % nu_ij
            Y(idx0+5,:,:) = 0;                   % dnudt_ij
            Y(idx0+6,:,:) = params.gnmda_0;      % gNMDA_ij
            Y(idx0+7,:,:) = 0.01e-6;             % Ca_ij
        end
    end
    Y(Ndend+1:Ndend+2,:,:) = 0;                 % TMS dendrite
    Y(Ndend+NTMS+1:Ndend+NTMS+2,:,:) = 0;                 % noise dendrite

    for i = 1:Npop, Y(Ndend+NTMS+NNOI+i,:,:) = params.glu_0; end

    % save a clean baseline copy of all states (to restore after warm-up)
    Y_baseline = Y;
    %


    %% --- φ_ij (grid) and Q histories (grid, per pop) ---
    % φ_ij, φ_ij_old: (i,j,Ny,Nx)
    phi_ij     = repmat(reshape(Q_ini_vec,[Npop,1,1,1]), [1,Npop,Ny,Nx]); % seed
    phi_ij_old = phi_ij;

    % Q, Q_hist: (pop, Ny, Nx [, history])
    Q = repmat(reshape(Q_ini_vec,[Npop,1,1]), [1,Ny,Nx]);
    Q_old = Q;
    Q_hist_len = max_tau + 3;
    Q_hist = repmat(Q, [1,1,1,Q_hist_len]);  % 4 x Ny x Nx x H
    q_head = 1;

    %% --- φ_ij (grid) and Q histories (grid, per pop) ---
    % φ_ij, φ_ij_old: (i,j,Ny,Nx)
    phi_ij     = repmat(reshape(Q_ini_vec,[Npop,1,1,1]), [1,Npop,Ny,Nx]); % seed
    phi_ij_old = phi_ij;

    % Q, Q_hist: (pop, Ny, Nx [, history])
    Q = repmat(reshape(Q_ini_vec,[Npop,1,1]), [1,Ny,Nx]);
    Q_old = Q;
    Q_hist_len = max_tau + 3;
    Q_hist = repmat(Q, [1,1,1,Q_hist_len]);  % 4 x Ny x Nx x H
    q_head = 1;

    %%% warm-up loop to settle voltages
    phi_ij_warm     = phi_ij;
    phi_ij_old_warm = phi_ij_old;
    Q_warm          = Q;
    Q_old_warm      = Q_old;
    Q_hist_warm     = Q_hist;
    q_head_warm     = q_head;
    Y_warm          = Y;

    % noise axonal damping setup (nftsim)
    Q_noise      = 0;        % initial noise "firing"
    Q_noise_old  = Q_noise;
    phi_noise    = 0;        % propagated noise field
    phi_noise_old= phi_noise;

    % for i = 1:Npop
    %     for j = 1:Npop
    %         idx0 = ((i-1)*Npop + (j-1))*7;
    %         % remove unit of nu for warm-up (nftsim)
    %         Y_warm(idx0+3,:,:) = params.nu_0_mx(i,j);  % nutil_ij
    %         Y_warm(idx0+4,:,:) = params.nu_0_mx(i,j);  % nu_ij
    %     end
    % end


    for step = 1:nsteps_warm

        % delayed Q field (Tau)
        prepopQ_field = zeros(Npop,Npop,Ny,Nx);
        for i = 1:Npop
            for j = 1:Npop
                delay_steps = round(params.Tau(i,j)/deltat);
                idx_delay   = mod(q_head_warm - delay_steps - 1, Q_hist_len) + 1;
                prepopQ_field(i,j,:,:) = Q_hist_warm(j,:,:,idx_delay);
            end
        end

        % propagate φ_ij (harmonic if single node, otherwise wave)
        phi_ij_next = phi_ij_warm;
        if Ny*Nx == 1
            for i = 1:Npop
                for j = 1:Npop
                    m = params.Tau_steps(i,j);

                    read_idx = q_head_warm - 1 - m;
                    while read_idx < 1, read_idx = read_idx + Q_hist_len; end
                    Qdel = Q_hist_warm(j,1,1,read_idx);

                    read_idx_old = read_idx - 1;
                    while read_idx_old < 1, read_idx_old = read_idx_old + Q_hist_len; end
                    Qdel_old = Q_hist_warm(j,1,1,read_idx_old);

                    phi_ij_next(i,j,1,1) = harmonic_step_scalar( ...
                        phi_ij_warm(i,j,1,1), phi_ij_old_warm(i,j,1,1), ...
                        Qdel, Qdel_old, params);
                end
            end
        else
            for i = 1:Npop
                for j = 1:Npop
                    p      = squeeze(phi_ij_warm(i,j,:,:));
                    p_old  = squeeze(phi_ij_old_warm(i,j,:,:));
                    Qcur   = squeeze(Q_warm(j,:,:));
                    Qprev  = squeeze(Q_old_warm(j,:,:));
                    preQ   = squeeze(prepopQ_field(i,j,:,:));
                    p_next = wave_step_grid(p, p_old, Qcur, Qprev, preQ, params, boundary);
                    phi_ij_next(i,j,:,:) = p_next;
                end
            end
        end
        phi_ij_old_warm = phi_ij_warm;
        phi_ij_warm     = phi_ij_next;

        % --- Noise axonal damping (NFTsim-style) ---
        % Generate a new noise "firing rate" sample
        if params.noise.enabled
            Q_noise_new = white_stim_nftsim(step-1, params);
        else
            Q_noise_new = 0;
        end

        % Propagate it with same harmonic scheme used for φ (Nodes=1)
        phi_noise_next = harmonic_step_scalar( ...
            phi_noise, ...       % current filtered noise
            phi_noise_old, ...   % previous
            Q_noise_new, ...     % new noise firing
            Q_noise_old, ...     % previous noise firing
            params );

        % Shift for next iteration
        phi_noise_old = phi_noise;
        phi_noise     = phi_noise_next;
        Q_noise_old   = Q_noise;
        Q_noise       = Q_noise_new;

        % Inject filtered noise into dendrite during warm-up
        noise_x = phi_noise;



        % stimuli: use absolute time from 0 (TMS will be 0 before onset)
        abs_step = step - 1;
        phi_x   = stim_waveform(abs_step, params);
        %noise_x = params.noise.enabled * white_stim_new(abs_step, params);
        %noise_x = params.noise.enabled * white_stim_nftsim(abs_step, params);

        % if params.noise.enabled
        %     noise_x = white_stim_nftsim(abs_step, params);
        % else
        %     noise_x = 0;
        % end
        %

        % integrate each node with full RHS
        for iy = 1:Ny
            for ix = 1:Nx
                y_node      = Y_warm(:,iy,ix);
                phi_node    = squeeze(phi_ij_warm(:,:,iy,ix));
                node_params = params;
                node_params.phi_ij = phi_node;
                y_new = rk4_step(@(y) model_equations(y, phi_x, noise_x, node_params), y_node, deltat);
                Y_warm(:,iy,ix) = y_new;
            end
        end

        % recompute Q from soma voltages
        for iPop = 1:Npop
            V_i = zeros(Ny,Nx);
            for jPop = 1:Npop
                idx0 = ((iPop-1)*Npop + (jPop-1))*N_bs;
                V_i = V_i + squeeze(Y_warm(idx0+1,:,:));
            end
            if iPop == 1
                V_i = V_i + squeeze(Y_warm(Ndend+1,:,:));  % TMS dendrite
            end
            if params.noise.enabled && iPop == params.noise.target_i
                V_i = V_i + squeeze(Y_warm(Ndend+NTMS+1,:,:)); % noise dendrite
            end
            Q_warm(iPop,:,:) = fire(V_i, params);
        end

        % update warm-up history
        Q_hist_warm(:,:,:,q_head_warm) = Q_warm;
        q_head_warm = q_head_warm + 1;
        if q_head_warm > Q_hist_len, q_head_warm = 1; end
        Q_old_warm = Q_warm;
    end

    % ---- after warm-up: keep only V/W from Y_warm, reset slow vars to baseline ----
    Y_after_warm = Y_warm;   % has fully evolved state after warm-up
    Y            = Y_baseline;  % reset everything

    % copy V_ij, W_ij from warm-up, keep nutil/nu/dnudt/gNMDA/Ca from baseline
    for iPop = 1:Npop
        for jPop = 1:Npop
            idx0 = ((iPop-1)*Npop + (jPop-1))*N_bs;
            Y(idx0+1,:,:) = Y_after_warm(idx0+1,:,:);  % V_ij
            Y(idx0+2,:,:) = Y_after_warm(idx0+2,:,:);  % W_ij
        end
    end

    % TMS dendrite Vx,Wx from warm-up
    Y(Ndend+1:Ndend+2,:,:) = Y_after_warm(Ndend+1:Ndend+2,:,:);

    % noise dendrite Vw,Ww from warm-up (even if disabled, this is harmless)
    Y(Ndend+NTMS+1:Ndend+NTMS+2,:,:) = Y_after_warm(Ndend+NTMS+1:Ndend+NTMS+2,:,:);

    % glutamate states: stay at baseline (already in Y_baseline)

    % carry over φ/Q state and history so Tau works correctly
    phi_ij     = phi_ij_warm;
    phi_ij_old = phi_ij_old_warm;
    Q          = Q_warm;
    Q_old      = Q_old_warm;
    Q_hist     = Q_hist_warm;
    q_head     = q_head_warm;
    %%% >>> END warm-up



    %% --- Outputs ---
    Yout      = zeros(Nstate, Ny, Nx, nsteps_out);
    Qout      = zeros(Npop, Ny, Nx, nsteps_out);
    phi_x_out = zeros(nsteps_out,1);   % (scalar pattern; broadcast per node)

    %% --- Main loop ---

    % noise axonal damping setup (nftsim)
    Q_noise      = 0;        % initial noise "firing"
    Q_noise_old  = Q_noise;
    phi_noise    = 0;        % propagated noise field
    phi_noise_old= phi_noise;

    out_idx = 1;
    for step = 1:nsteps

        prepopQ_field = zeros(Npop,Npop,Ny,Nx);
        for i = 1:Npop
            for j = 1:Npop
                delay_steps = round(params.Tau(i,j)/deltat);
                idx_delay   = mod(q_head - delay_steps - 1, Q_hist_len) + 1;  % 1..H
                prepopQ_field(i,j,:,:) = Q_hist(j,:,:,idx_delay);             % delayed Q_j
            end
        end

        % ---- Build φ_ij at grid with delays (Tau) ----
        phi_ij_next = phi_ij;  % preallocate
        if Ny*Nx == 1
            % single-node: harmonic per (i,j)
            for i=1:Npop
                for j=1:Npop
                    m = params.Tau_steps(i,j);

                    % delayed Q
                    read_idx = q_head - 1 - m;
                    while read_idx < 1, read_idx = read_idx + Q_hist_len; end
                    Qdel = Q_hist(j,1,1,read_idx);

                    read_idx_old = read_idx - 1;
                    while read_idx_old < 1, read_idx_old = read_idx_old + Q_hist_len; end
                    Qdel_old = Q_hist(j,1,1,read_idx_old);

                    phi_ij_next(i,j,1,1) = harmonic_step_scalar( ...
                        phi_ij(i,j,1,1), phi_ij_old(i,j,1,1), Qdel, Qdel_old, params);
                end
            end
        else
            % grid: full 2-D wave per (i,j)
            for i = 1:Npop
                for j = 1:Npop
                    % Slice fields for this (i←j) connection
                    p      = squeeze(phi_ij(i,j,:,:));
                    p_old  = squeeze(phi_ij_old(i,j,:,:));
                    Qcur   = squeeze(Q(j,:,:));        % current firing rates
                    Qprev  = squeeze(Q_old(j,:,:));    % previous firing rates
                    preQ   = squeeze(prepopQ_field(i,j,:,:));%

                    % Compute next φ on the grid
                    p_next = wave_step_grid(p, p_old, Qcur, Qprev, preQ, params, boundary);
                    % p_next = wave_step_grid_alternate(p, p_old, Qcur, Qprev, preQ, params, 'torus');

                    % Write back
                    phi_ij_next(i,j,:,:) = p_next;
                end
            end
        end
        phi_ij_old = phi_ij;
        phi_ij     = phi_ij_next;

        % ---- Stimuli (scalars, applied identically to all nodes) ----
        abs_step = (step-1) + nsteps_warm;
        phi_x   = stim_waveform(abs_step, params);

        % noise axonal damping setup (nftsim)
        if params.noise.enabled
            Q_noise_new = white_stim_nftsim(step-1, params);  % mean/asd as in config
        else
            Q_noise_new = 0;
        end

        % Propagate it with the same harmonic scheme (Nodes=1 case)
        phi_noise_next = harmonic_step_scalar(phi_noise, phi_noise_old, ...
            Q_noise_new, Q_noise_old, params);

        % Shift noise histories
        phi_noise_old = phi_noise;
        phi_noise     = phi_noise_next;
        Q_noise_old   = Q_noise;
        Q_noise       = Q_noise_new;

        % pass into the noise dendrite
        noise_x = phi_noise;

        %noise_x = params.noise.enabled * white_stim_nftsim(abs_step, params);

        % ---- Integrate each node independently ----
        for iy=1:Ny
            for ix=1:Nx
                y_node = Y(:,iy,ix);

                % build node-local φ_ij (Npop x Npop) for RHS
                phi_node = squeeze(phi_ij(:,:,iy,ix));

                % pass φ_ij via a node-local params copy (minimal change)
                node_params = params;
                node_params.phi_ij = phi_node;
                y_new = rk4_step(@(y) model_equations(y, phi_x, noise_x, node_params), y_node, deltat);
                Y(:,iy,ix) = y_new;
            end
        end

        % ---------- recompute Q from soma voltages (per population) ----------
        for iPop = 1:Npop
            V_i = zeros(Ny,Nx);
            % sum dendritic voltages V_ij
            for jPop = 1:Npop
                idx0 = ((iPop-1)*Npop + (jPop-1))*N_bs;
                V_i = V_i + squeeze(Y(idx0+1,:,:));
            end
            % add direct TMS dendrite to pop 1
            if iPop == 1
                V_i = V_i + squeeze(Y(Ndend+1,:,:));  % Vx
            end

            if params.noise.enabled
                if iPop == params.noise.target_i
                    V_i = V_i + squeeze(Y(Ndend+NTMS+1,:,:));
                end
            end
            Q(iPop,:,:) = fire(V_i, params);
        end


        % ---- Save (downsampled) ----
        if mod(step, output_interval_steps)==0
            Yout(:,:,:,out_idx) = Y;
            Qout(:,:,:,out_idx) = Q;
            phi_x_out(out_idx)  = phi_x;
            out_idx = out_idx + 1;
        end

        % ---- Push Q into ring buffer (per node) ----
        Q_hist(:,:,:,q_head) = Q;
        q_head = q_head + 1; if q_head > Q_hist_len, q_head = 1; end
        Q_old = Q; % Keep Q_old for next propagation (previous step’s Q)
    end

    %% results & plots

    % % per-population

    tplot = tvec_out + T_warmup; % warm-up period has no signal
    V_e   = plot_results(Yout, Qout, tplot, params, 1);

    %V_e = plot_results(Yout, Qout, tplot, params, 1); % cortical excitatory

    % plot_results(Yout, Qout, tplot, params, 2); % cortical inhibitory
    % plot_results(Yout, Qout, tplot, params, 3); % thalamic relay nuclei
    % plot_results(Yout, Qout, tplot, params, 4); % thalamic reticular nuclei

    % % per-dendrite

    % plot_results_j_to_i(Yout, Qout, tvec_out, params,i,j) : result for each
    % dendrite projecting from populaiton j to population i

    [nu_ee, nutil_ee, Ca_ee] = plot_results_j_to_i(Yout, Qout, tplot, params,1,1);

    % plot_results_j_to_i(Yout, Qout, tplot, params, 3, 1);  % thalamic relay (3) receiving from cortex (1)
    % plot_results_j_to_i(Yout, Qout, tplot, params, 2, 1);  % ctx inhibitory receiving from ctx excitatory

    % % nu_ee change post TMS/FUS
    nu_ee_last = nu_ee(length(nu_ee)-10/output_interval:length(nu_ee)); % last 10s
    mean_nu_ee_last = mean(nu_ee_last); % mean nu_ee in the last 10s
    pct_change_nu_ee = (mean_nu_ee_last - params.nu_0_mx(1,1))/params.nu_0_mx(1,1); % ratio of change compared with ini

    %pct_change_nu_ee_vec(jj) = pct_change_nu_ee;

    
    % plot

    t_axis =  (output_interval*(1:length(nu_ee)) -  output_interval)+T_warmup;
    
    figure;
    
    % Left y-axis (first two signals)
    yyaxis left
    plot(t_axis, nu_ee, 'LineWidth', 1.5); hold on;
    plot(t_axis, nutil_ee, 'LineWidth', 1.5);
    ylabel('mM');
    
    % Right y-axis (third signal)
    yyaxis right
    plot(t_axis, Ca_ee, 'LineWidth', 1.5);
    ylabel('uM');

    
    xlabel('Time (s)');
    legend('nu_ee', 'nu_til_ee', 'Ca_ee');
    
    set(gca, 'FontSize', 12);
end



    % test stim waveform
%     Tplot = 1; %s, time from stim-ONSET
%     plotting_stim_waveform(params, Tplot)
