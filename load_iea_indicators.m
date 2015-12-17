%LOAD_IEA_INDICATORS Function that loads the time series of ecosystem
%indicator suite, with time in rows and variables in columns, extracted
%from a spreadsheet into a text file. 
%
% by; AP Palacz @ DTU-Aqua
% last modified: 08 Dec 2015
%

function [ indicators, data_type ] = load_iea_indicators ( region )

global DIR

fnm = [ DIR, region, '/', region, '_iea_indicators.txt' ] ;

% NB: data in the txt file should follow the format with years in rows,
% variables in columns, with time indices in Column 1 and indicators in
% Columns 2 to N. 
% First row should be a header with variable names.

% Create a dataset array out of the loaded rows and columns
data = dataset ( 'file', fnm ) ;

indicators.values = double ( data ( :, 2:end ) ) ;
indicators.labels = data.Properties.VarNames ( 2:end ) ;
indicators.time   = double ( data ( :, 1 ) ) ;

if min(indicators.values(:)) == 1 && max(indicators.values(:)) == 5 
    data_type = 'quantiles' ; % data already converted into quantiles
else
    data_type = 'raw' ; % original data in absolute values
end


end% function

%
%         % Create a dataset array out of the loaded rows and columns
%         raw = dataset ( 'file', fnm ) ;
%         
%         switch data_type
%             case 'raw'
%                 data = raw ;
%             case 'quantiles'
%                 names = raw.Properties.VarNames(3+nRegime:end) ;
%                 data = raw ;
%                 % Convert into quantiles
%                 p = 0 : 0.2 : 1 ;
%                 for n = 1:length(names);
%                     breaks(:,n) = quantile(raw.(names{n}),p,1);
%                     data.(names{n}) = ordinal(raw.(names{n}),{'1','2','3','4','5'},...
%                         [],breaks(:,n));
%                 end
%         end
% end
% 
% end
