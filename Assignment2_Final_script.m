% CIVL 8360
% Assignment 2

clear; clc; close all;

% Input Earthquake --------------------------------------------------------
ATH = load('M7_soil_FN_9.acc');
A = reshape(ATH',1,[])*9.81;       % Acceleration Time History (m/s^2)
dt = 0.005;                        % Time Step (s)
t = (0:(length(A)-1))*dt;          % Time vector
steps = length(A);

% Acceleration Time History Plot
figure('Position',[200 200 900 300])
plot(t,A); grid on
xlabel('Time (s)'); ylabel('Acceleration (m/s^{2})'); title('Earthquake Acceleration')

% User Defined ------------------------------------------------------------
Tn = 0.5;          % Natural Period (s)
zeta = 0.05;       % Damping Ratio
wn = 2*pi/Tn;      % Natural Frequency (rad/s)

%% Part a) Trapezoid rule -------------------------------------------------

v_g = zeros(1,steps);
u_g = zeros(1,steps);

for i = 2:steps
v_g(i) = v_g(i-1) + 0.5*(A(i)+A(i-1))*dt;
u_g(i) = u_g(i-1) + 0.5*(v_g(i)+v_g(i-1))*dt;
end

% Plot results
figure;
subplot(3,1,1); plot(t,A); grid on; xlabel('t (s)'); ylabel('a (m/s^{2})'); title('Earthquake Acceleration');
subplot(3,1,2); plot(t,v_g); grid on; xlabel('t (s)'); ylabel('v (m/s)'); title('Earthquake Velocity');
subplot(3,1,3); plot(t,u_g); grid on; xlabel('t (s)'); ylabel('u (m)'); title('Earthquake Displacement');
sgtitle('Part (a) – Earthquake Ground Motion Time Histories');

PGA = max(abs(A));
fprintf('(a) PGA = %.3f g (%.3f m/s^2)\n', PGA/9.81, PGA);

%% Part b) Duhamel's -------------------------------------------------------
% Single Impulse Free Decay

uduh = zeros(steps,steps);

for k = 1:steps
    for i = k:steps
        uduh(i,k) = -1/wn * A(k) * sin(wn * (t(i)-t(k))) * exp(-zeta * wn * (t(i)-t(k))) * dt;
    end
end

% duhamel
u_total_duhamel = sum(uduh,2).';

% Displacement Time History
figure; plot(t,u_total_duhamel); xlabel('t (s)'); ylabel('u (m)'); title('Part (b) – Duhamel Integral'); grid on;

umax_b = max(abs(u_total_duhamel));
tmax_b = t( find(abs(u_total_duhamel)==umax_b, 1, 'first') );
fprintf('(b) Duhamel: max|u| = %.6e m at t = %.3f s\n', umax_b, tmax_b);

%% Part c) CDM -------------------------------------------------------------
u = zeros(1,steps);      % relative displacement
v = zeros(1,steps);      % relative velocity
a = zeros(1,steps);      % relative acceleration

v_i = zeros(1,steps);
a_i = zeros(1,steps);

% initial conditions
u(1) = 0; u(2) = 0;

% Integration CDM
for i = 2:steps-1
    u(i+1) = (-A(i) - ((1/dt^2) - (zeta*wn)/dt)*u(i-1) - (wn^2 - 2/(dt^2))*u(i)) / (1/(dt^2) + (zeta*wn)/dt);
end

% Plot results
figure; plot(t,u); grid on
xlabel('t (s)'); ylabel('u (m)'); title('Part (c) – CDM Displacement')

umax_c = max(abs(u));
tmax_c = t( find(abs(u)==umax_c, 1, 'first'));
fprintf('(c) CDM: max|u| = %.6e m at t = %.3f s\n', umax_c, tmax_c);

%% Part d) Newmark's -------------------------------------------------------
beta = 1/6; gamma = 1/2;

u_NM = zeros(1,steps);
v_NM = zeros(1,steps);
a_NM = zeros(1,steps);

k_hat = (wn^2 + (gamma/(beta*dt))*2*zeta*wn + 1/(beta*dt^2));
a1 = 1/(beta*dt) + (gamma/beta)*2*zeta*wn;
b1 = 1/(2*beta) + dt*((gamma/(2*beta)) - 1)*2*zeta*wn;

% initial relative acceleration
a_NM(1) = -A(1) - 2*zeta*wn*v_NM(1) - wn^2*u_NM(1);

% subsequent steps
for i = 1:steps-1
    dA(i) = - A(i+1) + A(i) + a1*v_NM(i) + b1*a_NM(i);
    du_NM(i) = dA(i)/k_hat;
    dv_NM(i) = (gamma/(beta*dt))*du_NM(i) - (gamma/beta)*v_NM(i) + dt*(1 - (gamma/(2*beta)))*a_NM(i);
    da_NM(i) = (1/(beta*dt^2))*du_NM(i) - (1/(beta*dt))*v_NM(i) - (1/(2*beta))*a_NM(i);

    u_NM(i+1) = u_NM(i) + du_NM(i);
    v_NM(i+1) = v_NM(i) + dv_NM(i);
    a_NM(i+1) = a_NM(i) + da_NM(i);
end

% absolute acceleration
a_abs = A + a_NM;

% Plots
figure;
subplot(3,1,1); plot(t,a_NM); grid on; xlabel('t (s)'); ylabel('a (m/s^2)'); title('Relative Acceleration');
subplot(3,1,2); plot(t,v_NM); grid on; xlabel('t (s)'); ylabel('v (m/s)'); title('Relative Velocity');
subplot(3,1,3); plot(t,u_NM); grid on; xlabel('t (s)'); ylabel('u (m)'); title('Relative Displacement');
sgtitle('Part (d) – Relative u, v, a with Newmarks method');

figure; plot(t,a_abs); grid on
xlabel('t (s)'); ylabel('a (m/s^2)'); title('Part (d) – Absolute Acceleration');

umax_d = max(abs(u_NM));
tmax_d = t(find(abs(u_NM)==umax_d, 1, 'first') );
peak_abs = max(abs(a_abs))/9.81;  % g
fprintf('(d) Newmark: max|u| = %.6e m at t = %.3f s; Peak |a_abs| = %.3f g\n', umax_d, tmax_d, peak_abs);

%% Part e) --------------------------------------------------------------
% Duhamel vs CDM vs Newmark
figure;
plot(t,u_total_duhamel,'g','LineWidth',1.4); hold on;
plot(t,u,'r');
plot(t,u_NM,'b'); hold off;
grid on
xlabel('t (s)'); ylabel('u (m)'); title('Part (e) – Relative Displacement');
legend('Duhamel','CDM','Newmark');

umax_b = max(abs(u_total_duhamel));
umax_c = max(abs(u));
umax_d = max(abs(u_NM));
fprintf('(e) Summary of max|u| (m): Duhamel = %.6e, CDM = %.6e, Newmark = %.6e\n', umax_b, umax_c, umax_d);

%% Part f) --------------------------------------------------------------
% Peak |a_abs| (Newmark) vs PGA, and effect of natural period (kept same)

% at current Tn
peak_abs = max(abs(a_abs))/9.81;   % g
fprintf('(f) Peak |a_abs| (Newmark at Tn=%.2f s) = %.3f g ; PGA = %.3f g\n', ...
        Tn, peak_abs, PGA/9.81);

% sweep a few periods
Tlist = [0.20 0.50 1.00 2.00];
peak_vs_T = zeros(size(Tlist));

beta = 1/6; gamma = 1/2;

for jj = 1:length(Tlist)
    Tnow = Tlist(jj);
    wnJ  = 2*pi/Tnow;

    x1J = (wnJ^2 + (gamma/(beta*dt))*2*zeta*wnJ + 1/(beta*dt^2));
    x2J = 1/(beta*dt) + (gamma/beta)*2*zeta*wnJ;
    x3J = 1/(2*beta) + dt*((gamma/(2*beta)) - 1)*2*zeta*wnJ;

    uJ = zeros(1,steps); vJ = zeros(1,steps); aJ = zeros(1,steps);
    aJ(1) = -A(1) - 2*zeta*wnJ*vJ(1) - wnJ^2*uJ(1);

    for i = 1:steps-1
        dAJ = -(A(i+1) - A(i)) + x2J*vJ(i) + x3J*aJ(i);
        duJ = dAJ/x1J;
        dvJ = (gamma/(beta*dt))*duJ - (gamma/beta)*vJ(i) + dt*(1 - gamma/(2*beta))*aJ(i);
        daJ = (1/(beta*dt^2))*duJ - (1/(beta*dt))*vJ(i) - (1/(2*beta))*aJ(i);
        uJ(i+1) = uJ(i) + duJ; vJ(i+1) = vJ(i) + dvJ; aJ(i+1) = aJ(i) + daJ;
    end

    a_abs_J = A + aJ;
    peak_vs_T(jj)= max(abs(a_abs_J))/9.81;      % g
end

fprintf('(f) Peak |a_abs| vs Tn (g):\n');
for jj = 1:length(Tlist)
    fprintf('Tn = %.2f s -> %.3f g (ratio to PGA = %.2f)\n', Tlist(jj), peak_vs_T(jj), peak_vs_T(jj)/(PGA/9.81));
end

figure;
plot(Tlist,peak_vs_T,'-o','LineWidth',1.2); hold on;
yline(PGA/9.81,'--','PGA','LabelHorizontalAlignment','left'); hold off; grid on;
xlabel('T_n (s)'); ylabel('Peak |a_{abs}| (g)');
title('Part (f) – Peak absolute acceleration vs T_n');
