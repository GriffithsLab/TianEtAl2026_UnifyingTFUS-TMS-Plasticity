import numpy as np

# ============================================================
# NFTsim-style white noise source
# ============================================================

_white_stim_initialized = False

def reset_white_stim_nftsim():
    """
    Reset the persistent RNG state.

    Call this once before each new simulation
    when running multiple protocols in a loop.
    """
    global _white_stim_initialized
    _white_stim_initialized = False


def white_stim_nftsim(step, params):
    """
    NFTsim-like white noise source.

    Uses a fixed RNG seed ONLY on first call,
    then generates deterministic Gaussian samples
    throughout the simulation.

    Parameters
    ----------
    step : int
        Simulation step index (kept for compatibility
        with MATLAB version; not explicitly used)

    params : namespace
        Must contain:
            params.noise.ranseed
            params.noise.mean
            params.noise.asd
    """

    global _white_stim_initialized

    # MATLAB persistent-style initialization
    if not _white_stim_initialized:

        if hasattr(params, "noise") and hasattr(params.noise, "ranseed"):
            np.random.seed(params.noise.ranseed)
        else:
            np.random.seed(0)

        _white_stim_initialized = True

    mu  = params.noise.mean
    sig = params.noise.asd

    # One Gaussian sample
    xi = mu + sig * np.random.randn()

    return xi
