function dat_pca = pca_imudata(dat)

%   This function estimates the principal component of the IMU data in
%   order to reduce complexity

%   Copyright (C) Mai 2019
%   D. Pedrosa, University Hospital of Gieﬂen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

%fprintf('starting pca ... \n');
scaling = 'yes';
numcomp = 1;
fx_scale = @(x) sqrt(norm((x*x') ./ length(x)));
fx_transpose = @(x) x.';

dims = size(dat);                                                           % saves the dimensions to later use it
dat_pca = nan(dims(1), dims(3));                                            % pre allocates space to fill with data later

for ntr = 1:dims(3) %  loop through all trials available
    scale = fx_scale(squeeze(dat(:,:,ntr)));
    dat_temp = fx_transpose(dat(:,:,ntr)./scale);                           % scales dataaccording to scaling
    
    %% Estimation of mixing matrix according to FT code
    C = (dat_temp*dat_temp')./(size(dat_temp,2)-1);
    
    % eigenvalue decomposition (EVD)
    [E,D] = eig(C);
    
    % sort eigenvectors in descending order of eigenvalues
    d = cat(2,(1:1:size(dat_temp,1))',diag(D));
    d = sortrows(d, -2);
    
    % return the desired number of principal components
    unmixing = E(:,d(1:numcomp,1))';
    mixing = [];
    
    if isempty(unmixing) && ~isempty(mixing)
        if (size(mixing,1)==size(mixing,2))
            unmixing = inv(mixing);
        else
            unmixing = pinv(mixing);
        end
    elseif isempty(mixing) && ~isempty(unmixing)
        if (size(unmixing,1)==size(unmixing,2)) && rank(unmixing)==size(unmixing,1)
            mixing = inv(unmixing);
        else
            mixing = pinv(unmixing);
        end
    elseif isempty(mixing) && isempty(unmixing)
        % this sanity check is needed to catch convergence problems in fastica
        % see http://bugzilla.fieldtriptoolbox.org/show_bug.cgi?id=1519
        error('the component unmixing failed');
    end
    
    % compute the activations in each trial
    if strcmp(scaling, 'yes')
        comp = scale * unmixing * dat_temp;
    else
        comp = unmixing * dat_temp;
    end
    dat_pca(:,ntr) = comp';
end