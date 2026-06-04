%% Actuator True Dynamics Model

function x_dot = actuator_truth_model(~, x, u)

% Actuator Parameters ** (UNKNOWN DURING SYS ID) **
J = 0.012;
b = 0.004;
Kt = 0.1;

% Assign states
theta = x(1);
omega = x(2);

% Initialize x_dot
x_dot = zeros(2,1);

% State Space Model
x_dot(1) = omega;
x_dot(2) = (Kt*u - b*omega)/J;

end