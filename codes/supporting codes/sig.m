function val = sig(x, slope)
    val = 1 ./ (1 + exp(-x.*slope));
end
