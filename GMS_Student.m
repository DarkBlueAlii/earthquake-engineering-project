% Ground Motion Selection
% NVE - Nov. 8, 2019
% Revision - Nov. 29, 2022

% This script is to select ground motions based on the NBC requirements.
% It follows Method A. It assumes that the structure is not base isolated.

% This script is for educational purposes only.

clearvars; close all; clc;
scrsz = get(0,'ScreenSize'); MyFont = {'FontName', 'Arial', 'FontSize', 8,'FontWeight','light'};

%% Period Range -----------------------------------------------------------
T = 0.85; % (s) - This is the target period based on effective stiffness
Tmin = 0.2*T; % (s)
Tmax = max(2.0*T,1.5); % (s)

% Target Spectrum ---------------------------------------------------------
% https://earthquakescanada.nrcan.gc.ca/hazard-alea/interpolat/nbc2020-cnb2020-en.php

Ta = [0 0.05 0.1 0.2 0.3 0.5 1.0 2.0 5.0 10.0]; % (s)

% Montreal, 10% in 50, (45.5017,-73.5673)
Sa = [0 0.249 0.232 0.141 0.105 0.0725 0.0356 0.0157 0.00390 0.00148];  %10
Loc = 'east'; % Location, east or west coast

% Vancouver, 2% in 50, (49.2827, -123.1207)
% Sa = [0.364 0.446 0.678 0.838 0.842 0.745 0.420 0.255 0.080 0.028]; 
% Loc = 'west'; % Location, east or west coast

% Site Coefficients -------------------------------------------------------
SC = 'a';                                       % Site Class (lower case)
%SiteClass % Function to correct site class - Not required for 2020 NBCC

% Number of scenarios to check based on east or west coast
if strcmp(Loc,'east'); Mmax = 2; else; Mmax = 3; end

% Compare Records to Target -----------------------------------------------
nR = 14;                    % Number of records per magnitude and distance
Mag = '679';                                        % Magnitude considered

SummaryO = []; 

% Plotting - Single plot - Figure of Ratio --------------------------------
SF = 1.0; % Adjust the size of the plot
figure('Name','Global Scaling','OuterPosition',[scrsz(3)/4 scrsz(4)/4 418*SF 313*SF],'Color','white') % Opens a new figure window
set(gca,'un','n','pos',[0.12 0.16 0.783 0.765]); % sets the location of the plot in the figure


for M = 1:Mmax
    
    % Function that collects the record to consider
    CollectRecords
    SummaryO = [SummaryO; Summary];
    
    % Select the best nR records ------------------------------------------   
    [A B] = sort(Summary(:,4)); % Sort based
    
    % Load response spectrum and acceleration records for select magnitude
    if M < 3 
        x1 = importdata([ Loc 'psa/' Loc Mag(M) SC '1.psa'])/100/9.81; % Load spectrums
        x2 = importdata([ Loc 'psa/' Loc Mag(M) SC '2.psa'])/100/9.81; % Load spectrums
        a1 = importdata([ Loc 'acc/' Loc Mag(M) SC '1.acc']); % Load spectrums
        a2 = importdata([ Loc 'acc/' Loc Mag(M) SC '2.acc']); % Load spectrums
        minL = min(length(a1),length(a2));
    else % For west coast Magnitude 9 there is only one distance
        x1 = importdata([ Loc 'psa/' Loc Mag(M) SC '1.psa'])/100/9.81; % Load spectrums
        a1 = importdata([ Loc 'acc/' Loc Mag(M) SC '1.acc']); % Load spectrums
        minL = min(length(a1));    
    end
       
    for i = 1:nR % Selects and scales each response spectrum and time history
        if(Summary(B(i),1)) == 1
            Outacc(:,i) = a1(1:minL,Summary(B(i),2)+1)*Summary(B(i),3);
            Outpsa(:,i) = x1(:,Summary(B(i),2)+1)*Summary(B(i),3);
        else
            Outacc(:,i) = a2(1:minL,Summary(B(i),2)+1)*Summary(B(i),3);
            Outpsa(:,i) = x2(:,Summary(B(i),2)+1)*Summary(B(i),3);
        end
        
        Selected(i+(M-1)*nR,1:5) = Summary(B(i),:); % Summary of selected records
        
    end
    
    clear Summary
    
    % Check that mean does not go lower than 90% of target spectrum =======
    muSR = spline(Ti,mean(Outpsa,2),Trs); % mean of response spectrums
    Ratio = muSR./ST; % Ratio of mean to target spectrum 
    
    if min(Ratio) < 0.9 % Applies correction if any fall below 90%
        Correction = 0.9/min(Ratio);
        Outacc = Correction*Outacc;
        Outpsa = Correction*Outpsa;
    else 
        Correction = 1; 
    end
    
    % plot
    plot(Trs,Ratio,'LineWidth',2); hold all
    plot(Trs,ones(length(Trs),1)*0.9,':','LineWidth',2,'Color','Black'); hold all
    
    % Labels
    ylabel('Ratio','Interpreter','latex');
    xlabel('Period (s)','Interpreter','latex');

    % Style
    set(gca, MyFont{:}); set(gcf, 'renderer', 'painters'); % Axis
        
    % Summary of selected records, records correction applied
    Selected((M-1)*nR+1:M*nR,6) = Correction; 
    
    % Column 1 = Distance number
    % Column 2 = Record number
    % Column 3 = Local scale factor
    % Column 4 = Standard deviation 
    % Column 5 = Magnitude scenario number
    % Column 6 = Global scale factor

    % Message for user to review data if large correction is applied
    if Correction > 1.05 || Correction < 0.95
        disp('WARNING: Large correction, check inputs');
        disp(['    Correction = ' num2str(Correction)]);
        disp(['    Magnitude = ' Mag(M)]);
        disp(''); 
    end
    
    % Mean of scaled response spectrum for plotting
    meanSR(:,M) = mean(Outpsa,2);

    % Output results ------------------------------------------------------
    if M == 1
        Outacc1 = Outacc;
        Outpsa1 = Outpsa; 
        csvwrite(['Output/' Loc '_' Mag(1) '_acc.csv'],Outacc1); 
        csvwrite(['Output/' Loc '_' Mag(1) '_psa.csv'],Outpsa1); 
    elseif M == 2
        Outacc2 = Outacc;
        Outpsa2 = Outpsa;
        csvwrite(['Output/' Loc '_' Mag(2) '_acc.csv'],Outacc2);
        csvwrite(['Output/' Loc '_' Mag(2) '_psa.csv'],Outpsa2);
    elseif M == 3
        Outacc3 = Outacc;
        Outpsa3 = Outpsa;
        csvwrite(['Output/' Loc '_' Mag(3) '_acc.csv'],Outacc3); 
        csvwrite(['Output/' Loc '_' Mag(3) '_psa.csv'],Outpsa3);
    end
    
    clear Outacc Outpsa
    
end


% Plotting - Single plot --------------------------------------------------
SF = 1.0; % Adjust the size of the plot
figure('Name','Response Spectra Comparison','OuterPosition',[scrsz(3)/4 scrsz(4)/4 418*SF 313*SF],'Color','white') % Opens a new figure window
set(gca,'un','n','pos',[0.12 0.16 0.783 0.765]); % sets the location of the plot in the figure


% Define plots
plot(Ta,Sa,'LineWidth',2,'Color','Black'); hold all
plot(Ti,meanSR(:,1),':','LineWidth',2,'Color','Red'); hold all
plot(Ti,meanSR(:,2),':','LineWidth',2,'Color','Blue'); hold all

if Mmax == 3
    plot(Ti,meanSR(:,3),':','LineWidth',2,'Color','Green'); hold all
end

plot(Ti,Outpsa1,'LineWidth',1,'Color',[0.9 0.9 0.9]); hold all
plot(Ti,Outpsa2,'LineWidth',1,'Color',[0.9 0.9 0.9]); hold all

if Mmax == 3 
    plot(Ti,Outpsa3,'LineWidth',1,'Color',[0.9 0.9 0.9]); hold all
end

plot(Ta,Sa,'LineWidth',2,'Color','Black'); hold all
plot(Ti,meanSR(:,1),':','LineWidth',2,'Color','Red'); hold all
plot(Ti,meanSR(:,2),':','LineWidth',2,'Color','Blue'); hold all

if Mmax == 3
    plot(Ti,meanSR(:,3),':','LineWidth',2,'Color','Green'); hold all
end

ylim = ceil((max([Outpsa1; Outpsa2],[],'all'))/0.2)*0.2; 
% x and y axis limits
axis([0 4 0 ylim]);

% X-Axis Label (Custom ticks)
set(gca,'xTick',[0:1:4])
ytickformat('%.0f'); % the number after .% is how many decimals

% Y-Axis
ytickformat('%.1f'); 

% Labels
ylabel('S (g)','Interpreter','latex');
xlabel('Period (s)','Interpreter','latex');

% Legend
h = legend('Target','Fit - 1','Fit - 2','location','NorthEast');

if Mmax == 3
    h = legend('Target','Fit - 1','Fit - 2','Fit - 3','location','NorthEast');
end

%set(h, 'Box', 'on','Interpreter','latex')

% Text
%text(10,475,'ISO Office','Interpreter','latex','FontSize',8)

% Style
set(gca, MyFont{:}); set(gcf, 'renderer', 'painters'); % Axis

% =========================
% print(['OnePlotFigure'],'-depsc')
% print(['OnePlotFigure'],'-dpdf')




