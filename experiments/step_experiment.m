%% STEP Experiment
clear
clc

dt = 0.01;
Tf = 10;

t = 0:dt:Tf;

% Input Signal
u_step = [zeros(1, 10), 5*ones(1, length(t)-10)]; % step 5V cmd

% Initial Conditions
x0 = [0; 0];

% Initialize vector of states
x_t = zeros(2, length(t));
x_t(:, 1) = x0;

% Run Ode45 to solve states
for k = 1:length(t)-1
    t_k = [t(k), t(k+1)];

    [~, xtemp] = ode45(@(t_in,x_in) actuator_truth_model(t_in, x_in, u_step(k)), t_k, x_t(:,k));

    x_t(:, k+1) = xtemp(end, 1);
end

% Add noise to nominal angular position output meas.
theta = x_t(1,:);
theta_meas = theta + 40*randn(1, length(theta));

% Plot to see inputs/outputs
figure
plot(t,u_step)
xlabel('Time (s)')
ylabel('Voltage (V)')
grid on

figure
plot(t,theta_meas)
xlabel('Time (s)')
ylabel('Position (rad)')
grid on

% Conclusions:
% Step input not enough freq.
% Need more frequency content, for better excitation

%% Data Logging

data.t = t;
data.u = u_step;
data.y = theta_meas;
data.dt = dt;

data.experiment.type = "Step";
data.experiment.date = datetime;

save('../data/step.mat', 'data');