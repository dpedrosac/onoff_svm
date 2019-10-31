figure; hold on

recs = 3;
cond = 'diadochokinesia';
par = {'diadochokinesia', 'rest', 'hold', 'tapping'};
idx_par = find(strcmp(par, cond));
idx = find(cell2mat(s{recs}.tble(:,7)));                % index of available recordings according to s{x}.tble
idx = idx(1:end-1);                                     % skip last recording to avoid problem with cutting data


if recs > 2; r = 2; else;r = 1; end
beg_trls = ...
    cell2mat(s{recs}.tble(idx,8))-s{recs}.offset*s{recs}.rateIMU;
trldat{1} = ceil(repmat(beg_trls,[1,dur*srIMU]) + ...   % (trldat{1}) = start index for all trials in continuous recording for IMU
    repmat([0:srIMU*dur-1], [size(beg_trls,1), 1]));

idx_cond = find(strcmp(s{recs}.tble(idx,3), cond));  % idx of the condition to be extracted
no = 3;

subplot(3,1,1);
plot(s{recs}.gyro(trldat{1}(idx_cond(no),:),:)); %original data

subplot(3,1,2);
plot(squeeze(imu_gyro{idx_par,r}(:,:,no)))