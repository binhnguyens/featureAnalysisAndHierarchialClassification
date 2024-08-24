%  Matlab Code-Library for Feature Selection
%  A collection of S-o-A feature selection methods
%  Version 6.2 October 2018
%  Support: Giorgio Roffo
%  E-mail: giorgio.roffo@glasgow.ac.uk
%
%  Before using the Code-Library, please read the Release Agreement carefully.
%
%  Release Agreement:
%
%  - All technical papers, documents and reports which use the Code-Library will acknowledge the use of the library as follows:
%    The research in this paper use the Feature Selection Code Library (FSLib) and a citation to:
%  ------------------------------------------------------------------------
% @InProceedings{RoffoICCV17,
% author={Giorgio Roffo and Simone Melzi and Umberto Castellani and Alessandro Vinciarelli},
% booktitle={2017 IEEE International Conference on Computer Vision (ICCV)},
% title={Infinite Latent Feature Selection: A Probabilistic Latent Graph-Based Ranking Approach},
% year={2017},
% month={Oct}}
%  ------------------------------------------------------------------------
% @InProceedings{RoffoICCV15,
% author={G. Roffo and S. Melzi and M. Cristani},
% booktitle={2015 IEEE International Conference on Computer Vision (ICCV)},
% title={Infinite Feature Selection},
% year={2015},
% pages={4202-4210},
% doi={10.1109/ICCV.2015.478},
% month={Dec}}
%  ------------------------------------------------------------------------

% FEATURE SELECTION TOOLBOX v 6.2 2018 - For Matlab 
% Please, select a feature selection method from the list:
% [1] ILFS 
% [2] InfFS 
% [3] ECFS 
% [4] mrmr 
% [5] relieff 
% [6] mutinffs 
% [7] fsv 
% [8] laplacian 
% [9] mcfs 
% [10] rfe 
% [11] L0 
% [12] fisher 
% [13] UDFS 
% [14] llcfs 
% [15] cfs 
% [16] fsasl 
% [17] dgufs 
% [18] ufsol 
% [19] lasso 

% Before using the toolbox compile the solution:
% make;

%% DEMO FILE
close all; clear; clc;
fprintf('\nFEATURE SELECTION TOOLBOX v 6.2 2018 - For Matlab \n');

%% Include dependencies
addpath('./lib'); % dependencies
addpath('./methods'); % FS methods
addpath(genpath('./lib/drtoolbox'));

%% Select a feature selection method from the list
listFS = {'ILFS','InfFS','ECFS','mrmr','relieff','mutinffs','fsv','laplacian','mcfs','rfe','L0','fisher','UDFS','llcfs','cfs','fsasl','dgufs','ufsol','lasso'};

% Method 1
% [ methodID ] = readInput( listFS );

% Method 2
% methodID = usr_input;

% Method 3
[ methodID ] = 4;

selection_method = listFS{methodID}; 

%% Load the data and select features for classification
series = 2;

path = '/Users/binhnguyen/Desktop/Desktop/Digital Mental Health/2. Data and Analysis/CPSS';
removed_var = {'MH_15A','MH_15B','MH_15C','MH_15D','MH_15E','MH_15F','MH_15G','ANXDVSEV','ANXDVGAD','ANXDVGAC'};

% Try to remove MHDVMHI and MH_30

switch series

    case 2
        filename = '/Series_2/cpss-5311-E-series2_F1.csv';
        tbl = readtable (strcat(path,filename));
        Y = tbl.ANXDVSEV; % GAD7
        X = tbl (:,2:end-2);
        for i=1:length(removed_var)
            var = find (string(X.Properties.VariableNames) == string(removed_var(i)));
            X(:,var) = [];
        end
        
    case 4
        filename = '/Series_4/cpss-5311-E-sources_F1.csv';
        tbl = readtable (strcat(path,filename));
        Y = tbl.ANXDVSEV; % GAD7
        X = tbl (:,2:end-2);
        for i=1:length(removed_var)
            var = find (string(X.Properties.VariableNames) == string(removed_var(i)));
            X(:,var) = [];
        end
end

%% Assign the values to X and Y
X_final = (table2array (X));
X_final = (X_final - min(X_final)) ./ ( max(X_final) - min(X_final) );
Y_final = Y;

% Removing the 99 state
X_final (find (Y_final == 9),:) = [];
Y_final (find (Y_final == 9)) = [];

% No symptons and minimal should be the same
Y_final (find (Y_final == 0)) = 1;



%% Hierarchical Seperation

seperation_choice= 5;


switch seperation_choice 
    case 1 % 012 vs 34 (Significance) - USED IN PAPER
        hold1 = 1;
        hold2 = 4;
    case 2 % 01 vs 4 (Minimal vs Severe)  - USED IN PAPER
        hold1 = 5;
        hold2 = 5;
    case 3 % 01 vs 34
        hold1 = 5;
        hold2 = 4;
    case 4 % 01 vs 2 vs 34 
        hold1 = 2;
        hold2 = 4;
    case 5 % 01 vs 2 vs 3 vs 4 (All classes)  - USED IN PAPER
        hold1 = 2;
        hold2 = 3;
        
%     Case 6, 7, 8 were - USED IN PAPER
    case 6 % 1 vs 2,3,4 (Minimal vs rest)
        hold1 = 4;
        hold2 = 4;
    case 7 % 2 vs 3,4 (Mild vs Mod and Severe)
        Y_final (find (Y_final == 1)) = 5; % Avoiding Class 1
        hold1 = 2;
        hold2 = 4;
    case 8 % 3 vs 4 (Mod vs Severe
        Y_final (find (Y_final == 1)) = 5; % Avoiding Class 1
        hold1 = 5;
        hold2 = 3;
        
    case 9 % 1 vs 2
        Y_final (find (Y_final == 4)) = 5; % Avoiding Class 4
        hold1 = 2;
        hold2 = 5;
    case 10 % 1 vs 3
        Y_final (find (Y_final == 4)) = 5; % Avoiding Class 4
        hold1 = 5;
        hold2 = 3;
    case 11 % 1 vs 4
        hold1 = 5;
        hold2 = 5;
end

% Updating class labels
Y_final (find (Y_final == 2)) = hold1;

Y_final (find (Y_final == 3)) = hold2;

% Setting xlab and ylab as the new grouped DF
xlab = cell(1,1);
ylab = cell(1,1);

for i =1:4
    xlab{i} = (X_final (find (Y_final == i),:));    
    ylab{i} = (Y_final (find (Y_final == i)));
end

% Final dataframes
X_final = [xlab{1};xlab{2};xlab{3};xlab{4}];
Y_final = [ylab{1};ylab{2};ylab{3};ylab{4}];


df_final = [X_final Y_final];


%% Train test split
P = cvpartition(Y_final,'Holdout',0.20);

X_train = double(X_final(P.training,:));
Y_train = (double( Y_final(P.training))); 
X_test = double( X_final(P.test,:) );
Y_test = (double( Y_final(P.test) ));

% Variable header names
feat_names = X.Properties.VariableNames;

% Number of features
numF = size(X_train,2);

%% Feature Selection on training data
switch lower(selection_method)
    case 'inffs'
        % Infinite Feature Selection 2015 updated 2016
        alpha = 0.5;    % default, it should be cross-validated.
        sup = 1;        % Supervised or Not
        [ranking, w] = infFS( X_train , Y_train, alpha , sup , 0 );
        
    case 'ilfs'
        % Infinite Latent Feature Selection - ICCV 2017
        [ranking, weights] = ILFS(X_train, Y_train , 6, 0 );
        
    case 'fsasl'
        options.lambda1 = 1;
        options.LassoType = 'SLEP';
        options.SLEPrFlag = 1;
        options.SLEPreg = 0.01;
        options.LARSk = 5;
        options.LARSratio = 2;
        nClass=2;
        [W, S, A, objHistory] = FSASL(X_train', nClass, options);
        [v,ranking]=sort(abs(W(:,1))+abs(W(:,2)),'descend');
    case 'lasso'
        lambda = 25;
        B = lasso(X_train,Y_train);
        [v,ranking]=sort(B(:,lambda),'descend');
        
    case 'ufsol'
        para.p0 = 'sample';
        para.p1 = 1e6;
        para.p2 = 1e2;
        nClass = 2;
        [~,~,ranking,~] = UFSwithOL(X_train',nClass,para) ;
        
    case 'dgufs'
        
        S = dist(X_train');
        S = -S./max(max(S)); % it's a similarity
        nClass = 2;
        alpha = 0.5;
        beta = 0.9;
        nSel = 2;
        [Y,L,V,Label] = DGUFS(X_train',nClass,S,alpha,beta,nSel);
        [v,ranking]=sort(Y(:,1)+Y(:,2),'descend');
        
        
    case 'mrmr'
        ranking = mRMR(X_train, Y_train, numF);
        
    case 'relieff'
        [ranking, w] = reliefF( X_train, Y_train, 20);
        
    case 'mutinffs'
        [ ranking , w] = mutInfFS( X_train, Y_train, numF );
        
    case 'fsv'
        [ ranking , w] = fsvFS( X_train, Y_train, numF );
        
    case 'laplacian'
        W = dist(X_train');
        W = -W./max(max(W)); % it's a similarity
        [lscores] = LaplacianScore(X_train, W);
        [junk, ranking] = sort(-lscores);
        
    case 'mcfs'
        % MCFS: Unsupervised Feature Selection for Multi-Cluster Data
        options = [];
        options.k = 5; %For unsupervised feature selection, you should tune
        %this parameter k, the default k is 5.
        options.nUseEigenfunction = 4;  %You should tune this parameter.
        [FeaIndex,~] = MCFS_p(X_train,numF,options);
        ranking = FeaIndex{1};
        
    case 'rfe'
        ranking = spider_wrapper(X_train,Y_train,numF,lower(selection_method));
        
    case 'l0'
        ranking = spider_wrapper(X_train,Y_train,numF,lower(selection_method));
        
    case 'fisher'
        ranking = spider_wrapper(X_train,Y_train,numF,lower(selection_method));
        
        
    case 'ecfs'
        % Features Selection via Eigenvector Centrality 2016
        alpha = 0.5; % default, it should be cross-validated.
        ranking = ECFS( X_train, Y_train, alpha )  ;
        
    case 'udfs'
        % Regularized Discriminative Feature Selection for Unsupervised Learning
        nClass = 2;
        ranking = UDFS(X_train , nClass );
        
    case 'cfs'
        % BASELINE - Sort features according to pairwise correlations
        ranking = cfs(X_train);
        
    case 'llcfs'
        % Feature Selection and Kernel Learning for Local Learning-Based Clustering
        ranking = llcfs( X_train );
        
    otherwise
        disp('Unknown method.')
end

%% Number of features to take
k=20;

% Ranking
disp (string(feat_names (ranking (1:k))));

%% DT classifier cross validated

acc2 = zeros (10,1);
scores2 =  zeros (10,3);

for i = 1:10
    c = cvpartition(Y_final,'Kfold',k);
    mdl = fitctree(X_final,Y_final,'CVPartition',c);
    err_rate = kfoldLoss(mdl);

    prediction = kfoldPredict(mdl);
    conMat_DT = confusionmat(prediction, Y_final);
    err_DT = (err_rate)*100;

    fprintf('\nMethod %s (DT): Accuracy: %.2f%%, Error-Rate: %.2f \n',selection_method,(100-err_DT),(err_DT));
    
    acc2 (i) = 100-err_DT;
    [scores2(i,1), scores2(i,2), scores2(i,3)]  = precision_f1_recall(conMat_DT);
end


fprintf ('\n Final score: %.2f +/- %.2f%% \n', mean (acc2), std(acc2));


%% SVM classifier cross validated

acc1 = zeros (10,1);
scores1 =  zeros (10,3);

for i =1:10
    Mdl_SVM = fitcecoc(X_final(:,ranking(1:k)),Y_final);
    Mdl_SVM = crossval(Mdl_SVM);

    err_SVM = kfoldLoss(Mdl_SVM) % mis-classification rate
    prediction = kfoldPredict(Mdl_SVM); % prediction
    conMat_SVM = confusionmat(prediction,Y_final); % the confusion matrix

    fprintf('\nMethod %s (Linear-SVMs): Accuracy: %.2f%%, Error-Rate: %.2f \n',selection_method,100*(1-err_SVM),100*(err_SVM));
    
    acc1 (i) = (1-err_SVM)*100;
    [scores1(i,1), scores1(i,2), scores1(i,3)]  = precision_f1_recall(conMat_SVM);
end

fprintf ('\n Final score: %.2f +/- %.2f%% \n', mean (acc1), std(acc1));

%% SVM - Other kernels for multi class

% RBF
t = templateSVM('KernelFunction','RBF','KernelScale','auto');
Mdl_SVM = fitcecoc(X_final(:,ranking(1:k)),Y_final,'Learners',t);
Mdl_SVM = crossval(Mdl_SVM);
classLoss = kfoldLoss(Mdl_SVM);
acc1 = (1-classLoss)*100;
fprintf ('\n Final score RBF: %.2f\n', acc1);

% Polynomial
t = templateSVM('KernelFunction','Polynomial','KernelScale','auto');
Mdl_SVM = fitcecoc(X_final(:,ranking(1:k)),Y_final,'Learners',t);
Mdl_SVM = crossval(Mdl_SVM);
classLoss = kfoldLoss(Mdl_SVM);
acc1 = (1-classLoss)*100;
fprintf ('\n Final score Polynomial: %.2f\n', acc1);


%% SVM - Other kernels 

% RBF
SVMModel = fitcsvm(X_final(:,ranking(1:k)),Y_final,'KernelFunction','RBF',...
    'KernelScale','auto');
% SVMModel.KernelParameters.Function

CVSVMModel = crossval(SVMModel);

classLoss = kfoldLoss(CVSVMModel);

acc1 = (1-classLoss)*100;

fprintf ('\n Final score RBF: %.2f\n', acc1);


% Polynomial
SVMModel = fitcsvm(X_final(:,ranking(1:k)),Y_final,'KernelFunction','Polynomial',...
    'KernelScale','auto');
% SVMModel.KernelParameters.Function

CVSVMModel = crossval(SVMModel);

classLoss = kfoldLoss(CVSVMModel);

acc2 = (1-classLoss)*100;

fprintf ('\n Final score Poly: %.2f\n', acc2);



%% Confusion matrix
CM_choice = 5;

switch CM_choice
    case 1
    %% Visualization of confusion matrix 1
    figure;
    confusionchart(conMat_SVM,{'Less than mild','Moderate and severe'});
    title ('Confusion matrix of SVM classifier');
%     saveas(gcf,['confusion matrix 012 vs 34.png']);

    %% Visualization of confusion matrix 2
    case 2
    figure;
    confusionchart(conMat_SVM,{'Minimal','Severe'});
    title ('Confusion matrix of SVM classifier');
%     saveas(gcf,['confusion matrix 01 vs 4.png']);

    %% Visualization of confusion matrix 3
    case 3
    figure;
    confusionchart(conMat_SVM,{'No symptons','Moderate and severe'});
    title ('Confusion matrix of SVM classifier');
%     saveas(gcf,['confusion matrix 01 vs 34.png']);

    %% Visualization of confusion matrix 4 
    case 4
    figure;
    confusionchart(conMat_SVM,{'No symptons','Mild','Moderate and severe'});
    title ('Confusion matrix of SVM classifier');
%     saveas(gcf,['confusion matrix 01 vs 2 vs 34.png']);

    %% Visualization of confusion matrix 4 
    case 5
    
    
end



%% DT classifier 

l = 2
Mdl_DT = fitctree(X_train(:,ranking(5:6)),Y_train);
C_DT = predict(Mdl_DT,X_test(:,ranking(1:l)));
err_DT = sum(Y_test~= C_DT)/P.TestSize; % mis-classification rate
conMat_DT = confusionmat(Y_test,C_DT); % the confusion matrix

% ranking
disp (string(feat_names (ranking (1:k))));

fprintf('\nMethod %s (DT): Accuracy: %.2f%%, Error-Rate: %.2f \n',selection_method,100*(1-err_DT),100*(err_DT));
