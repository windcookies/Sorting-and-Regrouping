clear;clc
cd("C:\Users\11566\Desktop\z road\期刊\DV论文\matlab\1、base_fea_data的backup");
load('cycle.mat',"cycle_first");
%% 整理特征数据——DV曲线
%% DV和电压
% 开始计时
tic;

profile on
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

data=matrix_DV;
cv_x_curve = std(data)./mean(data);  % 计算变异系数
cv_curve_nored=normalize(cv_x_curve,'range');
% 保留所有极大值
[~, locs] = findpeaks(cv_curve_nored);
sites_DV=locs;
DV_ed=matrix_DV(:,sites_DV);
profile viewer


% 结束计时并显示时间
elapsed_time = toc;
fprintf('代码运行时间：%.2f 秒\n', elapsed_time);


% 查看工作区中的变量及其内存占用
vars = whos;

% 初始化总内存占用（字节）
total_memory = 0;

% 遍历所有变量并累加内存占用
for i = 1:length(vars)
    total_memory = total_memory + vars(i).bytes;
end

% 输出总内存占用（以字节、KB、MB、GB 为单位）
fprintf('总内存占用：%.0f 字节\n', total_memory);
fprintf('总内存占用：%.2f MB\n', total_memory / 1024^2);



