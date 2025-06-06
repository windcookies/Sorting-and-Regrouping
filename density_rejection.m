%% DBSCAN用于聚类和识别噪声点
clear;clc
cd("C:\Users\11566\Desktop\z road\期刊\DV论文\matlab\11、DBSCAN方法的添加");
load('base_fea_ed.mat');
IC_ed=zscore(IC_ed);
V_ed=zscore(V_ed);
DV_ed=zscore(DV_ed);
%% V
i=1;
% 设置DBSCAN参数
epsilon = 10; % 邻域范围参数14
minPts = 2;    % 最小点数要求4
% 运行DBSCAN算法
X=V_ed;
labels = dbscan(X, epsilon, minPts);
% 可视化聚类结果
gscatter(X(:,1), X(:,2), labels);
title('DBSCAN聚类结果');
xlabel('X坐标');
ylabel('Y坐标');
%收集噪声点
delete_cells{i,1}=find(labels==-1);
%得到聚类数量
sorted_num=length(unique(labels))-1;
%得到分组group
x=[];
for i=1:sorted_num
x{i,1}=find(labels==i);
end
group_v_dbscan=x;
%% IC
% 设置DBSCAN参数
i=2;
epsilon = 7; % 邻域范围参数7.15
minPts = 2;    % 最小点数要求4
% 运行DBSCAN算法
X=IC_ed;
labels = dbscan(X, epsilon, minPts);
% 可视化聚类结果
gscatter(X(:,1), X(:,2), labels);
title('DBSCAN聚类结果');
xlabel('X坐标');
ylabel('Y坐标');
%收集噪声点
delete_cells{i,1}=find(labels==-1);
%得到聚类数量
sorted_num=length(unique(labels))-1;
%得到分组group
x=[];
for i=1:sorted_num
x{i,1}=find(labels==i);
end
group_ic_dbscan=x;
%% DV
% 设置DBSCAN参数
i=3;
epsilon = 4.9; % 邻域范围参数5
minPts = 2;    % 最小点数要求4
% 运行DBSCAN算法
X=DV_ed;
labels = dbscan(X, epsilon, minPts);
% 可视化聚类结果
gscatter(X(:,1), X(:,2), labels);
title('DBSCAN聚类结果');
xlabel('X坐标');
ylabel('Y坐标');
%收集噪声点
delete_cells{i,1}=find(labels==-1);
%得到聚类数量
sorted_num=length(unique(labels))-1;
%得到分组group
x=[];
for i=1:sorted_num
x{i,1}=find(labels==i);
end
group_dv_dbscan=x;
%% 汇总
delete_cells;%各方法的剔除电池
group_v_dbscan;%分组电池
group_ic_dbscan;%分组电池
group_dv_dbscan;%分组电池
save('group_dbscan.mat','delete_cells','group_v_dbscan','group_ic_dbscan','group_dv_dbscan');
