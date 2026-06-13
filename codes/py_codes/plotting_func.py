import numpy as np
import matplotlib.pyplot as plt

############################################################################################################
def plot_results_j_to_i(Yout, Qout, tvec, params, iPop, jPop):
    """
    Visualize synapse from population jPop -> iPop (spatially averaged).
    One-to-one translation of the MATLAB function (0-based indexing in Python).

    Yout shape: (Nstates_total, Ny, Nx, nT)
    Qout shape: (Npop, Ny, Nx, nT)
    iPop, jPop are 1-indexed (as in MATLAB).
    """
    Npop = 4
    block_size = 7  # [V, W, nutil, nu, dnudt, gNMDA, Ca]
    Ny, Nx = Yout.shape[1], Yout.shape[2]
    nT = tvec.size

    # start index of block (0-based)
    idx0 = ((iPop - 1) * Npop + (jPop - 1)) * block_size

    Ca_ij    = np.zeros(nT)
    nutil_ij = np.zeros(nT)
    nu_ij    = np.zeros(nT)
    gNMDA_ij = np.zeros(nT)

    # spatially averaged firing for postsynaptic population iPop
    Q_i = np.mean(Qout[iPop - 1, :, :, :], axis=(0, 1))  # (nT,)

    for k in range(nT):
        Yk = Yout[:, :, :, k]  # (Nstates_total, Ny, Nx)
        Ca_ij[k]    = np.mean(Yk[idx0 + 6, :, :])  # Ca
        nutil_ij[k] = np.mean(Yk[idx0 + 2, :, :])  # nutil
        nu_ij[k]    = np.mean(Yk[idx0 + 3, :, :])  # nu
        gNMDA_ij[k] = np.mean(Yk[idx0 + 5, :, :])  # gNMDA

    # --- Plots ---
    plt.figure()

    plt.subplot(4, 1, 1)
    plt.plot(tvec, Q_i, 'k', linewidth=1.2)
    plt.ylabel(r'$Q_i$ (Hz)')
    plt.title(f'Connection {iPop} ← {jPop}')

    plt.subplot(4, 1, 2)
    plt.plot(tvec, Ca_ij * 1e6, color=(0, 0.6, 0), linewidth=1.2)
    plt.ylabel(r'$Ca_{ij}$ ($\mu$M)')

    plt.subplot(4, 1, 3)
    plt.plot(tvec, nu_ij * 1e6, 'b', linewidth=1.3, label=r'$\nu_{ij}$')
    plt.plot(tvec, nutil_ij * 1e6, 'r--', linewidth=1.1, label=r'$\tilde{\nu}_{ij}$')
    plt.ylabel(r'$\nu_{ij},\ \tilde{\nu}_{ij}$ ($\mu$M)')
    plt.legend()

    plt.subplot(4, 1, 4)
    plt.plot(tvec, gNMDA_ij * 1e3, 'm', linewidth=1.3)
    plt.xlabel('Time (s)')
    plt.ylabel(r'$g_{NMDA,ij}$ (mS)')

    plt.tight_layout()
    plt.show()   
############################################################################################################
def plot_results(Yout, Qout, tvec, params, iPop):
    """
    Spatially averaged time courses for population iPop (1-based, as in MATLAB).
    Returns the soma voltage trace V_i (averaged over space).
    """
    Npop = 4
    Ny = Yout.shape[1]
    Nx = Yout.shape[2]

    block_size = 7
    Ndend = Npop * Npop * block_size
    NTMS  = 2  # not directly used here but kept for consistency

    nT = len(tvec)

    V_i      = np.zeros(nT)
    Ca_i     = np.zeros(nT)
    nutil_i  = np.zeros(nT)
    nu_i     = np.zeros(nT)
    gNMDA_i  = np.zeros(nT)

    # Mean over space for firing rate of this population
    Q_i = Qout[iPop - 1].mean(axis=(0, 1))  # shape: (nT,)

    for k in range(nT):
        Yk = Yout[:, :, :, k]

        # accumulate over space
        V_i_grid      = np.zeros((Ny, Nx))
        Ca_i_grid     = np.zeros((Ny, Nx))
        nutil_i_grid  = np.zeros((Ny, Nx))
        nu_i_grid     = np.zeros((Ny, Nx))
        gNMDA_i_grid  = np.zeros((Ny, Nx))

        for jPop in range(1, Npop + 1):
            idx0 = ((iPop - 1) * Npop + (jPop - 1)) * block_size

            # nftsim-style: include state contributions only if the dendrite exists
            scale_ij = 1.0 if params.conn_scale[iPop - 1, jPop - 1] != 0 else 0.0

            # Block layout (0-based): [0 V, 1 W, 2 nutil, 3 nu, 4 dnudt, 5 gNMDA, 6 Ca]
            Ca_i_grid     += scale_ij * Yk[idx0 + 6, :, :]
            nutil_i_grid  += scale_ij * Yk[idx0 + 2, :, :]
            nu_i_grid     += scale_ij * Yk[idx0 + 3, :, :]
            gNMDA_i_grid  += scale_ij * Yk[idx0 + 5, :, :]

            # Soma voltage is a sum of dendritic voltages (already scaled inside state)
            V_i_grid      += Yk[idx0 + 0, :, :]

        # add TMS dendrite to soma voltage for cortical excitatory pop (iPop == 1)
        if iPop == 1:
            V_i_grid += Yk[Ndend + 0, :, :]  # Vx

        # mean over space
        V_i[k]      = V_i_grid.mean()
        Ca_i[k]     = Ca_i_grid.mean()
        nutil_i[k]  = nutil_i_grid.mean()
        nu_i[k]     = nu_i_grid.mean()
        gNMDA_i[k]  = gNMDA_i_grid.mean()

    # --- Plot (unit conversions match MATLAB) ---
    fig, axs = plt.subplots(4, 1, figsize=(8, 10), sharex=True)

    axs[0].plot(tvec, Q_i, linewidth=1.2)
    axs[0].set_ylabel(r'$Q_i$ (Hz)')
    axs[0].set_title(f'Population {iPop}')

    axs[1].plot(tvec, Ca_i * 1e6, linewidth=1.2)
    axs[1].set_ylabel(r'$\mathrm{Ca}_i$ ($\mu$M)')

    axs[2].plot(tvec, nu_i * 1e3, linewidth=1.3)
    axs[2].plot(tvec, nutil_i * 1e3, linestyle='--', linewidth=1.1)
    axs[2].set_ylabel(r'$\nu_i,\ \tilde{\nu}_i$ (mM)')
    axs[2].legend([r'$\nu_i$', r'$\tilde{\nu}_i$'], loc='best')

    axs[3].plot(tvec, gNMDA_i * 1e3, linewidth=1.3)
    axs[3].set_xlabel('Time (s)')
    axs[3].set_ylabel(r'$g_{\mathrm{NMDA},i}$ (mS)')

    fig.tight_layout()
    plt.show() 
    # return V_i

