function [x, t, u] = shuttleEnhanced(thermCon, density, specHeat, tmax, nt, xmax, nx, method, location, doPlot)
% Function for modelling temperature in a space shuttle tile
% D N Johnston  05/02/21
% Modified by Alex Varney
%
% Input arguments:
% thermCon - thermal conductivity of material (0.0577 W/(m K))
% density - density of material (144, 9 lb/ft^3)
% specHeat - specific heat of material (1261)
% tmax   - maximum time
% nt     - number of timesteps
% xmax   - total thickness
% nx     - number of spatial steps
% method - solution method ('forward', 'backward' etc)
% location - image number/location on the shuttle, e.g. 597
% doPlot - true to plot graph; false to suppress graph.
%
% Return arguments:
% x      - distance vector
% t      - time vector
% u      - temperature matrix
%
% For example
%   [x, t, u] = shuttleEnhanced(0.0577, 144, 1261, 4000, 501, 0.05, 21, 'forward', true, 597);
%

% Loading in data from .mat file created by automaticImageAnalysis.m 
imagefile = num2str(location);
load(imagefile);  % trueTime (s) and trueTempC (Celsius)

% Initialise everything.
dt = tmax / (nt-1);
t = (0:nt-1) * dt;
dx = xmax / (nx-1);
x = (0:nx-1) * dx;
u = zeros(nt, nx);
alpha = thermCon/(density*specHeat);
p = alpha * dt / dx^2;

% Use interpolation to get outside temperature at times t 
% and store it as right-hand boundary R.
R = interp1(trueTime, trueTempC, t);

% set initial conditions equal to boundary temperature at t=0.
u(1, :) = R(1);
ivec = 2:nx-1; % set up index vector

% tic % time test to run shuttle
% Main timestepping loop.
for n=1:nt-1        % For time instance 1 to 500

    % Select method.
    switch method
        
        case 'forward'
            % calculate internal values using forward differencing
            u(n, 1) = R(n);
            u(n+1,ivec) = (1-2*p)*u(n,ivec) + p*(u(n,ivec-1)+u(n,ivec+1));
            
            % equation for neumann boundary
            u(n+1,nx) = (1-2*p)*u(n,nx)+2*p*u(n,nx-1);
            
            methTitle = 'Forward Differencing Method';
            
        case 'dufort-frankel'
            if n == 1
                nminus1 = 1;  % if statement for n-1 value when n=1
            else
                nminus1 = n-1;
            end
            % calculate internal values using dufort-frankel
            u(n, 1) = R(n);
            u(n+1,ivec) = ((1-2*p)*u(nminus1,ivec)+2*p*(u(n,ivec-1)+u(n,ivec+1)))/(1+2*p);
            
            % equation for neumann boundary
            u(n+1,nx) = ((1-2*p)*u(nminus1,nx)+4*p*u(n,nx-1))/(1+2*p);
            
            methTitle = 'DuFort-Frankel Method';
            
        case 'backward'
            % Calculate internal values using backward differencing
            % swapped L and R
            b(1)    = 1; 
            c(1)    = 0;
            d(1)    = R(n); 
            a(ivec) = -p;
            b(ivec) = 1 + 2*p;
            c(ivec) = -p;
            d(ivec) = u(n,ivec);
            a(nx)   = -2*p;  
            b(nx)   = 1+2*p;
            d(nx)   = u(n,nx);
            
            u(n+1,:) = tdm(a,b,c,d);
            
            methTitle = 'Backward Differencing Method';
            
        case 'crank-nicolson'
            % Calculate internal values using crank-nicolson
            b(1)    = 1; 
            c(1)    = 0;  
            d(1)    = R(n);
            a(ivec) = -p/2; 
            b(ivec) = 1 + p;
            c(ivec) = -p/2;
            d(ivec) = (p/2)*u(n,ivec-1)+(1-p)*u(n,ivec)+(p/2)*u(n,ivec+1);
            a(nx)   = -p;
            b(nx)   = 1+p;
            d(nx)   = p*u(n,nx-1)+(1-p)*u(n,nx);
            
            u(n+1,:) = tdm(a,b,c,d);
            
            methTitle = 'Crank-Nicolson Method';

        otherwise
            error (['Undefined method: ' method])
            return
    end
end
% toc % end time test

if doPlot
    % Create a plot
    figure(2)
    surf(x,t,u)
    shading interp  

    % Rotate the view
    view(140,30)

    % Label the axes and title
    xlabel('\itx\rm (m)')
    ylabel('\itt\rm (s)')
    zlabel(['\itu\rm (' char(176) 'C)'])
    title(methTitle)
end


% Tri-diagonal matrix solution for Backwards & Crank-Nicolson(from notes) 
function x = tdm(a,b,c,d)
n = length(b);

% Eliminate a terms
for i = 2:n
    factor = a(i) / b(i-1);
    b(i) = b(i) - factor * c(i-1);
    d(i) = d(i) - factor * d(i-1);
end

x(n) = d(n) / b(n);

% Loop backwards to find other x values by back-substitution
for i = n-1:-1:1
    x(i) = (d(i) - c(i) * x(i+1)) / b(i);
end
