% define apriori estimated structure of DC motor for gray box modeling

function [A, B, C, D] = motor_grey_model(params, ~)
% linear estimate of actuator dynamics in state space form
    b = params(1);
    J = params(2);
    Kt = params(3);

    A = [0, 1; 0, -b/J];
    B = [0; Kt/J];
    C = [0, 1]; % output omega
    D = 0;
end