%% System Identification Experiments
clear
clc

disp('Running Chirp Signal Input')
dt = 0.01;
Tf = 10;

t = 0:dt:Tf;

amps = [0.2, 2, 6];
names = ['low', 'med', 'high'];

data = struct();

for i = 1:length(amps)

% Input Signal
amp = amps(i);
u_chirp = amp*chirp(t, 0.1, t(end), 10); % increases frequency from 0.1 to 10 Hz

% Initial Conditions
x0 = [0; 0];

% Initialize vector of states
x_t = zeros(2, length(t));
x_t(:, 1) = x0;

% Run Ode45 to solve states
for k = 1:length(t)-1
    t_k = [t(k), t(k+1)];

    [~, xtemp] = ode45(@(t_in,x_in) actuator_truth_model(t_in, x_in, u_chirp(k)), t_k, x_t(:,k));

    x_t(:, k+1) = xtemp(end, :)';
end

% Add noise to nominal angular position output meas.
theta = x_t(1,:);
theta_meas = theta + 0.4*randn(1, length(theta));

omega = x_t(2,:);
omega_meas = omega + 0.1*randn(1, length(omega));

% Store in structure
name = names(i);

data.(name).t = t;
data.(name).u = u_chirp;
data.(name).y = omega_meas;
data.(name).dt = dt;

data.(name).amp = amp;

end

% Data Logging
save('../data/chirp.mat', 'data');
disp('Logged Chirp Data')



%% Plotting
% figure
% hold on
% grid on
% 
% plot(t, u_chirp)
% plot(t, theta_meas)
% plot(t, omega_meas)
% 
% xlabel('Time (s)')
% ylabel('Amplitude (V)')
% legend('Input', 'Pos.', 'Vel.')