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

% 使用退火算法优化路径
best_Route_SA = simulated_annealing(City_num, railway_time, spot_time, T);

% 使用人工蚁群优化算法优化路径
best_Route_ACO = ant_colony_optimization(City_num, railway_time, spot_time, T);

% 选择最优路径
if calculate_total_time(best_Route_SA, railway_time, spot_time) < calculate_total_time(best_Route_ACO, railway_time, spot_time)
    best_Route = best_Route_SA;
else
    best_Route = best_Route_ACO;
end

% 创建 GUI 界面
fig = uifigure('Name', '旅行规划结果', 'Position', [100 100 600 400]);

% 显示总费用
total_Cost = sum(cost(best_Route));
uilabel(fig, 'Text', sprintf('总费用: %.2f', total_Cost), 'Position', [20 350 560 30], 'FontSize', 14);

% 显示总时间
total_Time = calculate_total_time(best_Route, railway_time, spot_time);
uilabel(fig, 'Text', sprintf('总时间: %.2f 小时', total_Time), 'Position', [20 310 560 30], 'FontSize', 14);

% 显示游玩景点数量
uilabel(fig, 'Text', sprintf('游玩城市数量: %d', length(best_Route) + 1), 'Position', [20 270 560 30], 'FontSize', 14);

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