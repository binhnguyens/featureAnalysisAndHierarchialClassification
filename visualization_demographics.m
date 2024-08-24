 
%% Part 1 of Figure plotting - Seperate plots

for severity =1:1

%% Severity encoding
severity_names = ["None","Mild","Moderate","Severe"];

%% x1 is the variable that focusses on the specific severity
x1 = X_final(find (Y_final == severity),:);

%% Focussed features
demographic_feats = ["HHLDSIZC","AGEGRP","IMMIGRNC","SEX","MARSTATC"];
x1_focus = [];
c=1;

%% Finding the index of the features
for i = demographic_feats
   x1_focus(c) = find(strcmp(feat_names, i));
   c=c+1;
end

%% Saving only the columns of the features
x1_focus_feats = x1 (:,x1_focus);


%% Labelling the new x names and plotting
figure;
set(gcf,'Position',[100 100 500 900])
hold on;

num_rows = 5;
for i = 1:num_rows
    
   switch i 
       case 1 
           subplot (num_rows,1,i);
           histogram(x1_focus_feats (:,i));
           title ('Household size of Severity '+severity_names(severity));
           ylabel('Number of cases');
           xlabel ('Household size number');
           
       case 2
           hold = categorical(x1_focus_feats(:,i),...
               [1,2,3,4,5,6,7],{'15-24' '25-34' '35-44' '45-54',...
               '55-64','65-74','74+'});
           subplot (num_rows,1,i);
           histogram (hold);
           title ('Age group of Severity '+severity_names(severity));
           ylabel('Number of cases');
           xlabel ('Age');
           
       case 3
           hold = categorical(x1_focus_feats(:,i),...
               [1,2],{'Born in Canada', 'Landed and not a lnded immigrant'});
           subplot (5,1,i);
           histogram (hold);
           title ('Immigrant status of Severity '+severity_names(severity));
           ylabel('Number of cases');
           xlabel ('Label');
           
       case 4
           hold = categorical(x1_focus_feats(:,i),...
               [1,2],{'Male', 'Female'});
           subplot (5,1,i);
           histogram (hold);
           title ('Sex of Severity '+severity_names(severity));
           ylabel('Number of cases');
           xlabel ('Sex');
           
       case 5
           hold = categorical(x1_focus_feats(:,i),...
               [1,2,3,4],{'Married','Common-law', 'Widowed/Separated/Divorced','Single, never married'});
           subplot (num_rows,1,i);
           histogram (hold);
           title ('Marital status of Severity '+severity_names(severity));
           ylabel('Number of cases');
           xlabel ('Status');
   end
   
end

% saveas(gcf,['histogram of severity ', num2str(severity) ,'.png']);


end


% close all;



%% Part 2 of Figure plotting - Combined plots

for severity = 1:4
    
    % From Before
    severity_names = ["Minimal","Mild","Moderate","Severe"];

    x1 = X_final(find (Y_final == severity),:);

    demographic_feats = ["HHLDSIZC","AGEGRP","IMMIGRNC","SEX","MARSTATC"];
    x1_focus = [];

    c=1;
    for i = demographic_feats
       x1_focus(c) = find(strcmp(feat_names, i));
       c=c+1;
    end

    x1_focus_feats = x1 (:,x1_focus);

    % New part
    hshold_y{severity} = histcounts(x1_focus_feats (:,1));
    
    age_group_y {severity} = histcounts(x1_focus_feats(:,2));           
    
    boo_exp_y{severity} = histcounts(x1_focus_feats(:,5));
    
end

dim_x = 800;
dim_y = 500;
font_size = 25;

hshold_y = relative_freq (hshold_y);
age_group_y = relative_freq (age_group_y);
boo_exp_y = relative_freq (boo_exp_y);


% Household
figure;
binRange =1:4;
bar(binRange,[hshold_y{1}; hshold_y{2};hshold_y{3}; hshold_y{4}]');
title ('Household size categorized by GAD severity');
ylabel('Probability distribution');
xlabel ('GAD-7 Severity');
legend ('1','2','3','4','5+');
set(gca,'xticklabel',{'Minimal','Mild','Moderate','Severe'},'FontSize', font_size);
set(gcf,'Position',[100 100 dim_x dim_y])
ylim ([0 0.45]);
saveas(gcf,['household.png']);

% Age Group
figure;
binRange =1:4;
bar(binRange,[age_group_y{1}; age_group_y{2};age_group_y{3}; age_group_y{4};])
set(gca,'xticklabel',{'Minimal','Mild','Moderate','Severe'},'FontSize', font_size);
set(gcf,'Position',[100 100 dim_x dim_y])
ylim ([0 0.2]);
title ('Age group categorized by GAD severity');
ylabel('Probability distribution');
xlabel ('GAD-7 Severity');
legend ('15-24', '25-34' ,'35-44' ,'45-54','55-64','65-74','74+');
saveas(gcf,['age group.png']);

% Boo group
figure;
binRange =1:4;
bar(binRange,[boo_exp_y{1}; boo_exp_y{2};boo_exp_y{3}; boo_exp_y{4}]')
set(gca,'xticklabel',{'Minimal','Mild','Moderate','Severe'},'FontSize', font_size);
set(gcf,'Position',[100 100 dim_x dim_y])
title ('Marital status categorized by GAD severity');
ylabel('Probability distribution');
xlabel ('GAD-7 Severity');
ylim ([0 0.4]);
legend ('Married','Common-law',...
    'Seperated/Divorced/Widowed','Single, never married');
saveas(gcf,['marital status.png']);


%% Part 3 of - feature ranking - BH_35C
% disp (string(feat_names (ranking (1:k))));

% Focus on the top k features (k=20)
hold = find (string(X.Properties.VariableNames) == 'BH_35C');
optimal_feat_x = X_final (:,hold);
optimal_feat_y = Y_final;


% Remove 99
optimal_feat_y (find (optimal_feat_x == 9)) = [];
optimal_feat_x (find (optimal_feat_x == 9),:) = [];

histcount_var=cell(1,1);
for i = 1:4
    opt_feat_x = optimal_feat_x((find (optimal_feat_y == i)),:);
    histcount_var_temp{i} = histcounts(opt_feat_x);
    histcount_var {i} = histcount_var_temp{i}./sum(histcount_var_temp{i});
end

option = 2;
dim_x = 1200; 
dim_y = 600;
font_size = 30;

if option == 1
    histcount_var = histcount_var_temp;
    figure;
    bar([histcount_var{1};histcount_var{2};histcount_var{3};histcount_var{4}]);
    title ('Excercise outdoors');
    ylabel ('Probability distribution per cluster');
    xlabel ('Severity');
    
    set(gcf,'Position',[100 100 dim_x dim_y])
    ylim([0 .8])
    set(gca,'xticklabel',{'Minimal','Mild','Moderate','Severe'},'FontSize', font_size);
    legend ('Yes for mental health', 'Yes for physical health', 'Yes for mental and physical health', 'No');
end

if option == 2
    figure;
    bar([histcount_var{1};histcount_var{2};histcount_var{3};histcount_var{4}]);
    title ('Excercise outdoors (BH\_35C)');
    ylabel ('Probability per cluster');
    xlabel ('Severity');
    
    set(gcf,'Position',[100 100 dim_x dim_y])
    ylim([0 1])
    set(gca,'xticklabel',{'Minimal','Mild','Moderate','Severe'},'FontSize', font_size);
    legend ('Yes, for mental health', 'Yes, for physical health', ...
        'Yes, for mental and physical health', 'No');%,'Location','eastoutside');
end


saveas(gcf,['BH_35C_relativeFreq.png']);

% Part 4 of - feature ranking - BH_40B

% Focus on the top k features (k=20)
hold = find (string(X.Properties.VariableNames) == 'BH_40B');
optimal_feat_x = X_final (:,hold);
optimal_feat_y = Y_final;


% Remove 99
optimal_feat_y (find (optimal_feat_x == 9)) = [];
optimal_feat_x (find (optimal_feat_x == 9),:) = [];

histcount_var=cell(1,1);
for i = 1:4
    opt_feat_x = optimal_feat_x((find (optimal_feat_y == i)),:);
    histcount_var_temp{i} = histcounts(opt_feat_x);
    histcount_var {i} = histcount_var_temp{i}./sum(histcount_var_temp{i});
end

if option == 1
    histcount_var = histcount_var_temp;
    figure;
    bar([histcount_var{1};histcount_var{2};histcount_var{3};histcount_var{4}]);
    title ('Tobacco usage');
    ylabel ('Probability per cluster');
    xlabel ('Severity');

end

if option == 2
    figure;
    bar([histcount_var{1};histcount_var{2};histcount_var{3};histcount_var{4}]);
    title ('Tobacco usage (BH\_40B)');
    ylabel ('Probability per cluster');
    xlabel ('Severity');
    
    set(gcf,'Position',[100 100 dim_x dim_y])
    ylim([0 1.2])
    set(gca,'xticklabel',{'Minimal','Mild','Moderate','Severe'},'FontSize', font_size);
    legend ('Increased', 'Decreased', 'No change');%,'Location','eastoutside');
end

saveas(gcf,['BH_40B_relativeFreq.png']);



%% Part 5 of - feature ranking - BH_35B (Meditating)
% disp (string(feat_names (ranking (1:k))));

% Focus on the top k features (k=20)
hold = find (string(X.Properties.VariableNames) == 'BH_35B');
optimal_feat_x = X_final (:,hold);
optimal_feat_y = Y_final;


% Remove 99
optimal_feat_y (find (optimal_feat_x == 9)) = [];
optimal_feat_x (find (optimal_feat_x == 9),:) = [];

histcount_var=cell(1,1);
for i = 1:4
    opt_feat_x = optimal_feat_x((find (optimal_feat_y == i)),:);
    histcount_var_temp{i} = histcounts(opt_feat_x);
    histcount_var {i} = histcount_var_temp{i}./sum(histcount_var_temp{i});
end

option = 2;
dim_x = 1200; 
dim_y = 600;
font_size = 30;

if option == 1
    histcount_var = histcount_var_temp;
    figure;
    bar([histcount_var{1};histcount_var{2};histcount_var{3};histcount_var{4}]);
    title ('Meditation (BH\_35B)');
    ylabel ('Probability distribution per cluster');
    xlabel ('Severity');
    
    set(gcf,'Position',[100 100 dim_x dim_y])
    ylim([0 .8])
    set(gca,'xticklabel',{'Minimal','Mild','Moderate','Severe'},'FontSize', font_size);
    legend ('Yes for mental health', 'Yes for physical health', 'Yes for mental and physical health', 'No');
end

if option == 2
    figure;
    bar([histcount_var{1};histcount_var{2};histcount_var{3};histcount_var{4}]);
    title ('Meditation (BH\_35B)');
    ylabel ('Probability per cluster');
    xlabel ('Severity');
    
    set(gcf,'Position',[100 100 dim_x dim_y])
    ylim([0 1])
    set(gca,'xticklabel',{'Minimal','Mild','Moderate','Severe'},'FontSize', font_size);
    legend ('Yes, for mental health', 'Yes, for physical health', ...
        'Yes, for mental and physical health', 'No');%,'Location','eastoutside');
end


saveas(gcf,['BH_35B_relativeFreq.png']);

%% Part 6 of - feature ranking - BH_35B (Meditating)
% disp (string(feat_names (ranking (1:k))));

% Focus on the top k features (k=20)
hold = find (string(X.Properties.VariableNames) == 'BH_60C');
optimal_feat_x = X_final (:,hold);
optimal_feat_y = Y_final;


% Remove 99
optimal_feat_y (find (optimal_feat_x == 9)) = [];
optimal_feat_x (find (optimal_feat_x == 9),:) = [];

histcount_var=cell(1,1);
for i = 1:4
    opt_feat_x = optimal_feat_x((find (optimal_feat_y == i)),:);
    histcount_var_temp{i} = histcounts(opt_feat_x);
    histcount_var {i} = histcount_var_temp{i}./sum(histcount_var_temp{i});
end

histcount_var{3} = [0 histcount_var{3}]

option = 2;
dim_x = 1200; 
dim_y = 600;
font_size = 30;

if option == 1
    histcount_var = histcount_var_temp;
    figure;
    bar([histcount_var{1};histcount_var{2};histcount_var{3};histcount_var{4}]);
    title ('Use of Food Delivery Service (BH\_60C)');
    ylabel ('Probability distribution per cluster');
    xlabel ('Severity');
    
    set(gcf,'Position',[100 100 dim_x dim_y])
    ylim([0 .8])
    set(gca,'xticklabel',{'Minimal','Mild','Moderate','Severe'},'FontSize', font_size);
    legend ('Yes for mental health', 'Yes for physical health', 'Yes for mental and physical health', 'No');
end

if option == 2
    figure;
    bar([histcount_var{1};histcount_var{2};histcount_var{3};histcount_var{4}]);
    title ('Use of Food Delivery Service  week(BH\_60C)');
    ylabel ('Probability per cluster');
    xlabel ('Severity');
    
    set(gcf,'Position',[100 100 dim_x dim_y])
    ylim([0 1])
    set(gca,'xticklabel',{'Minimal','Mild','Moderate','Severe'},'FontSize', font_size);
    legend ('Daily', '4 or 5 times', ...
        '1 to 3 times', 'Never');%,'Location','eastoutside');
end


saveas(gcf,['BH_60C_relativeFreq.png']);
