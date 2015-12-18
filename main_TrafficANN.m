%MAIN_TRAFFICANN Main script which calls subroutines to build an ensemble of pattern recognition models to
%interpret ecosystem indicator data used to construct traditional "traffic
%light" diagrams, and to build a simple decision support tool that
%allows to explore different regimes within a given ecosystem.

% --------------------------------------------------------------------------------------
% by: AP Palacz @ DTU-Aqua
% by: MA St. John @ DTU-Aqua
% last modified: 18 Dec 2015
% --------------------------------------------------------------------------------------
% 24 Jul 2014: created the first version of the programme
% 16 Oct 2014: added classifier diversity estimate
% 17 Oct 2014: implemented the "regime guesser" GUI
% 21 Oct 2014; added errorbars on the GUI
% 22 Oct 2014: added the objective feature selection capability
% 01 Dec 2015: restructured the programme
% 07 Dec 2015: improved the efficiency of the programme
% 08 Dec 2015: added user interactive inputs, comments
% 17 Dec 2015: included the ui-plotting for DSS
% --------------------------------------------------------------------------------------

% Initialize the environment by:
clear all ; % clearing the workspace
close all ; % closing all figures
clc ; % clearing the command window

global DIR % global variables i.e. read by every subroutine

% -------------- MAKE CHANGES HERE !!! -------------------------------------------------
% Specify the input directory for all data files:
% DIR = '/home/arpa/Documents/DTU/projects/EURO-BASIN/Traffic_Light_Model/' ;
DIR = '/Volumes/n-faelles/Mike_and_Artur_AI/TrafficANN/';
%
% DIR = '.../N-faelles/PalaczAP/traffic/ '; % all the data used for my Machine
% Learning analysis is backed up at the N-Drive under /PalaczAP folder
% --------------------------------------------------------------------------------------

% Display numbers in non-scientific format
format shortg

% Default docked figures
set ( 0, 'DefaultFigureWindowStyle', 'normal' ) ; %or docked, or modal

% Create a pool with n clusters for paraller matlab computing
% myPool = parpool(2) ;

%% Choose region and load the integrated ecosystem indicator suite
% NB: Don't change the abbreviations in "regions" unless you change the
% names of data files accordingly
regions = { 1, 'GoR'        , 'Gulf of Riga'        ; ... 
            2, 'CBS'        , 'Central Baltic Sea'  ; ... 
            3, 'NAtlantic'  , 'North Atlantic'      ; ...
            4, '...'        , '...'                 } ;   
        
disp ( regions ) ;

reg = input ( 'Select the index of the region you want to work on: ' ) ;

[ indicators, data_type ] = load_iea_indicators ( regions{reg,2} ) ;
% indicators.values should have time series in rows, variables in columns

%% Fill in the blanks, or delete years with missing data

missing_opts = { 1, 'fill in the blanks'; ...
                 2, 'use complete indicators only' } ;

disp ( missing_opts ) ;

how_missing = input ( 'Select missing data treatment option from the list above [ENTER for default = 1 ]: ' ) ;

if isempty ( how_missing ) % get the default value if no other specified
    how_missing = 1 ;
end

switch how_missing 
    
    case 1 % fill in (recommended)
    
        [ indicators.values, fnan ] = cleanup_iea ( indicators.values, data_type ) ;
        indicators.labels(fnan) = [] ; clear fnan ;
    
    case 2 % skip incomplete indicators (not recommended)
        
        [ indicators, idx ] = select_features ( indicators, 'complete' ) ;
        % idx is the index of retained features

end

%% Optionally, convert raw data to quantiles if not done already:
if strcmp(data_type,'raw') == 1
    
    data_opts = input ('Use raw data (0) or quantiles (1)?: ') ;
    
    if data_opts == 1 ; % yes, convert to quantiles
        
        temp = indicators.values ;
        
        % Convert into quantiles
        p = 0 : 0.2 : 1 ;
        for n = 1 : length(indicators.labels) ;
            
            breaks = quantile ( temp(:,n), p, 1 ) ;
            
            temp2(:,n) = ordinal ( temp(:,n), {'1','2','3','4','5'}, ...
                [], breaks ) ;
        end
        
        indicators.values = double ( temp2 ) ;
        clear breaks temp temp2 p ;
        
    end
end

%% Load or classify regimes corresponding to indicators
% All datasets are already classified in terms of regimes by expert
% knowledge (C. Mollmann) but there are several options for the number of
% regimes identified. Either select a number of regimes OR use the optional
% ANN-based clustering tool to identify regime number
regimes_opts = { 1, 'expert classification'     ; ...
                 2, 'machine learning classification'} ;
        
disp ( regimes_opts ) ;

how_regimes = input ('Select method of classification [ENTER default = 1]: ') ;

if isempty ( how_regimes ) % get the default value if no other specified
    how_regimes = 1 ;
end

switch how_regimes
    
    case 1 % expert regime identification (by Christian)
        
        [ nReg, regimes ] = load_iea_regimes ( regions{reg,2} ) ;
        
    case 2 % machine learning clustering
        
        clusters = { 1, 'kmeans' ; ...
                     2, 'hierarchical clustering' } ;
                 
        disp ( clusters ) ;
        
        how_cluster = input ( 'Select clustering method to identify regimes [ENTER default = 1]: ' ) ;
        
        if isempty ( how_cluster ) % get the default value if no other specified
            how_cluster = 1 ;
        end
        
        switch how_cluster
            
            case 1 % kmeans
                
                kC = 5 ; % max number of clusters/regimes to be explored
                
                [ avgSilh, nReg, regs_opts, regimes ] = my_kmeans ( indicators.values, kC ) ;
                
                % To see the difference in avg silhuette value between diff
                % n of regimes, type "disp(avgSilh)", given on a 0-1 scale.
                
                sprintf ( '%s%d', 'The suggested optimal number of clusters/regimes is: ', nReg ) 
                
            case 2 % hierarchical clustering
                
                my_HierarchicalCluster ( indicators.time, indicators.values ) ;
                
                % NB: Visually inspect the dendrogram to determine what is the
                % optimal cluster size, e.g. by the number of non-black
                % colors.
                % Need to create a regimes array manually then. 
                
                disp('Warning! To continue, you need to provide the number of regimes, and regime index vector!');
                disp ( 'e.g. nReg = 3 ' ) ; 
                nReg = input ('"nReg" equals: ') ;
                disp ( 'e.g. regimes = [1 1 1 ... 2 2 2 ... 3 3 3 ... ] ' ) ;
                regimes = input ( '"regimes" equals: ') ;
                
        end% switch: how_cluster
        
end% switch: how_regimes
        
%% Feature selection
% Selec from among a list of options to select the final indicator suite:
featSelect_opts = { 1, 'corrmap' , 'Correlation map'     ; ...
                    2, 'simple'  , 'Simple filter'       ; ...
                    3, 'all'     , 'All inputs'          ; ...
                    4, 'complete', 'Complete only'       ; ...
                    5, 'random5' , 'Random 5'            ; ...
                    6, 'pca1'    , '5 highest PCA1'      ; ...
                    7, 'expert5' , 'expert 5 selected '  } ;

disp ( featSelect_opts ) ;

how_features = input ( 'Choose a feature selection method from the above [ENTER default = 7]: ' ) ;

if isempty ( how_features )
    how_features = 7 ;
end

[ indicators2, idx ] = select_features ( indicators, featSelect_opts{how_features,2}) ;
   

nFeat = length ( indicators2.labels ) ; % final length of the indicators suite
nTime = length ( indicators.time   ) ; % final time series length

X    = indicators2.values ; 
Yint = regimes ; % regimes represented as a single column vector with integers

%% Convert the Yint verctor with n regime indices into n columns with binary regime labels (1-yes,0-no) necessary for pattern recognition 
Ybin = zeros ( nTime, nReg ) ;
for nt = 1 : nReg ;
    ff = Yint == nt ; % find all rows with that regime index
    Ybin ( ff, nt ) = 1 ; % assign 1s to the corresponding regime column
end

%% Random permutation (to remove chronological bias when building the patrec tool)
randindx = randperm ( nTime ) ;

X = X ( randindx, : ) ; % permute indicators
Ybin = Ybin ( randindx, : ) ; % permute regimes according to same index
Yint = Yint ( randindx, : ) ; % as above, for the binary regime array

%% Train ANN-based pattern/regime recognition model

% Parition data for cross validation
% cv = cvpartition ( length(X), 'Holdout', 0.3 ) ;
kf = 3 ; % number of folds
cv = cvpartition ( length(X), 'Kfold', kf ) ;

Nesb = 10 ; % number of ANNs in an ensemble

nets   = cell (1, kf*Nesb ) ; % initialize the all nets cell array, number of folds times number of ensemble members
netsTr = cell (1, kf*Nesb ) ;

for i = 1 : cv.NumTestSets ;
    
    clear net netTr Xtrain Ytrain Xtest Xtrain regYtest regYtrain ;
    
    % Training set
    trainX    = X    ( training ( cv, i ), : ) ;
    trainYbin = Ybin ( training ( cv, i ), : ) ;
    trainYint = Yint ( training ( cv, i ), : ) ;
    
    % Test set
    testX    = X    ( test ( cv, i ), : ) ;
    testYbin = Ybin ( test ( cv, i ), : ) ;
    testYint = Yint ( test ( cv, i ), : ) ;
    
    % Display how many samples of each regime per training and test set,
    % respecitvely.
    disp ( 'Training Set' )
    tabulate ( vec2ind ( trainYbin' ) )
    
    disp ( 'Test Set' )
    tabulate ( vec2ind ( testYbin' ) )
    
    % Train multiple ANNs
    %nN =  [ 8 10 15 20 ] ; % number of neurons in the hidden layer
    nN =  5 ; % number of neurons in the hidden layer
    
    [ net, netTr ] = get_ANNensemble ( trainX, trainYbin, Nesb, nN ) ;
    
    % Evaluate training and test sets using a trained ensemble:
    
    [ Ztrain, enZtrain, enZsctrain, Ctrain, enCtrain ] = eval_ANNensemble ( trainX, trainYint, nReg, Nesb, net, 'off' ) ;
    
    disp(Ctrain);
    fprintf ( 'Prediction accuracy on training set: %f\n\n', enCtrain )
    
    [ Ztest, enZtest, enZsctest, Ctest, enCtest ] = eval_ANNensemble ( testX, testYint, nReg, Nesb, net, 'on' ) ;
   
    disp ( Ctest );
    fprintf ( 'Prediction accuracy on test set: %f\n\n', enCtest )
    
    accu_sum(i,1:2) = [ enCtrain enCtest] ;
    
    % to store all nets, use the following:
    nets  (1,(i-1)*Nesb+1:i*Nesb) = net ;
    netsTr(1,(i-1)*Nesb+1:i*Nesb) = netTr ;

% Classifier diversity - work in progress
% [ P(i), Q(i) ] = calcANNdiversity ( net, Ztest, regYtest ) ;

end% for

%% Apply all the nets to the entire time series:
[ Ztest, enZtest, enZsctest, Call, enCall ] = eval_ANNensemble ( X, Yint, nReg, Nesb, nets, 'on' ) ;

disp(Call);

fprintf ( 'Prediction accuracy on entire set: %f\n\n', enCall )

%% Mean/mode inputs for a regime:
initFigure ( 'w', 18, 12, 'on', 'normal' )

fs = 8 ; % font size
set(0,'defaulttextinterpreter','none')

for n = 1 : nReg ;

    f = Yint == n  ;
    
    for m = 1 : nFeat ;
        indicators2.mode(m,n) = mode ( X (f,m) ) ;
        indicators2.mean(m,n) = mean ( X (f,m) ) ;
    end
    clear f ;
    
    subplot(1,nReg,n)
    
    bar (indicators2.mode(:,n),'FaceColor','k') ;
    
    title(['Regime',num2str(n)],'FontSize',fs+2)
    ylim([0 6]); xlim([0 nFeat+1]);
    set(gca,'xtick',(1:nFeat),'xticklabel',indicators2.labels,...
        'xticklabelrotation',25,'ytick',(1:5),...
        'fontsize',fs,'box','off');
    ylabel('mode quantile value','FontSize',fs+4);

end
% pwd stands for current folder
export_fig ( [pwd, 'GoR_regimes',num2str(nReg),'_features',num2str(nFeat)], '-tif')

%% Simple DSS tool prototype
switch how_features
    
    case 5 % random 5
        
        DSS ( nets, indicators2.labels) ;

    case 6 % 5 highest PCA1 values
       
        DSS ( nets, indicators2.labels) ;

    case 7 % 5 expert-chosen indicators
        
        DSS ( nets, indicators2.labels) ;
        
    otherwise
        

end

% ----------- END ---------------------------------------



% %%----------- UNDER DEVELOPMENT -------------------------------------
%
% % % Calculate errors
% errors = gsubtract ( regimes', meanOUT ) ;
% % Number of misclassifications
% nError = sum(errors~=0) ;

% % Train the Random Forest algorithm
% 
% rfmodel = TreeBagger(100,inputs2',regimes2,...
%     'Method','classification','oobvarimp','on') ;
% 
% [Ypred,Yscore]= predict(rfmodel,inputs');
% 
% C = confusionmat ( cellstr(num2str(regimes2)), Ypred ) ;
% 
% disp(C)%,'VariableNames',rfmodel.ClassNames,'RowNames',rfmodel.ClassNames)
% fprintf('Prediction accuracy on test set: %f\n\n', sum(C(logical(eye(nRegime))))/sum(sum(C)))
% 
% figure
% plot(oobError(rfmodel));
% xlabel('Number of Grown Trees');
% ylabel('Out-of-Bag Classification Error');
% 
% vars = traffic.Properties.VarNames(6:end);
% 
% varimp = rfmodel.OOBPermutedVarDeltaError';
% [~,idxvarimp]= sort(varimp);
% labels = vars(idxvarimp);
% 
% figure
% barh(varimp(idxvarimp),1); ylim([1 52]);
% set(gca, 'YTickLabel',labels, 'YTick',1:numel(labels))
% title('Variable Importance'); xlabel('score')
% 
% % !!! Have not finished with the roc curve yet....
% [rocX,rocY,~,auc] = perfcurve(testYbin,Yscore(:,posIdx),posClass);
% 
% % Fuzzy shit
% tripdata
% [C,S] = subclust([datin datout],0.5)
% [C,S] = subclust([datin datout],0.5)
% myfis=genfis2(datin,datout,0.5);
% 
% 
% % Feature selection using glmfit... does not work for this target formulation
% [b0,dev0,stats0] = glmfit(inputs2,targets2,'binomial');
% 
% 
% % % From the webinar:
% % cvpartition
% % % use parallel:
% % % use gpu
% % % patrec gives scores, but then you round them, based on a threshold
% %
% % % classifiers: ANNs, logist, disc analysis, neigherest neighb, bagged trees, ensembles,
% % combo classifiers, mean, median, vote
% %
% % % Clustering:
% % k-means, hierarchical, SOMs
% % fuzzy cmeans, gaussian mixture models  -- all these give probabilities
% %
% % avg silhiuette value vs number of clusters, to check how many regimes i have in the data
% 
% 
% % !! Where to look for other tools:
% % http://www.37steps.com/prtools/
% % http://www.cs.waikato.ac.nz/ml/weka/
% 
% % [tpr,fpr,thresholds] = roc(targets,output)
% 
% 
