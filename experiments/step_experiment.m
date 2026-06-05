%% STEP Experiment
clear
clc

disp('Running Step Input')
dt = 0.01;
Tf = 10;

t = 0:dt:Tf;

amps = [0.2, 2, 6];
names = ['low', 'med', 'high'];

data = struct();

for i = 1:length(amps)

amp = amps(i);

% Input Signal
u_step = [zeros(1, 10), amp*ones(1, length(t)-10)]; % step cmd w/ amp

% Initial Conditions
x0 = [0; 0];

% Initialize vector of states
x_t = zeros(2, length(t));
x_t(:, 1) = x0;

% Run Ode45 to simulate plant outputs
for k = 1:length(t)-1
    t_k = [t(k), t(k+1)];

    [~, xtemp] = ode45(@(t_in,x_in) actuator_truth_model(t_in, x_in, u_step(k)), t_k, x_t(:,k));

    x_t(:, k+1) = xtemp(end, :)';
end

% Add simulated noise to nominal angular position output
theta = x_t(1,:);
theta_meas = theta + 0.4*randn(1, length(theta));

omega = x_t(2,:);
omega_meas = omega + 0.1*randn(1, length(omega));

% Store in structure
name = names(i);

data.(name).t = t;
data.(name).u = u_step;
data.(name).y = omega_meas;
data.(name).dt = dt;

data.(name).amp = amp;

end

% Data Logging
save('../data/step.mat', 'data');
disp('Logged Step Data')



%% Plotting
% Plot to see inputs/outputs (if wanted uncomment)
% figure
% hold on
% grid on
% 
% plot(t, u_step)
% plot(t, theta_meas)
% plot(t, omega_meas)
% 
% xlabel('Time (s)')
% ylabel('Amplitude (V)')
% legend('Input', 'Pos.', 'Vel.')