

# ================== Import Helpers and Libraries ==================
import numpy as np
import pandas as pd 
from types import SimpleNamespace
from physiology import fire, model_equations
from integrators_func import rk4_step
from wave_func import wave_step_grid
from stim_waveform import stim_waveform
from wnoise_func import white_stim_nftsim, reset_white_stim_nftsim
from harmonic_step_func import harmonic_step_scalar
from plotting_func import plot_results, plot_results_j_to_i  
from scipy.io import savemat
import copy


# duration_vec = [20,60,100,120,140,160,180]

duration_vec = [40]
pct_change_nu_ee_vec_py = np.zeros(len(duration_vec))

for ii in range(0,len(duration_vec)):
    
    reset_white_stim_nftsim()
    
    # ================== Grid and time ==================
    # Single node of Nx=Ny=1 (Change depending on how many nodes needed)
    Nx = 1
    Ny = 1  
    
    # Simulation time [s] and steps
    T = 350 + duration_vec[ii]
    deltat = 1e-4
    
    # ================== Creation of Parameter Library ==================
    params = SimpleNamespace()
    params.deltat = deltat
    boundary = 'torus' # boundary form of wave grids (not active if Nx=Ny=1)
    
    nu_unit = 1.0     
    
    # --- Wave constants ---
    L = 0.5
    longside = max(Nx, Ny)
    deltax = L / longside
    range_ = 0.086
    gamma = 116.0
    params.range = range_
    params.gamma = gamma
    
    dt2on12   = (deltat**2) / 12.0
    dfact     = dt2on12 * gamma**2
    dt2ondx2  = (deltat**2) / (deltax**2)
    p2        = dt2ondx2 * (range_**2) * gamma**2
    params.dfact        = dfact
    params.p2           = p2
    params.tenminus4p2  = 10.0 - 4.0*p2
    params.twominus4p2  =  2.0 - 4.0*p2
    params.expfactneg   = np.exp(-deltat * gamma)
    params.expfactpos   = np.exp(+deltat * gamma)
    
    # --- neural params ---
    params.alpha  = 83.333333
    params.beta   = 769.230769
    params.Lambda = 150e-6
    params.tGlu   = 30e-3
    params.tCa    = 50e-3
    params.t_BCM  = 7.0
    params.t_rec  = 1000.0
    params.glu_0  = 200e-6
    params.gnmda_0= 2e-3
    params.B_0    = 30e3
    params.z      = 0.01
    params.Q_max  = 340.0
    params.theta  = 13e-3
    params.sigma  = 3.8e-3
    params.V_r    = 195e-3
    params.Mg0    = 45.5e-3
    params.H0     = 62.0
    
    # --- Plasticity thresholds; omega function in CaDP ---
    params.dth = 0.2e-6   
    params.pth = 0.336e-6   
    
    params.xth = 1e-4
    # NOTE: y_th is computed per-dendrite inside model_equations in this driver.
    
    params.ltp = 1e-2 # 
    params.ltd = 5e-2 
    
    params.x2 = 4e7
    params.y2 = 4e7
    
    # --- Connectivity ---
    # 1) Set conn_scale[i,j] = 0 if no dendrite j to i (nu_0_mx/nu_max_mx for that pair are irrelevant)
    # 2) In NFTsim, conn_scale(i,j)=1 flags connection existence. Actual strength is via nu_0_mx(i,j)
    Npop = 4
    params.conn_scale = np.zeros((Npop, Npop), dtype=float)
    
    # General connectivity structure (used by Kevin) and MATLAB 1-based and Python is 0-based.
    params.conn_scale[0,0] = 1  # e←e
    params.conn_scale[0,1] = 1  # e←i
    params.conn_scale[0,2] = 1  # e←s
    params.conn_scale[0,3] = 0  # e←r
    params.conn_scale[1,0] = 1  # i←e
    params.conn_scale[1,1] = 1  # i←i
    params.conn_scale[1,2] = 1  # i←s
    params.conn_scale[1,3] = 0  # i←r
    params.conn_scale[2,0] = 1  # s←e
    params.conn_scale[2,1] = 0  # s←i
    params.conn_scale[2,2] = 0  # s←s
    params.conn_scale[2,3] = 1  # s←r
    params.conn_scale[3,0] = 1  # r←e
    params.conn_scale[3,1] = 0  # r←i
    params.conn_scale[3,2] = 1  # r←s
    params.conn_scale[3,3] = 0  # r←r
    
    # Default nu_0 and overrides
    default_nu = 13e-6
    params.nu_0_mx = default_nu * np.ones((Npop, Npop), dtype=float)
    
    # Kevin overrides (remember to multiply by nu_unit)
    params.nu_0_mx[0,0] = 0.001200   # e←e
    params.nu_0_mx[0,1] = -0.009839  # e←i
    params.nu_0_mx[0,2] = 0.009732   # e←s
    params.nu_0_mx[1,0] = 0.001532   # i←e
    params.nu_0_mx[1,1] = -0.009639  # i←i
    params.nu_0_mx[1,2] = 0.009732   # i←s
    params.nu_0_mx[2,0] = 0.001135   # s←e
    params.nu_0_mx[2,3] = -0.001222  # s←r
    params.nu_0_mx[3,0] = 0.000143   # r←e
    params.nu_0_mx[3,2] = 0.000058   # r←s
    
    params.nu_0_mx = params.nu_0_mx * nu_unit  
    
    # Default nu_max and overrides
    default_nu_max = 80e-6
    params.nu_max_mx = default_nu_max * np.ones((Npop, Npop), dtype=float)
    
    # Kevin overrides (remember to multiply by nu_unit)
    params.nu_max_mx[0,0] = 1e-2   # e←e
    params.nu_max_mx[0,1] = -1e-1  # e←i
    params.nu_max_mx[0,2] = 1e-1   # e←s
    params.nu_max_mx[1,0] = 1e-2   # i←e
    params.nu_max_mx[1,1] = -1e-1  # i←i
    params.nu_max_mx[1,2] = 1e-1   # i←s
    params.nu_max_mx[2,0] = 1e-2   # s←e
    params.nu_max_mx[2,3] = -1e-2  # s←r
    params.nu_max_mx[3,0] = 1e-2   # r←e
    params.nu_max_mx[3,2] = 1e-2   # r←s
    
    params.nu_max_mx = params.nu_max_mx * nu_unit  
    
    # --- Per-pop Q_ini (initial firing rates) ---
    Q_ini_vec = np.zeros((Npop, 1), dtype=float)
    Q_ini_vec[0, 0] =  6.985843  # e
    Q_ini_vec[1, 0] =  6.985843  # i
    Q_ini_vec[2, 0] =  5.638257  # s
    Q_ini_vec[3, 0] = 15.346630  # r
    
    # --- Axonal delays Tau(i,j) ---
    # Note: MATLAB code sets Tau_sec, but computes Tau_steps from Tau (zeros).
    params.Tau      = np.zeros((Npop, Npop), dtype=float)
    params.Tau_sec  = np.zeros((Npop, Npop), dtype=float)
    params.Tau_sec[0,2] = 0.0425  # e←s
    params.Tau_sec[1,2] = 0.0425  # i←s
    params.Tau_sec[2,0] = 0.0425  # s←e
    params.Tau_sec[3,0] = 0.0425  # r←e
    
    params.Tau_steps = np.round(params.Tau / deltat).astype(int)  # time steps (zeros)
    max_tau = int(np.max(params.Tau_steps)) if params.Tau_steps.size else 0 
    
    # --- External Stim / FUS waveform setup (directly impacts pop 1, cortical excitatory) ---
    # This mirrors main_FUS.m: continuous sinusoidal pulse-train mode.
    params.stim = SimpleNamespace()
    params.stim.mode = 'continuous'   # 'continuous' or intermittent/burst mode
    
    params.TMS_scale_x = 1.0
    params.nu_x = 0.008222  # Kevin
    
    params.onset = 50.0     # stimulation starting time [s]
    params.Duration = duration_vec[ii]  # total stimulation time [s]
    
    # ---- Continuous sinusoidal pulse-train config ----
    params.stim.cont = SimpleNamespace()
    params.stim.cont.prf_hz = 20.0 # 5
    
    duty_cycle = 0.1
    params.stim.cont.pulse_duration_s = duty_cycle * (1.0 / params.stim.cont.prf_hz)
    
    params.stim.cont.sin_freq_hz = 500.0  # sinusoid frequency inside pulse
    
    r_a_m = 0.3  # ratio: oscillatory amplitude / DC mean
    
    # TMS parameters used to compute FUS parameters by equivalent energy
    amp_TMS = 40.0
    n_TMS = 3.0
    p_TMS = 0.5e-3
    
    params.stim.cont.mean = amp_TMS * np.sqrt(
        (2.0 * n_TMS * p_TMS)
        / (params.stim.cont.pulse_duration_s * (2.0 + r_a_m**2))
    )
    params.stim.cont.amp = r_a_m * params.stim.cont.mean
    params.stim.cont.phase_rad = 0.0
    
    # Optional intermittent/burst fields, used only if params.stim.mode is not 'continuous'.
    # These are included for compatibility with stim_waveform.py.
    params.amp = 40.0
    params.width = 0.5e-3
    params.bursts = 3
    params.freq = 50.0
    params.oscillation_freq = 5.0
    params.on = 2.0
    params.off = 0.0
    
    # ============================================= 
    
    # --- White-noise (added to one pop), optional ---
    params.noise = SimpleNamespace()
    params.noise.enabled  = True
    #params.noise.enabled = False # Comment the true statement and uncomment this if you want to switch OFF noise.
    
    params.noise.target_i = 3  # MATLAB 1-based → pop index 3; we’ll use 1-based in logic then convert
    params.noise.mean     = 0.48   
    params.noise.asd      = 5e-3   
    params.noise.ranseed  = 8
    params.noise_scale    = 1.0
    params.nu_noise       = 0.008222   # CHANGED: To match Kevin's conversion to mili units
    
    # ================== Warm-up configuration ==================
    # Reason: To exclude the initial blowup in the simulation. 
    # Simulate the original system for 5 seconds and take the initial condition to be at the 5 second. 
    # In the NFTsim they truncate the first 5 seconds. 
    T_warmup     = 5.0                            # Warm-up duration (s)
    nsteps_warm  = int(round(T_warmup / deltat))  # Warm-up steps
    T            = T - T_warmup                   # Main-sim time after warm-up
    nsteps       = int(round(T / deltat))         # Recompute steps for main phase
    
    phi_x_out_full = np.zeros((nsteps,), dtype=float)
    
    # --- Output interval ---
    output_interval       = 1e-3
    output_interval_steps = int(round(output_interval / deltat))
    nsteps_out            = int(np.floor(nsteps / output_interval_steps))
    tvec_out              = np.arange(nsteps_out, dtype=float) * output_interval
    tplot                 = tvec_out + T_warmup   # Shift time axis for plotting/results
    
    # --- State vector layout (per node) ---
    # Per dendrite i<-j: [V, W, nutil, nu, dnudt, gNMDA, Ca] (7 states)
    N_bs   = 7
    Ndend  = Npop * Npop * N_bs
    NTMS   = 2   # (Vx, Wx)
    NNOI   = 2   # (Vw, Ww)
    Nglu   = Npop
    Nstate = Ndend + NTMS + NNOI + Nglu
    
    # Full grid state
    Y = np.zeros((Nstate, Ny, Nx), dtype=float)
    
    # initial conditions
    for i in range(1, Npop + 1):
        for j in range(1, Npop + 1):
            idx0 = ((i - 1) * Npop + (j - 1)) * 7
            Y[idx0 + 0, :, :] = 0.0                             # V_ij
            Y[idx0 + 1, :, :] = 0.0                             # W_ij
            Y[idx0 + 2, :, :] = params.nu_0_mx[i-1, j-1]        # nutil_ij
            Y[idx0 + 3, :, :] = params.nu_0_mx[i-1, j-1]        # nu_ij
            Y[idx0 + 4, :, :] = 0.0                             # dnudt_ij
            Y[idx0 + 5, :, :] = params.gnmda_0                  # gNMDA_ij
            Y[idx0 + 6, :, :] = 0.01e-6                         # Ca_ij
    
    # Check on the + 0 here!
    Y[Ndend + 0:Ndend + 2, :, :] = 0.0                          # TMS dendrite (Vx, Wx) 
    Y[Ndend + NTMS + 0: Ndend + NTMS + 2, :, :] = 0.0           # noise dendrite (Vw, Ww)
    
    for i in range(1, Npop + 1):
        Y[Ndend + NTMS + NNOI + (i - 1), :, :] = params.glu_0   # per-pop glutamate
    
    # --- Keep a clean baseline copy of all states (to restore after warm-up) ---
    Y_baseline = Y.copy()   # Baseline snapshot
    
    # --- phi_ij (grid) and Q histories (grid, per pop) ---
    # phi_ij, phi_ij_old: shape (i, j, Ny, Nx)
    phi_ij     = np.tile(Q_ini_vec.reshape(Npop, 1, 1, 1), (1, Npop, Ny, Nx))  # seed with per-postsyn Q_ini
    phi_ij_old = phi_ij.copy()
    
    # Q, Q_hist: (pop, Ny, Nx [, history])
    Q      = np.tile(Q_ini_vec.reshape(Npop, 1, 1), (1, Ny, Nx))
    Q_old  = Q.copy()
    Q_hist_len = max_tau + 3
    Q_hist = np.tile(Q[:, :, :, np.newaxis], (1, 1, 1, Q_hist_len))  # 4 x Ny x Nx x H
    q_head = 0  # Python 0-based ring buffer head
    
    # ------------------ WARM-UP LOOP ------------------
    phi_ij_warm     = phi_ij.copy()
    phi_ij_old_warm = phi_ij_old.copy()
    Q_warm          = Q.copy()
    Q_old_warm      = Q_old.copy()
    Q_hist_warm     = Q_hist.copy()
    q_head_warm     = q_head
    Y_warm          = Y.copy()
    
    # Noise axonal damping states (NFTsim-style)
    Q_noise      = 0.0
    Q_noise_old  = Q_noise
    phi_noise    = 0.0
    phi_noise_old= phi_noise
    
    for step in range(1, nsteps_warm + 1):
    
        # delayed Q field (Tau)
        prepopQ_field = np.zeros((Npop, Npop, Ny, Nx), dtype=float)
        for i in range(1, Npop + 1):
            for j in range(1, Npop + 1):
                delay_steps = int(np.round(params.Tau[i-1, j-1] / deltat))
                idx_delay   = (q_head_warm - delay_steps - 1) % Q_hist_len
                prepopQ_field[i-1, j-1, :, :] = Q_hist_warm[j-1, :, :, idx_delay]
    
        # propagate φ_ij (harmonic if single node, otherwise wave)
        phi_ij_next = phi_ij_warm.copy()
        if Ny * Nx == 1:
            for i in range(1, Npop + 1):
                for j in range(1, Npop + 1):
                    m = int(params.Tau_steps[i-1, j-1])
                    read_idx      = (q_head_warm - 1 - m) % Q_hist_len
                    Qdel          = Q_hist_warm[j-1, 0, 0, read_idx]
                    read_idx_old  = (read_idx - 1) % Q_hist_len
                    Qdel_old      = Q_hist_warm[j-1, 0, 0, read_idx_old]
                    phi_ij_next[i-1, j-1, 0, 0] = harmonic_step_scalar(
                        phi_ij_warm[i-1, j-1, 0, 0],
                        phi_ij_old_warm[i-1, j-1, 0, 0],
                        Qdel, Qdel_old, params
                    )
        else:
            for i in range(1, Npop + 1):
                for j in range(1, Npop + 1):
                    p      = np.squeeze(phi_ij_warm[i-1, j-1, :, :])
                    p_old  = np.squeeze(phi_ij_old_warm[i-1, j-1, :, :])
                    Qcur   = np.squeeze(Q_warm[j-1, :, :])
                    Qprev  = np.squeeze(Q_old_warm[j-1, :, :])
                    preQ   = np.squeeze(prepopQ_field[i-1, j-1, :, :])
                    p_next = wave_step_grid(p, p_old, Qcur, Qprev, preQ, params, boundary)
                    phi_ij_next[i-1, j-1, :, :] = p_next
    
        phi_ij_old_warm = phi_ij_warm
        phi_ij_warm     = phi_ij_next
    
        # --- Noise axonal damping (NFTsim-style) ---
        if params.noise.enabled:
            Q_noise_new = white_stim_nftsim(step - 1, params)   # Noise source
        else:
            Q_noise_new = 0.0
    
        phi_noise_next = harmonic_step_scalar(
            phi_noise,        # current filtered noise
            phi_noise_old,    # previous filtered noise
            Q_noise_new,      # new noise firing sample
            Q_noise_old,      # previous noise firing sample
            params
        )
    
        # shift noise histories
        phi_noise_old = phi_noise
        phi_noise     = phi_noise_next
        Q_noise_old   = Q_noise
        Q_noise       = Q_noise_new
    
        # Inject filtered noise into dendrite during warm-up
        noise_x = phi_noise
    
        # stimuli: absolute time from 0 (TMS will be 0 before onset)
        abs_step = step - 1
        phi_x    = stim_waveform(abs_step, params)
        phi_x_out_full[step - 1] = phi_x 
    
        # integrate each node with full RHS
        for iy in range(Ny):
            for ix in range(Nx):
                y_node      = Y_warm[:, iy, ix].copy()
                phi_node    = np.squeeze(phi_ij_warm[:, :, iy, ix])
                node_params = params
                node_params.phi_ij = phi_node
                y_new = rk4_step(lambda y: model_equations(y, phi_x, noise_x, node_params),
                                 y_node, deltat)
                Y_warm[:, iy, ix] = y_new
    
        # recompute Q from soma voltages
        for iPop in range(1, Npop + 1):
            V_i = np.zeros((Ny, Nx), dtype=float)
            for jPop in range(1, Npop + 1):
                idx0 = ((iPop - 1) * Npop + (jPop - 1)) * N_bs
                V_i += np.squeeze(Y_warm[idx0 + 0, :, :])     # V_ij
            if iPop == 1:
                V_i += np.squeeze(Y_warm[Ndend + 0, :, :])    # Vx
            if params.noise.enabled and (iPop == params.noise.target_i):
                V_i += np.squeeze(Y_warm[Ndend + NTMS + 0, :, :])  # Vw
            Q_warm[iPop - 1, :, :] = fire(V_i, params)
    
        # update warm-up history
        Q_hist_warm[:, :, :, q_head_warm] = Q_warm
        q_head_warm = (q_head_warm + 1) % Q_hist_len
        Q_old_warm  = Q_warm
    
    # ---- after warm-up: keep only V/W from Y_warm, reset slow vars to baseline ----
    Y_after_warm = Y_warm.copy()
    Y            = Y_baseline.copy()   # reset everything
    
    # copy V_ij, W_ij from warm-up; keep nutil/nu/dnudt/gNMDA/Ca from baseline
    for iPop in range(1, Npop + 1):
        for jPop in range(1, Npop + 1):
            idx0 = ((iPop - 1) * Npop + (jPop - 1)) * N_bs
            Y[idx0 + 0, :, :] = Y_after_warm[idx0 + 0, :, :]  # V_ij
            Y[idx0 + 1, :, :] = Y_after_warm[idx0 + 1, :, :]  # W_ij
    
    # TMS dendrite Vx,Wx from warm-up
    Y[Ndend:Ndend + 2, :, :] = Y_after_warm[Ndend:Ndend + 2, :, :]
    
    # noise dendrite Vw,Ww from warm-up 
    Y[Ndend + NTMS:Ndend + NTMS + 2, :, :] = Y_after_warm[Ndend + NTMS:Ndend + NTMS + 2, :, :]
    
    # carry over φ/Q state and history so Tau works correctly
    phi_ij     = phi_ij_warm
    phi_ij_old = phi_ij_old_warm
    Q          = Q_warm
    Q_old      = Q_old_warm
    Q_hist     = Q_hist_warm
    q_head     = q_head_warm
    
    # ================== Outputs ==================
    Yout      = np.zeros((Nstate, Ny, Nx, nsteps_out), dtype=float)
    Qout      = np.zeros((Npop, Ny, Nx, nsteps_out), dtype=float)
    phi_x_out = np.zeros((nsteps_out,), dtype=float)  # scalar pattern per saved step
    
    # ================== Main loop ==================
    # Noise axonal damping states (NFTsim-style) for main phase
    Q_noise      = 0.0
    Q_noise_old  = Q_noise
    phi_noise    = 0.0
    phi_noise_old= phi_noise
    
    out_idx = 0
    for step in range(1, nsteps + 1):
    
        prepopQ_field = np.zeros((Npop, Npop, Ny, Nx), dtype=float)
        for i in range(1, Npop + 1):
            for j in range(1, Npop + 1):
                delay_steps = int(np.round(params.Tau[i-1, j-1] / deltat))  # Tau is all zeros as in MATLAB 
                idx_delay   = (q_head - delay_steps - 1) % Q_hist_len
                prepopQ_field[i-1, j-1, :, :] = Q_hist[j-1, :, :, idx_delay]  # delayed Q_j
    
        # ---- Build phi_ij at grid with delays (Tau) ----
        phi_ij_next = phi_ij.copy()  # preallocate
        if Ny * Nx == 1:
            # single-node: harmonic per (i,j)
            for i in range(1, Npop + 1):
                for j in range(1, Npop + 1):
                    m = int(params.Tau_steps[i-1, j-1])  # (zeros)
                    # delayed Q indices
                    read_idx     = (q_head - 1 - m) % Q_hist_len
                    Qdel         = Q_hist[j-1, 0, 0, read_idx]
                    read_idx_old = (read_idx - 1) % Q_hist_len
                    Qdel_old     = Q_hist[j-1, 0, 0, read_idx_old]
                    # harmonic update
                    phi_ij_next[i-1, j-1, 0, 0] = harmonic_step_scalar(
                        phi_ij[i-1, j-1, 0, 0],
                        phi_ij_old[i-1, j-1, 0, 0],
                        Qdel, Qdel_old, params
                    )
        else:
            # grid: full 2-D wave per (i,j)
            for i in range(1, Npop + 1):
                for j in range(1, Npop + 1):
                    p     = np.squeeze(phi_ij[i-1, j-1, :, :])
                    p_old = np.squeeze(phi_ij_old[i-1, j-1, :, :])
                    Qcur  = np.squeeze(Q[j-1, :, :])                 # current firing rates
                    Qprev = np.squeeze(Q_old[j-1, :, :])             # previous firing rates
                    preQ  = np.squeeze(prepopQ_field[i-1, j-1, :, :])# delayed presyn drive
                    p_next = wave_step_grid(p, p_old, Qcur, Qprev, preQ, params, boundary)
                    phi_ij_next[i-1, j-1, :, :] = p_next
    
        phi_ij_old = phi_ij
        phi_ij     = phi_ij_next
    
        # ---- Stimuli (scalars, applied identically to all nodes) ----    
        abs_step = (step - 1) + nsteps_warm     # Absolute time index since start of sim
        phi_x    = stim_waveform(abs_step, params)        # Absolute-time TMS call
        phi_x_out_full[step - 1] = phi_x 
    
        if params.noise.enabled:
            Q_noise_new = white_stim_nftsim(step - 1, params)    # same generator, but we now filter it
        else:
            Q_noise_new = 0.0
    
        phi_noise_next = harmonic_step_scalar(
            phi_noise, phi_noise_old,
            Q_noise_new, Q_noise_old,
            params
        )
        phi_noise_old = phi_noise
        phi_noise     = phi_noise_next
        Q_noise_old   = Q_noise
        Q_noise       = Q_noise_new
    
        noise_x = phi_noise                   # Inject filtered noise (NFTsim-style)
    
        # ---- Integrate each node independently ----
        for iy in range(Ny):
            for ix in range(Nx):
                y_node = Y[:, iy, ix].copy()
    
                # build node-local φ_ij (Npop x Npop) for RHS
                phi_node = np.squeeze(phi_ij[:, :, iy, ix])
    
                # pass φ_ij via a node-local params copy (minimal change to flow)
                node_params = copy.copy(params)
                node_params.phi_ij = phi_node            
                
                #node_params = params
                #node_params.phi_ij = phi_node
    
                y_new = rk4_step(lambda y: model_equations(y, phi_x, noise_x, node_params),
                                 y_node, deltat)
                Y[:, iy, ix] = y_new
    
        # ---------- recompute Q from soma voltages (per population) ----------
        for iPop in range(1, Npop + 1):
            V_i = np.zeros((Ny, Nx), dtype=float)
            # sum dendritic voltages V_ij over all j
            for jPop in range(1, Npop + 1):
                idx0 = ((iPop - 1) * Npop + (jPop - 1)) * N_bs
                V_i += np.squeeze(Y[idx0 + 0, :, :])
            # add direct TMS dendrite to pop 1
            if iPop == 1:
                V_i += np.squeeze(Y[Ndend + 0, :, :])  # Vx
            # add white-noise dendrite if enabled and targeted
            if params.noise.enabled:
                if iPop == params.noise.target_i:
                    V_i += np.squeeze(Y[Ndend + NTMS + 0, :, :])  # Vw
            Q[iPop - 1, :, :] = fire(V_i, params)
    
        # ---- Save (downsampled) ----
        if (step % output_interval_steps) == 0:
            Yout[:, :, :, out_idx] = Y
            Qout[:, :, :, out_idx] = Q
            phi_x_out[out_idx]     = float(np.asarray(phi_x).ravel()[0])  # store scalar
            out_idx += 1
    
        # ---- Push Q into ring buffer (per node) ----
        Q_hist[:, :, :, q_head] = Q
        q_head = (q_head + 1) % Q_hist_len
        Q_old = Q
    
    # ================== Plot results ==================
    # This can be changed to plot for the relevant connections in the four populations. 
    # plot_results_j_to_i(Yout, Qout, tvec_out, params, 1, 1)  # e to e
    # V_e = plot_results(Yout, Qout, tplot, params, 1)           # Add cortical excitatory V_e
    # plot_results(Yout, Qout, tplot, params, 1)
    
    # plot_results_j_to_i(Yout, Qout, tplot,   params, 1, 1)     # keep dendrite-specific plot (e-e)
    
    # ================== EXTRACT nu_ee START/END & SAVE in Excel File Locally ==================
    # E-E is the first dendrite block; nu is the 4th state in each 7-state block (0-based index 3)
    nu_ee_ts = Yout[3, 0, 0, :] 
    start_idx = 0
    end_idx = len(tvec_out) - 1
    
    nu_start = float(nu_ee_ts[start_idx])
    nu_end   = float(nu_ee_ts[end_idx])
    
    
    # savemat(f"nu_ee.mat", {f"nu_ee":nu_ee_ts})
    
    nu_ee_last = nu_ee_ts[len(nu_ee_ts) - int(10 / output_interval) : len(nu_ee_ts)]
    mean_nu_ee_last = np.mean(nu_ee_last)
    
    pct_change_nu_ee = (
        (mean_nu_ee_last - params.nu_0_mx[0, 0])
        / params.nu_0_mx[0, 0]
    )
    

    print("pct_change_nu_ee = ", pct_change_nu_ee)
    
    nu_ee = Yout[3, 0, 0, :].copy()
    nutil_ee = Yout[2, 0, 0, :].copy()
    Ca_ee = Yout[6, 0, 0, :].copy()
    tplot_full = np.arange(nsteps) * deltat + T_warmup
    pct_change_nu_ee_py = pct_change_nu_ee
    
    
    #savemat(
        #"debug_driver_outputs.mat",
        #{
            #"nu_ee": nu_ee,
            #"nutil_ee": nutil_ee,
            #"Ca_ee": Ca_ee,
            ##"phi_x_out": phi_x_out,
            #"tplot": tplot,
            ##"Qout": Qout,
            ##"Yout_shape": np.array(Yout.shape),
            #"pct_change_nu_ee_py": pct_change_nu_ee_py,
            ##"phi_x_out_full": phi_x_out_full,
            ##"tplot_full": tplot_full
        #},
    #)
    
    
    ## Your existing selection of "V_e":
    #V_e_ts = Yout[1, 0, 0, :]              # full time series now
    #df = pd.DataFrame({"t": tvec_out, "V_e": V_e_ts})
    
    pct_change_nu_ee_vec_py[ii] = pct_change_nu_ee_py
    

savemat(f"pct_change_nu_ee_vec_py.mat", {f"pct_change_nu_ee_vec_py":pct_change_nu_ee_vec_py})

