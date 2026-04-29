
function val = x_of_Ca(Ca, param)
    val = param.xth + param.ltp * sig(Ca - param.pth, param.x2);
end

