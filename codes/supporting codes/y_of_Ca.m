function val = y_of_Ca(Ca, param, yth_override)
    % If a per-dendrite yth is provided, use it; otherwise fall back to global param.yth
    % if nargin < 3 || isempty(yth_override)
    %     yth_loc = param.yth;
    % else
    %     yth_loc = yth_override;
    % end
    yth_loc = yth_override;
    val = yth_loc + param.ltd * sig(Ca - param.dth, param.y2) ...
                  - param.ltd * sig(Ca - param.pth, param.y2);
end