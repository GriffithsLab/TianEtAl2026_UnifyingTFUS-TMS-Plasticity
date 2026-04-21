function xi = white_stim_nftsim(step, params)
%WHITE_STIM_NFTSIM  NFTsim-like white noise source.
%   xi = white_stim_nftsim(step, params)
%   - Uses a fixed seed (params.noise.ranseed) the *first* time it is called.
%   - Then generates xi ~ N(mean, asd) every call.
%
%   This reproduces NFTsim’s “one deterministic realization” behavior.

    persistent initialized

    if isempty(initialized)
        if isfield(params, 'noise') && isfield(params.noise, 'ranseed')
            rng(params.noise.ranseed, 'twister');  % fixed seed per simulation
        else
            rng(0, 'twister');                     % default if not given
        end
        initialized = true;
    end

    mu  = params.noise.mean;   % corresponds to "Mean:" in config
    sig = params.noise.asd;    % corresponds to "ASD:" in config

    % One NFTsim-style Gaussian sample:
    xi = mu + sig * randn();
end
