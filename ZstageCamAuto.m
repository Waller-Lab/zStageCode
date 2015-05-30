%%

% Camera Parameters:
% PixelClock=6;
% FrameRate=3.49;
% ExpTime=276.88;
% 
% zstage Parameters::
% zfocus
% MeasuringMethod

%%
clear all;close all;
global Camh;

%% Initialize Camera
%create Matlab figure container
% refer the handbook of thorlab active x programming
fpos=get(0,'DefaultFigurePosition');
fpos(3)=650;
fpos(4)=450;

f=figure('Position',fpos,'Menu','None','Name','UC480 Camera DCC1545M');

%create ActiveX controller

Camh=actxcontrol('uc480.uc480Ctrl.1',[20 20 600 400],f);

%Initialize Camera

ret=InitCamera(Camh, 0);
if ret~=0 %initializing fails
    break;
    display('Error in initializing camera');
end

data_folder = 'C:\\Users\\Rene\\Desktop\\Control Motion Stage\\measuring images' ;

%set parameters, order of parameters should be PixelClock, FrameRate,
%ExpTime. Important!!!
PixelClock=6;
FrameRate=3.49;
ExpTime=6.675;
display(['Want to set the parameters as:',' PixelClock=',num2str(PixelClock),...
    ';FrameRate=',num2str(FrameRate),'; ExposureTime=',num2str(ExpTime)]);
SetPixelClock(Camh, PixelClock);
SetFrameRate(Camh, FrameRate);
SetExposureTime(Camh, ExpTime);

%check whether the parameters are initialized correctly.
pc1=GetPixelClock(Camh);
fr1=GetFrameRate(Camh);
et=GetExposureTime(Camh);

display(['The parameters are finally set as:',' PixelClock=',num2str(pc1),...
    ';FrameRate=',num2str(fr1),'; ExposureTime=',num2str(et)]);
pause(0.1);
FreezeImage(Camh, 0);%
%test camera
%FreezeImage(Camh, 'IS_WAIT');
SaveImage(Camh,sprintf('C:\\Users\\Rene\\Desktop\\Control Motion Stage\\test.bmp'));
%%

global Movh;
%actxcontrolselect

fpos=get(0,'DefaultFigurePosition');
fpos(3)=650;
fpos(4)=450;
f2=figure('Position',fpos,'Menu','None','Name','Piezo Stage Matlab GUI');

%create ActiveX controller

Movh=actxcontrol('MGPIEZO.MGPiezoCtrl.1',[20 20 600 400],f2);
Movh.StartCtrl;

%Set the Serial Number
SN=41845291;
set(Movh,'HWSerialNum', SN);
% Indentify the device
Movh.Identify;
 
%pause(5); % waiting for the GUI to load up;
%% Controlling the Hardware

%First 0 is the channel ID (channel 1)

SetVoltPosDispMode(Movh,0,2);%DISP_VOLTS=1;DISP_POS=2;

SetControlMode(Movh,0,2);%OPEN_LOOP=1;CLOSED_LOOP=2;OPEN_LOOP_SMOOTH=3;CLOSED_LOOP_SMOOTH=4;

% ZeroPosition(Movh,0);%zero
%

%SetPosOutput(Movh,0,10);
%[chn pos1]=GetPosOutput(Movh,0,0);


% SetJogStepSize(Movh,10);
% [CtrlMode1 CtrlMode2] =GetControlMode(Movh,0,0);
%SetPosOutput(Movh,0,70);
%[Dummy Pa2]=GetPosOutput(Movh,0,0);

% Findfocus=input('Have you found the focus[Y/N]:','s');
% if Findfocus=='Y'|| Findfocus=='y'
% 
%     [dummy1 zfocus]=Movh.GetPosOutput(0,0);
% 
% else
% 
%     ExitCamera(Camh);
%     delete(Camh);
% 
%     Movh.StopCtrl;
%     delete(Movh);
%     break
% end

zfocus=100;%um, set the focus position on the control machine by hand in advance.

%choosing a measuring method
%MeasuringMethod='NonEquallySpaced';
MeasuringMethod='EquallySpaced';

switch MeasuringMethod
    case 'EquallySpaced'
        Nz=131;
        dz=0.5;%um
        z=([1:Nz]-floor(Nz/2)-1)*dz+zfocus;
        %z = (20:1:100) ;
        %z=([1:Nz])*dz;
    case 'NonEquallySpaced'
        % measuring symmetrically over the focus
        % z grows exponentially from the focus to further defocusing
        % distance
        Nz=65;
        Nz_half=floor(Nz/2);
        zmin=0.2;
        zmax=32.5;
        beta=(zmax/zmin)^(1/(Nz_half-1));

        z=[-zmin*beta.^([(Nz_half-1):-1:0]) 0 zmin*beta.^([0:(Nz_half-1)])]+zfocus;%um
    otherwise
        disp(['Error in choosing measuring scheme'])
end


resolution=0.05; %um
z2=zeros(1,Nz);

%warmup
FreezeImage(Camh, 0);%
pause(0.3);
SaveImage(Camh,sprintf('C:\\Users\\Rene\\Desktop\\Control Motion Stage\\test.bmp'));
for k=1:length(z)
    MovToPos_zjs(Movh,z(k),resolution); % mov z stage to position z(k);quite unstable; Can anyone write a more stable version?
    %SetPosOutput(Movh,0,z(k));
    pause(0.1);
    [dummy1 currentPos]=Movh.GetPosOutput(0,0);%get curre
    z2(k)=currentPos;
    
    %CLEAN CAMERA'S MEMEORY. Any better way to do this?
    pause(0.4);
    FreezeImage(Camh, 0);%what is 0? 
    pause(0.4);
    SaveImage(Camh,sprintf('C:\\Users\\Rene\\Desktop\\Control Motion Stage\\test.bmp'));
    for kn=1:1
    pause(0.4);
    FreezeImage(Camh, 0);%what is 0? 
    pause(0.4);
    %SaveImage(Camh,sprintf('C:\\Users\\Rene\\Desktop\\Control Motion Stage\\measuring images\\%d_%d.bmp',k,kn));
    SaveImage(Camh,sprintf('%s\\%.2fum.bmp',data_folder,z(k)));
  
    end
    
end

z2=z2'-zfocus;
z=z'-zfocus;

%%
ExitCamera(Camh);
delete(Camh);

Movh.StopCtrl;
delete(Movh);
close;
close;

save([data_folder 'meas.mat'], 'z', 'PixelClock', 'FrameRate', 'ExpTime') ;