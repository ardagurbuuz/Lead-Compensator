d = 2; a = 1;

OSp = 10;                                                  % belirlediğimiz (spec) max overshoot (%)
ts  = 4;                                                   % belirlediğimiz settling time (s), 2% criterion
band = 0.02;                                               % settling band (2%)

s = tf('s');
G = d/(s*(s+a));

OSspec = OSp/100;
zeta_min = -log(OSspec)/sqrt(pi^2 + (log(OSspec))^2);
sigma = 4/ts;                                               % 2% settling time yaklaşımı

sd_min = -sigma + 1j*( (sigma/zeta_min)*sqrt(1 - zeta_min^2) );

z0 = 2.0723;  p0 = 5.8757;
K0 = 1/abs(((sd_min+z0)/(sd_min+p0))*evalfr(G,sd_min));     % magnitude condition
C0 = K0*(s+z0)/(s+p0);                                      % ilk lead compensator
T0 = feedback(C0*G,1);

info0 = stepinfo(T0,'SettlingTimeThreshold',band);
OS0 = info0.Overshoot/100;               % ilk lead tasarımının gerçek overshoot'u (0–1 aralığında)

kOS = OS0/OSspec;                        % overshoot şişirme katsayısı
m = 1.2;                                 % R/C toleransı, op-amp etkileri için implementation margin (1.2 = +20%)
OSdesign = OSspec/(kOS*m);

zeta_d = -log(OSdesign)/sqrt(pi^2 + (log(OSdesign))^2);
wn_d = sigma/zeta_d;                              % natural frequency
wd_d = wn_d*sqrt(1 - zeta_d^2);                   % damped frequency
sd = -sigma + 1j*wd_d;                            % artık tasarımda kullanacak tutarlı dominant pole

p = 6;                                            % lead pole, yeterince solda bir seçim

phiNeed = -180 - angle(evalfr(G,sd))*180/pi;      %angle(evalfr(G,sd)) G(sd​)'nin fazı, Root locus angle condition için toplam fazın − 180° olması lazım
phiNeed = mod(phiNeed,360);
phiNeed = min(phiNeed, 360-phiNeed);              % plant'in fazı şu kadar - o zaman lead'in eklemesi gereken faz şu kadar, 0–180° aralığına indirge

f = @(zz) (angle(sd+zz) - angle(sd+p))*180/pi - phiNeed;
z = fzero(f, 1.7);                                % initial value

K = 1/abs(((sd+z)/(sd+p))*evalfr(G,sd));          % yeni z ve p ile magnitude cond.
C = K*(s+z)/(s+p);                                % final compensator

Tun = feedback(G,1);
Tco = feedback(C*G,1);

info_un = stepinfo(Tun,'SettlingTimeThreshold',band);
info_co = stepinfo(Tco,'SettlingTimeThreshold',band);

disp("Spec -> zeta_min, sigma:");
disp([zeta_min sigma])

disp("Calibration (initial lead) -> OS0, kOS:");
disp([OS0 kOS])

disp("Design OS (with margin m) -> OSdesign, zeta_d, sd:");
disp([OSdesign zeta_d real(sd) imag(sd)])

disp("Final compensator -> K, z, p:");
disp([K z p])

disp("Phase check (deg) -> need, provided, error:");
phiC = (angle(sd+z) - angle(sd+p))*180/pi;
disp([phiNeed phiC (phiNeed-phiC)])

disp("Closed-loop poles (uncomp / comp):");
disp(pole(Tun).')
disp(pole(Tco).')

disp("stepinfo uncompensated:"); disp(info_un)
disp("stepinfo compensated:");   disp(info_co)