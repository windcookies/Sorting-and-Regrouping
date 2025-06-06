clear;clc
path = 'C:\Users\11566\Desktop\z road\期刊\DV论文\matlab\6、improved_fcm的backup';  % 读取数据
cd(path);    % 把当前工作目录切换到指定文件夹
fea=load('base_fea_ed.mat');
fea=fea.V_ed;
% cellnum_remain=fea(:,1);
cellnum_remain=1:252;
fea=fea(:,2:end);
%% 最近邻网络
% DV对应r=38,只有一个unique_net,即全部组合
% V对应r=10,有4个unique_net,分别为233、236、236、238数量，仍无法实现最近邻网络数等于分组数
r=14;
% 距离计算,填入矩阵
DIST=zeros(size(fea,1),size(fea,1));
data=fea;
% 欧式距离计算
for i=1:size(fea,1)
    vec1=data(i,:);
    for j=i+1:size(fea,1)
     vec2=data(j,:);
     DIST(i,j)=norm(vec1-vec2);
     DIST(j,i)=DIST(i,j);
    end
end
%
% 假设DIST是已经存在的矩阵，其中包含了距离信息  
% 初始化最近邻网络矩阵  
ner_matrix = zeros(size(DIST));  
% 构建最近邻网络矩阵  
for i = 1:size(DIST, 1)  
    % 获取当前行的距离向量，并排序  
    [sorted_dist, sort_idx] = sort(DIST(i, :));  
    % 存储排序后的索引到ner_matrix  
    ner_matrix(i, :) = sort_idx;  
end  
% 提取每个点的r阶最近邻，直到unique_ners=234  
work_ner_sum = ner_matrix(:,2:r);  
% 获取唯一的近邻索引，即网络中的节点  
A_unique_ners = unique(work_ner_sum);  
% 初始化最近邻网络图矩阵  
ner_network = false(size(DIST));  
% 构建最近邻网络图  
for i = 1:size(DIST, 1)  
    % 获取当前点的近邻索引  
    ners_of_i = work_ner_sum(i, :);  
    % 在ner_network中标记连接关系  
    ner_network(i, ners_of_i) = true;  
    ner_network(ners_of_i, i) = true;  
end  
% 寻找每个点的最近邻集合  
cell_net = cell(size(DIST, 1), 1);  
for i = 1:size(DIST, 1)  
    % 初始化当前点的最近邻集合  
    current_net = i;  
    % 迭代寻找所有连接的近邻  
    while true  
        % 获取当前近邻集合的近邻索引  
        next_ners = unique(work_ner_sum(current_net,:));  
        % 如果没有新的近邻被添加，则结束循环  
        if isempty(setdiff(next_ners, current_net))  
            break;  
        end  
        % 更新当前近邻集合  
        current_net = union(current_net,next_ners);  
    end  
    % 存储最终的最近邻集合  
    cell_net{i} = unique(current_net);  
end  
%unique_net用于存放
net_length= cellfun(@(x) length(x), cell_net, 'UniformOutput', false);  
net_length=cell2mat(net_length);
[net_length_sort_x,net_length_sort_y]=sort(net_length);
unique_length=unique(net_length_sort_x);
kk=0;
for i=1:length(unique_length)
   same_length=find(net_length_sort_x==unique_length(i));
   same_length_index=net_length_sort_y(same_length);
   A=[];
    for j=1:length(same_length_index)
        A(j,:)=cell_net{same_length_index(j)};
    end
    % 将每一行转换成字符串或其他唯一格式
     A_str = mat2cell(A, ones(size(A, 1), 1), size(A, 2));
     A_str = cellfun(@mat2str, A_str, 'UniformOutput', false);
% 找到唯一的行（转换后的）
     [unique_rows, ia, ~] = unique(A_str, 'stable');
% 提取唯一的原始数组
     unique_arrays = A(ia, :);
   for k=1:size(unique_arrays,1) 
       kk=kk+1;
       unique_net{kk,1}=unique_arrays(k,:);
   end
end
% 组合
arrays=unique_net;
% 输入的数组
% 初始化
bestSolution = [];
bestCount = 0;
% 循环遍历所有数组的可能组合
for i = 1:length(arrays)
    currentSolution = {arrays{i}};
    for j = i+1:length(arrays)
        intersectFound = false;
        for k = 1:length(currentSolution)
            if ~isempty(intersect(currentSolution{k}, arrays{j}))
                intersectFound = true;
                break;
            end
        end
        if ~intersectFound
            currentSolution{end+1} = arrays{j};
        end
    end
    % 计算当前组合的元素数量
    currentElements = unique([currentSolution{:}]);
    currentCount = length(currentElements);
    if currentCount > bestCount
        bestCount = currentCount;
        bestSolution = currentSolution;
    end
end

% 显示结果
disp(size(fea,1));
disp(size(A_unique_ners,1));
disp('最优组合包含的元素总数:');
disp(bestCount);
%% 开始聚类
options = [1.1 NaN 1e-7 NaN];
[centers,U] = fcm(fea,5,options);
maxU = max(U);
index1 = find(U(1,:) == maxU);
index2 = find(U(2,:) == maxU);
index3 = find(U(3,:) == maxU);
index4 = find(U(4,:) == maxU);
index5 = find(U(5,:) == maxU);
index_sum=length(index1)+length(index2)+length(index3)+length(index4)+length(index5);
% 得到最终聚类序号
cell_sort_num=cellnum_remain;
group=cell(5,1);
group{1,1}=cell_sort_num(index1);
group{2,1}=cell_sort_num(index2);
group{3,1}=cell_sort_num(index3);
group{4,1}=cell_sort_num(index4);
group{5,1}=cell_sort_num(index5);
%加载数据
VOLT=load("VOLT.mat");
VOLT=VOLT.VOLT;
CAP=load("CAP.mat");
CAP=CAP.CAP;
%
% group=load('fcm_group_dv_ed.mat');
% group=group.group;
%
for i=1:length(group)
    onegroup=group{i};
    %电压
    vol=VOLT(onegroup,[2 end]);
    %容量
    cap=CAP(onegroup,[2 end]);
    ALL_CK=[vol cap];
    if length(onegroup)==1
        ALL_talk_CK(i,:)=0;
    else
    ALL_talk_CK(i,:)=std(ALL_CK);
    end
    jiaquan(i)=length(onegroup);
end
   jiaquan1=jiaquan./sum(jiaquan);
   sum_in_CK=jiaquan1*ALL_talk_CK;

% 保存
%%
save('IF_V_a.mat','group');