
setupStage = 1;
%% Set up Z-Stage
if (setupStage)
clear all; close all; clc;
global h; % make h a global variable so it can be used outside the main
          % function. Useful when you do event handling and sequential           
          
% Create Matlab Figure Container
fpos    = get(0,'DefaultFigurePosition'); % figure default position
fpos(3) = 650; % figure window size;Width
fpos(4) = 450; % Height
 
f = figure('Position', fpos,...
           'Menu','None',...
           'Name','APT GUI');

% Create ActiveX Controller
h = actxcontrol('MGPIEZO.MGPiezoCtrl.1',[20 20 600 400 ], f);
 
% Start Control
h.StartCtrl;
 
% Set the Serial Number
SN = 41845291; % put in the serial number of the hardware
set(h,'HWSerialNum', SN);
 
% Indentify the device
h.Identify;

% MovToPos_zjs(h,0,0.1);
% ZeroPosition(Movh,0);%zero
% [dummy1 currentPos]=Movh.GetPosOutput(0,0);%get current position
ZeroPosition(h,0);%zero
SetVoltPosDispMode(h,0,2);%DISP_VOLTS=1;DISP_POS=2;
SetControlMode(h,0,2);%OPEN_LOOP=1;CLOSED_LOOP=2;OPEN_LOOP_SMOOTH=3;CLOSED_LOOP_SMOOTH=4;
pause(30);
end
%% Set up camera and dome arduino
% Parameters
domeArduinoPort = 'COM4';
cameraArduinoPort = 'COM10';

% close all serial connections
delete(instrfindall);

% Open new connections to arduinos
domeArduino = serial(domeArduinoPort,'BaudRate',9600,'DataBits',7);
fopen(domeArduino);

cameraArduino = serial(cameraArduinoPort,'BaudRate',9600,'DataBits',7);
fopen(cameraArduino);

domeArduino.FlowControl = 'software';
cameraArduino.FlowControl = 'software';

%%

% LEDs to capture
%ledList = 249:250;
% ledList = [59,60,61,62,63,64,72,76,77,78,79,80,81,82,83,84,90,91,94,95,96,97,98,99,100,101,102,103,104,110,111,113,114,121,122,123,124,131,132,134,144,145,146,152,153,156,167,168,174,175,178,179,180,190,191,195,196,198,199,200,201,202,203,212,213,217,218,219,221,222,225,226,232,236,241,242,245,250,256,259,264,265,266,268,269,270,271,274,281,282,287,288,290,291,293,294,295,296,309,310,311,313,319,332,333,337,353,354,358,359,360,361,362,363,364,374,375,377,378,379,380,381,382,383,384,385,386,394,395,396,397,402,405,406,407,413,414,415,422,426,427,432,441,442,445,446,460,461,462];
ledList=1:150;
% ledList=151:300;
% ledList=301:450;
% ledList=451:508;

% steps to acquire for each LED
stepList=0.1:10:140.1;

cameraExposureTime = 1.0; % seconds


%% Run Data Collection

% Loops through LEDs
frameNum=0;
for stepIdx = 1:size(stepList,2)
    stepPos = stepList(stepIdx);
    MovToPos_zjs(h, stepPos, 0.05);
    pause(0.1);
    disp(['Moved to z position: ' num2str(stepPos)]);
    for ledIdx = 1:size(ledList,2)
        led = ledList(ledIdx);
%         fprintf(domeArduino,'dh%s',num2str(led));
        a=sprintf(['dh' num2str(led)]);
        try
            fprintf(domeArduino,a,'async');
        catch err
            warning('Something went wrong...');
            err.message
        end
        pause(0.03);
        disp(['Turned on LED #: ' num2str(led)]);
        fprintf(cameraArduino,'f');
        pause(0.03);
        pause(cameraExposureTime + 0.2);
        disp('Acquired!');
        frameNum = frameNum + 1
    end
%         SetOutputLUTTrigParams(h,0, 1, 1, 0, 2, 1, 1, 0, 0);

end

%% Clean up

% if (setupStage)
%     h.StopCtrl;
%     delete(h);
%     close;
% end
% 
% fclose(cameraArduino);
% fclose(domeArduino);
