
clc
clear all
close all

% load the data
startdate = '01/01/1994';
enddate = '01/01/2022';
f = fred
FXY = fetch(f,'CLVMNACSCAB1GQFR',startdate,enddate)
JPY = fetch(f,'JPNRGDPEXP',startdate,enddate)
fxy = log(FXY.Data(:,2));
jpy = log(JPY.Data(:,2));
q = FXY.Data(:,1);

T = size(fxy,1);

% Hodrick-Prescott filter
lam = 1600;
A = zeros(T,T);

% unusual rows
A(1,1)= lam+1; A(1,2)= -2*lam; A(1,3)= lam;
A(2,1)= -2*lam; A(2,2)= 5*lam+1; A(2,3)= -4*lam; A(2,4)= lam;

A(T-1,T)= -2*lam; A(T-1,T-1)= 5*lam+1; A(T-1,T-2)= -4*lam; A(T-1,T-3)= lam;
A(T,T)= lam+1; A(T,T-1)= -2*lam; A(T,T-2)= lam;

% generic rows
for i=3:T-2
    A(i,i-2) = lam; A(i,i-1) = -4*lam; A(i,i) = 6*lam+1;
    A(i,i+1) = -4*lam; A(i,i+2) = lam;
end

tauFXGDP = A\fxy;
tauJPGDP = A\jpy;

% detrended GDP
fxytilde = fxy-tauFXGDP;
jpytilde = jpy-tauJPGDP;

% plot detrended GDP
dates = 1994:1/4:2022.1/4; zerovec = zeros(size(fxy));
figure
title('Detrended log(real GDP) 1994Q1-2022Q1'); hold on
plot(q, fxytilde,'b', q, jpytilde,'r')
legend('FX','Japan','Location','southwest');
datetick('x', 'yyyy-qq')


% compute sd(y), sd(c), rho(y), rho(c), corr(y,c) (from detrended series)
fxysd = std(fxytilde)*100;
jpysd = std(jpytilde)*100;
corryc = corrcoef(fxytilde(1:T),jpytilde(1:T)); corryc = corryc(1,2);

disp(['Percent standard deviation of detrended log real GDP of France: ', num2str(fxysd),'.']); disp(' ')
disp(['Percent standard deviation of detrended log real GDP of Japan: ', num2str(jpysd),'.']); disp(' ')
disp(['Correlation between detrended log real GDP of France and Japan: ', num2str(corryc),'.']);
