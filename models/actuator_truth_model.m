%% Actuator True Dynamics Model

function x_dot = actuator_truth_model(~, x, u)

% Actuator Parameters ** (UNKNOWN DURING SYS ID) **
J = 0.012; % rot. inertia
b = 0.004; % damping
Kt = 0.1; % voltage gain

% NONLINEARITIES
Fc = 0.02; % coulomb friction

Fs = 0.035; % stribeck friction (higher than coulomb)
vs = 0.1; % stribeck velocity scale
V_max = 5; % for saturation

% Assign states
theta = x(1);
omega = x(2);

% Include Nonlinear Coulomb Friction Force
friction_coulomb = Fc*sign(omega);

% Add Stribeck Friction for velocity-dependant formula
stribeck = Fc + (Fs-Fc)*exp(-(abs(omega)/vs)^2);

eps_w = 1e-4; % for numerical instability around 0
sign_omega = omega / (abs(omega) + eps_w);
friction_stribeck = stribeck * sign_omega;

% Saturation on input voltage
u_sat = max(-V_max, min(u, V_max));

% Initialize x_dot
x_dot = zeros(2,1);

% State Space Model (with Nonlinear friction)
x_dot(1) = omega;
x_dot(2) = (Kt*u_sat - b*omega - friction_stribeck)/J;

end