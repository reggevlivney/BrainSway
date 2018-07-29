function y = EEG_BL_filter(x)
    [Ne,T] = size(x);
    y = nan(3*Ne,T);
    for ii = 1 : Ne
            y(ii,:)      = alphaFilter(x(ii,:));
            y(ii+Ne,:)   = betaFilter(x(ii,:));
            y(ii+2*Ne,:) = thetaFilter(x(ii,:));
    end
end

