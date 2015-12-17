function [ avgSilh, nRegime, cidx, regimes ] = my_kmeans ( X, kN ) 

% Note: there is stochasticity in these solutions, hence using the replicates option

initFigure ('w',10,24,'on','normal');
    
for nc = 2 : kN ;

    [ cidx(:,nc-1), cmeans, sumd ] = kmeans ( X, nc, 'replicates', 10, 'display','final','dist', 'cosine' ) ; 
    % 'cosine' is another dist option that gives similar high silh values; others are sqEuclidean, cityblock, hamming

    subplot ( kN-1, 1, nc-1 )
    [ silh(:,nc-1), h ] = silhouette ( X, cidx(:,nc-1), 'cosine' ) ;
    
    set ( get ( gca, 'Children' ), 'FaceColor', [ .8 .8 1 ] ) ;
    xlabel ( 'Silhouette Value' ) ;
    ylabel ( 'Cluster' ) ;

    % fnmout = 'Silhuette' ;
    % figdir = [pwd,'/figures/'];
    % export_fig ( [figdir, fnmout], '-pdf' , '-native') ;

end

% Calculate average silhuette value per cluster type:
avgSilh = nanmean (silh,1) ;

% Find the cluster size with highest avg silhuette value
nRegime = find ( nanmax(avgSilh) ) + 1 ; % +1 to turn run index into actual cluster size (i.e. min cluster size = 2)

% Assign clusters/regimes in the final configuration
regimes = cidx (:,nRegime-1) ; % -1 because 

end
    