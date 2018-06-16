function [] = printcov(tDataCov,mDetails,nSubj,nSess,nTrial)
%PRINTCOV - printing the selected covariance
idx     =   find(mDetails(:,1)==nSubj & mDetails(:,2)==nSess);
    if length(idx)>=nTrial
        figure;
        image(tDataCov(:,:,idx(nTrial)));
        t = title("Cov of Subject: " +num2str(nSubj) + ", Session: " + num2str(nSess) + ", Trial: " + num2str(nTrial));
        t.FontSize = 18;
    else
        disp("can't find this cov");
    end
end

