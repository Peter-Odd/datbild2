function val = similarity(a,b,opt)

switch opt
    case 'mse'
        % Mean square error
        val = sum((a(:)-b(:)).^2);
    case 'cor'
        % Correlation
        val = corr2(a,b);
end
        