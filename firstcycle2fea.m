clear;clc
cd("C:\Users\11566\Desktop\z road\期刊\DV论文\matlab\1、base_fea_data的backup");
load('cycle.mat',"cycle_first");
%% 整理特征数据——矩阵形式——容量、IC特征、DV曲线、电压曲线；
%% DV和电压
data=cycle_first(1);
data_cell=data{1};
% 计算出容量，以及每AH容量的位置
example=data_cell{1};
time_seq=example(:,1);
i_seq=example(:,2);
q=i_seq(1:end).*[5;diff(time_seq)]./3600;
Q=cumsum(q);
Q_max=abs(floor(Q(end)));
Q_site=zeros(length(Q_max),1);
for ii=1:Q_max
[~,Q_site(ii,1)]=min(abs(abs(Q)-ii));
end
% 提取电压序列
for i=1:252
    work=data_cell{i};
    v0=work(:,3); 
%正序
  v2_1=v0;
  for i0=1:length(v0)
  v1=v0(1:i0);
  v2_1(i0,1)=max(v1);%处理后的电压序列
  end
%反序
  v2_2=v0;
  for i0=1:length(v0)
  v1=v0(end+1-i0:end);
  v2_2(length(v0)+1-i0,1)=min(v1);%处理后的电压序列
  end
  v2=(v2_1+v2_2)./2;
V(:,i)=v2;
end
matrix_V=V';
%----------------提取温度
for i=1:252
    work=data_cell{i};
    T(:,i)=work(:,4); 
end
matrix_T=T';
%————————————————————温度
% 提取不重复电压序列的应有差值
for i=1:252
    v3=V(:,i);
    v3_a=unique(v3);% 找到不重复值，目的是避免ΔV=0
% 对不重复值插值
index_a=zeros(1,length(v3_a));
for i_a=1:length(v3_a)
    v3_aaa=v3_a(i_a);
    index_a(i_a)=find(v3==v3_aaa,1);
end% 首先找到顺序的
%之后找到平均位置，相当于顺逆序取平均
diff_index_a=diff(index_a);
index_a_1=index_a;
for ii_a=1:length(diff_index_a)-1
      index_a_1(ii_a)=floor((index_a(ii_a+1)+index_a(ii_a))./2);
end
%通过索引找到对应的Q
v3_a;             % unique_v
q_a=Q(index_a_1); % unique_v对应的Q
%求DV
dv0=diff(v3_a)./diff(q_a);%dv0
q_x0=0.5*q_a(1:end-1)+0.5*q_a(2:end);%dv0对应的横坐标
dv1 = interp1(q_x0,dv0,1:Q_max-1,'linear');
DV(:,i)=dv1;
IC_curve=[];
IC_curve(:,2)=diff(q_a)./diff(v3_a);
IC_curve(:,1)=0.5*v3_a(1:end-1)+0.5*v3_a(2:end);%对应的电压\
IC_cell{i,1}=IC_curve;
end
matrix_DV=DV';
%% IC特征——低峰电压、IC值和高峰电压、IC值
load('IC_data.mat','IC');
matrix_IC=IC;
%% 容量——————————————————————————————%
%% 起止电压  3.222- 3.299
filename='2021-11-07.mat';
record=load(filename);
record_data=record.data_everday;
bat=record_data{1};
current=bat(:,2);
start=find(current<0,1);%起点
current_cut=current(start:end);
stop=find(current_cut==0,1)+start-2;%终点
  for i1=1:252
bat=record_data{i1};
curt=bat(start:stop,2);
time=bat(start-1:stop,1);
cap=curt.*diff(time);
cap_sum=cumsum(cap)./3600;
volt=bat(start:stop,3);
%————————————————————————————————%调节电压波动
%正序
  volt_1=volt;
  for i0=1:length(volt)
  v1=volt(1:i0);
  volt_1(i0,1)=min(v1);%处理后的电压序列
  end
%反序
  volt_2=volt;
  for i0=1:length(volt)
  v1=volt(end+1-i0:end);
  volt_2(length(volt)+1-i0,1)=max(v1);%处理后的电压序列
  end
  volt_ed=(volt_1+volt_2)./2;
%————————————————————————————————%获得unique电压，并将容量对应
   volt_a=unique(volt_ed);% 找到不重复值
   index_a=zeros(1,length(volt_a));
for i_a=1:length(volt_a)
    volt_aaa=volt_a(i_a);
    index_a(i_a)=find(volt_ed==volt_aaa,1);
end% 首先找到顺序的
%之后找到平均位置，相当于顺逆序取平均
diff_index_a=diff(index_a);
index_a_1=index_a;
for ii_a=1:length(diff_index_a)-1
      index_a_1(ii_a)=floor((index_a(ii_a+1)+index_a(ii_a))./2);
end
%通过索引找到对应的Q
volt_a;             % unique_v
cap_a=cap_sum(index_a_1);   % unique_v对应的Q

[~,cut_1]=min(abs(volt_a-3.299));
[~,cut_2]=min(abs(volt_a-3.222));

CAP(i1,1)=cap_a(cut_1)-cap_a(cut_2);
  end
matrix_CAP=CAP;
%% 保存
save('base_fea.mat','matrix_CAP','matrix_IC','matrix_DV','matrix_V','matrix_T','IC_cell','ICC','all_vol');

%————————————————————————————————————————————————————————————————————%
%% 验证是否有空集
% B = isnan(Q_site);  
% % 使用sum函数计算NaN元素的数量  
% numNaNs = sum(B(:));  
% % 显示NaN元素的数量  
% disp(numNaNs);
% %%  查看一波
% z1z=sum(v0);
% z2z=sum(v2_1);
% z3z=sum(v2_2);
% z4z=sum(v2);
% AA=[v0 v2_1 v2_2 v2];
% plot(AA,'linewidth',2);


