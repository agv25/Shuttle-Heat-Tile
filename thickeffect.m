% Script to plot inner surface temperature against time for different
% thicknesses using Crank-Nicolson method

clear all % clear workspace

% Final inner temp for different thicknesses

i=0;
bestMethod = 'crank-nicolson';  % stable with 2nd order accuracy in time and space
bestnx = 51;   % chosen from analysis in shuttlestability_nx for crank
bestnt = 501;   % chosen from analysis in shuttlestability_nt for crank
tmax = 4000;   % default max time


figure(5)
% Loop to run shuttle.m for every thickness
for thick = 0.02:0.01:0.08
    hold on  % Keep last plot
    i=i+1;    
    % Run shuttle to find temperature
    [~, t, u] = shuttle(tmax, bestnt, thick, bestnx, bestMethod, false);
    
    % Plot tile inner temp vs time for each thickness
    plot(t,u(:,end));
end

% Plot max temp of 175degC for comparison
plot([0,max(t)], [175,175], 'r-.');

% Plot outer Surface Temp for comparison
plot(t, u(:,1), 'k--');
title('Tile Inner Surface Temperature vs Time for Varied Tile Thicknesses');
xlabel('Time, t (s)');
ylabel(['Inner Surface Temperature (' char(176) 'C)']);
legend('0.02m', '0.03m','0.04m','0.05m','0.06m','0.07m','0.08m','Max Temp.', 'Outer Surface');


