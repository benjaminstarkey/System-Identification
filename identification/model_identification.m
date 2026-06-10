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


%% Data Input Amp and Signal Processing
names = fieldnames(stepp);

for i = 1:length(names)
    label = names{i};
    step_data.(label) = iddata(stepp.(label).y(:), stepp.(label).u(:), stepp.(label).dt);
    chirp_data.(label) = iddata(chirp.(label).y(:), chirp.(label).u(:), chirp.(label).dt);
    prbs_data.(label) = iddata(prbs.(label).y(:), prbs.(label).u(:), prbs.(label).dt);
end

%% Select Training Dataset and Generate Models
disp('Training Models using PRBS 2V Data...')
z_train = prbs_data.med;

orders = 1:3; % parameter to test different orders

tf_models = cell(1, length(orders));
ss_models = cell(1, length(orders));
i = 1;

for n = orders

% Generate Models from Training
tf_models{i} = tfest(z_train, n); % nth order TF
ss_models{i} = ssest(z_train, n); % n state ss

i = i+1;
end

disp('Trained Linear Models Successfully')

% % NONLINEAR MODEL TRAINING
% nl_models = cell(1, length(orders));
% 
% for i = 1:length(orders)
%     n = orders(i);
%     nl_models{i} = nlhw(z_train, [1 n 1]);
% end
% 
% disp('Trained Nonlinear Models Successfully')

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


%% PRBS Amplitude Analysis
data_sets = {z_train, prbs_data.low, prbs_data.high};
data_names = ["PRBS 2V (Training)", "PRBS 0.2V", "PRBS 6V"];

fit_table = zeros(length(trained_models), length(data_sets));

for k = 1:length(data_sets)
    z_data = data_sets{k};

    for m = 1:length(trained_models)
        [~, fit_val] = compare(z_data, trained_models{m});
        fit_table(m, k) = fit_val; 
    end

end

% Table Headers for Rows
model_names = {};

for n = orders
    model_names{end+1} = sprintf("TF-%d", n);
end

for n = orders
    model_names{end+1} = sprintf("SS-%d", n);
end

% for n = orders
%     model_names{end+1} = sprintf("NLHW-%d", n);
% end

% Plotting Heatmap
figure
heatmap(data_names, model_names, fit_table);
colormap(parula)
clim([0, 100])

title('PRBS Amplitude Analysis')
xlabel('Dataset')
ylabel('Model Type')




%% Input Type Analysis
data_sets = {z_train, step_data.med, chirp_data.med};
data_names = ["PRBS 2V (Training)", "Step 2V", "Chirp 2V"];

fit_table = zeros(length(trained_models), length(data_sets));

for k = 1:length(data_sets)
    z_data = data_sets{k};

    for m = 1:length(trained_models)
        [~, fit_val] = compare(z_data, trained_models{m});
        fit_table(m, k) = fit_val; 
    end

end

% Table Headers for Rows
model_names = {};

for n = orders
    model_names{end+1} = sprintf("TF-%d", n);
end

for n = orders
    model_names{end+1} = sprintf("SS-%d", n);
end

% for n = orders
%     model_names{end+1} = sprintf("NLHW-%d", n);
% end

% Plotting Heatmap
figure
heatmap(data_names, model_names, fit_table);
colormap(parula)
clim([0, 100])

title('Input Analysis')
xlabel('Dataset')
ylabel('Model Type')


%% Grey Box Linear Parameter Estimation

% Initial Parameter Guesses [b, J, Kt]
params_guess = [0.005; 0.01; 0.12];
params_names = {'b'; 'J'; 'Kt'};

grey_lin_model = idgrey(@motor_grey_model, params_guess, 'c');
grey_lin_est_model = greyest(z_train, grey_lin_model);
%%
[~, grey_fit_val] = compare(prbs_data.high, grey_lin_est_model);

%% Grey Nonlinear Parameter Estimation

params_guess = {0.005; 0.01; 0.12; 0.03; 0.04; 0.06};
params_names = {'b'; 'J'; 'Kt'; 'Fc'; 'Fs'; 'vs'};

grey_nonlin_model = idnlgrey(@motor_grey_nonlin_model,[1 1 1],params_guess, 0);

% Settings to help solver
grey_nonlin_model.Algorithm.SimulationOptions.Solver = 'ode15s';
grey_nonlin_model.Algorithm.Display = 'on';

grey_nonlin_model.Parameters(1).Minimum = 0.0001; % b min
grey_nonlin_model.Parameters(2).Minimum = 0.001; % J min
grey_nonlin_model.Parameters(3).Minimum = 0.01; % Kt min
grey_nonlin_model.Parameters(4).Minimum = 0.001; % Fs min
grey_nonlin_model.Parameters(5).Minimum = 0.001; % Fc min
grey_nonlin_model.Parameters(6).Minimum = 0.01; % vs min

grey_nonlin_model.Parameters(1).Name = 'b';
grey_nonlin_model.Parameters(2).Name = 'J';
grey_nonlin_model.Parameters(3).Name = 'Kt';
grey_nonlin_model.Parameters(4).Name = 'Fc';
grey_nonlin_model.Parameters(5).Name = 'Fs';
grey_nonlin_model.Parameters(6).Name = 'vs';

grey_nonlin_est_model = nlgreyest(z_train, grey_nonlin_model);
%% Parameter Validation Table

est_names = {grey_nonlin_est_model.Parameters.Name}';
est_values = [grey_nonlin_est_model.Parameters.Value]';

est_cov = grey_nonlin_est_model.Report.Parameters.FreeParCovariance;
est_stdev = sqrt(diag(est_cov));

true_values = [0.004; 0.012; 0.1; 0.02; 0.035; 0.1];
percent_error = abs((est_values - true_values) ./ true_values) * 100;

summary_table = table(est_names, true_values, round(est_values,3), round(est_stdev,3), round(percent_error,3), ...
    'VariableNames', {'Parameter', 'True_Value', 'Identified_Value', 'Std_Deviation', 'Percent_Error'});

disp(summary_table);
