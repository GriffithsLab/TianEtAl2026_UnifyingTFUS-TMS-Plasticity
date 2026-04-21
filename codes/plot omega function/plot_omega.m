function plot_omega(params_new, params_fung)
    % Compare x, y, eta, omega vs Ca for new vs Fung setups
    %
    % params_new: struct with fields ltp, ltd, dth, pth, etc.
    % params_fung: struct with fields ltp, ltd, dth, pth, etc.

    % Ca range for plotting
    Ca_range = linspace(0, 1e-6, 500);

    % Preallocate arrays
    x_new = zeros(size(Ca_range));
    y_new = zeros(size(Ca_range));
    eta_new = zeros(size(Ca_range));
    omega_new = zeros(size(Ca_range));

    x_fung = zeros(size(Ca_range));
    y_fung = zeros(size(Ca_range));
    eta_fung = zeros(size(Ca_range));
    omega_fung = zeros(size(Ca_range));

    % Compute functions for each Ca
    for k = 1:length(Ca_range)
        Ca = Ca_range(k);

        % --- New setup ---
        x_new(k)     = x_of_Ca(Ca, params_new);
        y_new(k)     = y_of_Ca_simple(Ca, params_new);
        eta_new(k)   = x_new(k) + y_new(k);
        omega_new(k) = x_new(k) / (x_new(k) + y_new(k) + eps);

        % --- Fung setup ---
        x_fung(k)     = x_of_Ca(Ca, params_fung);
        y_fung(k)     = y_of_Ca_simple(Ca, params_fung);
        eta_fung(k)   = x_fung(k) + y_fung(k);
        omega_fung(k) = x_fung(k) / (x_fung(k) + y_fung(k) + eps);
    end

    % --- Plotting ---
    figure;

    grey = [0.5 0.5 0.5]; % grey color for thresholds

    % % x(Ca)
    % subplot(2,2,1);
    % plot(Ca_range, x_new, 'b-', 'LineWidth', 1.5); hold on;
    % plot(Ca_range, x_fung, 'b--', 'LineWidth', 1.5);
    % xline(params_new.dth, '--', 'Color', grey, 'LineWidth', 1);
    % xline(params_new.pth, '-.', 'Color', grey, 'LineWidth', 1);
    % xlabel('Ca (M)'); ylabel('x(Ca)');
    % legend('New setup','Fung 2014','dth','pth');
    % title('x(Ca)');
    % 
    % % y(Ca)
    % subplot(2,2,2);
    % plot(Ca_range, y_new, 'r-', 'LineWidth', 1.5); hold on;
    % plot(Ca_range, y_fung, 'r--', 'LineWidth', 1.5);
    % xline(params_new.dth, '--', 'Color', grey, 'LineWidth', 1);
    % xline(params_new.pth, '-.', 'Color', grey, 'LineWidth', 1);
    % xlabel('Ca (M)'); ylabel('y(Ca)');
    % legend('New setup','Fung 2014','dth','pth');
    % title('y(Ca)');
    % 
    % % eta(Ca) = x + y
    % subplot(2,2,3);
    % plot(Ca_range, eta_new, 'g-', 'LineWidth', 1.5); hold on;
    % plot(Ca_range, eta_fung, 'g--', 'LineWidth', 1.5);
    % xline(params_new.dth, '--', 'Color', grey, 'LineWidth', 1);
    % xline(params_new.pth, '-.', 'Color', grey, 'LineWidth', 1);
    % xlabel('Ca (M)'); ylabel('\eta(Ca) = x+y');
    % legend('New setup','Fung 2014','dth','pth');
    % title('\eta(Ca)');
    % 
    % % omega(Ca) = x / (x+y)
    % subplot(2,2,4);
    % plot(Ca_range, omega_new, 'k-', 'LineWidth', 1.5); hold on;
    % plot(Ca_range, omega_fung, 'k--', 'LineWidth', 1.5);
    % xline(params_new.dth, '--', 'Color', grey, 'LineWidth', 1);
    % xline(params_new.pth, '-.', 'Color', grey, 'LineWidth', 1);
    % xlabel('Ca (M)'); ylabel('\omega(Ca) = x/(x+y)');
    % legend('New setup','Fung 2014','dth','pth');
    % title('\omega(Ca)');
    % sgtitle('Comparison of x, y, \eta, \omega vs Ca');

    % omega(Ca) = x / (x+y)
    
    plot(Ca_range, omega_new, 'k-', 'LineWidth', 1.5); hold on;
    plot(Ca_range, omega_fung, 'k--', 'LineWidth', 1.5);
    xline(params_new.dth, '--', 'Color', grey, 'LineWidth', 1);
    xline(params_new.pth, '-.', 'Color', grey, 'LineWidth', 1);
    xlabel('Ca (M)'); ylabel('\omega(Ca) = x/(x+y)');
    legend('New setup','Fung 2014','dth','pth');
    title('\omega(Ca)');

    
end
