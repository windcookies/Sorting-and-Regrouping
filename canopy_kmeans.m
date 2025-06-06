clear;clc
path = 'C:\Users\11566\Desktop\z road\期刊\DV论文\matlab\4、canopy_kmeans的backup';  % 读取数据
cd(path);    % 把当前工作目录切换到指定文件夹
% 读取点
fea=load('base_fea_remain_ed.mat');
fea=fea.IC;
% cellnum_remain=1:252;
cellnum_remain=fea(:,1);
fea=fea(:,2:end);
%% CANOPY
%T1为创建新组的距离，T2为归类组内距离
%调整使canopies_group为cell——————————————————并确保yifenzu=cellnum_remain
T1=0.16;T2=0.06;
%计算所有点之间的距离
k2=1;
for i1=1:size(fea,1)
    for j1=i1+1:size(fea,1)
   distance_sum_points(k2,1)=norm(fea(i1,:)-fea(j1,:));
   k2=k2+1;
    end
end
sum_pingjun=mean(distance_sum_points);
sum_zhongwei=median(distance_sum_points);
sum_zuida=max(distance_sum_points);
% 聚类
% 初始化Canopies集合  
list=fea;
list_index=1:size(list,1);
list_index=list_index';
canopies = [];  
canopies_group={};
% 随机选择一个点作为起始点  
start_point = randi(size(list,1));  
k1=1;
canopies(k1,:)= list(start_point,:);  
canopies_group{k1} = start_point;  
list_index(start_point)=[];
% 迭代处理数据点集合  
cishu=0;
while ~isempty(list_index)&&cishu<=10000%控制迭代次数
    cishu=cishu+1;
    % 随机从list中抽取一个
      i0=randi(size(list_index,1)); 
      i=list_index(i0);
      points=list(i,:);
    % 查找距离当前点最近的Canopy  
      [~,idx] = min(pdist2( points, canopies)); 
      distance=norm(points - canopies(idx,:) );
    % 判断
       if distance <= T2%归入该组，从list删除           
            canopies_group{idx,1} = union(canopies_group{idx}, i); 
            list_index=setdiff(list_index,i);
       elseif distance > T1  %新的canopy
             k1=k1+1;
            list_index=setdiff(list_index,i);
            canopies(k1,:) = points; %新坐标
            canopies_group{k1,1}=i;%新索引
       
       else%介于T1和T2之间，归入该组，但不从list删除 
           canopies_group{idx,1} = union(canopies_group{idx}, i);  
       end

end  
%总结判断
   yifenzu= cellfun(@(x) x(:),canopies_group, 'UniformOutput', false);
   yifenzu=cell2mat(yifenzu);
   yifenzu=unique(yifenzu);
%% KMEANS
% 找出初始聚类中心
% data0= cellfun(@(x) x(:),canopies_group, 'UniformOutput', false);
% data=cell2mat(data0);
% data=sort(data);
% data=fea(data,:);
% k=length(canopies_group);
% data_canopy=cellfun(@(x) fea(x,:),canopies_group, 'UniformOutput', false); %获取点的数据
% center=cellfun(@(x) mean(x,1),data_canopy, 'UniformOutput', false);      %计算质心
% center=cell2mat(center);                                 %cell转化为矩阵
% distance_center=pdist2(fea,center);      % 计算每组点离质心的距离
% [~,index_center]=min(distance_center);

for j=36014:36014
    rng(j);
index_center=randperm(245,5);

% index_center=cellfun(@(x) x(randperm(length(x),1)),canopies_group, 'UniformOutput', false);
% index_center=cell2mat(index_center);
%——————————————————————————————————%
center=fea(index_center,:);
% 执行KMEANS
idx=kmeans(fea,5,"Start",center);
idx_new=1:252;
idx_new=idx_new';
for i=1:252
    if ismember(i,cellnum_remain)
        site=find(cellnum_remain==i);
        idx_new(i)=idx(site);
    else
        idx_new(i)=0;
    end
end
for id=1:5
 group{id,1}=find(idx_new==id);
end


%%  
%%  计算分组的电压和容量的标准差
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
tongji(j,:)=sum_in_CK;
end
%%
save('CK_IC.mat','group');






