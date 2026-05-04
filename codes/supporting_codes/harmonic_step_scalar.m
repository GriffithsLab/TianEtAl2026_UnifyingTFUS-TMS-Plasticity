function phi_next = harmonic_step_scalar(phi, phi_old, Q, Q_old, params)
% Faithful NFTsim-style harmonic propagator for Nodes = 1
% Implements: phi'' + 2γ phi' + γ² phi = γ² Q
% Matches your harmonic_step(phi, phi_old, Q, Q_old, params)

    deltat = params.deltat;
    gamma  = params.gamma;

    a        = exp(-gamma * deltat);
    dt2on12  = (deltat^2)/12;
    dfact    = dt2on12 * gamma^2;

    % Predictor for Q at n+1 (NFTsim uses history buffer)
    Q_pred = 2*Q - Q_old;

    % p^2 = 0 in single-node harmonic, so (10 - 4p^2) => 10
    phi_next = a .* ( ...
        2.*phi - a.*phi_old + ...
        dfact .* ( 10.*Q + Q_pred + Q_old ) );
end
