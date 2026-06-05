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

    x_t(:, k+1) = xtemp(end, :)';
end

% Add noise to nominal angular position output meas.
theta = x_t(1,:);
theta_meas = theta + 0.1*randn(1, length(theta));

omega = x_t(2,:);
omega_meas = omega + 0.1*randn(1, length(omega));

% Plot to see inputs/outputs
figure
hold on
grid on

plot(t, u_step)
plot(t, theta_meas)
plot(t, omega_meas)

xlabel('Time (s)')
ylabel('Amplitude (V)')
legend('Input', 'Pos.', 'Vel.')

% Conclusions:
% Step input not enough freq.
% Need more frequency content, for better excitation

%% Data Logging

data.t = t;
data.u = u_step;
data.y = omega_meas;
data.dt = dt;

data.experiment.type = "Step";
data.experiment.date = datetime;

save('../data/step.mat', 'data');