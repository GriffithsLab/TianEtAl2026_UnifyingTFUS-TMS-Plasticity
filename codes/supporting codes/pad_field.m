function field_padded = pad_field(field, boundary)
    % field: 2D array (Ny x Nx)
    % boundary: 'torus' or 'sphere'
    %
    % returns: padded array with 1-cell ghost border

    [Ny, Nx] = size(field);

    % Start with zeros + interior copy
    field_padded = zeros(Ny+2, Nx+2);
    field_padded(2:Ny+1, 2:Nx+1) = field;

    if strcmpi(boundary, 'torus')
        % --- Top ghost row = bottom row
        field_padded(1, 2:Nx+1)   = field(end, :);
        % --- Bottom ghost row = top row
        field_padded(end, 2:Nx+1) = field(1, :);

        % --- Left ghost col = right col
        field_padded(2:Ny+1, 1)   = field(:, end);
        % --- Right ghost col = left col
        field_padded(2:Ny+1, end) = field(:, 1);

        % --- Four corners
        field_padded(1,1)     = field(end,end);
        field_padded(1,end)   = field(end,1);
        field_padded(end,1)   = field(1,end);
        field_padded(end,end) = field(1,1);

    elseif strcmpi(boundary, 'sphere')
        % --- Top ghost row = reversed bottom row
        field_padded(1, 2:Nx+1)   = fliplr(field(end, :));
        % --- Bottom ghost row = reversed top row
        field_padded(end, 2:Nx+1) = fliplr(field(1, :));

        % --- Left ghost col = right col
        field_padded(2:Ny+1, 1)   = field(:, end);
        % --- Right ghost col = left col
        field_padded(2:Ny+1, end) = field(:, 1);

        % --- Four corners (approx same as C++ version)
        field_padded(1,1)     = field(end,end);
        field_padded(1,end)   = field(end,1);
        field_padded(end,1)   = field(1,end);
        field_padded(end,end) = field(1,1);
    else
        error('Unknown boundary type: %s', boundary);
    end
end
