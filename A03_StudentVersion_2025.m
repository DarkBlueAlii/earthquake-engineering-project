% CIVL 8360 Earthquake Engineering
% Response Spectrum - Assignment 3
% Niel Van Engelen - 20230205

% This script is meant for educational purposes only. 

clc; clearvars; close all;

% Assumptions -------------------------------------------------------------
% Assume small damping (wd = w)

% Define Variables --------------------------------------------------------

% Load Record
FileName = 'RSN732_LOMAP_A02133.AT2'; %                                     <== CHANGE NAME FOR DIFFERENT FILES
delimiterIn = ' '; headerlinesIn = 4; % Header to .AT2 files
Ain = importdata(FileName,delimiterIn,headerlinesIn); % Import array
Amatrix = Ain.data'*9.81; % Converts acceleration to m/s/s
A = Amatrix(:); % Converts matrix to a vector

% Time Vector
dt = 0.005; % Time Step (s)                                                  <== CHANGE VALUE FOR DIFFERENT FILES
time = (0:1:length(A)-1)*dt; % Time (s)
steps = length(time); % Maximum number of steps considered

% System Properties
Tn = .05:.005:5; % Natural Period (s)
zetad = [0.01 0.05 0.10]; % Damping Ratio                                   <== CHANGE FOR DIFFERENT LEVELS OF DAMPING

for period = 1:length(Tn) % Cycles through the different periods
    wn = 2*pi/Tn(period); % Natural Frequency (rad/s)
    
    for damping = 1:length(zetad) % Cycles through the different damping
        zeta = zetad(damping);
              
        % Define Initial Conditions ---------------------------------------
        u = zeros(1,steps); % Relative Displacement
        ud = zeros(1,steps); % Relative Velocity
        udd = zeros(1,steps); % Relative Acceleration
        utotal = zeros(1,steps); % Total Acceleration
        P = A*-1; % Effective applied force (i.e. earthquake acceleration)
        
		% Time Stepping - Newmark's Method --------------------------------
        % Initial Calculations 
        kbar = wn^2 + 3*2*zeta*wn/dt + 6/dt^2;
        a = 6/dt+3*2*zeta*wn;
        b = 3 + dt/2*2*zeta*wn;
        
        % Iterations
        udd(1) = (P(1) - 2*zeta*wn*ud(1) - wn^2*u(1)); % Initial Acc.
        
        for i = 1:steps-1
            dp(i) = P(i+1)-P(i);           
            dpbar(i) = dp(i) + a*ud(i) + b*udd(i);            
            du(i) = dpbar(i)/kbar;            
            dud(i) = 3/dt*du(i)-3*ud(i)-dt/2*udd(i);            
            dudd(i) = 6/dt^2*(du(i)-dt*ud(i))-3*udd(i);           
            
            u(i+1) = u(i)+du(i);
            ud(i+1) = ud(i)+dud(i);
            udd(i+1) = udd(i)+dudd(i);
            utotal(i+1) = udd(i+1)+A(i+1);
        end
        
        % Response Spectra ------------------------------------------------
        uddmax(period,damping) = max(abs(utotal))/9.81; % Total Acceleration (g)
        udmax(period,damping) = max(abs(ud)); % Velocity (m/s)
        umax(period,damping) = max(abs(u)); % Disp (m)
        
        usA(period,damping) = umax(period,damping)*wn^2/9.81; % Pseudo Acc. (g)
        usV(period,damping) = umax(period,damping)*wn; % Pseudo Vel. (m/s)
    end
end


scrsz = get(0,'ScreenSize'); % retrieves your screen size to help scale the figures

% Acceleration Time History
figure('Name','Part (a)','OuterPosition',[scrsz(3)/4 scrsz(4)/4 418*2 313],'Color','white'); 
plot(time,A)
xlabel('Time (s)')
ylabel('Acceleration (m/s^2)')
grid on


