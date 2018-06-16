function tCov_PT = covPT(tCov,vDetails)
%COVPT - Parallel transport for the covariances matrices

%% Riemannian Mean
vSubjects   = unique(vDetails).';
Nelc        = size(tCov,1);
tMeanCov    = nan(Nelc,Nelc,length(vSubjects));

for jj = 1:length(vSubjects)
    ii = vSubjects(jj);
    disp("Riemannian Mean over subject " + num2str(ii));
    vSessIdx            =   find(vDetails == ii);
    tMeanCov(:,:,jj)    =   RiemannianMean(tCov(:,:,vSessIdx));
end

%% Total Riemannian Mean
mMeanMeanCov = RiemannianMean(tMeanCov);

%% Parallel Transport
% figure;
tCov_PT                 = nan(Nelc,Nelc,size(tCov,3));
mMeanMinusSquareRoot    = mMeanMeanCov^(1/2);
for ii = 1:length(vSubjects)
    ss = vSubjects(ii);
    E  =  mMeanMinusSquareRoot / (tMeanCov(:,:,ii)^(1/2));
    vSessIdx            =   find(vDetails == ss);
    for jj = vSessIdx.'
        tCov_PT(:,:,jj) = E * tCov(:,:,jj) * E.';
    end
end

end

