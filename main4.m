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
City_num = 285; 
T = 84; % 总时间限制

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

% 以每个城市为起点进行搜索
for start = 1:City_num
    if choice_city(start)==0
        continue;
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
            if choice_city(i)==0
                continue;
            end
            travel_Time = railway_time(current, i);
            visit_Time = spot_time(i);
            
            % 检查是否可以在时间限制内访问城市i
            if total_Time + travel_Time + visit_Time <= T
                % 计算综合评分（评分高度减去交通费用和门票费用）
                score = spot_score(i) - railway_cost(current, i) - cost(i);
                
                % 更新最优城市选择
                if score > best_Score
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
    
    % 更新最佳路线和最小成本
    if current_solution_cost < min_Cost
        best_Route = visited_City;
        min_Cost = current_solution_cost;
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

    % 更新最佳时间
    if current_Time > best_Time
        best_Time = current_Time;
    end
end

% 输出结果
fprintf('游玩城市: ');
fprintf('广州, '); 
fprintf('%s, ', city{best_Route});
fprintf('\n');
fprintf('游玩城市数量: %d\n', length(best_Route) + 1); % 包括广州
fprintf('总费用: %f\n', min_Cost);
fprintf('总时间: %f\n', best_Time + 60); % 