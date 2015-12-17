%GETANNENSEMBLE
%
% by: AP Palacz @ DTU-Aqua
% last modified: 07 Dec 2015
%

function [ net, netTr ] = get_ANNensemble ( Xtrain, Ytrain, Nesb, nN )

nDifNets = round(Nesb/numel(nN)) ; % divide the number of ensembles by the size of nN (how many net structures)
m = 1.0 ; % initialize m which will increase until m=nDifNets;

net   = cell(1,Nesb); % initialize the total net in a cell which will contain all indiv. net structures
netTr = cell(1,Nesb); % initialize the total net in a cell which will contain all indiv. net structures

for i = 1 : Nesb ;
    
    % Train
    if i == 1;
        % netType = [] ; % do this if you want to use interactive input
        netType = 2 ; % do this if you're sure you're using patrec
    end;
    
    % If this iteration is larger than intended # of classifiers with same structure, then increase number of neurons
    if i > nDifNets * m ;
        m = m + 1 ;
    end;
    nN2 = nN(m);
    
    % Train the ANN, bring out the net and training outputs
    [ ann, tr, netType ] = train_TrafficANN ( Xtrain', Ytrain', nN2 , netType ) ;  
    
    %assignin ( 'caller',  strcat ( 'net', num2str (i) ) , ann ) ;
    %assignin ( 'caller',  strcat ( 'netTr', num2str (i) ) , tr ) ;
  
    net{1,i} = ann ;
    netTr{1,i} = tr ;    
    
    %net{1,i} = eval ( strcat('net', num2str (i)) ) ;
    %netTr{1,i} = eval ( strcat('netTr', num2str (i)) ) ;
    
    clear ann tr;
    
end% for

end% function
