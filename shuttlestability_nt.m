% Script to analyse time step stability for each method
% Created by Alex Varney 01/04/2021
% Use data from automaticImageAnalysis.m

clear all % clear workspace

% Investigation for Time Step, dt

i=0;   % initialise indeces
nx = 21;   % default number of spatial steps
thick = 0.05;   % default tile thickness
tmax = 4000;   % max time of simulation  

% Loop to run shuttle.m for every time step and take its final temp
for nt = 41:5:1001   % creates dt from 100s to 4s
    i=i+1;  % increase index by one
    dt(i) = tmax/(nt-1);   % calculate each dt
    % display nt & dt
    disp (['nt = ' num2str(nt) ', dt = ' num2str(dt(i)) ' s']); 
    
    % Find Forward final temp at each time step
    [~, ~, u] = shuttle(tmax, nt, thick, nx, 'forward', false);
    uf(i) = u(end, nx);
    
    % Find Backward final temp at each time step
    [~, ~, u] = shuttle(tmax, nt, thick, nx, 'backward', false);
    ub(i) = u(end, nx);
    
    % Find DuFort-Frankel final temp at each time step
    [~, ~, u] = shuttle(tmax, nt, thick, nx, 'dufort-frankel', false);
    ud(i) = u(end, nx);
    
    % Find Crank-Nicolson final temp at each time step
    [~, ~, u] = shuttle(tmax, nt, thick, nx, 'crank-nicolson', false);
    uc(i) = u(end, nx);
end

% Plot timestep vs final temp
figure(3)
plot(dt, [uf; ub; ud; uc]);
title('Time Step Stability Investigation for All Methods')
xlabel('Time step, dt (s)')
ylabel(['Final Temp at Inner Surface (' char(176) 'C)'])
ylim([145 180]);  % apply axes limits fro best representaion
xlim([0 100]);  
hold on

% Plot 2 lines +/-1% of final inner surface temp
% Find average inner surface temp
tempAvg = (uf(end) + ub(end) + ud(end) + uc(end))/4;

% Create error limit +/-1% and use for tolerance
error = 0.01;
tolerance = error*tempAvg;

% Create upper and lower limits
upperT = tempAvg + tolerance;
lowerT = tempAvg - tolerance;

% Plot upper and lower limits
plot([0,max(dt)],[upperT,upperT], 'k--');
plot([0,max(dt)],[lowerT,lowerT], 'k--');
legend ('Forward', 'Backward', 'DuFort-Frankel', 'Crank-Nicolson');
set(legend, 'Location', 'Best')


% Find dt where each method becomes too innaccurate
% Forward
i=0;
% Run through time steps large to small again
for nt = 41:5:1001
    i=i+1;
    dt(i) = tmax/(nt-1);
    % If statement to know max allowable time step
    if uf(i) > lowerT & uf(i) < upperT
        fmaxdt = dt(i);    % forward max time step
        break  % stop the for loop
    end
end

% Backwards
i=0;
% Run through time steps large to small again
for nt = 41:5:1001
    i=i+1;
    dt(i) = tmax/(nt-1);    
    % If statement to know max allowable time step
    if ub(i) > lowerT & ub(i) < upperT
        bmaxdt = dt(i);    % backwards max time step
        break  % stop the for loop
    end
end

% DuFort-Frankel
i=0;
% Run through time steps large to small again
for nt = 41:5:1001
    i=i+1;
    dt(i) = tmax/(nt-1);
    % If statement to know max allowable time step
    if ud(i) > lowerT & ud(i) < upperT
        dmaxdt = dt(i);    % dufort max time step
        break  % stop the for loop
    end
end

% Crank-Nicolson
i=0;
% Run through time steps large to small again
for nt = 41:5:1001
    i=i+1;
    dt(i) = tmax/(nt-1);
    % If statement to know max allowable time step
    if uc(i) > lowerT & uc(i) < upperT
        cmaxdt = dt(i);    % crank-nicolson max time step
        break  % stop the for loop
    end
end

% Determine most stable method and each methods max dt 
% Calculate nt for each dt
fnt = (tmax/fmaxdt) + 1;
bnt = (tmax/bmaxdt) + 1;
dnt = (tmax/dmaxdt) + 1;
cnt = (tmax/cmaxdt) + 1;

% Put into matrix to itentify most and least stable method
methodnt = [fnt, bnt, dnt, cnt];
methods = ["Forward Differencing", "Backward Differencing", "DuFort-Frankel", "Crank-Nicolson"];

% Most stable has minimum nt, least stable has max nt
dtmostStableMethod = methods(find(methodnt == min(methodnt)));
dtleastStableMethod = methods(find(methodnt == max(methodnt)));

% Display least and most stable method
disp(['Least stable method/s with respect to time step is:', dtleastStableMethod]);
disp(['Most stable method/s with respect to time step is:', dtmostStableMethod]);

% Display all max time steps for each method for user
disp(['Max Forward Differencing Time Step: ', num2str(fmaxdt), 's (nt = ', num2str(fnt),')'])
disp(['Max Backwards Differencing Time Step: ', num2str(bmaxdt), 's (nt = ', num2str(bnt),')'])
disp(['Max DuFort-Frankel Time Step: ', num2str(dmaxdt), 's (nt = ', num2str(dnt),')'])
disp(['Max Crank-Nicolson Time Step: ', num2str(cmaxdt), 's (nt = ', num2str(cnt),')'])


