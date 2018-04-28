cd D:\BrainSwayData\Exp_EC\mat\
files = dir('*.mat');
n   =   16;
% Loop through each
for id = 1:length(files)
    % Get the file name (minus the extension)
    [~, f] = fileparts(files(id).name);
        f  = f(1:n);
        try
    movefile(files(id).name,[f,'.mat']);
        catch 
        end
        flag = 1;
end
