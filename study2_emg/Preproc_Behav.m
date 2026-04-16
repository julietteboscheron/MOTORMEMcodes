%% What does this do?
% Preproc_Behav creates the behavioural df's from the exvr logs output
% during the task.
%%
function Preproc_Behav(cfg_input)

GeneralVariables;
ObstaclesNames;

subj_list = cfg_input.subj_list;

% Loop on subjects
for isubj = 1:length(subj_list)

    % Init
    subj = subj_list(isubj);
    disp(['Preprocessing behav, subject ' num2str(subj)]);

    % Load
    % Initialize data_recall as an empty table
    data_recall = table();

    % Exception handling for subject 63 with missing datafile_recall1 (add
    % other exceptions as required)
    if subj ~= 63
        datafile_recall1 = dir([path2rawdata '/sub-' num2str(subj) '/recall/block1/log_exvr-designer*']);
        if ~isempty(datafile_recall1)
            data_recall1 = readtable([path2rawdata '/sub-' num2str(subj) '/recall/block1/' datafile_recall1.name]);
            data_recall = [data_recall; data_recall1];  % Append data_recall1 if it exists
        end
    end

    % Proceed to load datafile_recall2 as usual
    datafile_recall2 = dir([path2rawdata '/sub-' num2str(subj) '/recall/block2/log_exvr-designer*']);
    if ~isempty(datafile_recall2)
        data_recall2 = readtable([path2rawdata '/sub-' num2str(subj) '/recall/block2/' datafile_recall2.name]);
        data_recall = [data_recall; data_recall2];  % Append data_recall2
    end

    % Loading encoding data
    datafile_encod = dir([path2rawdata '/sub-' num2str(subj) '/encoding/Results_Sub*.txt']);
    if ~isempty(datafile_encod)
        data_encod = readtable([path2rawdata '/sub-' num2str(subj)  '/encoding/' datafile_encod.name]);
    else
        disp(['Encoding data file not found for subject ' num2str(subj)]);
    end

    % Load recall condition data
    datafile_recallcond = dir([path2rawdata '/sub-' num2str(subj) '/recall/part2/log_exvr-designer-*.csv']);
    if ~isempty(datafile_recallcond)
        data_recallcond = readtable([path2rawdata '/sub-' num2str(subj) '/recall/part2/' datafile_recallcond.name]);
        data_recallcond.words = Preproc_Behav_CorrectObstNames({data_recallcond.words{:,1}})';
    else
        disp(['Recall condition data file not found for subject ' num2str(subj)]);
    end


   
    % Get recall variables
    word = {};
    for itrl = 1:size(data_recall, 1)
        word = [word data_recallcond.words{itrl}];
    end
    index_recall = Preproc_Behav_OrderObstRecall({obstacles{:,2}}, word);  % Find order in which obstacles (as in obstacles) were presented during recall
    q1 = data_recall.q1;
    q2 = data_recall.q2;
    q3 = data_recall.q3;
    q4 = data_recall.q4;

    % Get encoding variables
    %if subj == 3 | subj == 6  % These subjects started the task and then was interrupted, so started again
    %     i_barrier = find(contains(data_encod.Var3, 'Barrier'));  % Remove first part of the task and keep only second run
    %     data_encod(1:i_barrier(3)-1,:) = [];
    % end
    obstacle_encod = data_encod.Var3(~isnan(data_encod.Var7));
    i_barrier=find(contains(obstacle_encod, 'Barrier'));
    obstacle_encod(i_barrier)=[];
    index_encod=Preproc_Behav_OrderObstRecall({obstacles{:,2}}, obstacle_encod);% Find order in which obstacles (as in word) were presented during encoding
    reorder_encod = Preproc_Behav_OrderObstRecall(word, obstacle_encod);  % Reorder encoding to match order of obstacles in recall
    trial_cond_encod = data_encod.Var7(~isnan(data_encod.Var7));
    trial_cond_encod(i_barrier) = [];
    trial_cond = trial_cond_encod(reorder_encod);  % foot or no foot condition at encoding, for each trial in the order of recall

    % Get Signal Detection Theory conditions
    
    recalled_cond = data_recallcond.foot_nofoot;  % extract answers on recall cond task
    obst_recallcondtask = data_recallcond.words;  % extract obstacle names on recall cond task
    i_barrier = find(contains(obst_recallcondtask, 'Barrier'));  % find barrier osbtacle
    recalled_cond(i_barrier) = [];  % Remove barrier obstacle from answers
    obst_recallcondtask(i_barrier) = [];  % Remove barrier obstacle from obstacle names
    index_recallcond = Preproc_Behav_OrderObstRecall(word, obst_recallcondtask);  % find new order for recall cond trials to match the order of recall trials
    recalled_cond = recalled_cond(index_recallcond);  % reorder recall cond trials to match recall task
    SDT_cond = zeros(1, length(trial_cond));  % init vector foLARMS
    SDT_cond(trial_cond==1 & recalled_cond==0) = 2;  % MISSES SDT values
    SDT_cond(trial_cond==1 & recalled_cond==1) = 4;  % HITS (Both trial_cond and recalled_cond are order as the recall task)
    SDT_cond(trial_cond==0 & recalled_cond==1) = 3;  % FALSE ALARM
    SDT_cond(trial_cond==0 & recalled_cond==0) = 1;  % CORRECT REJECTIONS
   


    % Save
    save(['../Data_/DataProcessed_/s'  num2str(subj) '/databehav_trialcond.mat'], 'trial_cond','word', 'q1','q2','q3','q4', 'index_recall', 'index_encod', '-v7.3');
    save(['../Data_/DataProcessed_/s'  num2str(subj) '/databehav_SDTcond.mat'], 'SDT_cond', '-v7.3');
    save(['../Data_/DataProcessed_/s'  num2str(subj) '/databehav_otherVars.mat'], 'recalled_cond', 'word', 'q1','q2','q3','q4', 'index_recall', 'index_encod', '-v7.3');  

end