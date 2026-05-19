%% CIVL 8360 – Term Project
% Plot ALL cases vs baseline from Total.xlsx using exact table ranges
clear; clc; close all;

fileName    = 'Total.xlsx';
stories     = 1:3;
storyLabels = {'Story 1','Story 2','Story 3'};
eqNames     = {'Loma Prieta','Northridge'};

% 7 cases in order of your table (3 columns per case)
caseLabels = { ...
    'Baseline', ...
    'C=600 – 1 Big', ...
    'C=600 – 3 Small', ...
    'C=1200 – 1 Big', ...
    'C=1200 – 3 Small', ...
    'C=1800 – 1 Big', ...
    'C=1800 – 3 Small'};

%% helper handle (3-storey responses) =====================================
plot_three_storey = @(M, quantityName, yLabelText) ...
    plot_three_storey_internal(M, stories, storyLabels, ...
                               eqNames, caseLabels, ...
                               quantityName, yLabelText);

%% 1) DISPLACEMENT  (B4:V5) ===============================================
Mdisp = readmatrix(fileName, 'Sheet','Displacement', ...
                              'Range','B4:V5');   % 2 x 21
plot_three_storey(Mdisp, 'Displacement', 'Displacement (mm)');

%% 2) STORY DRIFT  (B4:V5) ================================================
Mdrift = readmatrix(fileName, 'Sheet','Story Drift', ...
                               'Range','B4:V5');   % 2 x 21
plot_three_storey(Mdrift, 'Storey Drift', 'Storey Drift (mm)');

%% 3) PEAK FLOOR ACCELERATION  (B4:V5) ====================================
Macc = readmatrix(fileName, 'Sheet','Peak |acceleration|', ...
                             'Range','B4:V5');     % 2 x 21
plot_three_storey(Macc, 'Peak Floor Acceleration', ...
                        'Peak Floor Acc. (m/s^2)');

%% 4) BASE SHEAR  (B4:H5) =================================================
% B–H: baseline + 6 damper cases (same order as caseLabels)
Mbs = readmatrix(fileName, 'Sheet','Base Shear', ...
                            'Range','B4:H5');     % 2 x 7

for eq = 1:2
    figure;
    bar(Mbs(eq,:));
    grid on;
    xticks(1:numel(caseLabels));
    xticklabels(caseLabels);
    xtickangle(30);
    ylabel('Base Shear (kN)');
    title(sprintf('Base Shear – %s', eqNames{eq}));
end


%% INTERNAL FUNCTION (same file) ==========================================
function plot_three_storey_internal(M, stories, storyLabels, ...
                                    eqNames, caseLabels, ...
                                    quantityName, yLabelText)
% M is 2 x 21 numeric: 3 columns per case × 7 cases
nCases = numel(caseLabels);

for eq = 1:2
    figure; hold on;
    for k = 1:nCases
        cols = (3*(k-1)+1):(3*k);  % columns for this case
        y    = M(eq, cols);        % [Story1 Story2 Story3]

        plot(stories, y, '-o', ...
             'LineWidth', 1.5, ...
             'DisplayName', caseLabels{k});
    end
    grid on;
    xticks(stories);
    xticklabels(storyLabels);
    xlabel('Storey');
    ylabel(yLabelText);
    title(sprintf('%s vs Storey – %s', quantityName, eqNames{eq}));
    legend('Location','eastoutside');
    hold off;
end
end
