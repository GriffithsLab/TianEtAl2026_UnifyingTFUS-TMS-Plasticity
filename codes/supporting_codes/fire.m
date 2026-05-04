function Q = fire(v, param)
    % Compute firing response from V
    Q = param.Q_max ./ (1.0 + exp(-(v - param.theta) ./ param.sigma));
end
