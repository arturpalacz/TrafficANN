%TRAIN_TRAFFICANN  Train an Artificial Neural Network
%
%

% --------------------------------------------------------------------------------------
% Copyright: AP Palacz @ DTU-Aqua
% last modified: 15 Oct 2014
% --------------------------------------------------------------------------------------
%
% 09 Sep 2013
%   Changed net to nett to solve the naming conflict
% 16 July 2014
%   Added the choice between feedforward net and patrec net. Nettype is passed as output argument after the first choice
% 15 Oct 2014
%   Changed windowdisplay to OFF for saving time in large ensemble simulations
%

function  [ ann, tr, netType ] = train_TrafficANN ( inputs, targets, nN , netType )

clear net nett

format longe

%% Create a Fitting Network

if isempty ( netType ) == 1;
    disp ({1,'Feedforward net'; 2, 'Pattern Recognition Net'});
    netType = input ('Select type of net: ');
end;

switch netType
    case 1
        nett = feedforwardnet ( nN ) ;
        % For a list of all plot functions type: help nnplot
        nett.plotFcns = { 'plotperform', 'plottrainstate', 'ploterrhist', 'plotregression', 'plotwb' };
        
    case 2
        nett = patternnet ( nN ) ;
        % For a list of all plot functions type: help nnplot
        nett.plotFcns = { 'plotperform', 'plottrainstate', 'plotroc', 'plotconfusion', 'plotwb' };
        
end;

%% Data preprocessing
nett.inputs{1}.processFcns  = {'removeconstantrows','mapminmax'}; %,'fixunknowns','mapstd'};
nett.outputs{2}.processFcns = {'removeconstantrows','mapminmax'}; %,'fixunknowns','mapstd'};

%% Setup Division of Data for Training, Validation, Testing
% For a list of all data division functions type: help nndivide
nett.divideFcn = 'dividerand';  % Divide data randomly

nett.divideMode = 'sample';  % Divide up every sample
nett.divideParam.trainRatio = 70/100;
nett.divideParam.valRatio   = 15/100;
nett.divideParam.testRatio  = 15/100;

%% Choose the transfer function
nett.layers{1}.transferFcn = 'tansig';

%% Choose training algorithm
% For help on training function 'trainlm' type: help trainlm
% For a list of all training functions type: help nntrain
nett.trainFcn = 'trainlm';  % Levenberg-Marquardt

%nett.trainFcn = 'traingdx';  % Variable learning rate --> quick but bad, 44%
%nett.trainFcn = 'trainbr';   % Bayesian regularization --> good, 86% before the end of training, long training
%nett.trainFcn = 'trainbfg';  % BFGS Quasi-Newton -- > good but many negative values 86%, long (9min)
%nett.trainFcn = 'traingdm';  % Gradient Descent with Momentum --> very bad 14%, finds a local minimum and stays
%nett.trainFcn = 'trainscg';  % Scaled Conjugate Gradient --> good 83%, few negative, really long, 19min without end

%% Choose a Performance Function
% For a list of all performance functions type: help nnperformance
nett.performFcn = 'mse';  % Mean squared error

%% Set display properties
nett.trainParam.showWindow      = false ; % 1-true, 0-false
nett.trainParam.showCommandLine = false ;

%% Train the Network
%[pn,ps] = mapminmax(inputs);
%[tn,ts] = mapminmax(targets);

%tic
[ ann, tr ] = train ( nett, inputs, targets );
%toc

%% Test and evaluate the Network
% outputs       = nett       ( inputs                );
% errors        = gsubtract (      targets, outputs );
% performance   = perform   ( nett, targets, outputs );

end