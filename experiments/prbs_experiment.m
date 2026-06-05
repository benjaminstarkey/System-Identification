%% System Identification Experiments
clear
clc

dt = 0.01;
Tf = 10;

t = 0:dt:Tf;

% Input Signal
u_PRBS = 2*idinput(length(t), 'prbs'); % discrete binary switching for safety, emulating white noise freq.
disp('Running Pseudorandom Binary Sequence Input')


%% Experiment using Input Signal
% Initial Conditions
x0 = [0; 0];

% Initialize vector of states
x_t = zeros(2, length(t));
x_t(:, 1) = x0;

% Run Ode45 to solve states
for k = 1:length(t)-1
    t_k = [t(k), t(k+1)];

    [~, xtemp] = ode45(@(t_in,x_in) actuator_truth_model(t_in, x_in, u_PRBS(k)), t_k, x_t(:,k));

    x_t(:, k+1) = xtemp(end, :)';
end

% Add noise to nominal angular position output meas.
theta = x_t(1,:);
theta_meas = theta + 0.4*randn(1, length(theta));

omega = x_t(2,:);
omega_meas = omega + 0.1*randn(1, length(omega));



% Plot to see inputs/outputs
figure
hold on
grid on

plot(t, u_PRBS)
plot(t, theta_meas)
plot(t, omega_meas)

xlabel('Time (s)')
ylabel('Amplitude (V)')
legend('Input', 'Pos.', 'Vel.')



%% Data Logging

data.t = t;
data.u = u_PRBS;
% data.y = theta_meas;
data.y = omega_meas;
data.dt = dt;

data.experiment.type = "PRBS";
data.experiment.date = datetime;

save('../data/prbs.mat', 'data');
disp('Logged PRBS Data')
