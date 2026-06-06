%% Use Experimental Data for Model Identification
clear
clc
% Load data from different inputs
load step.mat
stepp = data;

load chirp.mat
chirp = data;

load prbs.mat
prbs = data;


%% Regime Looping
names = fieldnames(stepp);

for i = 1:length(names)
    label = names{i};
    step_data.(label) = iddata(stepp.(label).y(:), stepp.(label).u(:), stepp.(label).dt);
    chirp_data.(label) = iddata(chirp.(label).y(:), chirp.(label).u(:), chirp.(label).dt);
    prbs_data.(label) = iddata(prbs.(label).y(:), prbs.(label).u(:), prbs.(label).dt);
end

%% Select Training Dataset
z_train = prbs_data.med;

orders = 2:3; % parameter to test different orders

tf_models = {};
ss_models = {};
i = 1;

for n = orders

% Generate Models from Training
tf_models{i} = tfest(z_train, n); % nth order TF
ss_models{i} = ssest(z_train, n); % n state ss

i = i+1;
end

disp('Trained Model')

%% Evaluate on Training Data and Experimental Data
trained_models = [tf_models, ss_models];

figure
compare(z_train, trained_models{:});
title('Training Data Validity Comparison')

[~, fit.train] = compare(z_train, trained_models{:});


%% Evaluate on Test Data Outside Training Set
% Step
z_exp_step = step_data.med;

figure
compare(z_exp_step, trained_models{:});
title('Step Data Validity Comparison')

[~, fit.exp.step] = compare(z_exp_step, trained_models{:});

% Chirp
z_exp_chirp = chirp_data.med;

figure
compare(z_exp_chirp, trained_models{:});
title('Chirp Data Validity Comparison')

[~, fit.exp.chirp] = compare(z_exp_chirp, trained_models{:});


