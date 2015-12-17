%CLEANUP_IEA Function to replace missing values with averages from
%surrounding years, following C. Mollmann. 
%
% by: AP Palacz @ DTU-Aqua
% last modified: 08 Dec 2015
%

function [ inputs, fnan ] = cleanup_iea ( inputs, data_type ) 

% For every NaN in a feature, replace with the mean of neighbouring four values (real or nan)
for n = 1 : size(inputs,2) ; % for every feature
    
    f = find ( isnan ( inputs(:,n) ) ) ; % find all time steps with NaN in that feature
    
    if ~isempty(f); % if any time points to fill at all
        
        for nn = 1 : length ( f ) ; % loop through those time steps
            
            %if f(nn)<size(targets,2)-1; % only if that
            
            switch data_type
                
                case 'raw' % means absolute values
                    
                    if f(nn) <= 2; % if the time point is any of the first two, take mean of first 4
                        inputs(f(nn),n) =  ( nanmean ( inputs ( f(nn)  :f(nn)+4, n ) ) ) ;
                    elseif f(nn) == size(inputs,1) % if the last year in ts, take the mean of previous 4
                        inputs(f(nn),n) =  ( nanmean ( inputs ( f(nn)-4:f(nn)  , n ) ) ) ;
                    else % otherwise, take 2 from before and 2 from later
                        inputs(f(nn),n) =  ( nanmean ( inputs ( f(nn)-2:f(nn)+2, n ) ) ) ;
                    end
                    
                case 'quantiles' % absolute values converted into quantiles relative to the whole time series
                    
                    if f(nn) <= 2; % if the time point is any of the first two, take mean of first 4
                        inputs(f(nn),n) = roundn ( nanmean ( inputs ( f(nn)  :f(nn)+4, n ) ), 0 ) ;
                    elseif f(nn) == size(inputs,1) % if the last year in ts, take the mean of previous 4
                        inputs(f(nn),n) = roundn ( nanmean ( inputs ( f(nn)-4:f(nn)  , n ) ), 0 ) ;
                    else % otherwise, take 2 from before and 2 from later
                        inputs(f(nn),n) = roundn ( nanmean ( inputs ( f(nn)-2:f(nn)+2, n ) ), 0 ) ;
                    end
                    
            end% switch
        end% for
    end% if
    clear f ;
end% for

% If mean was taken only of NaNs, then the resulting Inf needs to be replaced with a NaN
inputs ( isinf(inputs) ) = NaN ;

% If there are still features with NaNs, delete them
fnan = any(isnan(inputs)) ;
inputs (:, fnan ) = [] ;

end% function
