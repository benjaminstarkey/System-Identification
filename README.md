# System-Identification of DC Motor
## Project Overview
Model nonlinear DC motor with friction and saturation, collect experimental data using step, chirp, and PRBS signals across various voltage regimes, 

## Analysis
### Linear TF Cross Validation
Train 2nd order linear TF with differing voltage regime PRBS signals. Linear models perform well when validated and trained on same voltage operating regime, however degrade when validated against operating conditions outside the training set. This shows the limitation from unmodeled dynamics and nonlinearities on a linear plant model to sufficiently capture dynamics across voltage conditions, particularly low voltage as a result of the high friction forces.

LINEAR CROSS VAL HEAT MAP, centered

### Nonlinear Grey Model
To improve model identification across regimes, a physics-informed nonlinear grey model is developed to train with several input types and voltages across the operating window. Estimates of the motor parameters are directly identified within 25% error on linear terms and 35-50% on nonlinear parameters despite measurement noise.

| Parameter | True Value | Identified Value | Std Deviation | Error (%) |
| :--- | :---: | :---: | :---: | :---: |
| `b` (Viscous Damping) | 0.004 | 0.005 | 0.001 | **+22.69%** |
| `J` (Rotor Inertia) | 0.012 | 0.015 | 0.002 | **+22.69%** |
| `Kt` (Torque Constant) | 0.1 | 0.123 | 0.016 | **+22.84%** |
| `Fc` (Coulomb Friction) | 0.02 | 0.025 | 0.003 | **+24.01%** |
| `Fs` (Static Friction) | 0.035 | 0.047 | 0.009 | **+34.92%** |
| `vs` (Stiction Velocity) | 0.1 | 0.052 | 0.016 | **-48.42%** |

The cross validation heatmap below shows nonlinear grey model performing significantly better than the best linear model, yielding >90% fits across voltage operating regimes and input types. 

NONLINEAR CROSS VAL HEAT MAP COMPARISON, centered

The nonlinear grey model accurately models the low voltage PRBS signal despite the 7% fit metric, since high frequency, low amplitude voltage switching keeps the motor operating in the stiction deadband and around zero velocity. Measurement noise creates a low SNR and skews the fit metric. At ~9.5s, the model accurately tracks a response where the motor is commanded long enough to break out of the friction regime, validating the model at low voltages despite the 7% fit metric.

LOW PRBS SIGNAL TRACKING 7%, centerd
