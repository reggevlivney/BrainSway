function M = RiemannianMean(tC)

Np = size(tC, 3);
M  = mean(tC, 3);

WAITBAR = false;

if WAITBAR == true
    h = waitbar(0, 'Riemannian Mean');
end
for ii = 1 : 20
    if WAITBAR == true
        waitbar(ii / 20);
    end
    A = M ^ (1/2);      %-- A = C^(1/2)
    B = A ^ (-1);       %-- B = C^(-1/2)
        
    S = zeros(size(M));
    for jj = 1 : Np
        C = tC(:,:,jj);
        S = S + A * logm(B * C * B) * A;
    end
    S = S / Np;
    
    M = A * expm(B * S * B) * A; 
    
    eps = norm(S, 'fro');
    if (eps < 1e-6)
        break;
    end
end
if WAITBAR == true
    close(h);
end

end