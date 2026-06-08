%% Actuator Grey Dynamics Model: ESTIMATE MODEL PARAMETER VALUES

function [x_dot, y] = motor_grey_nonlin_model(t, x, u, b, J, Kt, Fc, Fs, vs, varargin)

% extract params
% b = params(1);
% J = params(2);
% Kt = params(3);
% Fs = params(4);
% Fc = params(5);
% vs = params(6);

% grab state
omega = x(1);

% Saturation on input voltage
V_max = 5; % for saturation
u_sat = max(-V_max, min(u, V_max));

% Add Stribeck Friction for velocity-dependant formula
stribeck = Fc + (Fs-Fc)*exp(-(abs(omega)/vs)^2);
eps_w = 1e-4; % for numerical instability around 0
sign_omega = omega / (abs(omega) + eps_w);
friction_stribeck = stribeck * sign_omega;

% % Initialize x_dot
% x_dot = zeros(2,1);

% State Space Model (with Nonlinear friction)
x_dot = (Kt*u_sat - b*omega - friction_stribeck)/J;

y = omega;

end