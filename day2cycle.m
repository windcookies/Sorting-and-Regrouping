clear;clc
path = "E:\eledata";  % 读取数据
cd(path);    %把当前工作目录切换到指定文件夹
file = dir(fullfile(path,'*.mat')); 
FileNames = {file.name}';  %转换为n行1列的cell数据
[s,~] = sort_nat(FileNames);
%% 依次读取每天，转换为cycle-充电段
day_num=length(s);
cycle_all=cell(day_num*2,2);


for i=1:day_num
% 读取mat文件
name=s{i};
Work=importdata(name);
% 提取第一个cell，找到时间序列，寻找拐点
work=Work{1};
second_t=work(:,1);
hour_t=work(:,1)./3600;
[~,door1]=min(abs(hour_t-8));%8点充电必结束
[~,door2]=min(abs(hour_t-19));%19点应在放电

I=work(:,2);
V=work(:,3);

process1=V(1:door1);
site1=find(I>0,1);%第一充起始
[~,site2]=max(process1);%第一充结束
if site1>site2%一些异常情况
    continue
end
process2=V(door1:door2);% 这段时间，包括了第二充

[~,site30]=min(process2);% 第一放结束
[~,site4]=max(process2);% 第二充结束
site30=door1-1+site30;
site4=door1-1+site4;
process3=I(site30:site4);% 第一放结束到第二充结束
site3=find(process3>0,1);
site3=site30-1+site3;% 第二充开始

   for j=1:252%把252个电池放进去
       work=Work{j};
cycle_1{j,1}=work(site1:site2,:);
cycle_2{j,1}=work(site3:site4,:);
   end
cycle_all{i*2-1,1}=cycle_1;
cycle_all{i*2-1,2}=name(1:10);
cycle_all{i*2,1}=cycle_2;
cycle_all{i*2,2}=name(1:10);

end
%% 整理 删除

del=[];
for i=1:length(cycle_all)
%  将时间重新整理
Work=cycle_all{i,1};
if isempty(Work)
    del=[del i ];
    continue
end
work=Work{1};
if isempty(work)
    del=[del i ];
    continue
end

baset=work(1,1);
work(:,1)=work(:,1)-baset+1;

% 小于1.5小时的删除
t=work(:,1)./3600;
dt=t(end)-t(1);
   if dt<1.5
      del=[del i ];
   end
  
   for j=1:252
z=Work{j,1};
z(:,1)=work(:,1);
Work{j,1}=z;
   end
  cycle_all{i,1}=Work; 
end
%%  
cycle_processed=cycle_all;
cycle_processed(del,:)=[];
%% 描述  大于2GB
save('341cycle.mat','cycle_processed','-v7.3');









