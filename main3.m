function main3
    % 创建图形界面
    fig = uifigure('Name', '旅游路线规划', 'Position', [100 100 600 400]);

    % 创建输入框和标签
    lbl = uilabel(fig, 'Position', [20 350 100 22], 'Text', '起始城市:');
    txt = uieditfield(fig, 'text', 'Position', [120 350 100 22], 'Value', 'Guangzhou');

    % 创建按钮
    btn = uibutton(fig, 'Position', [250 350 100 22], 'Text', '开始规划', ...
        'ButtonPushedFcn', @(btn, event) planRoute(txt.Value));

    % 创建表格来显示路线
    uit = uitable(fig, 'Position', [20 50 560 200]);

    % 创建标签来显示总花费时间和费用
    lblTime = uilabel(fig, 'Position', [20 270 200 22], 'Text', '总花费时间: ');
    lblCost = uilabel(fig, 'Position', [20 300 200 22], 'Text', '门票和交通的总费用: ');

    % 规划路线的函数
    function planRoute(startCity)
        % 读取数据
        filename = fullfile(getenv('USERPROFILE'), 'Desktop', 'dataset.xlsx');
        data = readtable(filename);

        % 筛选有高铁站的城市
        citiesWithHighSpeedRail = data(data.Gaotie == 1, :);

        % 初始化变量
        maxTime = 144; % 144小时
        currentTime = 0;
        totalCost = 0;
        visitedCities = {startCity};
        currentCity = startCity;

        % 定义权重参数
        alpha = 0.5; % 旅行时间重要性权重
        beta = 0.5; % 景点评分重要性权重

        % 游玩路线规划
        while currentTime < maxTime
            % 找到当前城市的所有邻近城市
            neighbors = citiesWithHighSpeedRail(strcmp(citiesWithHighSpeedRail.city, currentCity), :);

            % 排除已经访问过的城市
            neighbors = neighbors(~ismember(neighbors.Nearcity, visitedCities), :);

            if isempty(neighbors)
                break;
            end

            % 选择综合游玩体验最好的城市
            scores = neighbors.score;
            travelTimes = neighbors.GTtime;
            [~, idx] = max(alpha * scores - beta * travelTimes);
            nextCity = neighbors.Nearcity{idx};

            % 更新时间和费用
            travelTime = neighbors.GTtime(idx);
            ticketCost = neighbors.Menpiao(idx);
            travelCost = neighbors.GTfei(idx);

            if currentTime + travelTime > maxTime
                break;
            end

            currentTime = currentTime + travelTime;
            totalCost = totalCost + ticketCost + travelCost;

            % 更新当前城市和访问过的城市列表
            currentCity = nextCity;
            visitedCities{end+1} = currentCity;
        end

        % 更新表格数据
        dataTable = table(visitedCities', 'VariableNames', {'城市'});
        dataTable.Menpiao = zeros(height(dataTable), 1);
        dataTable.GTfei = zeros(height(dataTable), 1);

        for i = 2:height(dataTable)
            city = dataTable.city{i};
            idx = find(strcmp(citiesWithHighSpeedRail.Nearcity, city));
            dataTable.Menpiao(i) = citiesWithHighSpeedRail.Menpiao(idx);
            dataTable.GTfei(i) = citiesWithHighSpeedRail.GTfei(idx);
        end

        uit.Data = dataTable;

        % 更新标签
        lblTime.Text = sprintf('总花费时间: %.2f 小时', currentTime);
        lblCost.Text = sprintf('门票和交通的总费用: %.2f 元', totalCost);

        % 可视化处理
        figure;

        % 绘制旅游路线
        subplot(2, 1, 1);
        routeStr = strjoin(visitedCities, ' -> ');
        text(0.1, 0.5, routeStr, 'FontSize', 12);
        title('旅游路线');
        axis off;

        % 绘制总花费时间和费用
        subplot(2, 1, 2);
        uitable('Data', dataTable{:,:}, 'ColumnName', dataTable.Properties.VariableNames, ...
            'RowName', [], 'Units', 'Normalized', 'Position', [0, 0, 1, 0.4]);

        % 显示总花费时间和费用
        annotation('textbox', [0.1, 0.45, 0.8, 0.05], 'String', ...
            sprintf('总花费时间: %.2f 小时, 门票和交通的总费用: %.2f 元, 可以游玩的景点数量: %d', ...
            currentTime, totalCost, length(visitedCities) - 1), 'FontSize', 12, 'EdgeColor', 'none');
    end
end