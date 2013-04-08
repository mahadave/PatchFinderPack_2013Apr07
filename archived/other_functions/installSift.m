function []=installSift()
% installs the vl_sift toolbox

    vl_sift_install = '../toolbox/';   % install the vl_sift toolbox    
    run(fullfile(vl_sift_install,'vl_setup'));

end