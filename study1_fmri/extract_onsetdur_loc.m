%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Format onsets and durations for the motor localizer task %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  @Juliette Boscheron
%
% This function formats onset and duration information for the motor
% localizer task, in which participants alternated between Move and Rest
% blocks.
%
% It takes as input condition names and corresponding timing matrices,
% and returns names, onsets, and durations in a format compatible with
% SPM first-level model specification.


function [names,onsets, durations] = extract_onsetdur_loc(input)
    
    names=cell(1,length(input{1,1}));
    onsets=cell(1,length(input{1,1}));
    durations=cell(1,length(input{1,1}));
    for i=1:length(input{1,1})
          names{i}=strcat(input{1,1}{i}, '_all');
          onsets{i}=input{1,2}{i}(:,1);
          durations{i}=input{1,2}{i}(:,3);
    end
end