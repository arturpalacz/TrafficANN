function [ nReg, regimes ] = load_iea_regimes ( region )

global DIR

fnm = [ DIR, region, '/', region, '_iea_regimes.txt' ] ;

% Create a dataset array out of the loaded rows and columns
data = dataset ( 'file', fnm ) ;

time = double ( data ( :, 1 ) ) ;

temp = double ( data ( :, 2:end ) ) ;
nl = size ( temp, 2 ) ; % number of regime classification options, i.e. 2 or 4 regimes present
nopt = max ( temp ) ; % take out the max number from each column

if length ( nopt ) > 1 ;
    sprintf ( '%s', 'Possible # of regimes: ' )
    disp(nopt);
    nReg = input ('Choose how many regimes you want to work with: ' ) ;
    idx = nopt==nReg ;
    regimes = temp ( :, idx ) ;
else
    nReg = nopt ;
    regimes = temp ;
end
clear temp :

end% function
