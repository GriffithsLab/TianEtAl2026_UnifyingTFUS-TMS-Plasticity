function p_next = wave_step_grid(p, p_old, Q, Q_old, prepopQ, params, boundary)
% wave_step_grid
% Advances the wave-propagated field φ one timestep using a five-point stencil.
% This is numerically identical to your earlier wave_step (same op order).

    % Pad arrays with ghost cells (reuse your existing pad_field)
    p_pad      = pad_field(p,       boundary);
    p_old_pad  = pad_field(p_old,   boundary);
    Q_pad      = pad_field(Q,       boundary);
    Q_old_pad  = pad_field(Q_old,   boundary);
    prepop_pad = pad_field(prepopQ, boundary);

    [Ny, Nx] = size(p);         % interior size
    p_next = zeros(Ny, Nx);

    % Coefficients (already precomputed in params for identity)
    dfact        = params.dfact;         % (Δt^2/12) γ^2
    p2           = params.p2;            % (Δt^2/Δx^2) (r^2 γ^2)
    tenminus4p2  = params.tenminus4p2;   % 10 - 4 p^2
    twominus4p2  = params.twominus4p2;   % 2  - 4 p^2
    e_neg        = params.expfactneg;    % e^{-γ Δt}
    e_pos        = params.expfactpos;    % e^{+γ Δt}

    % Loop over interior (shifted by 1 due to padding)
    for i = 2:Ny+1
        for j = 2:Nx+1
            % von Neumann neighbors
            sump = p_pad(i-1,j) + p_pad(i+1,j) + p_pad(i,j-1) + p_pad(i,j+1);
            sumQ = Q_pad(i-1,j) + Q_pad(i+1,j) + Q_pad(i,j-1) + Q_pad(i,j+1);

            % drive term (Q + presynaptic history)
            drive = dfact * ( ...
                     tenminus4p2 * Q_pad(i,j) + ...
                     prepop_pad(i,j) * e_pos + ...
                     Q_old_pad(i,j) * e_neg + ...
                     p2 * sumQ );

            % φ update
            p_next(i-1,j-1) = e_neg * ( ...
                              twominus4p2 * p_pad(i,j) + ...
                              p2 * sump - ...
                              p_old_pad(i,j) * e_neg + ...
                              drive );
        end
    end
end
