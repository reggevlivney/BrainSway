function y = EEG_filter(x)
    [Ne,T,Nt] = size(x);
    y = nan(3*Ne,T,Nt);
    for ii = 1 : Ne
        for nn = 1 : Nt
            y(ii,:,nn)      = alphaFilter(x(ii,:,nn));
            y(ii+Ne,:,nn)   = betaFilter(x(ii,:,nn));
            y(ii+2*Ne,:,nn) = thetaFilter(x(ii,:,nn));
        end
    end
end

