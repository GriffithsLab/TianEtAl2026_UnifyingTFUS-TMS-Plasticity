function [nu_ij, Ca_ij] = plot_results_j_to_i(Yout, Qout, tvec, params, iPop, jPop)
    % Visualize synapse from population jPop -> iPop (spatially averaged)
    Npop = 4; block_size = 7;
    Ny = size(Yout,2);
    Nx = size(Yout,3);
    nT = length(tvec);

    idx0 = ((iPop-1)*Npop + (jPop-1))*block_size;

    Ca_ij    = zeros(1,nT);
    nutil_ij = zeros(1,nT);
    nu_ij    = zeros(1,nT);
    gNMDA_ij = zeros(1,nT);
    Q_i = squeeze(mean(mean(Qout(iPop,:,:,:),[2 3]),[1 2]));

    for k = 1:nT
        Yk = Yout(:,:,:,k);
        Ca_ij(k)    = mean(squeeze(Yk(idx0+7,:,:)),"all");
        nutil_ij(k) = mean(squeeze(Yk(idx0+3,:,:)),"all");
        nu_ij(k)    = mean(squeeze(Yk(idx0+4,:,:)),"all");
        gNMDA_ij(k) = mean(squeeze(Yk(idx0+6,:,:)),"all");
    end

    figure;
    subplot(4,1,1);
    plot(tvec, Q_i, 'k','LineWidth',1.2);
    ylabel('$Q_i$ (Hz)','Interpreter','latex');
    title(['Connection ',num2str(iPop),' \leftarrow ',num2str(jPop)]);

    subplot(4,1,2);
    plot(tvec, Ca_ij*1e6, 'Color',[0 .6 0],'LineWidth',1.2);
    ylabel('$Ca_{ij}$ ($\mu$M)','Interpreter','latex');

    % subplot(4,1,3);
    % plot(tvec, nu_ij*1e6, 'b','LineWidth',1.3); hold on;
    % plot(tvec, nutil_ij*1e6, 'r--','LineWidth',1.1);
    % ylabel('$\nu_{ij},\ \tilde{\nu}_{ij}$ ($\mu$M)','Interpreter','latex');
    % legend({'$\nu_{ij}$','$\tilde{\nu}_{ij}$'},'Interpreter','latex');

    subplot(4,1,3);
    plot(tvec, nu_ij*1e3, 'b','LineWidth',1.3); hold on;
    plot(tvec, nutil_ij*1e3, 'r--','LineWidth',1.1);
    ylabel('$\nu_{ij},\ \tilde{\nu}_{ij}$ (mM)','Interpreter','latex');
    legend({'$\nu_{ij}$','$\tilde{\nu}_{ij}$'},'Interpreter','latex');


    subplot(4,1,4);
    plot(tvec, gNMDA_ij*1e3, 'm','LineWidth',1.3);
    xlabel('Time (s)');
    ylabel('$g_{NMDA,ij}$ (mS)','Interpreter','latex');
end
