% Script to analyse spatial step stability for each method
% Created by Alex Varney 01/04/2021
% Use data from automaticImageAnalysis.m

clear all  % clear workspace

% Investigation for Spatial Step, dx

i=0;   % initialise indeces
thick = 0.05;   % default thickness
tmax = 4000;   % max time of the simulation
nt = 501;   % default number of time steps

% Loop to run shuttle.m for every spatial step and take its final temp
for nx = 6:5:401
    i=i+1;  % increase index by one
    dx(i) = thick/(nx-1);  % calculate each dx
    % display each nx & dx
    disp (['nx = ' num2str(nx) ', dx = ' num2str(dx(i)) ' m']);
    
    % Find Forward final temp at each spatial step
    [~, ~, u] = shuttle(tmax, nt, thick, nx, 'forward', false);
    uf(i) = u(end, nx);
    
    % Find Backward final temp at each spatial step
    [~, ~, u] = shuttle(tmax, nt, thick, nx, 'backward', false);
    ub(i) = u(end, nx);
    
    % Find DuFort-Frankel final temp at each spatial step
    [~, ~, u] = shuttle(tmax, nt, thick, nx, 'dufort-frankel', false);
    ud(i) = u(end, nx);
    
    % Find Crank-Nicolson final temp at each spatial step
    [~, ~, u] = shuttle(tmax, nt, thick, nx, 'crank-nicolson', false);
    uc(i) = u(end, nx);
end

% Plot timestep vs final temp
figure(4)
plot(dx, [uf; ub; ud; uc]);
title('Spatial Step Stability Investigation for All Methods')
xlabel('Spatial Step, dx (m)')
ylabel(['Final Temp at Inner Surface (' char(176) 'C)'])
ylim([155 165]);
% xlim([0 100]);
hold on

% Plot 2 lines +/-1% of final inner surface temp
% Find estimate of average inner surface temp
tempAvg = (ub(end) + uc(end))/2;  % only use backwards and crank

% Create error limit +/-1% and use for tolerance
error = 0.01;
tolerance = error*tempAvg;

% Create upper and lower limits
upperT = tempAvg + tolerance;
lowerT = tempAvg - tolerance;

% Plot upper and lower limits
plot([0,max(dx)],[upperT,upperT], 'k--');
plot([0,max(dx)],[lowerT,lowerT], 'k--');
legend ('Forward', 'Backward', 'DuFort-Frankel', 'Crank-Nicolson');
set(legend, 'Location', 'Best')


% Find dx where each method becomes too innaccurate
% Forward
i=0;
% Run through spatial steps large to small again
for nx = 6:5:401
    i=i+1;
    dx(i) = thick/(nx-1);
    % If statement to know min allowable spatial step
    if uf(i) < lowerT || uf(i) > upperT
        fmindx = dx(i-1);    % forward min spatial step
        break  % stop the for loop
    end
end

% Backward
i=0;
% Run through time steps large to small again
for nx = 6:5:401
    i=i+1;
    dx(i) = thick/(nx-1);
    % If statement to know min allowable spatial step
    if ub(i) < lowerT || ub(i) > upperT
        bmindx = dx(i-1);    % backwards min spatial step
        break  % stop the for loop
    else
        bmindx = dx(end); % reaches end of the loop
    end
end

% DuFort-Frankel
i=0;
% Run through spatial steps large to small again
for nx = 6:5:401
    i=i+1;
    dx(i) = thick/(nx-1);    
    % If statement to know min allowable spatial step
    if ud(i) < lowerT || ud(i) > upperT
        dmindx = dx(i-1);    % dufort max spatial step
        break  % stop the for loop
    end
end

% Crank-Nicolson
i=0;
% Run through time steps large to small again
for nx = 6:5:401
    i=i+1;
    dx(i) = thick/(nx-1);   
    % If statement to know min allowable spatial step
    if uc(i) < lowerT || uc(i) > upperT
        cmindx = dx(i-1);    % crank-nicolson min spatial step
        break  % stop the for loop
    else
        cmindx = dx(end);  % reaches end of the loop
    end
end

% Determine most stable method and each methods min dx
% Calculate nx for each dx
fnx = (thick/fmindx) + 1;
bnx = (thick/bmindx) + 1;
dnx = (thick/dmindx) + 1;
cnx = (thick/cmindx) + 1;

% Put into matrix to itentify most and least stable method
methodnx = [fnx, bnx, dnx, cnx];
methods = ["Forward Differencing", "Backward Differencing", "DuFort-Frankel", "Crank-Nicolson"];

% Most stable has max nx, least stable has min nx
dxmostStableMethod = methods(find(methodnx == max(methodnx)));
dxleastStableMethod = methods(find(methodnx == min(methodnx)));

% Display least and most stable method
disp(['Least stable method/s with respect to spatial step is:', dxleastStableMethod]);
disp(['Most stable method/s with respect to spatial step is:', dxmostStableMethod]);

% Display all min spatial steps for each method for user
disp(['Min Forward Differencing Spatial Step: ', num2str(fmindx), 'm (nx = ', num2str(fnx),')'])
disp(['Min Backwards Differencing Spatial Step: ', num2str(bmindx), 'm (nx = ', num2str(bnx),')'])
disp(['Min DuFort-Frankel Spatial Step: ', num2str(dmindx), 'm (nx = ', num2str(dnx),')'])
disp(['Min Crank-Nicolson Spatial Step: ', num2str(cmindx), 'm (nx = ', num2str(cnx),')'])




