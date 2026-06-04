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
