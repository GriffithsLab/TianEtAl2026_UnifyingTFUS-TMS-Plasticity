function dydt = model_equations(y, phi_x, noise_x, params)
% RHS for 4-pop with per-connection phi_ij (Tau), TMS dendrite (pop1), and
% white-noise dendrite (params.noise.target_i). Per-connection nu_max_ij.

    Npop = 4; bs = 7;
    Ndend = Npop*Npop*bs; NTMS = 2; NNOI = 2;
    glu_offset = Ndend + NTMS + NNOI;  % 4 glutamate states follow

    dydt = zeros(size(y));
    V_soma = zeros(Npop,1);

    % --- Synaptic dendrites & plasticity (i <- j) ---
    for i = 1:Npop
        for j = 1:Npop
            idx0 = ((i-1)*Npop + (j-1))*bs;
            V_ij     = y(idx0+1);
            W_ij     = y(idx0+2);
            nutil_ij = y(idx0+3);
            nu_ij    = y(idx0+4);
            dnudt_ij = y(idx0+5);
            gNMDA_ij = y(idx0+6);
            Ca_ij    = y(idx0+7);

            phi_ij   = params.phi_ij(i,j);
            drive_ij = params.conn_scale(i,j) * nu_ij * phi_ij;

            dV_ij = W_ij;
            dW_ij = params.alpha*params.beta * ...
                     (drive_ij - V_ij - (1/params.alpha+1/params.beta)*W_ij);

            % Per-connection nu_max
            nu_max_ij = params.nu_max_mx(i,j);          
            nu_0_ij = params.nu_0_mx(i,j);
            %denom = max(abs(nu_0_ij), eps);
            yth_ij = params.xth * (nu_max_ij - nu_0_ij) / nu_0_ij;
            % yth is a parameter in the omega function, and is updated per-dendrite

            x_Ca = x_of_Ca(Ca_ij, params);
            y_Ca = y_of_Ca(Ca_ij, params, yth_ij);
            dnutil_ij = x_Ca*(nu_max_ij - nutil_ij) - y_Ca*nutil_ij;
            ddnudt_ij = -2*params.z*dnudt_ij + params.z^2*(nutil_ij - nu_ij);
            dnu_ij    = dnudt_ij;

            %if nu_ij <= 0, ratio = 1; else, ratio = nutil_ij/nu_ij; end

            if nu_ij == 0
                dgNMDA_ij = 0;
            else
                ratio = nutil_ij/nu_ij;
                dgNMDA_ij = -gNMDA_ij/params.t_BCM*(ratio - 1) + ...
                             (params.gnmda_0 - gNMDA_ij)/params.t_rec;
            end

            V_soma(i) = V_soma(i) + V_ij;

            dydt(idx0+(1:6)) = [dV_ij; dW_ij; dnutil_ij; dnu_ij; ddnudt_ij; dgNMDA_ij];
            % Ca updated after binding/H from soma & glu
        end
    end

    % --- Direct TMS dendrite to population 1 ---
    Vx = y(Ndend+1); Wx = y(Ndend+2);
    drive_x = params.TMS_scale_x * params.nu_x * phi_x;
    dVx = Wx;
    dWx = params.alpha*params.beta * ...
          (drive_x - Vx - (1/params.alpha+1/params.beta)*Wx);
    dydt(Ndend+(1:2)) = [dVx; dWx];
    V_soma(1) = V_soma(1) + Vx;

    % --- Direct white-noise dendrite to params.noise.target_i ---
    if params.noise.enabled
        iN = params.noise.target_i;
        Vw = y(Ndend+NTMS+1);  Ww = y(Ndend+NTMS+2);
        drive_w = params.noise_scale * params.nu_noise * noise_x;
        dVw = Ww;
        dWw = params.alpha*params.beta * ...
              (drive_w - Vw - (1/params.alpha+1/params.beta)*Ww);
        dydt(Ndend+NTMS+(1:2)) = [dVw; dWw];
        V_soma(iN) = V_soma(iN) + Vw;
    end

    % --- Per-pop glutamate -> binding/H -> Ca_ij ---
    for i = 1:Npop
        gi_idx = glu_offset + i;
        glu_i  = y(gi_idx);

        % excitatory sources = populations 1 and 3, if connected to the
        % target population i
        phi_exc_to_i = any(params.conn_scale(i,1))*params.phi_ij(i,1) +  any(params.conn_scale(i,3))*params.phi_ij(i,3);
        dglu_i = params.Lambda * phi_exc_to_i - glu_i/params.tGlu;
        dydt(gi_idx) = dglu_i;

        binding_i = sig(glu_i - params.glu_0, params.B_0);
        H_i       = (params.V_r - V_soma(i)) * sig(V_soma(i) - params.Mg0, params.H0);

        for j = 1:Npop
            idx0   = ((i-1)*Npop + (j-1))*bs;
            Ca_ij  = y(idx0+7);
            gN_ij  = y(idx0+6);
            dCa_ij = gN_ij * binding_i * H_i - Ca_ij/params.tCa;
            if Ca_ij + dCa_ij*params.deltat < 0
                dCa_ij = -Ca_ij/params.deltat;
            end
            dydt(idx0+7) = dCa_ij;
        end
    end
end
