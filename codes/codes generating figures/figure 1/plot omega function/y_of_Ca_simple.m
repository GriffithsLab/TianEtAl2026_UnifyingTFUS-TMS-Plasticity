function val = y_of_Ca_simple(Ca, param)
    
    % specific nu and nu_max per synapse
    % nu = 1.2e-3;
    % nu_max = 1e-2;

    nu = 13e-6;
    nu_max = 80e-6;

    yth_loc = param.xth * (nu_max-nu)/nu; 
    val = yth_loc + param.ltd * sig(Ca - param.dth, param.y2) ...
                  - param.ltd * sig(Ca - param.pth, param.y2);
end