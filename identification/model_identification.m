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
disp('Training Models...')
z_train = prbs_data.med;

orders = 2:3; % parameter to test different orders

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

% NONLINEAR MODEL TRAINING
nl_models = cell(1, length(orders));

for i = 1:length(orders)
    n = orders(i);
    nl_models{i} = nlhw(z_train, [1 n 1]);
end

disp('Trained Nonlinear Models Successfully')

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


%% PRBS Amplitude Nonlinear Analysis
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




%% Input Nonlinear Analysis
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

