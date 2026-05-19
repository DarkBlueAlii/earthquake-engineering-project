%% Reduction plots for Ali's term project
clc; clear; close all;

% Case labels (order matches your tables) ---------------------------------
cases = {'C=600 kN-s/m (1 Damper)', 'C=600 kN-s/m (3 Dampers)', ...
         'C=1200 kN-s/m (1 Damper)','C=1200 kN-s/m (3 Dampers)', ...
         'C=1800 kN-s/m (1 Damper)','C=1800 kN-s/m (3 Dampers)'};
nCase = numel(cases);

%% 1) BASE SHEAR REDUCTION (%) ============================================
% From your "Base Shear" sheet (Reduction % row)
baseRed_Loma = [14.45 14.64 14.41 14.49 14.73 14.85];
baseRed_Nort = [30.67 31.40 25.97 28.57 22.67 25.08];

baseRed = [baseRed_Loma(:) baseRed_Nort(:)];

figure;
bar(baseRed);
set(gca,'XTick',1:nCase,'XTickLabel',cases);
xtickangle(45);
ylabel('% Reduction');
title('Base Shear Reduction (%)');
legend('Loma Prieta','Northridge','Location','best');
grid on;

%% 2) DISPLACEMENT REDUCTION (%) ==========================================
% From your "Displacement" sheet (Reduction % row)
% rows = cases, cols = Story 1–3
dispRed_Loma = [16.84 18.29 19.01;   % C600-1Big
                16.97 18.50 19.23;   % C600-3Small
                17.23 18.70 19.40;   % C1200-1Big
                16.97 18.50 19.68;   % C1200-3Small
                18.26 19.66 20.29;   % C1800-1Big
                17.49 19.11 19.90];  % C1800-3Small

dispRed_Nort = [35.46 35.25 35.15;   % C600-1Big
                30.86 30.35 30.40;   % C600-3Small
                34.94 38.60 40.30;   % C1200-1Big
                35.76 40.44 42.62;   % C1200-3Small
                34.57 38.12 39.81;   % C1800-1Big
                34.42 39.08 41.30];  % C1800-3Small

% Average over the 3 storeys (same as my plots)
dispRed_Loma_mean = mean(dispRed_Loma, 2);
dispRed_Nort_mean = mean(dispRed_Nort, 2);

dispRed = [dispRed_Loma_mean dispRed_Nort_mean];

figure;
bar(dispRed);
set(gca,'XTick',1:nCase,'XTickLabel',cases);
xtickangle(45);
ylabel('% Reduction');
title('Displacement Reduction (%)');
legend('Loma Prieta','Northridge','Location','best');
grid on;

%% 3) DRIFT REDUCTION (%) =================================================
% From your "Story Drift" sheet (Reduction % row)
driftRed_Loma = [16.73 19.91 22.94;   % C600-1Big
                 16.73 20.35 22.94;   % C600-3Small
                 17.12 20.35 22.94;   % C1200-1Big
                 16.73 20.35 22.94;   % C1200-3Small
                 18.29 20.78 22.94;   % C1800-1Big
                 17.51 20.78 23.85];  % C1800-3Small

driftRed_Nort = [35.49 35.01 34.76;   % C600-1Big
                 30.80 29.98 30.47;   % C600-3Small
                 34.82 42.23 45.49;   % C1200-1Big
                 35.71 44.42 47.21;   % C1200-3Small
                 34.60 41.58 46.35;   % C1800-1Big
                 34.38 43.76 36.91];  % C1800-3Small

driftRed_Loma_mean = mean(driftRed_Loma, 2);
driftRed_Nort_mean = mean(driftRed_Nort, 2);

driftRed = [driftRed_Loma_mean driftRed_Nort_mean];

figure;
bar(driftRed);
set(gca,'XTick',1:nCase,'XTickLabel',cases);
xtickangle(45);
ylabel('% Reduction');
title('Drift Reduction (%)');
legend('Loma Prieta','Northridge','Location','best');
grid on;

%% 4) PEAK FLOOR ACCELERATION REDUCTION (%) ===============================
% From your "Peak Floor Acc" sheet (Reduction % row)
accRed_Loma = [ 9.80 19.22 24.86;   % C600-1Big
                9.90 19.60 25.19;   % C600-3Small
                9.79 19.27 24.81;   % C1200-1Big
                9.76 19.45 25.04;   % C1200-3Small
               10.03 19.71 25.21;   % C1800-1Big
               10.01 19.91 25.61];  % C1800-3Small

accRed_Nort = [ 7.04 36.43 35.54;   % C600-1Big
                8.39 31.00 31.69;   % C600-3Small
                0.75 41.06 46.10;   % C1200-1Big
                2.24 42.74 47.37;   % C1200-3Small
                1.25 39.76 48.27;   % C1800-1Big
                2.40 42.16 51.01];  % C1800-3Small

accRed_Loma_mean = mean(accRed_Loma, 2);
accRed_Nort_mean = mean(accRed_Nort, 2);

accRed = [accRed_Loma_mean accRed_Nort_mean];

figure;
bar(accRed);
set(gca,'XTick',1:nCase,'XTickLabel',cases);
xtickangle(45);
ylabel('% Reduction');
title('Peak Floor Acceleration Reduction (%)');
legend('Loma Prieta','Northridge','Location','best');
grid on;
