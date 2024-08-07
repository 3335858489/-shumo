% 初始参数设置
City_num = 285; 
T = 144; % 总时间限制

% 获取桌面路径
desktopPath = fullfile(getenv('USERPROFILE'), 'Desktop');

% 导入高铁票价数据
filename_1 = fullfile(desktopPath, '二等座.xlsx'); 
[~, ~, raw1] = xlsread(filename_1);
railway_cost = cell2mat(raw1(2:end, 2:end)); % 高铁费用

% 导入高铁时间数据
filename_2 = fullfile(desktopPath, 'time.xlsx'); 
[~, ~, raw2] = xlsread(filename_2);
railway_time = cell2mat(raw2(2:end, 2:end)); % 高铁时间

% 导入机场数据
filename_3 = fullfile(desktopPath, 'airport.xlsx'); 
airport = xlsread(filename_3, 1, 'A1:IV300');

% 导入景点门票费用
filename_4 = fullfile(desktopPath, '景点费用.xlsx');                    
range = 'A:A';               
cost = xlsread(filename_4, 1, range);  % 每个城市的门票费用

% 导入景点游玩时间
filename_5 = fullfile(desktopPath, '景点游玩时间.xlsx');                                  
spot_time = xlsread(filename_5, 1, range);  % 每个城市的游玩时间（小时）

% 导入景点评分
filename_6 = fullfile(desktopPath, '景点评分.xlsx');                                  
spot_score = xlsread(filename_6, 1, range);  % 每个城市的评分

% 定义城市名矩阵
[~, txt] = xlsread(fullfile(desktopPath, 'area.xlsx'));  % 读取城市间距离信息
city = txt(1, 2:end);
for i = 1:City_num   
    city{i} = city{i}(1:end-1);
end

% 初始化
best_Route = []; % 存储最佳路线的城市索引
min_Cost = inf;   % 初始化成本为无穷大
best_Time = 0;    % 初始化最佳时间为0

% 模拟退火算法参数设置
initial_temperature = 100;  % 初始温度
final_temperature = 1;      % 最终温度
cooling_rate = 0.98;        % 冷却速率

current_temperature = initial_temperature;
current_solution = [];
current_cost = inf;

while current_temperature > final_temperature
    % 以每个城市为起点进行搜索
    start = randi(City_num);  % 随机选择起点
    while airport(start) == 0
        start = randi(City_num);  % 确保起点有机场
    end
    
    % 初始化搜索参数
    current = start;  
    visited_City = [];    
    total_Time = 0;
    total_Cost = 0;
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
 
        % 寻找评分最高、交通费用最低且景点门票费用最低的城市
        best_City = -1;
        best_Score = -inf;
        best_Cost = inf;
        
        % 遍历剩余城市，选择最优的下一个城市
        for i = remaining_Cities
            travel_Time = railway_time(current, i);
            visit_Time = spot_time(i);
            
            % 检查是否可以在时间限制内访问城市i
            if total_Time + travel_Time + visit_Time <= T
                % 计算综合评分（评分高度减去交通费用和门票费用）
                score = spot_score(i) - railway_cost(current, i) - cost(i);
                
                % 更新最优城市选择
                if score > best_Score || (score == best_Score && railway_cost(current, i) < best_Cost)
                    best_Score = score;
                    best_City = i;
                    best_Cost = railway_cost(current, i);
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
 
    % 计算当前解的成本
    current_solution_cost = total_Cost;
    
    % 接受或拒绝新解
    if current_solution_cost < current_cost
        current_solution = visited_City;
        current_cost = current_solution_cost;
    else
        delta_cost = current_solution_cost - current_cost;
        acceptance_probability = exp(-delta_cost / current_temperature);
        if rand() < acceptance_probability
            current_solution = visited_City;
            current_cost = current_solution_cost;
        end
    end
    
    % 更新温度
    current_temperature = current_temperature * cooling_rate;
end

% 更新最佳路线和最小成本
best_Route = current_solution;
min_Cost = current_cost;
best_Time = 0;  % 如果需要计算最佳时间，可以在此处根据最佳路线重新计算总时间

% 输出结果
fprintf('入境城市: %s\n', city{best_Route(1)});
fprintf('游玩城市: ');
fprintf('%s, ', city{best_Route});
fprintf('\n');
fprintf('总费用: %f\n', min_Cost);