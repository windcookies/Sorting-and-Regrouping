% 基于距离的剔除代码
clear;clc
cd("C:\Users\11566\Desktop\z road\期刊\DV论文\matlab\2、base_fea_remain的backup");
load('base_fea_ed.mat','IC_ed','DV_ed','V_ed');
cishu=1;
%% IC
% 得到剔除电池的编号（cell_del）和保留电池的编号(cell_remain)
% 先明确何种特征
data=IC_ed;
% 距离矩阵
DIST=zeros(252,252);
% 欧式距离计算
for i=1:251
    vec1=data(i,:);
    for j=i+1:252
     vec2=data(j,:);
     DIST(i,j)=norm(vec1-vec2);
     DIST(j,i)=DIST(i,j);
    end
end
% 平均距离
mean_dist=mean(DIST);
cell_sort_num=1:252;
value_del=[];
for j=1:cishu
   std_dist=std(mean_dist);
   mean_mean_dist=mean(mean_dist);
   %三西格玛原则
   x=find(mean_dist>mean_mean_dist+3*std_dist);
   y=find(mean_dist<mean_mean_dist-3*std_dist);
   %剩余的电池序号和距离矩阵
   value_del=unique([value_del mean_dist([x y])]);
   mean_dist=setdiff(mean_dist,value_del);
   j=j+1;
end
idx = ismember(mean(DIST), mean_dist);  
cell_sort_num(idx)=[];  
cell_del=cell_sort_num;
cell_remain=setdiff(1:252,cell_del);
IC=[cell_remain' IC_ed(cell_remain,:)];
%% DV
% 得到剔除电池的编号（cell_del）和保留电池的编号(cell_remain)
% 先明确何种特征
data=DV_ed;
% 距离矩阵
DIST=zeros(252,252);
% 欧式距离计算
for i=1:251
    vec1=data(i,:);
    for j=i+1:252
     vec2=data(j,:);
     DIST(i,j)=norm(vec1-vec2);
     DIST(j,i)=DIST(i,j);
    end
end
% 平均距离
mean_dist=mean(DIST);
cell_sort_num=1:252;
value_del=[];
for j=1:cishu
   std_dist=std(mean_dist);
   mean_mean_dist=mean(mean_dist);
   %三西格玛原则
   x=find(mean_dist>mean_mean_dist+3*std_dist);
   y=find(mean_dist<mean_mean_dist-3*std_dist);
   %剩余的电池序号和距离矩阵
   value_del=unique([value_del mean_dist([x y])]);
   mean_dist=setdiff(mean_dist,value_del);
   j=j+1;
end
idx = ismember(mean(DIST), mean_dist);  
cell_sort_num(idx)=[];  
cell_del=cell_sort_num;
cell_remain=setdiff(1:252,cell_del);
DV=[cell_remain' DV_ed(cell_remain,:)];
%% V
% 得到剔除电池的编号（cell_del）和保留电池的编号(cell_remain)
% 先明确何种特征
data=V_ed;
% 距离矩阵
DIST=zeros(252,252);
% 欧式距离计算
for i=1:251
    vec1=data(i,:);
    for j=i+1:252
     vec2=data(j,:);
     DIST(i,j)=norm(vec1-vec2);
     DIST(j,i)=DIST(i,j);
    end
end
% 平均距离
mean_dist=mean(DIST);
cell_sort_num=1:252;
value_del=[];
for j=1:cishu
   std_dist=std(mean_dist);
   mean_mean_dist=mean(mean_dist);
   %三西格玛原则
   x=find(mean_dist>mean_mean_dist+3*std_dist);
   y=find(mean_dist<mean_mean_dist-3*std_dist);
   %剩余的电池序号和距离矩阵
   value_del=unique([value_del mean_dist([x y])]);
   mean_dist=setdiff(mean_dist,value_del);
   j=j+1;
end
idx = ismember(mean(DIST), mean_dist);  
cell_sort_num(idx)=[];  
cell_del=cell_sort_num;
cell_remain=setdiff(1:252,cell_del);
V=[cell_remain' V_ed(cell_remain,:)];
%% 保存
save('base_fea_remain_ed.mat','IC','DV','V');
