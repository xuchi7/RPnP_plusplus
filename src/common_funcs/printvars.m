function printvars(varargin)
    for i = 1:nargin
        fprintf(num2str(varargin{i}));
        fprintf(' ');
    end
    fprintf('\n');
end