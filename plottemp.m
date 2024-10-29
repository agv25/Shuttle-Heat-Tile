% Script to scan image finding temperature and time data
%
% Image from http://www.columbiassacrifice.com/techdocs/techreprts/AIAA_2001-0352.pdf
% Now available at 
% http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.26.1075&rep=rep1&type=pdf
%
% D N Johnston 05/02/21
% Modified by Alex Varney

name = '597';
img=imread([name '.jpg']);

figure(1);
image(img);
hold on

% Locate red pixels in image
[j,i] = find(img(:,:,1)>150 & img(:,:,2)<100 & img(:,:,3)<100); 

% Solving multiple pixel problem
[iu, iindex] = unique(i, 'first');   % finds first pixel
ju = j(iindex);
[iu, iindex] = unique(i, 'last');    % finds last pixel
jul = j(iindex);

% Calculate mean value of first and last pixel plots
juAvg = (ju+jul)/2;

% Initialise time and temp vectors
timeData = [];
tempData = [];

while 1 % infinite loop
    [x, y, button] = ginput(1); % get one point using mouse
    if button ~= 1 % break if anything except the left mouse button is pressed
        break
    end
    plot(x, y, 'og') % 'og' means plot a green circle.
    
    % Note that x and y are pixel coordinates.
    % Locate the pixel coordinates of the axes, interactively as follows:
    % First point is top of y-axis, second point is end of x-axis.
    timeData = [timeData, x];
    tempData = [tempData, y];
end
hold off

% Scale pixel and data readings, also corrects inverted y-axis
realTime = (iu - timeData(1)) .* (2000) ./ (timeData(2) - timeData(1));
realTemp = (juAvg - tempData(2)) .* (2000) ./ (tempData(1) - tempData(2));

% Convert Fahrenheit to Celsius
realTempC = (realTemp - 32)*(5/9);

% Add temperature values for t=0 and t=4000 (required for plot)
trueTempC = [realTempC(1); realTempC; realTempC(end)];
trueTime = [0; realTime; 4000];

% Save data to .mat file with same name as image file
save(name, 'trueTime', 'trueTempC');

