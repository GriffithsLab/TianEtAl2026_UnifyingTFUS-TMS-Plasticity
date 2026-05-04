function V_i = plot_results(Yout, Qout, tvec, params, iPop)
    % Plot spatially averaged time courses for population iPop
    Npop = 4; 
    Ny = size(Yout,2);
    Nx = size(Yout,3);

    block_size = 7;
    Ndend = Npop*Npop*block_size;
    NTMS  = 2;  
    Nglu  = Npop;

    % --- Compute spatial averages ---
    nT = length(tvec);
    V_i      = zeros(1,nT);
    Ca_i     = zeros(1,nT);
    nutil_i  = zeros(1,nT);
    nu_i     = zeros(1,nT);
    gNMDA_i  = zeros(1,nT);
    Q_i      = squeeze(mean(mean(Qout(iPop,:,:,:),[2 3]),[1 2]));

    for k = 1:nT
        Yk = Yout(:,:,:,k);

        % accumulate over space
        V_i_grid      = zeros(Ny,Nx);
        Ca_i_grid     = zeros(Ny,Nx);
        nutil_i_grid  = zeros(Ny,Nx);
        nu_i_grid     = zeros(Ny,Nx);
        gNMDA_i_grid  = zeros(Ny,Nx);

        for jPop = 1:Npop
            idx0 = ((iPop-1)*Npop + (jPop-1))*block_size;
            scale_ij = any(params.conn_scale(iPop,jPop)); %nftsim style

            % Weighted sums for per-pop summaries
            Ca_i_grid     = Ca_i_grid     + scale_ij * squeeze(Yk(idx0+7,:,:));
            nutil_i_grid  = nutil_i_grid  + scale_ij * squeeze(Yk(idx0+3,:,:));
            nu_i_grid     = nu_i_grid     + scale_ij * squeeze(Yk(idx0+4,:,:));
            gNMDA_i_grid  = gNMDA_i_grid  + scale_ij * squeeze(Yk(idx0+6,:,:));

            % Soma voltage is a sum of dendritic voltages 
            V_i_grid = V_i_grid + squeeze(Yk(idx0+1,:,:)); 
            % no scale_ij is needed because it has been incorporated in computing each V_ij

        end

        % add TMS dendrite for cortical excitatory pop (i=1) to soma voltage only
        if iPop == 1
            V_i_grid = V_i_grid + squeeze(Yk(Ndend+1,:,:));
            % already scaled by TMS_scale_x
        end

        % mean over space
        V_i(k)       = mean(V_i_grid,"all");
        Ca_i(k)      = mean(Ca_i_grid,"all");
        nutil_i(k)   = mean(nutil_i_grid,"all");
        nu_i(k)      = mean(nu_i_grid,"all");
        gNMDA_i(k)   = mean(gNMDA_i_grid,"all");
    end

    % --- Plot ---
    % figure; 
    % 
    % subplot(4,1,1);
    % plot(tvec, Q_i, 'b','LineWidth',1.2);
    % ylabel('$Q_i$ (Hz)','Interpreter','latex');
    % title(['Population ', num2str(iPop)]);
    % 
    % subplot(4,1,2);
    % plot(tvec, Ca_i*1e6, 'Color',[0 .6 0],'LineWidth',1.2);
    % ylabel('$\mathrm{Ca}_i$ ($\mu$M)','Interpreter','latex');
    % 
    % subplot(4,1,3);
    % plot(tvec, nu_i*1e3, 'b','LineWidth',1.3); hold on;
    % plot(tvec, nutil_i*1e3, 'r--','LineWidth',1.1);
    % ylabel('$\nu_i,\ \tilde{\nu}_i$ (mM)','Interpreter','latex');
    % legend({'$\nu_i$','$\tilde{\nu}_i$'},'Interpreter','latex');
    % 
    % subplot(4,1,4);
    % plot(tvec, gNMDA_i*1e3, 'm','LineWidth',1.3);
    % xlabel('Time (s)'); ylabel('$g_{\mathrm{NMDA},i}$ (mS)','Interpreter','latex');

    
end
