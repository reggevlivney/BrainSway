
M               = randn(62, 2000);
M               = M - mean(M, 2);
[U, S, V]       = svd(M);
L               = 60;
S(L:L+1, L:L+1) = 0;
X               = U * S * V';

T1          = randn(62);
T1          = T1 * T1';
[Ut, St]    = eig(T1);
T1          = Ut * Ut';



Y           = [T1 * U(:,1:L), U(:,61:62)] * S * V;

[Ux, Sx, Vx] = svd(X);
[Uy, Sy, Vy] = svd(Y);

Unx = Ux(:,61:62);
Uny = Uy(:,61:62);

P = Unx' * Uny
abs(eig(P))

