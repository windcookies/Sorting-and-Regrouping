%记录下每次平均放电电压
%形成252行 8列的double
%可据此计算252与平均放电电压的差
clear;clc
path = 'C:\Users\11566\Desktop\毕业论文书写\第一章\materials\计算_容量和电压';  % 读取数据
cd(path);    %把当前工作目录切换到指定文件夹
%% 读取放电区间
file = dir(fullfile(path,'*.mat*')); %先读数据
for i=1:1
filename=file(i).name;
record=load(filename);
record_data=record.data_everday;
bat=record_data{1};
current=bat(:,2);
start=find(current<0,1);%起点
current_cut0=current(start:end);
stop=find(current_cut0==0,1)+start-2;%终点
current_cut1=current(start:stop);
  for i1=1:252
bat=record_data{i1};
volt=bat(start:stop,3);
v_ave(i1,i)=mean(volt);
volt1=bat(1:start,3);
vvolt(:,i1)=volt1';
  end
end

%% 保存
VOLT=v_ave;
save('VOLT.mat','VOLT');










