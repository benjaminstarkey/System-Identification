%% Use Experimental Data for Model Identification

% Load data from different inputs
load step.mat
step = data;

load chirp.mat
chirp = data;

load prbs.mat
prbs = data;

data_step = iddata(step.y(:), step.u(:), step.dt);
data_chirp = iddata(chirp.y(:), chirp.u(:), chirp.dt);
data_prbs = iddata(prbs.y(:), prbs.u(:), prbs.dt);

step_sys = tfest(data_step, 2);
chirp_sys = tfest(data_chirp, 2);
prbs_sys = tfest(data_prbs, 2);

%% Data Analysis, Comparisons
step_poles = pole(step_sys)
chirp_poles = pole(chirp_sys)
prbs_poles = pole(prbs_sys)

%%
figure
% compare(data_prbs, prbs_sys)
% compare(data_chirp, prbs_sys)
compare(data_step, prbs_sys)