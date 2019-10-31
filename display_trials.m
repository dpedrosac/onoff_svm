% test script

clearvars -except s
figure(99);
cond = 'hold';
tno = 2;
time_vec = s{tno}.timeEMG;
% idx = find(cell2mat(cellfun(@(x) strcmp({cond}, x), s{tno}.tble(:,3), 'UniformOutput', 0)));
idx = find(cell2mat(cellfun(@(x) ~isempty(x), s{tno}.tble(:,1), 'UniformOutput', 0)));
sr = 200;

for k = 1:numel(idx)
    if k ~= numel(idx); pt = 15; else pt = 5; end
    subplot(6,5,k);
    time_idx = [cell2mat(s{tno}.tble(idx(k),7)):1:cell2mat(s{tno}.tble(idx(k),7))+pt*sr];
    
%     time_ids(1) = dsearchn(time_vec, cell2mat(s{tno}.tble(idx(k),8)));
%     time_ids(2) = time_ids(1) + 15*sr;
%     plot(time_vec(time_ids(1):time_ids(2),:), s{tno}.accel(time_ids(1):time_ids(2),:))
    plot([0:pt*sr]./1/sr, s{tno}.emg(time_idx,:));
    title(cell2mat(s{tno}.tble(idx(k),3)))
    
    idx_marker = dsearchn(time_vec, s{tno}.timeEMG(cell2mat(s{tno}.tble(idx(k),7))));
%     hold on; plot(time_vec(idx_marker)*[1 1], [-2, 2])
end

%%
figure(1);
cond = 'hold';
tno = 2;
time_vec = s{tno}.timeEMG;
% idx = find(cell2mat(cellfun(@(x) strcmp({cond}, x), s{tno}.tble(:,3), 'UniformOutput', 0)));
idx = find(cell2mat(cellfun(@(x) ~isempty(x), s{tno}.tble(:,1), 'UniformOutput', 0)));
sr = 200;

for k = 1:numel(idx)
    if k ~= numel(idx); pt = 15; else; pt = 5; end
    subplot(6,5,k);
    time_idx = [cell2mat(s{tno}.tble(idx(k),7)):1:cell2mat(s{tno}.tble(idx(k),7))+pt*sr];
    
%     time_ids(1) = dsearchn(time_vec, cell2mat(s{tno}.tble(idx(k),8)));
%     time_ids(2) = time_ids(1) + 15*sr;
%     plot(time_vec(time_ids(1):time_ids(2),:), s{tno}.accel(time_ids(1):time_ids(2),:))
    plot([0:pt*sr]./1/sr, s{tno}.emg(time_idx,:));
    title(cell2mat(s{tno}.tble(idx(k),3)))
    
    idx_marker = dsearchn(time_vec, s{tno}.timeEMG(cell2mat(s{tno}.tble(idx(k),7))));
%     hold on; plot(time_vec(idx_marker)*[1 1], [-2, 2])
end