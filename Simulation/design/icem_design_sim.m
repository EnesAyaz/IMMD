% Design ans Simulation with IGBT

Ts = 1e-6; % sec
Tfinal = 0.1; % sec
Ripth = 0.08; % sec
fsw = 20e3; % Hz
Vdc = 540; % Volts
Pout = 8e3/0.94; % W
Ef = 155; % Volts
Ls = 13.8e-3; % Henries
Rs = 1e-3; % Ohms
fout = 50; % Hz
wout = 2*pi*fout; % rad/sec
m = 3;
np = 1;
ns = 1;
n = ns*np;
Poutm = Pout/n; % Watts
Is = Poutm/(Ef*m); % amps
Xs = wout*Ls; % Ohms
Vdrop = Is*Xs; % Volts
Vt = sqrt(Ef^2+Vdrop^2); % Volts
Vdcm = Vdc/ns; % volts
ma = Vt*sqrt(3)/(Vdcm*0.612);
delta = acos(Ef/Vt); % radians
deltad = delta*180/pi; % degrees
pf = cos(delta);
phase = [0 90 0 90];
Rin = 10;
%Lin = 1e-3;
Vin = Vdc + Rin*(Pout/Vdc);
Cdc = 100e-6;


Idcrms1 = Is*sqrt( 2*ma*(sqrt(3)/(4*pi) +...
    pf^2*(sqrt(3)/pi-9*ma/16)) ); % Amps

Vdcrip = 1;
Cdcreq1 = ns*(ma*Is/(16*fsw*Vdcrip))*...
    sqrt( (6 - (96*sqrt(3)*ma)/(5*pi) +...
    (9*ma^2/2) )*pf^2 + (8*sqrt(3)*ma)/(5*pi) ); % Farads


%%
% Design ans Simulation with GaN

Ts = 1e-7; % sec
Tfinal = 0.06; % sec
Ripth = 0.05; % sec
fsw = 50e3; % Hz
Vdc = 540; % Volts
Pout = 8e3/0.94; % W
m = 3;
np = 2;
ns = 2;
n = ns*np;
Ef = 155/ns; % Volts
Ls = 13.8e-3/n; % Henries
Rs = 1e-3/n; % Ohms
fout = 50; % Hz
wout = 2*pi*fout; % rad/sec
Poutm = Pout/n; % Watts
Is = Poutm/(Ef*m); % amps
Xs = wout*Ls; % Ohms
Vdrop = Is*Xs; % Volts
Vt = sqrt(Ef^2+Vdrop^2); % Volts
Vdcm = Vdc/ns; % volts
ma = Vt*sqrt(3)/(Vdcm*0.612);
delta = acos(Ef/Vt); % radians
deltad = delta*180/pi; % degrees
pf = cos(delta);
phase = [0 90 0 90];
Rin = 10;
%Lin = 1e-3;
Vin = Vdc + Rin*(Pout/Vdc);
Cdc = 25e-6;

Idcrms1 = np*Is*sqrt( 2*ma*(sqrt(3)/(4*pi) +...
    pf^2*(sqrt(3)/pi-9*ma/16)) ); % Amps

Vdcrip = 1;
intv = 0.48;
Cdcreq1 = intv*np*ns*(ma*Is/(16*fsw*Vdcrip))*...
    sqrt( (6 - (96*sqrt(3)*ma)/(5*pi) +...
    (9*ma^2/2) )*pf^2 + (8*sqrt(3)*ma)/(5*pi) ); % Farads


%Cdc = Cdcreq1;
%Cdc = round(Cdc*1e5)/1e5;


%%
% Selected GaNs
% Transphorm: TPH3205WSB, 35A, 650V, 60 mOhm, Cascode
% GaN Systems: GS66508B, 30A, 650V, 50 mOhm, E-mode

%%
% 1st device
% TPH3205WSB
% Loss analysis
clear Psc;
clear Pdc;
clear Pds;
clear Pss;

fsw = 0;
while(fsw<100e3)
    fsw = fsw+10e3
    %fsw = 100e3; % Hz
    Icp = Iphase*sqrt(2);
    Iep = Iphase*sqrt(2);
    
    Vceo = 0; % V
    Ro = 93.8*1e-3; % Ohms
    Vdo = 0.6; % V
    Rd = (8-5.4)/(88-60); % Ohms
    Vnom = 400; % V
    Inom = 22; % A
    Eon = 1/6*(Inom*Vnom*(36+7.6)*1e-9); % J
    Eoff = 1/6*(Inom*Vnom*(40+8.6)*1e-9); % J
    Err = 1/6*(Inom*Vnom*(40)*1e-9); % J
    
    % Loss calculation
    Psc = Vceo*Icp/(2*pi) + Ro*Icp^2/8 + ma*pf*Vceo*Icp/8 + ma*pf*Ro*Icp^2/(3*pi); % W
    Pdc = Vdo*Iep/(2*pi) + Rd*Iep^2/8 - ma*pf*Vdo*Iep/8 - ma*pf*Rd*Iep^2/(3*pi); % W
    Pss = (Eon+Eoff)*fsw*Vdcm*Icp/(pi*Vnom*Inom); % W
    Pds = Err*fsw*Vdcm*Icp/(pi*Vnom*Inom) % W
    
    Ploss1 = Psc+Pdc+Pss+Pds; % W
    Ploss = Ploss1*6; % W
    efficiency = 100*Pdrout/(Ploss+Pdrout); % percent

end


% 
% fsw = 10e3:1e3:100e3; % Hz
% for k = 1:numel(fsw)
%     % Datasheet values
%     %Rds_onB = 49e-3; % Ohms, @25C, @17A, @8V Vgs
%     %Tj = 125; % C
%     %Rds_on = Rds_onB*(Tj/125+0.8); % Ohms
%     % It is assumed that, Rds_on is not affected by current amplitude up to 80A
%     % This assumption is based on datasheet graph (Ids vs Vds)
%     Rds_on = 93.8*1e-3; % Ohms
%     VsdB = 0.5; % V
%     Iep = Iphase*sqrt(2);
%     Vsd = Iep*0.09163+VsdB; % V
%     % The following time values should be normalized
%     tdon = 36e-9; % s,VDS=400V, ID = 18A, 25C
%     tdoff = 40e-9; % s,VDS=400V, ID = 18A, 25C
%     tr = 7.6e-9; % s,VDS=400V, ID = 18A, 25C
%     tf = 8.6e-9; % s,VDS=400V, ID = 18A, 25C
%     trr = 40e-9; % s,VDS=400V, ID = 18A, 1000A/ms, 25C
%     ton = tdon+tr; % s
%     toff = tdoff+tf; % s
%     Icp = Iep;
%     Eon = Vdcm*Icp*ton/6; % J
%     Eoff = Vdcm*Icp*toff/6; % J
%     % Irr value was not present in the datasheet. Peak value is taken
%     Irr = Iep; % A
%     Vce_p = Vdcm; % V
%     Eon = Eon*7
%     
%     % Loss calculation
%     Psc(k) = Rds_on*Icp^2*(1/8+ma*pf/(3*pi)); % W
%     Pdc(k) = Iep*Vsd*(1/8-ma*pf/(3*pi)); % W
%     Pss(k) = (Eon+Eoff)*fsw(k)*(1/pi); % W
%     Pds(k) = (1/8)*Irr*trr*Vce_p*fsw(k); % W
%     
%     % Total loss
%     Ploss1 = Psc(k)+Pdc(k)+Pss(k)+Pds(k); % W
%     Ploss = Ploss1*6; % W
%     efficiency2(k) = 100*Pdrout./(Ploss+Pdrout); % percent
%     %fprintf('Efficiency value with GaN with %gkHz is %g %%\n',fsw(k),efficiency2(k));
% end


%%
% 2nd device
% GS66508B
% Loss analysis
clear Psc;
clear Pdc;
clear Pds;
clear Pss;

fsw = 0;
while(fsw<100e3)
    fsw = fsw+10e3
    %fsw = 100e3; % Hz
    Icp = Iphase*sqrt(2);
    Iep = Iphase*sqrt(2);
    
    Vceo = 0; % V
    Ro = 113.2*1e-3; % Ohms
    Vdo = 0; % V
    Rd = (1)/(20); % Ohms
    Vnom = 400; % V
    Inom = 15; % A
    Eon = 47.5e-6; % J
    Eoff = 7.5e-6; % J
    Err = 7e-6; % J
    
    % Loss calculation
    Psc = Vceo*Icp/(2*pi) + Ro*Icp^2/8 + ma*pf*Vceo*Icp/8 + ma*pf*Ro*Icp^2/(3*pi); % W
    Pdc = Vdo*Iep/(2*pi) + Rd*Iep^2/8 - ma*pf*Vdo*Iep/8 - ma*pf*Rd*Iep^2/(3*pi); % W
    Pss = (Eon+Eoff)*fsw*Vdcm*Icp/(pi*Vnom*Inom); % W
    Pds = Err*fsw*Vdc*Icp/(pi*Vnom*Inom); % W
    
    Ploss1 = Psc+Pdc+Pss+Pds; % W
    Ploss = Ploss1*6; % W
    efficiency = 100*Pdrout/(Ploss+Pdrout); % percent

end




% Datasheet values
%Rds_onB = 49e-3; % Ohms, @25C, @17A, @8V Vgs
%Tj = 125; % C
%Rds_on = Rds_onB*(Tj/125+0.8); % Ohms
% It is assumed that, Rds_on is not affected by current amplitude up to 80A
% This assumption is based on datasheet graph (Ids vs Vds)
%Rds_on = 113.2*1e-3; % Ohms
%VsdB = 0.5; % V
%Iep = Iphase*sqrt(2);
%Vsd = Iep*0.09163+VsdB; % V
%Vsd = 0.836; % V
% The following time values should be normalized
% tdon = 4.3e-9; % s,VDS=400V, ID = 18A, 25C
% tdoff = 8.2e-9; % s,VDS=400V, ID = 18A, 25C
% tr = 4.9e-9; % s,VDS=400V, ID = 18A, 25C
% tf = 3.4e-9; % s,VDS=400V, ID = 18A, 25C
% trr = 40e-9; % s,VDS=400V, ID = 18A, 1000A/ms, 25C
% ton = tdon+tr; % s
% toff = tdoff+tf; % s
% Icp = Iep;
% Eon = Vdcm*Icp*ton/6; % J
% Eoff = Vdcm*Icp*toff/6; % J
% Irr value was not present in the datasheet. Peak value is taken
% Irr = Iep; % A
% Vce_p = Vdcm; % V
% trr = 0;
% Eon = 47.5e-6
%

% Loss calculation
% Psc = Rds_on*Icp^2*(1/8+ma*pf/(3*pi)); % W
% Pdc = Iep*Vsd*(1/8-ma*pf/(3*pi)); % W
% Pss = (Eon+Eoff)*fsw*(1/pi); % W
% Pds = (1/8)*Irr*trr*Vce_p*fsw; % W
% 
% % Total loss
% Ploss1 = Psc+Pdc+Pss+Pds; % W
% Ploss = Ploss1*6; % W
% efficiency = 100*Pdrout/(Ploss+Pdrout); % percent


%%
% 3rd device
% FP35R12KT4P
% Loss analysis
clear Psc;
clear Pdc;
clear Pds;
clear Pss;

Vdc = 540;
scale = sqrt(3)/(2*sqrt(2));
ma = 0.8;
Vllrms = ma*scale*Vdc;
Pdrout = Pout/effmotor;
pf = 0.9;
Sdrout = Pdrout/pf;
Iphase = Sdrout/(sqrt(3)*Vllrms);
Icp = Iphase*sqrt(2);
Iep = Iphase*sqrt(2);
Vce_p = Vdc;
%fsw = 10e3; % Hz

% Datasheet values - Infineon
% Vcesat = 2.0; % V
% Vec = 1.55; % V
% Eon1 = 2.2e-3; % J
% Eoff1 = 1.8e-3; % J
% Err1 = 1.6e-3; % J

Vceo = 0.8; % V
Ro = (2.5-1.95)/(45-30); % Ohms
Vdo = 0.95; % V
Rd = (2-1.55)/(55-30); % Ohms
Vnom = 600; % V
Inom = 25; % A
Eon = 2.65e-3; % J
Eff = 2.20e-3; % J
Err = 0.9e-3; % J

% Loss calculation
Psc = Vceo*Icp/(2*pi) + Ro*Icp^2/8 + ma*pf*Vceo*Icp/8 + ma*pf*Ro*Icp^2/(3*pi); % W
Pdc = Vdo*Iep/(2*pi) + Rd*Iep^2/8 - ma*pf*Vdo*Iep/8 - ma*pf*Rd*Iep^2/(3*pi); % W
Pss = (Eon+Eoff)*fsw*Vdc*Icp/(pi*Vnom*Inom); % W
Pds = Err*fsw*Vdc*Icp/(pi*Vnom*Inom); % W

% Loss calculation
%Psc = Vcesat*Icp*(1/8+ma*pf/(3*pi)); % W
% Pdc = Iep*Vec*(1/8-ma*pf/(3*pi)) % W
%Pss = (Eon1+Eoff1)*fsw*(1/pi); % W
%Pds = (1/8)*trr*Irr*Vec_p*fsw; % W
% Pds = Err*fsw*(1/pi); % W

% Total loss
Ploss1 = Psc+Pdc+Pss+Pds; % W
Ploss = Ploss1*6; % W
efficiency = 100*Pdrout./(Ploss+Pdrout); % percent
% fprintf('Efficiency value with GaN with %gkHz is %g %%\n',fsw,efficiency2);


%%
% Simulation parameters

% Number of modules
n = 4;
% Step time
Ts = 1e-6; % sec
% Modulation index
ma = 1;
% Switching frequency
fsw = 10e3; % Hz
% DC link voltage
Vdc = 540; % Volts
% Load
Ptotal = 8e3; % W
Pout = Ptotal/n; % W
pf = 0.9;
Sout = Pout/pf; % VA
fout = 50; % Hz
wout = 2*pi*fout; % rad/sec
Vll_rms = ma*Vdc*0.612; % Volts
Iline = Sout/(Vll_rms*sqrt(3)); % Amps
Zload = Vll_rms/(Iline*sqrt(3)); % Ohms
Rload = Zload*pf; % Ohms
Xload = sqrt(Zload^2-Rload^2); % Ohms
Lload = Xload/wout; % Henries
phase = 0:90:270;

%%
% Run the simulation
sim('immd_design_elen_sim.slx');


%%
% Design and simulation with series connected modules

% Number of modules
n = 4;
ns = 2;
np = n/ns;
% Step time
Ts = 1e-6; % sec
% Modulation index
ma = 0.8;
% Switching frequency
fsw = 10e3; % Hz
% DC link voltage
Vdc = 540; % Volts
Vdcm = Vdc/ns;
% Load
Ptotal = 8e3/0.9; % W
Pout = Ptotal/n; % W
pf = 0.9;
Sout = Pout/pf; % VA
fout = 50; % Hz
wout = 2*pi*fout; % rad/sec
Vll_rms = ma*Vdcm*0.612; % Volts
Iline = Sout/(Vll_rms*sqrt(3)); % Amps
Zload = Vll_rms/(Iline*sqrt(3)); % Ohms
Rload = Zload*pf; % Ohms
Xload = sqrt(Zload^2-Rload^2); % Ohms
Lload = Xload/wout; % Henries
phase = [0 80 0 80];

Rin = 10;
%Lin = 1e-3;
Vin = Vdc + Rin*(Ptotal/Vdc);
Cdc = 100e-6;

%%
% RMS current
Idct = Ptotal/Vdc;
Idcc = np*(3/(2*sqrt(2)))*ma*Iline*pf;
Irmss = np*Iline*sqrt(2*ma*(sqrt(3)/(4*pi) + pf^2*(sqrt(3)/pi-9*ma/16)));
Irms_perc = 100*Irmss/Idcc;
Irms_int = 6.69;
Irms_int_perc = 100*Irms_int/Idcc;

%%
% IGBT'li sistem RMS ak�m ve Cdc
Vdc = 540;
Vllrms = 0.612*0.8*Vdc;
Pout = 8e3;
Pdrout = Pout/effmotor;
pf = 0.9;
Sdrout = Pdrout/pf;
Iphase = Sdrout/(sqrt(3)*Vllrms);
% RMS current
Idct = Ptotal/Vdc;
Idcc = (3/(2*sqrt(2)))*ma*Iphase*pf;
Irmss = Iphase*sqrt(2*ma*(sqrt(3)/(4*pi) + pf^2*(sqrt(3)/pi-9*ma/16)));
Irms_perc = 100*Irmss/Idcc

fsw = 10e3; % Hz
volt_ripple_perc = 1;
volt_ripple = volt_ripple_perc*Vdc/100;
Iapeak = Iphase*sqrt(2);
Cdc = ma*(Iapeak - Idcc)/(volt_ripple*fsw*2)
Cdcm = Cdc*1e6


%%
% Voltage ripple

fsw = 10e3; % Hz
Cdc = 100e-6; % F
Iapeak = np*Iline*sqrt(2);
volt_ripple = ma*(Iapeak - Idcc)/(Cdc*fsw*2);
volt_ripple_perc = volt_ripple/Vdc*100


%%
fsw = 10e3; % Hz
volt_ripple_perc = 1;
volt_ripple = volt_ripple_perc*Vdc/100;
Iapeak = np*Iline*sqrt(2);
Cdc = ma*(Iapeak - Idcc)/(volt_ripple*fsw*2);
Cdcm = Cdc*1e6;
Cdcm_int = Cdcm*0.52;


%%
% By waveforms
timea = Vdcc(:,1);
Vdc_int = Vdcc(:,2);
Idc1_int = Idc1(:,2);
Idc2_int = Idc2(:,2);
Icap_int = Icap(:,2);
Idct_int = Idct(:,2);


%%
timea = Vdcc(:,1);
Vdc_noint = Vdcc(:,2);
Idc1_noint = Idc1(:,2);
Idc2_noint = Idc2(:,2);
Icap_noint = Icap(:,2);
Idct_noint = Idct(:,2);


%%
figure;
plot(timea,Vdc_noint,'b-','Linewidth',2);
hold on;
plot(timea,Vdc_int,'r-','Linewidth',2);
hold off;
grid on;
set(gca,'FontSize',12);
%xlabel('Zaman (s)','FontSize',12,'FontWeight','Bold')
%ylabel('DA Bara Gerilimi (Volt)','FontSize',12,'FontWeight','Bold')
%legend('Interleaving yok','Interleaving var');
xlim([0.03 0.04])

xlabel('Time (s)','FontSize',12,'FontWeight','Bold')
ylabel('DC link voltage (V)','FontSize',12,'FontWeight','Bold')
legend('without interleaving','with interleaving');

%%
rms_noint = Irmss*ones(1,numel(timea));
rms_int = 0.52*Irmss*ones(1,numel(timea));
figure;
plot(timea,-Icap_noint,'b-','Linewidth',2);
hold on;
plot(timea,-Icap_int,'r-','Linewidth',2);
hold on;
plot(timea,rms_noint,'k-','Linewidth',3);
hold on;
plot(timea,rms_int,'g-','Linewidth',3);
hold on;
hold off;
grid on;
set(gca,'FontSize',12);
xlabel('Zaman (s)','FontSize',12,'FontWeight','Bold')
ylabel('DA Bara Kondansat�r Ak�m� (Amper)','FontSize',12,'FontWeight','Bold')
legend('Interleaving yok','Interleaving var','Interleaving yok - RMS','Interleaving var - RMS');
xlim([0.0395 0.04])
ylim([-20 30])

%%
figure;
subplot(2,1,1);
plot(timea,Idc1_int,'b-','Linewidth',2);
hold on;
plot(timea,Idc2_int,'r-','Linewidth',2);
hold on;
%plot(timea,Idct_noint,'k-','Linewidth',2);
hold on;
%plot(timea,Idct_int,'g-','Linewidth',2);
hold off;
grid on;
set(gca,'FontSize',12);
%xlabel('Zaman (s)','FontSize',12,'FontWeight','Bold')
%ylabel('DA Bara Ak�m� (Amper)','FontSize',12,'FontWeight','Bold')
%legend('1. mod�l','2. mod�l');
xlim([0.0395 0.04])
ylim([-5 30]);

%xlabel('Time (s)','FontSize',12,'FontWeight','Bold')
ylabel('DC link current (A)','FontSize',12,'FontWeight','Bold')
legend('module-1','module-2');

subplot(2,1,2);
%plot(timea,Idc1_int,'b-','Linewidth',2);
hold on;
%plot(timea,Idc2_int,'r-','Linewidth',2);
hold on;
plot(timea,Idct_noint,'k-','Linewidth',2);
hold on;
plot(timea,Idct_int,'b-','Linewidth',2);
hold off;
grid on;
set(gca,'FontSize',12);
%xlabel('Zaman (s)','FontSize',12,'FontWeight','Bold')
%ylabel('DA Bara Ak�m� (Amper)','FontSize',12,'FontWeight','Bold')
%legend('Toplam - Interleaving yok','Toplam - Interleaving var');
xlim([0.0395 0.04])
ylim([-5 60]);

xlabel('Time (s)','FontSize',12,'FontWeight','Bold')
ylabel('DC link current (A)','FontSize',12,'FontWeight','Bold')
legend('without interleaving','with interleaving');

%%
% interleaving results
ang = [0 15 30 45 60 75 90 105 120 135 150 165 180]';
rms = [12.77 11.58 10.22 8.85 7.89 7.15 6.69 6.71 7.33 8.64 9.65 10.24 10.45]';
perc = 100*rms/rms(1);
dca = 16.43;
perc2 = 100*rms/dca;

figure;
plot(ang,rms,'bo-','Linewidth',3);
grid on;
set(gca,'FontSize',12);
xlabel('Phase shift (degrees)','FontSize',12,'FontWeight','Bold')
ylabel('RMS current (A)','FontSize',12,'FontWeight','Bold')

figure;
plot(ang,perc,'bo-','Linewidth',3);
grid on;
set(gca,'FontSize',12);
xlabel('Phase shift (degrees)','FontSize',12,'FontWeight','Bold')
ylabel('RMS current (%)','FontSize',12,'FontWeight','Bold')
ylim([0 100]);

figure;
plot(ang,perc2,'bo-','Linewidth',3);
grid on;
set(gca,'FontSize',12);
xlabel('Phase shift (degrees)','FontSize',12,'FontWeight','Bold')
ylabel('RMS current (%)','FontSize',12,'FontWeight','Bold')
ylim([0 100]);


%%
% Run the simulation
sim('immd_design_elen_sim2.slx');

%%
Irmss = Iline*sqrt(2*ma*(sqrt(3)/(4*pi) + pf^2*(sqrt(3)/pi-9*ma/16)));
Idcc = (3/(2*sqrt(2))).*ma.*Iline*pf/0.999;
Irmss/Idcc;


%%
% Get parameters
Irms = Icrms(numel(Icrms));
Idc = Icdc(numel(Icdc));

% Calculation
Irms_perc = 100*Irms./Idc;
