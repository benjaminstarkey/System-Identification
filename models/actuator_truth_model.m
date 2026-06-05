%% Actuator True Dynamics Model

function x_dot = actuator_truth_model(~, x, u)

% Actuator Parameters ** (UNKNOWN DURING SYS ID) **
J = 0.012;
b = 0.004;
Kt = 0.1;
Fc = 0.02;

% Assign states
theta = x(1);
omega = x(2);

% Include Nonlinear Coulomb Friction Force
friction_coulomb = Fc*sign(omega);

% Initialize x_dot
x_dot = zeros(2,1);

% State Space Model (with Nonlinear friction)
x_dot(1) = omega;
x_dot(2) = (Kt*u - b*omega - friction_coulomb)/J;

end