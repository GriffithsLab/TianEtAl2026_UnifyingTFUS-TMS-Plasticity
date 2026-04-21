function plot_phi(phi_out, Qout, tvec_out)
    % Extract signals (single node)
    phi = squeeze(phi_out(1,1,:));
    Q   = squeeze(Qout(1,1,:));

    % Plot comparison
    figure;
    plot(tvec_out, Q, 'b', 'LineWidth', 1.5); hold on;
    plot(tvec_out, phi, 'r--', 'LineWidth', 1.5);
    xlabel('Time (s)', 'Interpreter','latex');
    ylabel('Activity (Hz)', 'Interpreter','latex');
    legend('$Q$ (firing rate)', '$\phi$ (wave field)', ...
           'Interpreter','latex', 'Location','best');
    title('Comparison of $Q$ and $\phi$', 'Interpreter','latex');
    grid on;
end
