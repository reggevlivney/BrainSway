function mDists = cal_dist_mat(tDataCov)
%% calculates the distances matrix using Rimannian distances
Nmats   =   size(tDataCov,3);
mDists  =   zeros(Nmats,Nmats);
    for ii = 1:Nmats
        for jj = ii+1:Nmats
            mDists(ii,jj) = RiemannianDist(tDataCov(:,:,ii),tDataCov(:,:,jj));
            mDists(jj,ii) = mDists(ii,jj);
            disp("RimannianDist over: " + num2str(ii) + "," + num2str(jj))
        end
    end
end