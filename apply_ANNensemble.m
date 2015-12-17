
function  [ Z, enZ, enZsc ] = apply_ANNensemble ( X, net )


for i = 1 : numel(net) ;
    
    % Load the indiv net
    ann = net{1,i} ;
    
    % Make a net label for graph
    A{i} = strcat('net', num2str (i)); 
    
    Z.Scores(:,:,i) = sim ( ann , X' ) ;
    Z.Classes(:,i) = vec2ind ( Z.Scores(:,:,i) ) ; % vec2ind to get discrete classes from cont. values
  
end;

% Get the mean and standard deviation of the ensemble:
enZsc.mean = squeeze ( nanmean ( Z.Scores, 3 ) ) ;
enZsc.median = squeeze ( median ( Z.Scores, 3 ) ) ;
enZsc.stdev = squeeze ( std ( Z.Scores, 0, 3 ) ) ;

enZ.mean = vec2ind ( squeeze ( nanmean ( Z.Scores, 3 ) ) ) ;
enZ.median = vec2ind ( squeeze ( median ( Z.Scores, 3 ) ) ) ;

end
