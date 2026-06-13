import numpy as np
############################################################################################################
def fire(v, param):
    """Compute firing response from V (logistic)."""
    return param.Q_max / (1.0 + np.exp(-(v - param.theta) / param.sigma))
############################################################################################################
def sig(x, slope):
    """Element-wise logistic with gain `slope`."""
    return 1.0 / (1.0 + np.exp(-x * slope))
############################################################################################################
def x_of_Ca(Ca, param):
    """x(Ca) = x_th + ltp * sig(Ca - pth, x2)."""
    return param.xth + param.ltp * sig(Ca - param.pth, param.x2)
############################################################################################################
def y_of_Ca(Ca, param, yth_override):
    """y(Ca) = y_th + ltd * sig(Ca - dth, y2) - ltd * sig(Ca - pth, y2)."""
    yth_loc = yth_override
    return yth_loc + param.ltd * sig(Ca - param.dth, param.y2) \
                      - param.ltd * sig(Ca - param.pth, param.y2)
############################################################################################################
def model_equations(y, phi_x, noise_x, params):
    """
    RHS for 4-pop with per-connection phi_ij (Tau), TMS dendrite (pop1),
    and white-noise dendrite (params.noise.target_i). Per-connection nu_max_ij.

    Python port of the provided MATLAB function (one-to-one).
    """
    Npop = 4
    bs = 7
    Ndend = Npop * Npop * bs
    NTMS = 2
    NNOI = 2
    glu_offset = Ndend + NTMS + NNOI  # 4 glutamate states follow

    y = np.asarray(y, dtype=float)
    dydt = np.zeros_like(y)
    V_soma = np.zeros(Npop, dtype=float)

    # --- Synaptic dendrites & plasticity (i <- j) ---
    for i in range(1, Npop + 1):
        for j in range(1, Npop + 1):
            idx0 = ((i - 1) * Npop + (j - 1)) * bs

            V_ij     = y[idx0 + 0]
            W_ij     = y[idx0 + 1]
            nutil_ij = y[idx0 + 2]
            nu_ij    = y[idx0 + 3]
            dnudt_ij = y[idx0 + 4]
            gNMDA_ij = y[idx0 + 5]
            Ca_ij    = y[idx0 + 6]

            phi_ij   = params.phi_ij[i-1, j-1]
            drive_ij = params.conn_scale[i-1, j-1] * nu_ij * phi_ij

            dV_ij = W_ij
            dW_ij = params.alpha * params.beta * (
                drive_ij - V_ij - (1.0/params.alpha + 1.0/params.beta) * W_ij
            )

            # Per-connection nu_max
            nu_max_ij = params.nu_max_mx[i-1, j-1]
            nu_0_ij   = params.nu_0_mx[i-1, j-1]
            yth_ij    = params.xth * (nu_max_ij - nu_0_ij) / nu_0_ij
            # yth is a parameter in the omega function, updated per dendrite

            xCa = x_of_Ca(Ca_ij, params)
            yCa = y_of_Ca(Ca_ij, params, yth_ij)
            dnutil_ij = xCa * (nu_max_ij - nutil_ij) - yCa * nutil_ij
            ddnudt_ij = -2.0 * params.z * dnudt_ij + (params.z ** 2) * (nutil_ij - nu_ij)
            dnu_ij    = dnudt_ij

            # if nu_ij == 0 -> dgNMDA_ij = 0; else standard update
            if nu_ij == 0:
                dgNMDA_ij = 0.0
            else:
                ratio = nutil_ij / nu_ij
                dgNMDA_ij = -gNMDA_ij / params.t_BCM * (ratio - 1.0) + \
                            (params.gnmda_0 - gNMDA_ij) / params.t_rec

            V_soma[i-1] += V_ij

            # write back (Ca updated later)
            dydt[idx0 + 0] = dV_ij
            dydt[idx0 + 1] = dW_ij
            dydt[idx0 + 2] = dnutil_ij
            dydt[idx0 + 3] = dnu_ij
            dydt[idx0 + 4] = ddnudt_ij
            dydt[idx0 + 5] = dgNMDA_ij

    # --- Direct TMS dendrite to population 1 ---
    Vx = y[Ndend + 0]
    Wx = y[Ndend + 1]
    drive_x = params.TMS_scale_x * params.nu_x * phi_x
    dVx = Wx
    dWx = params.alpha * params.beta * (
        drive_x - Vx - (1.0/params.alpha + 1.0/params.beta) * Wx
    )
    dydt[Ndend + 0] = dVx
    dydt[Ndend + 1] = dWx
    V_soma[0] += Vx

    # --- Direct white-noise dendrite to params.noise.target_i ---
    if getattr(params, "noise", None) is not None and params.noise.enabled:
        iN = int(params.noise.target_i)  # MATLAB is 1-based
        Vw = y[Ndend + NTMS + 0]
        Ww = y[Ndend + NTMS + 1]
        drive_w = params.noise_scale * params.nu_noise * noise_x
        dVw = Ww
        dWw = params.alpha * params.beta * (
            drive_w - Vw - (1.0/params.alpha + 1.0/params.beta) * Ww
        )
        dydt[Ndend + NTMS + 0] = dVw
        dydt[Ndend + NTMS + 1] = dWw
        V_soma[iN - 1] += Vw

    # --- Per-pop glutamate -> binding/H -> Ca_ij ---
    for i in range(1, Npop + 1):
        gi_idx = glu_offset + (i - 1)
        glu_i  = y[gi_idx]

        # excitatory sources = pops 1 and 3, if connected to target pop i
        phi_exc_to_i = (
            (params.conn_scale[i-1, 0] != 0) * params.phi_ij[i-1, 0] +
            (params.conn_scale[i-1, 2] != 0) * params.phi_ij[i-1, 2]
        )
        dglu_i = params.Lambda * phi_exc_to_i - glu_i / params.tGlu
        dydt[gi_idx] = dglu_i

        binding_i = sig(glu_i - params.glu_0, params.B_0)
        H_i       = (params.V_r - V_soma[i-1]) * sig(V_soma[i-1] - params.Mg0, params.H0)

        for j in range(1, Npop + 1):
            idx0   = ((i - 1) * Npop + (j - 1)) * bs
            Ca_ij  = y[idx0 + 6]
            gN_ij  = y[idx0 + 5]
            dCa_ij = gN_ij * binding_i * H_i - Ca_ij / params.tCa
            if Ca_ij + dCa_ij * params.deltat < 0.0:
                dCa_ij = -Ca_ij / params.deltat
            dydt[idx0 + 6] = dCa_ij

    return dydt

