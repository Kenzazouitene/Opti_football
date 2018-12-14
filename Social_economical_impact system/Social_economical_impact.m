clear;

%% Load the data for 10 premier league teams
load('astat_7')
 

x1 = double(actualstatistics13(:,1)); %Load the stadium capacity of those 10 teams
x2 = double(actualstatistics13(:,2)); %Load the percentage of local players of of those 10 teams
x3 = double(actualstatistics13(:,3)); %Load the percentage of wins of of those 10 teams
x4 = double(actualstatistics13(:,5)); %Load the percentage of season ticket holders of of those 10 teams

Y = (actualstatistics13(:,6)); % Load the index linked rating their integration into the community to each of those teams

%% Normalisation

%Calculate the mean to be able to reverse the normalisation
x1_m = mean(x1(1:11)); %Mean of stadium capacity 
x2_m = mean(x2(1:11)); %Mean of percentage of local players
x3_m = mean(x3(1:11)); %Mean of percentage of wins
x4_m = mean(x4(1:11)); %Mean of percentage of season ticket holders
Y_m = mean(Y(1:11)); %Mean of the index

%Calculate the standard deviation to be able to reverse the normalisation
x1_std = std(x1(1:11)); %Standard deviation of stadium capacity
x2_std = std(x2(1:11)); %Standard deviation of percentage of local players
x3_std = std(x3(1:11)); %Standard deviation of percentage of wins
x4_std = std(x4(1:11)); %Standard deviation of percentage of season ticket holders
Y_std = std(Y(1:11));  %Standard deviation of of the index

%Normalise the dataset using the mapstd function
x1 = mapstd(x1');
x2 = mapstd(x2');
x3 = mapstd(x3');
x4 = mapstd(x4');

%Extract the normalised bounds 
x1_cons = (x1(12)); % stadium capacity
x2_cons = (x2(12)); % percentage of local players
x3_cons = (x3(12)); % percentage of wins
x4_cons = (x4(12)); % percentage of season ticket holders
Y = mapstd(Y');  % The index

%Extract the normalised datasets
x1 = (x1(1:11))'; % stadium capacity
x2 = (x2(1:11))'; % percentage of local players
x3 = (x3(1:11))'; % percentage of wins
x4 = (x4(1:11))'; % percentage of season ticket holders
Y = (Y(1:11))'; % The index

%%Model regression
p = polyfitn([x1,x2,x3],Y,2) %Using the polyfitn package to regress a 2nd degree polynomial from the data
polyn2sympoly(p) %display the objective function

%% Optimisation with fmincon

%Objective function
fun = @(x)1/(9.6692*x(1)^2 + 18.228*x(1)*x(2) + 6.7718*x(1)*x(3) - 3.4662*x(1) + 1.2272*x(2)^2 - 5.1496*x(2)*x(3) - 2.3057*x(2) - 4.8726*x(3)^2 - 1.6145*x(3) + 0.92729)

ub=[4.5324,1.09,1.075] %normalised upper bounds of the variables
lb=[x1_cons,x2_cons,x3_cons]  %normalised lower bounds of the variables
x0 = [10,5,10]; %x0, start point of the fmincon algorithms

% Constraint for the turnover
A1 = [1000, 100, 10];
b = [5]; %5 percent turnover
% 
b = mapstd(b') % normalised turnover


%Setting the options for fmincon
algorithms = ["interior-point","sqp","sqp-legacy","active-set","trust-region-reflective"];
algorithm = algorithms(3);
options = optimoptions('fmincon','Algorithm',algorithm);
% x_con = fmincon(fun,x0,A1,b,[],[],lb,[])
x = fmincon(fun,x0,A1,b,[],[],lb,ub,[],options)

% [x,fval,exitflag,output] = fmincon(fun,x0,A1,b,[],[],lb,ub,[],'options')




%unormalize data

x1_f = (x(1)*x1_std)+x1_m
x2_f = (x(2)*x2_std)+x2_m
x3_f = (x(3)*x3_std)+x3_m



%% other algorithms tried

% options = optimset('PlotFcns',@optimplotfval);
% options = optimset('Display','iter','PlotFcns',@optimplotfval);
% x = fminsearch(fun,x0,options)
% 
% 
%  
%x = lsqnonlin(fun,x0)
%   
%rng default % For reproducibility
%gs = GlobalSearch;
%sixmin = @(x)1/(-24*(x(1))^2 - 59*x(2)*x(1) - 24*x(3)*x(1) + 60.8*x(1) -  16*(x(2))^2 + 14.8*x(3)*x(2)+34.2*x(2) + 32.1*(x(3))^2 - 20.3*x(3) -17.36);
%problem = createOptimProblem('fmincon','x0',[100,2,7],...
%      'objective',sixmin,'lb',[x1_cons,x2_cons,x3_cons],'ub',[]);
%[x_gbs,fval,exitflag,output,solutions] = run(gs,problem)
% 
%x1_gbs = -0.6 
%x2_gbs =  0.59
%x3_gbs = 0.92
%x1_gbs = mapstd('reverse',x1_gbs)
