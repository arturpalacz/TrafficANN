%SELECT_FEATURES Function that performs feature selection using one of
%several methods. 

%
% by: AP Palacz @ DTU-Aqua
% last modified: 08 Dec 2015
%

function [ features, idx ] = select_features ( data, mode )

X = data.values ;
labels = data.labels ;

switch mode
    
    case 'complete'
        
        idx =  all ( ~isnan ( X ) ) ;
        
        features.values = X ( :, idx ) ;

    case 'corrmap'
        
        nFeat = size ( X, 2 ) ; % assuming that features are in columns
        
        % Check if that is likely correct:
        if size(X,1) < size(X,2) ;
            disp('Warning! There are less time steps than features!!!');
            cdn = input('Do you want to proceed?[1-yes,0-no] ');
            switch cdn
                case 1
                    ...
                case 0
                return
            end
        end
        
        [ CM ] = corrmap ( X, labels, 0 ) ; % 0 is for ungrouped, 1 for kkmeans clustered features according to similarity
        
%         fnmout = ['corrmap_',num2str(reg)] ;
%         figdir = [pwd,'/figures/'];
%         export_fig ( [figdir, fnmout], '-pdf' , '-native') ;
%         export_fig ( [figdir, fnmout], '-tiff' , '-native') ;
        
        
        avgCM = nanmean ( abs ( CM (1:end-1,1:end-1) ) ) ;
        
        avgCM(avgCM==Inf)=NaN;
        
        initFigure ( 'w', 11, 8, 'on', 'normal' ) ;
        
        plot ( avgCM, 'k' ) ;
        hold on;
        
        thr_sig1 = prctile ( avgCM, 100-1*15.87 ) ;
        thr_sig5 = prctile ( avgCM, 100-5*15.87 ) ;
        thr_avg  = nanmean ( avgCM ) ;
        
        plot ( [0  nFeat], [thr_avg thr_avg], 'Color', 'b', 'LineWidth', 2 ) ; % 50th percentile = 1 st. dev.
        %line ( 0:.1:nFeat, thr_sig1, 'Color', 'r', 'LineWidth', 3 ) ; % 15.87th percentile = 1 st. dev.
        %line ( 0:.1:nFeat, thr_sig5, 'Color', 'g', 'LineWidth', 3 ) ; % 5*15.87th percentile = 1 st. dev.
        xlabel('Feature number');
        ylabel('Average correlation coefficient');
        set(gca,'FontSize',8);
%         title(['ICES area ', num2str(num2roman(reg))]);
        
%         fnmout = ['featSelect_',num2str(reg)] ;
%         figdir = [pwd,'/figures/'];
%         export_fig ( [figdir, fnmout], '-pdf' , '-native') ;
%         
        hold off;
        
        % Find & select features whose mean correlation coefficient is outside 1stdev of the p of all features
        %cr = input ('Check the graph and pick criterion [1-mean,2-1sigma,5-5sigma]: ') ;
        cr = 1;
        switch cr
            case 1
                idx = ( avgCM < thr_avg ) ;
            case 2
                idx = ( avgCM < thr_sig1 ) ;
            case 5
                idx = ( avgCM < thr_sig5 ) ;
        end
        
        % Reduced features set:
        features.values = X ( :, idx ) ;
        
    case 'simple' % based on a paired t-test
        
    % under development
    
    case 'random5'
        
        k = 5 ;
        N = size(X,2);
        index = randperm(N);
        idx = index(1:k) ;
        
        features.values = X(:,idx) ;
        
    case 'pca1'
        
        N = size(X,2) ;
        
        idx = [1:3 N-1:N] ; % first three and last three, i.e. with highest positive and negative PCA scores
        
        features.values = X ( : , idx ) ; % 3 most positive PC1 and 3 most negative PC1

%     case 'forecast1'
%         FeatProps.Labels = {'S_May_50','Her_W','DIN_load','PO4_load','Chla_spr','Runoff','NO23_win','Her_cat','Her_R',...
%                                        'T_aug20','Air_T','Chla_sum','T_feb50','PO4_win','Her_Bio','T_may20'};
%         inputs  = double ( traffic (:,FeatProps.Labels) ) ; % now each year is one row, each indicator a column
%     case 'forecast2'
%         inputs  = double ( traffic (:,{'S_May_50','Her_W','DIN_load','PO4_load','Chla_spr','Runoff','NO23_win',...
%                                        'Air_T','Chla_sum','PO4_win','Her_Bio','T_may20'}) ) ; % now each year is one row, each indicator a column
%     case 'forecast3'
%         inputs  = double ( traffic (:,{'S_May_50','DIN_load','PO4_load','Chla_spr','Runoff','Air_T','NO23_win','PO4_win','Her_Bio','T_may20'}) ) ; % now each year is one row, each indicator a column
%     
    
    case 'expert5'
        
        labels2 = {'SalMay50m','ChlaSum','NO23win','HerBio','TempMay20m'} ;
        
        idx = ismember ( labels, labels2) ;
        
        features.values = X(:,idx) ;
        
end% switch

features.labels = labels(idx) ;
        
end% function
