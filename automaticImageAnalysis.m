% Script to automatically analyse multiple shuttle temp images
% works for images provided
% created by Alex Varney

% Choosing which image to scan
% Asking user to input a known image number
prompts = {'Enter temp image number, e.g. 597'};
input = inputdlg(prompts);

% Switching image name for each possible case, returns error for unkown
% image number
switch input{1}
    case '850'
        image_name = '850';
        
    case '730'
        image_name = '730';
        
    case '711'
        image_name = '711';
        
    case '597'
        image_name = '597';
        
    case '590'
        image_name = '590';
        
    case '502'
        image_name = '502';
        
    case '480'
        image_name = '480';

    case '468'
        image_name = '468';
       
    otherwise
            error (['Unkown image: ' input]);
            return
end  

% Read image
img = imread([image_name '.jpg']);


% Locating the axes on the graph
% Locating black pixels
[y,x] = find(img(:,:,1)==0  & img(:,:,2)==0 & img(:,:,3)==0);

% Finding x axis row and y axis collumn - mode for most common pixel number
xaxis = mode(y);
yaxis = mode(x);

% Find all black pixels on y axis collumn
[ay,ax] = find(img(:,yaxis,1)==0  & img(:,yaxis,2)==0 & img(:,yaxis,3)==0);

% Find all black pixels on x axis row
[by,bx] = find(img(xaxis,:,1)==0  & img(xaxis,:,2)==0 & img(xaxis,:,3)==0);

ytop = min(ay);  % top of y axis, y co-ordinate
xend = max(bx);  % end of x axis, x co-ordinate

timeData = [yaxis, xend];  % time axis co-ordinates ([originx, xend])
tempData = [ytop, xaxis];  % temp axis co-ordinates ([ytop, originy])


% Locate pixels for temp and time data
% Locating red pixels
[j,i] = find(img(:,:,1)>150 & img(:,:,2)<100 & img(:,:,3)<100);

% Solving multiple pixel problem
[iu, iindex] = unique(i, 'first');   % finds first pixel
ju = j(iindex);
[iu, iindex] = unique(i, 'last');    % finds last pixel
jul = j(iindex);

% Calculate mean value of first and last pixels
juAvg = (ju+jul)/2;


% Scale data readings, also corrects inverted y-axis
realTime = (iu - timeData(1)) .* (2000) ./ (timeData(2) - timeData(1));
realTemp = (juAvg - tempData(2)) .* (2000) ./ (tempData(1) - tempData(2));

% Convert Fahrenheit to Celsius
realTempC = (realTemp - 32)*(5/9);

% Add temperature values for t=0 and t=4000 (required for plot)
trueTempC = [realTempC(1); realTempC; realTempC(end)];
trueTime = [0; realTime; 4000];

% Save data to .mat file with same name as image file
save(image_name, 'trueTime', 'trueTempC');

