    

% For magnitude 9 scenario, there is only one distance to consider
if M == 3
    jmax = 1;
else
    jmax = 2;
end

for j = 1:jmax % Check near and far motion
        
        x = importdata([Loc 'psa/' Loc Mag(M) SC num2str(j) '.psa']); % Load spectrums
        Freq = x(:,1); % (Hz) Frequency of input spectrum
        Ti = 1./Freq; % (s) Period of input spectrum
        x = x(:,2:end)/100/9.81; % Convert units from cm/s2 to g
        
        % Assign range to fit over; these values based on recommendation
        % from Atkinson (2009)
        if strcmp('east',Loc) == 1 && M == 1 
            Trmin = 0; % Default 0
            Trmax = 1.0; % Default 1.0
        elseif strcmp('east',Loc) == 1 && M == 2
            Trmin = 0.5; % Default 0.5
            Trmax = 2.0; % Default 2.0
        elseif strcmp('west',Loc) == 1 && M == 1
            Trmin = 0; % Default 0
            Trmax = 1.0; % Default 1.0
        elseif strcmp('west',Loc) == 1 && M == 2
            Trmin = 0.5; % Default 0.5
            Trmax = 2.0; % Default 2.0
        elseif strcmp('west',Loc) == 1 && M == 3   
            Trmin = 1.0; % Default 1.0
            Trmax = 5.0; % Default 5.0
        end
            
        % Ensure a fit over the entire period range of interest -----------
        % Assign a period spacing of 0.02 seconds
        Trs = max(Tmin,Trmin):0.02:min(Tmax,Trmax); 
        if strcmp('east',Loc) == 1 && M == 2 && Trmax < Tmax
            Trs = max(Tmin,Trmin):0.02:Tmax; 
        end
            
        % Check NBC requirement to have at least 20 points 
        % Increases the number of points by 2 if it doesn't, error if still
        % not okay
        if length(Trs)<20 
            disp('Not enough time steps')
            disp(['    Magnitude = ' Mag(M)]); 
            Trs = min(Trs):0.01:max(Trs);
            if length(Trs)<20 
                error('NOT ENOUGH TIME STEPS - CHANGE INTERVAL'); 
            end
        end
        
        ST = (interp1q(Ta',Sa',Trs'))'; % Target Spectrum fit to range of interest
        
        for i = 1:45 % 45 records per input file
            Sg = spline(Ti,x(:,i),Trs); % fitted input spectral acceleration
            mu(i) = mean(ST./Sg); % Mean target/input - This is the scale factor
            
            if mu(i) <= 2.0 && mu(i) > 0.5 % Check that mean is acceptable
                Std(i) = std(ST./Sg/(mu(i))); % Determine Standard deviation
                
            else
                Std(i) = 100; % If mean is not okay, give large STD
            end
            
            [A, B] = sort(Std); % Arrange from lowest Std to highest
        end
        
        % Select records and scale factor, record results
        
        for i = 1:nR % Number of records to select
            if j == 1
                Summary(i,1) = 1; % Distance
                Summary(i,2) = B(i); % Record number
                Summary(i,3) = mu(B(i)); % Scale factor
                Summary(i,4) = Std(B(i)); % STD
                Summary(i,5) = M; % Magnitude number
            elseif j == 2
                Summary(i+nR,1) = 2;
                Summary(i+nR,2) = B(i);
                Summary(i+nR,3) = mu(B(i));
                Summary(i+nR,4) = Std(B(i));
                Summary(i+nR,5) = M; 
            end
        end
        
        clear B Std
        
end