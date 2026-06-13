import numpy as np
###########################################################################################################
def pad_field(field, boundary):
    """
    field: 2D array (Ny x Nx)
    boundary: 'torus' or 'sphere'
    returns: padded array with 1-cell ghost border
    """
    Ny, Nx = field.shape

    # Start with zeros + interior copy
    field_padded = np.zeros((Ny + 2, Nx + 2), dtype=field.dtype)
    field_padded[1:Ny+1, 1:Nx+1] = field

    if isinstance(boundary, str) and boundary.lower() == 'torus':
        # --- Top ghost row = bottom row
        field_padded[0, 1:Nx+1]   = field[-1, :]
        # --- Bottom ghost row = top row
        field_padded[-1, 1:Nx+1]  = field[0, :]

        # --- Left ghost col = right col
        field_padded[1:Ny+1, 0]   = field[:, -1]
        # --- Right ghost col = left col
        field_padded[1:Ny+1, -1]  = field[:, 0]

        # --- Four corners
        field_padded[0, 0]        = field[-1, -1]
        field_padded[0, -1]       = field[-1, 0]
        field_padded[-1, 0]       = field[0, -1]
        field_padded[-1, -1]      = field[0, 0]

    elif isinstance(boundary, str) and boundary.lower() == 'sphere':
        # --- Top ghost row = reversed bottom row
        field_padded[0, 1:Nx+1]   = field[-1, ::-1]
        # --- Bottom ghost row = reversed top row
        field_padded[-1, 1:Nx+1]  = field[0, ::-1]

        # --- Left ghost col = right col
        field_padded[1:Ny+1, 0]   = field[:, -1]
        # --- Right ghost col = left col
        field_padded[1:Ny+1, -1]  = field[:, 0]

        # --- Four corners (approx same as C++ version)
        field_padded[0, 0]        = field[-1, -1]
        field_padded[0, -1]       = field[-1, 0]
        field_padded[-1, 0]       = field[0, -1]
        field_padded[-1, -1]      = field[0, 0]
    else:
        raise ValueError(f"Unknown boundary type: {boundary}")

    return field_padded
############################################################################################################
def wave_step_grid(p, p_old, Q, Q_old, prepopQ, params, boundary):
    """
    Advances the wave-propagated field φ one timestep using a five-point stencil.
    """

    # Pad arrays with ghost cells (reuse your existing pad_field)
    p_pad      = pad_field(p,       boundary)
    p_old_pad  = pad_field(p_old,   boundary)
    Q_pad      = pad_field(Q,       boundary)
    Q_old_pad  = pad_field(Q_old,   boundary)
    prepop_pad = pad_field(prepopQ, boundary)

    Ny, Nx = p.shape                 # interior size
    p_next = np.zeros((Ny, Nx), dtype=float)

    # Coefficients (precomputed in params for identity)
    dfact        = params.dfact        # (Δt^2/12) γ^2
    p2           = params.p2           # (Δt^2/Δx^2) (r^2 γ^2)
    tenminus4p2  = params.tenminus4p2  # 10 - 4 p^2
    twominus4p2  = params.twominus4p2  # 2  - 4 p^2
    e_neg        = params.expfactneg   # e^{-γ Δt}
    e_pos        = params.expfactpos   # e^{+γ Δt}

    # Loop over interior (shifted by 1 due to padding)
    for i in range(1, Ny + 1):
        for j in range(1, Nx + 1):
            # von Neumann neighbors
            sump = (
                p_pad[i-1, j] + p_pad[i+1, j] +
                p_pad[i, j-1] + p_pad[i, j+1]
            )
            sumQ = (
                Q_pad[i-1, j] + Q_pad[i+1, j] +
                Q_pad[i, j-1] + Q_pad[i, j+1]
            )

            # drive term (Q + presynaptic history)
            drive = dfact * (
                tenminus4p2 * Q_pad[i, j] +
                prepop_pad[i, j] * e_pos +
                Q_old_pad[i, j] * e_neg +
                p2 * sumQ
            )

            # φ update
            p_next[i-1, j-1] = e_neg * (
                twominus4p2 * p_pad[i, j] +
                p2 * sump -
                p_old_pad[i, j] * e_neg +
                drive
            )

    return p_next
