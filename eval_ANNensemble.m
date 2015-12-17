
function  [ Z, enZ, enZsc, C, enC ] = eval_ANNensemble ( X, regY, nRegime, Nesb, nets, plotopt )


for i = 1 : size(nets,2) ;
    
    % Load the indiv net
    ann = nets{1,i} ;
    
    % Make a net label for graph
    A{i} = strcat('net', num2str (i));
    
    Z.Scores(:,:,i) = sim ( ann , X' ) ;
    Z.Classes(:,i) = vec2ind ( Z.Scores(:,:,i) ) ; % vec2ind to get discrete classes from cont. values
    
    C = confusionmat ( regY', vec2ind ( squeeze( Z.Scores(:,:,i) ) ) ) ;
    iC(i) = 100 * sum(C(logical(eye(nRegime))))/sum(sum(C)) ;
    
end

% find and eliminate the worst classifiers from the ensemble
f = iC > 0 ; % this basically does not help at all, if the threshold is high (e.g. 50%), it even decreases C for ensemble

% Get the mean and standard deviation of the ensemble:
enZsc.mean = squeeze ( nanmean ( Z.Scores(:,:,f), 3 ) ) ;
enZsc.median = squeeze ( median ( Z.Scores(:,:,f), 3 ) ) ;
enZ.mean = vec2ind ( squeeze ( nanmean ( Z.Scores(:,:,f), 3 ) ) ) ;
enZ.median = vec2ind ( squeeze ( median ( Z.Scores(:,:,f), 3 ) ) ) ;

%
C = confusionmat ( regY', enZ.mean ) ;

enC = 100 * sum(C(logical(eye(nRegime))))/sum(sum(C)) ;


%% Bar plot
switch plotopt
    
    case 'on'
        
        initFigure( 'w', 8, 10, 'on', 'normal' )
        
        % Colors
        clrCerulean = [0.0, 0.48, 0.65];
        clrOrangeRed = [1.0, 0.27, 0.0];
        clrOliveGreen = [0.33, 0.42, 0.18];
        % Bar plot with prediction accuracy of ensemble mean vs individual nets
        hBar = bar ( [iC enC] ) ;
        % Get a handle to the children
        hBarChildren = get(hBar, 'Children');
        % Set the colors we want to use
        myBarColors = [clrCerulean; clrOrangeRed];
        % This defines which bar will be using which index of "myBarColors", i.e. the first
        %  two bars will be colored in "clrCerulean", the next 6 will be colored in "clrOrangeRed"
        %  and the last 4 bars will be colored in "clrOliveGreen"
        index = [ones(1,Nesb) 2];
        % Set the index as CData to the children
        set(hBarChildren, 'CData', index);
        % And set the custom colormap. Takes care of everything else
        colormap(myBarColors);
        
        ylabel('Prediction accuracy on test set [%]');
        
        set(gca,'xtick',(1:10:Nesb+1),'xticklabel', [ A(1:10:end), 'ensemble' ],'box','off' ) ;
        
        % export_fig ( [indir, 'GoR_forecast4'], '-pdf' , '-native')
        
    case 'off'
        
end% switch

end
