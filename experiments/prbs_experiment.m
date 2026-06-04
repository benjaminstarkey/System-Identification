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

    x_t(:, k+1) = xtemp(end, 1);
end

% Add noise to nominal angular position output meas.
theta = x_t(1,:);
theta_meas = theta + 10*randn(1, length(theta));

% Plot to see inputs/outputs
figure
plot(t, u_PRBS)
xlabel('Time (s)')
ylabel('Voltage (V)')
grid on

figure
plot(t, theta_meas)
xlabel('Time (s)')
ylabel('Position (rad)')
grid on

