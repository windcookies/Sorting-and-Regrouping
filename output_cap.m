%记录下每次的放电上下限，找到公共电压区间
%记录公共电压区间放电量
%形成252行 8列的double,为后续计算容量衰减率做准备
clear;clc
path = 'C:\Users\11566\Desktop\毕业论文书写\第一章\materials\计算_容量和电压';  % 读取数据
cd(path);    %把当前工作目录切换到指定文件夹
%% 读取公共放电区间
file = dir(fullfile(path,'*.mat*')); %先读数据
for i=1:8
filename=file(i).name;
record=load(filename);
record_data=record.data_everday;
bat=record_data{1};
current=bat(:,2);
start=find(current<0,1);%起点
current_cut=current(start:end);
stop=find(current_cut==0,1)+start-2;%终点
  for i1=1:252
bat=record_data{i1};
volt=bat(start:stop,3);
V_start(i1,i)=volt(1);
V_end(i1,i)=volt(end);
  end
end

%% 起止电压  3.222- 3.299（3.321，剔除几个异常低的电池）
% 平均从.148-.345
% 中位从.161-.339
for i=1:8

    work_start=V_start(:,i);
    V_day(i,1)=min(work_start);
    work_end=V_end(:,i);
    V_day(i,2)=max(work_end);

end



%% 开始读取放电容量
file = dir(fullfile(path,'*.mat*')); %先读数据
for i=8:8
filename=file(i).name;
record=load(filename);
record_data=record.data_everday;
bat=record_data{1};
current=bat(:,2);
start=find(current<0,1);%起点
current_cut=current(start:end);
stop=find(current_cut==0,1)+start-2;%终点
  for i1=1:252
bat=record_data{i1};
volt=bat(start:stop,3);
curt=bat(start:stop,2);
time=bat(start-1:stop,1);
cap=curt.*diff(time);
[~,cut_1]=min(abs(volt-3.299));
[~,cut_2]=min(abs(volt-3.222));
cap_sum=cumsum(cap)./3600;
cap_cut=sum(cap(cut_1:cut_2))./3600;
CAP(i1,i)=abs(cap_cut);
  end
end
%% 保存
save('CAP.mat','CAP');
%% CAP 拟合
%x=[5 13 73 128 193 234 283 340];  %按照次数来
x=[0 5 33 31 37 22 27 29];        %按照天数来
x=cumsum(x)+1;
x_index=1:x(end);
for i=1:252

  y = CAP(i,:);
  p = polyfit(x,y,1);
  y_all=p(1).*x_index+p(2);
  Y(i,:)=y_all;
end
%% 放电Q-V拟合
%% 调节v0，使波动消除
%正序
volt;

v2_1=volt;

v0_a=unique(v2_1);
for i0=1:length(volt)
v1=volt(1:i0);
v2_1(i0,1)=min(v1);%处理后的电压序列
end
%反序
v2_2=volt;
for i0=1:length(volt)
v1=volt(end+1-i0:end);
v2_2(length(volt)+1-i0,1)=max(v1);%处理后的电压序列
end

v3=(v2_2+v2_1)./2;% 顺逆序电压取平均
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

q_a=cap_sum(index_a_1);

%% 滤波——得先插值，再光滑smoothdata，
% 插值为与连续电压一一对应的，再光滑。
v4=min(v3_a):0.001:max(v3_aa);
ic4 =-interp1(v3_a,q_a,v4,'linear');%更优于三次样条插值



