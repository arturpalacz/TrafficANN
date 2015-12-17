function my_HierarchicalCluster ( time, X )

eucD = pdist ( X, 'spearman'); % test other options too 'euclidean', 'correlation', 'cityblock' etc. type help pdist for more

clustTreeEuc = linkage(eucD,'average');
%clustTreeEuc = linkage(eucD,'single');
%clustTreeEuc = linkage(eucD,'complete');

% the closer the cophenetic correlation to 1, the more accurate the tree is as a representation of data
[ C, D ] = cophenet(clustTreeEuc,eucD) ;

%T = max(clustTreeEuc(:,3))*0.7 ; % this is the threshold if using the default dendrogram option
%nReg = length ( find ( clustTreeEuc(:,3) > T ) ) ;

initFigure ('w', 16, 16, 'on', 'normal' ) ;

[h,nodes,outperm,col] = dendrogram_arpa ( clustTreeEuc, 'orientation','left', 'ColorThreshold', 'default' ) ;
set(h,'LineWidth',2) ;

% default colorthreshold is 70% of the maximum linkage, i.e. 0.7*max(clustTreeEuc(:,3))

h_gca = gca;
h_gca.TickDir = 'out';
h_gca.TickLength = [.002 0];
h_gca.YTickLabel = time(outperm) ;

end