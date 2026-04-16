%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Format onsets and durations by encoding condition %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  @Juliette Boscheron
%
% This function formats onset and duration information for the MOTORMEM
% task by separating trials according to encoding condition (Foot vs
% NoFoot).
%
% It takes as input task names and their associated timing matrices, and
% returns cell arrays of names, onsets, and durations for direct use in
% SPM first-level GLM specification.


function [names,onsets, durations] = extract_onsetdur_for_spm(input)
    names=cell(1,2*length(input{1,1}));
    onsets=cell(1,2*length(input{1,1}));
    durations=cell(1,2*length(input{1,1}));
    j =1;k=1;
    for i=1:(2*length(input{1,1}))
        if mod(i,2)==0 
          %  no foot
            names{i}=strcat(input{1,1}{j}, '_nofoot');
            onsets{i}=input{1,2}{j}(find(input{1,2}{j}(:,4)==0),1);
            durations{i}=input{1,2}{j}(find(input{1,2}{j}(:,4)==0),3);
            j=j+1;
        else 
           % foot
            names{i}=strcat(input{1,1}{k}, '_foot');
            onsets{i}=input{1,2}{j}(find(input{1,2}{j}(:,4)==1),1);
            durations{i}=input{1,2}{j}(find(input{1,2}{j}(:,4)==1),3);
            k=k+1;
        end
    end
end