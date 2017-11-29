%% Initial Configurations
clear all;

%% Device Parameters
Cgd = 2e-12;
Cgs = 238e-12;
Cds = 63e-12;

Ls = 2e-10;
Ld = 7e-10;
Lg = 7e-10;
Lss = 1e-9;

Rg = 1.5;
Rd = 25e-6;
Rs = 25e-6;

%% Circuit Parasitics
Ldc = 5e-9;
Lground = 5e-9;

%% Gate Driver
Ron = 20;
Roff = 5;
%% Source parameters
PulseAmplitude = 6;
fsw = 1000e3;
Vdc = 400;
VpulseMax = 6;
VpulseMin = -3;
% Quantities in below are in percent
Dtop = 49; % duty cycle of top
Dbot = 49; % duty cycle of bot
DelayTop = 0;
DelayBot = 50;


%% Load parameters
Rload = 200/15;
Lload = 10e-6;
Cload = 0.22e-6;
%% Run Simulink
SampleTime = 5e-13;
model = 'HalfBridgeCapacitanceModeled';
load_system(model);
StopTime = 3e-6;
set_param(model, 'StopTime','3e-6' )
sim(model);

%% Plots
Vgs = -3:1:6;
Vds = -7:0.1:420;
cur = 4.5057;
K = cur * 0.8 * (273/300)^(-2.7);
x0 = 0.31 ;
x1 = 0.255;
slp = 2;
f1 = figure('Name','Top Switch Turn On','units','normalized','outerposition',[0 0 1 1]);
f2 = figure('Name','Top Switch Turn Off','units','normalized','outerposition',[0 0 1 1]);
f3 = figure('Name','Bottom Switch Turn On','units','normalized','outerposition',[0 0 1 1]);
f4 = figure('Name','Bottom Switch Turn Off','units','normalized','outerposition',[0 0 1 1]);
for GateIndex = 1:10
    for i=1:((427/0.1)+1)
        GS = Vgs(GateIndex);
        DS = Vds(i);
        GD = GS - DS;
        if Vds(i)>0
            I_top(GateIndex,i) = K*log(1+exp(26*(GS-1.7)/slp))*(DS)/(1+max((x0+x1*(GS+4.1)),0.2)*DS);
        else
            I_top(GateIndex,i) = -K*log(1+exp(21*(GD-1.7)/slp))*(-DS)/(1+max((x0+x1*(GD+6.1)),0.2)*(-DS));
        end
    end
end

figure(f1);
hold all
for j=[1,2,3,4,5,6,7,8,9]
    plot((Vds), I_top(j,:),'Linewidth',2.0);
end
xlabel('Vds(V)');
ylabel('Ids(A)');
title({'Ids vs Vds curves for Top Switch during Turn ON(Blue DS, Red CH)'})
legend ('Vgs = -3','Vgs = -2','Vgs = -1','Vgs = 0','Vgs = 1','Vgs = 2','Vgs = 3','Vgs = 4','Vgs = 5');
hold off

figure(f2);
hold all
for j=[1,2,3,4,5,6,7,8,9]
    plot((Vds), I_top(j,:),'Linewidth',2.0);
end
xlabel('Vds(V)');
ylabel('Ids(A)');
title({'Ids vs Vds curves for  Top Switch during Turn OFF(Blue DS, Red CH)'})
legend ('Vgs = -3','Vgs = -2','Vgs = -1','Vgs = 0','Vgs = 1','Vgs = 2','Vgs = 3','Vgs = 4','Vgs = 5');
hold off


Isens = 5;
Vsens = 5;


drawArrow = @(x,y,varargin) quiver( x(1),y(1),x(2)-x(1),y(2)-y(1),0, varargin{:} );
Period = 1/fsw;
% Turn OFF for Top Switch
    ToffSampleMid = 2.5*Period/SampleTime + 1 ;
    MarginOff = round(1*Period/100/SampleTime);
    ToffSampleBegin = ToffSampleMid - MarginOff + 2451 ;
    ToffSampleEnd   = ToffSampleMid + MarginOff ;
    DurationTopOFF = ToffSampleEnd - ToffSampleBegin;
% Turn ON for Top Switch
    TonSampleMid = 2*Period/SampleTime + 1 ;
    MarginOn = round(2*Period/100/SampleTime);
    TonSampleBegin = TonSampleMid ;
    TonSampleEnd   = TonSampleMid + MarginOn - 20000;%0.48*Period/SampleTime;   
    DurationTopON = TonSampleEnd - TonSampleBegin; 
%Top Switch Plot
% Turn OFF Plot
InitI = TopCurrentDS(ToffSampleBegin);
InitV = TopVoltageDS(ToffSampleBegin);
EnergyTopOFF = 0;
TopOFFVI = zeros(1,2);
figure(f2)
hold all
for j=ToffSampleBegin:ToffSampleEnd
    if abs(TopVoltageDS(j)-InitV) >= Vsens || abs(TopCurrentDS(j)-InitI) >= Isens
        X = [InitV TopVoltageDS(j)];
        Y = [InitI TopCurrentDS(j)];
        drawArrow(X,Y,'MaxHeadSize',150,'Color','b','LineWidth',2);
        InitV = TopVoltageDS(j);
        InitI = TopCurrentDS(j);
    end
    EnergyTopOFF = abs(TopVoltageDS(j) * TopCurrentDS(j)) * SampleTime + EnergyTopOFF;
    TopOFFVI(j+1-ToffSampleBegin,:) = [TopVoltageDS(j),TopCurrentDS(j)];
    EnergyTOFinst(j+1-ToffSampleBegin) = EnergyTopOFF;
end 
PowerTopOFF = EnergyTopOFF / Period;
    plot(TopVoltageDS(ToffSampleBegin),TopCurrentDS(ToffSampleBegin),'*','Linewidth',10.0);
    plot(TopVoltageDS(ToffSampleEnd),TopCurrentDS(ToffSampleEnd),'*','Linewidth',10.0);
hold off

InitI = TopChCurr(ToffSampleBegin);
InitV = TopVoltageDS(ToffSampleBegin);
figure(f2)
hold all
for j=ToffSampleBegin:ToffSampleEnd
    if abs(TopVoltageDS(j)-InitV) >= Vsens || abs(TopChCurr(j)-InitI) >= Isens
        X = [InitV TopVoltageDS(j)];
        Y = [InitI TopChCurr(j)];
        drawArrow(X,Y,'MaxHeadSize',150,'Color','r','LineWidth',2);
        InitV = TopVoltageDS(j);
        InitI = TopChCurr(j);
    end
end 
    plot(TopVoltageDS(ToffSampleBegin),TopChCurr(ToffSampleBegin),'*','Linewidth',10.0);
    plot(TopVoltageDS(ToffSampleEnd),TopChCurr(ToffSampleEnd),'*','Linewidth',10.0);
hold off
% Turn ON Plot

InitI = TopCurrentDS(TonSampleBegin);
InitV = TopVoltageDS(TonSampleBegin);
EnergyTopON = 0;
TopONVI = zeros(1,2);
figure(f1)
hold all
for j=TonSampleBegin:TonSampleEnd
    if abs(TopVoltageDS(j)-InitV) >= Vsens || abs(TopCurrentDS(j)-InitI) >= Isens
        X = [InitV TopVoltageDS(j)];
        Y = [InitI TopCurrentDS(j)];
        drawArrow(X,Y,'MaxHeadSize',150,'Color','b','LineWidth',2);
        InitV = TopVoltageDS(j);
        InitI = TopCurrentDS(j);
    end
    EnergyTopON = abs(TopVoltageDS(j) * TopCurrentDS(j)) * SampleTime + EnergyTopON;
    TopONVI(j+1-TonSampleBegin,:) = [TopVoltageDS(j),TopCurrentDS(j)];
    EnergyTONinst(j+1-TonSampleBegin) = EnergyTopON;
end 
PowerTopON = EnergyTopON / Period;
    plot(TopVoltageDS(TonSampleBegin),TopCurrentDS(TonSampleBegin),'*','Linewidth',10.0);
    plot(TopVoltageDS(TonSampleEnd),TopCurrentDS(TonSampleEnd),'*','Linewidth',10.0);
hold off;

InitI = TopChCurr(TonSampleBegin);
InitV = TopVoltageDS(TonSampleBegin);
figure(f1)
hold all
for j=TonSampleBegin:TonSampleEnd
    if abs(TopVoltageDS(j)-InitV) >= Vsens || abs(TopChCurr(j)-InitI) >= Isens
        X = [InitV TopVoltageDS(j)];
        Y = [InitI TopChCurr(j)];
        drawArrow(X,Y,'MaxHeadSize',150,'Color','r','LineWidth',2);
        InitV = TopVoltageDS(j);
        InitI = TopChCurr(j);
    end
end 
    plot(TopVoltageDS(TonSampleBegin),TopChCurr(TonSampleBegin),'*','Linewidth',10.0);
    plot(TopVoltageDS(TonSampleEnd),TopChCurr(TonSampleEnd),'*','Linewidth',10.0);
hold off;




%Bot Switch Plot
% Turn OFF for Bottom Switch
    ToffSampleMid = 2*Period/SampleTime + 1 ;
    MarginOff = round(Period/100/SampleTime);
    ToffSampleBegin = ToffSampleMid - MarginOff + 3732;
    ToffSampleEnd   = ToffSampleMid + MarginOff;
    DurationBotOFF = ToffSampleEnd - ToffSampleBegin;
% Turn ON for Bottom Switch
    TonSampleMid = 2.5*Period/SampleTime + 1 ;
    MarginOn = round(2.5*Period/100/SampleTime);
    TonSampleBegin = TonSampleMid - MarginOn;
    TonSampleEnd   = TonSampleMid + MarginOn - 37379;%0.48*Period/SampleTime;  
    DurationBotON = TonSampleEnd - TonSampleBegin;
Vds = -10:0.1:410;
for GateIndex = 1:10
    for i=1:((420/0.1)+1)
        GS = Vgs(GateIndex);
        DS = Vds(i);
        GD = GS - DS;
        if Vds(i)>0
            I_bottom(GateIndex,i) = K*log(1+exp(26*(GS-1.7)/slp))*(DS)/(1+max((x0+x1*(GS+4.1)),0.2)*DS);
        else
            I_bottom(GateIndex,i) = -K*log(1+exp(21*(GD-1.7)/slp))*(-DS)/(1+max((x0+x1*(GD+6.1)),0.2)*(-DS));
        end
    end
end


figure(f3);
hold all
for j=[1,2,3,4,5,6,7,8,9]
    plot((Vds), I_bottom(j,:),'Linewidth',2.0);
end
xlabel('Vds(V)');
ylabel('Ids(A)');
title({'Ids vs Vds curves for Bottom Switch during Turn ON(Blue DS, Red CH)'})
legend ('Vgs = -3','Vgs = -2','Vgs = -1','Vgs = 0','Vgs = 1','Vgs = 2','Vgs = 3','Vgs = 4','Vgs = 5');
hold off

figure(f4);
hold all
for j=[1,2,3,4,5,6,7,8,9]
    plot((Vds), I_bottom(j,:),'Linewidth',2.0);
end
xlabel('Vds(V)');
ylabel('Ids(A)');
title({'Ids vs Vds curves for Bottom Switch during Turn OFF(Blue DS, Red CH)'})
legend ('Vgs = -3','Vgs = -2','Vgs = -1','Vgs = 0','Vgs = 1','Vgs = 2','Vgs = 3','Vgs = 4','Vgs = 5');
hold off

% Turn ON Plot
InitI = BotCurrentDS(TonSampleBegin);
InitV = BotVoltageDS(TonSampleBegin);
EnergyBotON = 0;
BotONVI = zeros(1,2);
figure(f3)
hold all
for j=TonSampleBegin:TonSampleEnd
    if abs(BotVoltageDS(j)-InitV) >= Vsens || abs(BotCurrentDS(j)-InitI) >= Isens
        X = [InitV BotVoltageDS(j)];
        Y = [InitI BotCurrentDS(j)];
        drawArrow(X,Y,'MaxHeadSize',20,'Color','b','LineWidth',2);
        InitV = BotVoltageDS(j);
        InitI = BotCurrentDS(j);
    end
    EnergyBotON = abs(BotVoltageDS(j) * BotCurrentDS(j)) * SampleTime + EnergyBotON;
    BotONVI(j+1-TonSampleBegin,:) = [BotVoltageDS(j),BotCurrentDS(j)];
    EnergyBONinst(j+1-TonSampleBegin) = EnergyBotON;
end      
PowerBotON = EnergyBotON / Period;
plot(BotVoltageDS(TonSampleBegin),BotCurrentDS(TonSampleBegin),'*','Linewidth',10.0);
plot(BotVoltageDS(TonSampleEnd),BotCurrentDS(TonSampleEnd),'*','Linewidth',10.0);
hold off

InitI = BotChCurr(TonSampleBegin);
InitV = BotVoltageDS(TonSampleBegin);
figure(f3)
hold all
for j=TonSampleBegin:TonSampleEnd
    if abs(BotVoltageDS(j)-InitV) >= Vsens || abs(BotChCurr(j)-InitI) >= Isens
        X = [InitV BotVoltageDS(j)];
        Y = [InitI BotChCurr(j)];
        drawArrow(X,Y,'MaxHeadSize',20,'Color','r','LineWidth',2);
        InitV = BotVoltageDS(j);
        InitI = BotChCurr(j);
    end
end 
    plot(BotVoltageDS(TonSampleBegin),BotChCurr(TonSampleBegin),'*','Linewidth',10.0);
    plot(BotVoltageDS(TonSampleEnd),BotChCurr(TonSampleEnd),'*','Linewidth',10.0);
hold off
% Turn OFF Plot
InitI = BotCurrentDS(ToffSampleBegin);
InitV = BotVoltageDS(ToffSampleBegin);
EnergyBotOFF = 0;
BotOFFVI = zeros(1,2);
figure(f4)
hold all
for j=ToffSampleBegin:ToffSampleEnd
    if abs(BotVoltageDS(j)-InitV) >= Vsens || abs(BotCurrentDS(j)-InitI) >= Isens
        X = [InitV BotVoltageDS(j)];
        Y = [InitI BotCurrentDS(j)];
        drawArrow(X,Y,'MaxHeadSize',20,'Color','b','LineWidth',2);
        InitV = BotVoltageDS(j);
        InitI = BotCurrentDS(j);
    end
    EnergyBotOFF = abs(BotVoltageDS(j) * BotCurrentDS(j)) * SampleTime + EnergyBotOFF;
    BotOFFVI(j+1-ToffSampleBegin,:) = [BotVoltageDS(j),BotCurrentDS(j)];
    EnergyBOFinst(j+1-ToffSampleBegin) = EnergyBotOFF;
end
PowerBotOFF = EnergyBotOFF / Period;
plot(BotVoltageDS(ToffSampleBegin),BotCurrentDS(ToffSampleBegin),'*','Linewidth',10.0);
plot(BotVoltageDS(ToffSampleEnd),BotCurrentDS(ToffSampleEnd),'*','Linewidth',10.0);
hold off

InitI = BotChCurr(ToffSampleBegin);
InitV = BotVoltageDS(ToffSampleBegin);
figure(f4)
hold all
for j=ToffSampleBegin:ToffSampleEnd
    if abs(BotVoltageDS(j)-InitV) >= Vsens || abs(BotChCurr(j)-InitI) >= Isens
        X = [InitV BotVoltageDS(j)];
        Y = [InitI BotChCurr(j)];
        drawArrow(X,Y,'MaxHeadSize',20,'Color','r','LineWidth',2);
        InitV = BotVoltageDS(j);
        InitI = BotChCurr(j);
    end
end
plot(BotVoltageDS(ToffSampleBegin),BotChCurr(ToffSampleBegin),'*','Linewidth',10.0);
plot(BotVoltageDS(ToffSampleEnd),BotChCurr(ToffSampleEnd),'*','Linewidth',10.0);
hold off

%%
%Print to Screen
fprintf('//////////////////////////////////////////////////////////////////////////////////////// \n');
fprintf('---------------------------------------------------------------------------------------- \n');
fprintf('Results of STANDART Calculation \n');
fprintf('Energy Top ON: %f \n', EnergyTopON);
fprintf('Power Top ON: %f \n', PowerTopON);
fprintf('Energy Top OFF: %f \n', EnergyTopOFF);
fprintf('Power Top OFF: %f \n', PowerTopOFF);
fprintf('Energy Bot ON: %f \n', EnergyBotON);
fprintf('Power Bot ON: %f \n', PowerBotON);
fprintf('Energy Bot OFF: %f \n', EnergyBotOFF);
fprintf('Power Bot OFF: %f \n', PowerBotOFF);
fprintf('\n');
fprintf('---------------------------------------------------------------------------------------- \n');
fprintf('Area Calculations\n');
%---------------------
X = BotONVI(:,1);
Y = BotONVI(:,2);
Size = size(X);
Xsize = Size(1);
integ1 = 0;
InstPower = 0;
figure('units','normalized','outerposition',[0 0 1 1]);
for i = 1:Xsize - 1
    deltaX = (X(Xsize) - X(1))/Xsize;
    deltaY = Y(i);
    integ1(i+1) = integ1(i) + abs(deltaX*deltaY);
    InstPower(i) = abs(deltaX*deltaY);
end
subplot(2,2,3);
plot((1:Xsize)*SampleTime,integ1,(1:Xsize)*SampleTime,X,(1:Xsize)*SampleTime,Y,(1:Xsize)*SampleTime,10*EnergyBONinst*fsw,'Linewidth',2.0);
title('Bot ON switching energy and instantenous power');
legend('Inst. Power AREA calc.','Voltage','Current','Power Cons. up to now IV calc.(x10) ');
AreaBotON = integ1(Xsize-1);
fprintf('Bottom ON Area: %f \n', AreaBotON );
%---------------------
X1 = BotOFFVI(:,1);
Y1 = BotOFFVI(:,2);
Size = size(X1);
Xsize1 = Size(1);
integ2 = 0;
InstPower = 0;
for i = 1:Xsize1 - 1
    deltaX1 = (X1(Xsize1) - X1(1))/Xsize1;
    deltaY1 = Y1(i);
    integ2(i+1) = integ2(i) + abs(deltaX1*deltaY1);
    InstPower(i) = abs(deltaX1*deltaY1);
end
subplot(2,2,4);
plot((1:Xsize1)*SampleTime,integ2,(1:Xsize1)*SampleTime,X1,(1:Xsize1)*SampleTime,Y1,(1:Xsize1)*SampleTime,10*EnergyBOFinst*fsw,'Linewidth',2.0);
title('Bot OFF switching energy and instantenous power');
legend('Inst. Power AREA calc.','Voltage','Current','Power Cons. up to now IV calc.(x10) ');
AreaBotOFF = integ2(Xsize1);
fprintf('Bottom OFF Area: %f \n', AreaBotOFF);
%---------------------
X2 = TopONVI(:,1);
Y2 = TopONVI(:,2);
Size = size(X2);
Xsize2 = Size(1);
integ3 = 0;
InstPower = 0;
for i = 1:Xsize2 - 1
    deltaX2 = (X2(Xsize2) - X2(1))/Xsize2;
    deltaY2 = Y2(i);
    integ3(i+1) = integ3(i) + abs(deltaX2*deltaY2);
    InstPower(i) = abs(deltaX2*deltaY2);
end
subplot(2,2,1);
plot((1:Xsize2)*SampleTime,integ3/100,(1:Xsize2)*SampleTime,X2,(1:Xsize2)*SampleTime,Y2,(1:Xsize2)*SampleTime,10*EnergyTONinst*fsw,'Linewidth',2.0);
title('Top ON switching energy and instantenous power');
legend('Inst. Power AREA calc.(/100)','Voltage','Current','Power Cons. up to now IV calc.(x10) ');
AreaTopON = integ3(Xsize2);
fprintf('Top ON Area: %f \n', AreaTopON);
%---------------------
X3 = TopOFFVI(:,1);
Y3 = TopOFFVI(:,2);
Size = size(X3);
Xsize3 = Size(1);
integ4 = 0;
InstPower = 0;
for i = 1:Xsize3 - 1
    deltaX3 = (X3(Xsize3) - X3(1))/Xsize3;
    deltaY3 = Y3(i);
    integ4(i+1) = integ4(i) + abs(deltaX3*deltaY3);
    InstPower(i) = abs(deltaX3*deltaY3);
end
subplot(2,2,2);
plot((1:Xsize3)*SampleTime,integ4,(1:Xsize3)*SampleTime,X3,(1:Xsize3)*SampleTime,Y3,(1:Xsize3)*SampleTime,10*EnergyTOFinst*fsw,'Linewidth',2.0);
title('Top OFF switching energy and instantenous power');
legend('Inst. Power AREA calc.','Voltage','Current','Power Cons. up to now IV calc.(x10) ');
AreaTopOFF = integ4(Xsize3);
fprintf('Top OFF Area: %f \n', AreaTopOFF);
%---------------------
fprintf('\n');
fprintf('---------------------------------------------------------------------------------------- \n');
fprintf('Results with AREA Calculation \n');
fprintf('Energy Top ON: %f \n', DurationTopON * SampleTime * AreaTopON);
fprintf('Power Top ON: %f \n', DurationTopON * SampleTime * AreaTopON / Period);
fprintf('Energy Top ON: %f \n', DurationTopOFF * SampleTime * AreaTopOFF);
fprintf('Power Top OFF: %f \n', DurationTopOFF * SampleTime * AreaTopOFF / Period);
fprintf('Energy Bot ON: %f \n', DurationBotON * SampleTime * AreaBotON);
fprintf('Power Bot ON: %f \n', DurationBotON * SampleTime * AreaBotON / Period);
fprintf('Energy Bot OFF: %f \n', DurationBotOFF * SampleTime * AreaBotOFF);
fprintf('Power Bot OFF: %f \n', DurationBotOFF * SampleTime * AreaBotOFF / Period);


