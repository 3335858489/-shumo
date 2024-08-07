% 获取桌面路径
desktopPath = fullfile(getenv('USERPROFILE'), 'Desktop');

% 导入高铁票价数据
filename_1 = fullfile(desktopPath, '一等座.xlsx'); 
[~, ~, raw1] = xlsread(filename_1);
railway_cost = cell2mat(raw1(2:end, 2:end)); % 高铁费用

% 导入高铁时间数据
filename_2 = fullfile(desktopPath, 'time.xlsx'); 
[~, ~, raw2] = xlsread(filename_2);
railway_time = cell2mat(raw2(2:end, 2:end)); % 高铁时间

% 导入景点
filename_3 = fullfile(desktopPath, '城市.xlsx');                    
range = 'A:A';               
choice_city = xlsread(filename_3, 1, range);  % 每个城市的门票费用

% 导入景点门票费用
filename_4 = fullfile(desktopPath, '景点费用.xlsx');                                
cost = xlsread(filename_4, 1, range);  % 每个城市的门票费用

% 导入景点游玩时间
filename_5 = fullfile(desktopPath, '景点游玩时间.xlsx');                                  
spot_time = xlsread(filename_5, 1, range);  % 每个城市的游玩时间（小时）

% 导入景点评分
filename_6 = fullfile(desktopPath, '景点评分.xlsx');                                  
spot_score = xlsread(filename_6, 1, range);  % 每个城市的评分

% 初始参数设置
City_num = 50; % 最令外国游客向往的50个城市
T = 144; % 总时间限制

% 定义城市名矩阵
[~, txt] = xlsread(fullfile(desktopPath, 'area.xlsx'));  % 读取城市间距离信息
city = txt(1, 2:end);
for i = 1:City_num   
    city{i} = city{i}(1:end-1);
end

% 初始化
best_Route = []; % 存储最佳路线的城市索引
max_Cities = 0;  % 初始化最多城市数
total_Cost = 0;  % 初始化总费用
total_Time = 0;  % 初始化总时间

% 广州的索引（假设广州是第一个城市）
start = 1;

% 初始化搜索参数
current = start;  
visited_City = [];    
remaining_Cities = 1:City_num;

while total_Time < T    % 当总时间小于限制时
    % 标记当前城市为已访问
    visited_City = [visited_City, current];
    remaining_Cities(remaining_Cities == current) = [];
    
    % 更新总时间和总成本
    if length(visited_City) > 1
        total_Time = total_Time + spot_time(current) + railway_time(visited_City(end-1), current);
        total_Cost = total_Cost + railway_cost(visited_City(end-1), current) + cost(current);
    else
        total_Time = total_Time + spot_time(current);
        total_Cost = total_Cost + cost(current);
    end
    
    % 检查是否超出时间限制
    if total_Time > T
        break;
    end
    
    % 寻找评分最高的城市
    best_City = -1;
    best_Score = -inf;
    
    % 遍历剩余城市，选择最优的下一个城市
    for i = remaining_Cities
        travel_Time = railway_time(current, i);
        visit_Time = spot_time(i);
        
        % 检查是否可以在时间限制内访问城市i
        if total_Time + travel_Time + visit_Time <= T
            % 计算综合评分（评分高度）
            score = spot_score(i);
            
            % 更新最优城市选择
            if score > best_Score
                best_Score = score;
                best_City = i;
            end
        end
    end
    
    % 如果没有找到合适的下一个城市，则结束搜索
    if best_City == -1
        break;
    end
    
    % 更新当前城市为选择的最佳城市
    current = best_City;
end

% 计算总时间
current_Time = 0;
for i = 1:length(visited_City)
    current_city = visited_City(i);

    % 加上当前城市的游玩时间
    current_Time = current_Time + spot_time(current_city);

    % 对于第一个城市，只加上游玩时间
    if i == 1
        continue;
    end

    % 加上从前一个城市到当前城市的高铁行驶时间
    previous_city = visited_City(i - 1);
    current_Time = current_Time + railway_time(previous_city, current_city);
end

% 更新最佳路线和最多城市数
if length(visited_City) > max_Cities
    best_Route = visited_City;
    max_Cities = length(visited_City);
    total_Time = current_Time;
end

% 创建 GUI 界面
fig = uifigure('Name', '旅行规划结果', 'Position', [100 100 600 400]);

% 显示总费用
uilabel(fig, 'Text', sprintf('总费用: %.2f', total_Cost), 'Position', [20 350 560 30], 'FontSize', 14);

% 显示总时间
uilabel(fig, 'Text', sprintf('总时间: %.2f 小时', total_Time), 'Position', [20 310 560 30], 'FontSize', 14);

% 显示游玩景点数量
uilabel(fig, 'Text', sprintf('游玩城市数量: %d', max_Cities + 1), 'Position', [20 270 560 30], 'FontSize', 14);

% 创建显示城市列表的表格
cityTable = uitable(fig, 'Position', [20 20 560 240]);

% 准备城市列表数据
numCities = length(best_Route);
cityData = cell(ceil((numCities + 1) / 10), 1); % 加1是因为要加上广州
for i = 1:10:(numCities + 1)
    endIdx = min(i+9, numCities + 1);
    if i == 1
        cityNames = ['广州', city(best_Route(1:endIdx-1))];
    else
        cityNames = city(best_Route(i-1:endIdx-1));
    end
    cityData{ceil(i/10)} = strjoin(cityNames, ' -> ');
end

% 设置表格数据
cityTable.Data = cityData;
cityTable.ColumnName = {'游玩城市路线'};
cityTable.ColumnWidth = {540};