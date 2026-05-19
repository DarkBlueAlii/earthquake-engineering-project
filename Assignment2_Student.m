% CIVL 8360
% Assignment 2

clear all; clc; close all;

% Input Earthquake --------------------------------------------------------
ATH = load('M7_soil_FN_9.acc');
A = reshape(ATH',1,[])*9.81; % Acceleration Time History (m/s/s)
dt = 0.005; % Time Step (s)
time = [0:(length(A)-1)]*dt; t = time; % Time vector
steps = length(A); 

% Acceleration Time History Plot
scrsz = get(0,'ScreenSize'); figure('Position', [scrsz(3)/3 scrsz(4)/3 900 300])
plot(time,A);
xlabel('Time (s)')
ylabel('Acceleration (m/s^{2})')
title('Earthquake Acceleration')
grid on

% User Defined ------------------------------------------------------------
Tn = 1.00; % Natural Period (s)
zeta = .05; % Damping Ratio
wn = 2*pi/Tn; % Natural Frequency (rad/s)


% Part a) -----------------------------------------------------------------

% Student to solve

% Part b) Duhamel's -------------------------------------------------------

% Single Impulse Free Decay
for k = 1:steps
    for i = k:steps
        uduh(i,k) = -1/wn*A(k)*sin(wn*(t(i)-t(k)))*exp(-zeta*wn*(t(i)-t(k)))*dt;    
    end
end

uduhamel = sum(uduh'); % Displacement Time History

% Part c) CDM -------------------------------------------------------------

% Student to solve

% Part d) Newmark's -------------------------------------------------------

% Student to solve








