function [optimalThickness] = testThickness(thermCon, density, specHeat, maxT, location, drawPlot)
% Function that uses the shooting method to evaluate an optimal thickness
% for a given max temperature that the tile is allowed to reach at a chosen
% location on the shuttle
%
% created by Alex Varney 15/04/2021
% 
% Inputs:
% thermCon - thermal conductivity of material (0.0577)
% density - density of material (144)
% specHeat - specific heat of material (1261)
% maxT - maximum allowed tile temperature (Celsius)
% location - image number/location on the shuttle e.g. 597
% drawPlot - true to plot graph; false to suppress graph.
%
% Output:
% optimalThickness - the minimum thickness of the tile (m)
%
% For Example:
%   [optimalThickness] = testThickness(0.0577, 144, 1261, 175, 597, true);

% Chosen parameters
method = 'crank-nicolson';   % best chosen method
tmax = 4000;   
nt = 501;
nx = 51;
doPlot = false;  % no shuttle plot

% Initial Thickness guesses
thick1 = 0.1;
thick2 = 0.01;

% Shooting method loop
for i = 1:100  % enough loops to shoot many times
    
   % Call shuttle.m to run for both thicknesses
   [~,~,u1] = shuttleEnhanced(thermCon, density, specHeat, tmax, nt, thick1, nx, method, location, doPlot);
   [~,t,u2] = shuttleEnhanced(thermCon, density, specHeat, tmax, nt, thick2, nx, method, location, doPlot);
   
   % Identify temp at tile inner surface
   finalT(1) = max(u1(:,nx));
   finalT(2) = max(u2(:,nx));
   
   % Error for current loop
   error = maxT-finalT(2);
   
   if abs(error) < 0.1  % if less than 0.1 degree difference
       break
   end
   
   % Guess 3 by Shooting Method
   thick3 = thick2 + error*((thick2-thick1)/(finalT(2)-finalT(1)));
   
   % Update thicknesses for next shoot
   thick1 = thick2;
   thick2 = abs(thick3);
   
end

% Shooting method result, thick2 when loop breaks
optimalThickness = thick2;

% Display Optimal Thickness for tile
disp(['Max inner surface temperature of ', num2str(maxT),  char(176) 'C at location ', num2str(location), ': ', num2str(optimalThickness)]);

% testThickness plot
if drawPlot
    % Plot
    figure(6)
    plot(t,u2(:,end), 'r');  % temperature at inner surface vs time
    hold on
    plot(t, u2(:,1), 'b');   % temperature at outer surface vs time
    plot([0, max(t)], [maxT, maxT], 'k--');   % maximum allowable temp line
    legend('Inner Surface Temp.', 'Outer Surface Temp.', 'Maximum Allowable Temp.');
    title('Tile Temperature for Optimal Tile Thickness at Location ', num2str(location));
    xlabel('Time, t(s)');
    ylabel(['Temperature (', char(176), 'C)']);
end

