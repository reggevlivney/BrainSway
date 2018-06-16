function tCov_PT = covPT(tCov,mDetails)
%COVPT - Parallel transport for the covariances matrices

%% Riemannian Mean
vSubjects   = unique(mDetails(:,1)).';
Nelc        = size(tCov,1);
tMeanCov    = nan(Nelc,Nelc,length(vSubjects));

for ii = vSubjects
    disp("Riemannian Mean over subject " + num2str(ii));
    vSessIdx            =   find(mDetails(:,1) == ii);
    tMeanCov(:,:,ii)    =   RiemannianMean(tCov(:,:,vSessIdx));
end

%% Total Riemannian Mean
mMeanMeanCov = RiemannianMean(tMeanCov);

%% Parallel Transport
% figure;
tCov_PT                 = nan(Nelc,Nelc,size(tCov,3));
mMeanMinusSquareRoot    = mMeanMeanCov^(1/2);
for ii = vSubjects
    E =  mMeanMinusSquareRoot / (tMeanCov(:,:,ii)^(1/2));
    vSessIdx            =   find(mDetails(:,1) == ii);
    for jj = vSessIdx.'
        tCov_PT(:,:,jj) = E * tCov(:,:,jj) * E.';
    end
end

end

