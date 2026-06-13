import numpy as np

def harmonic_step(phi, phi_old, Q, Q_old, params):
    """
    Faithful NFTsim-style harmonic propagator for Nodes = 1
    Implements: phi'' + 2*\gamma*phi' + \gamma^{2}*phi = \gamma^{2}*Q
    
    """

    # Extract constants
    # deltat = params.deltat
    # gamma  = params.gamma

    # Precompute coefficients
    a        = np.exp(-params.gamma * params.deltat)
    ainv     = np.exp(params.gamma * params.deltat)  # kept for 1:1 parity with MATLAB (not used)
    dt2on12  = (params.deltat**2) / 12.0
    dfact    = dt2on12 * (params.gamma**2)

    # Predictor for Q at n+1 (NFTsim uses history buffer here)
    Q_pred = 2 * Q - Q_old

    # Harmonic update (NFTsim scheme with correction term)
    phi_next = a * (
        2.0 * phi - a * phi_old +
        dfact * ((10.0 - 0.0) * Q + Q_pred + Q_old)
    )

    return phi_next
############################################################################################################
def harmonic_step_scalar(phi, phi_old, Q, Q_old, params):
    """
    Faithful NFTsim-style harmonic propagator for Nodes = 1
    Implements: phi'' + 2*gamma*phi' + gamma**2 * phi = gamma**2 * Q
    Mirrors the MATLAB harmonic_step_scalar.
    """
    deltat = params.deltat
    gamma  = params.gamma

    a        = np.exp(-gamma * deltat)
    dt2on12  = (deltat**2) / 12.0
    dfact    = dt2on12 * (gamma**2)

    # Predictor for Q at n+1 (NFTsim uses history buffer)
    Q_pred = 2.0 * Q - Q_old

    # p^2 = 0 in single-node harmonic, so (10 - 4p^2) => 10
    phi_next = a * (2.0 * phi - a * phi_old + dfact * (10.0 * Q + Q_pred + Q_old))
    return phi_next