filename = fullfile(getenv('USERPROFILE'), 'Desktop', 't1.csv');

% 使用 readtable 读取数据
data = readtable(filename);

% 提取城市、景点和评分列
cities = data{:, 1}; % 第一列是城市名称
sites = data{:, 2}; % 第二列是景点名称
scores = data{:, 3}; % 第三列是评分

% 找到最高评分
maxScore = max(scores);

% 计算获得最高评分的景点总数
numMaxScoreSites = sum(scores == maxScore);

% 识别拥有最高评分景点的城市
uniqueCities = unique(cities); % 获取城市列表
cityCount = zeros(length(uniqueCities), 1); % 存储每个城市拥有的最高评分景点数量

for i = 1:length(uniqueCities)
    citySites = scores(strcmp(cities, uniqueCities{i})); % 选择该城市的所有景点评分
    cityCount(i) = sum(citySites == maxScore); % 计算该城市中获得最高评分的景点数量
end

% 创建一个新数组，包含城市名称和对应的最高评分景点数量
cityScores = [uniqueCities, num2cell(cityCount)];

% 找出拥有最高评分景点数量最多的前10个城市
% 根据第二列（最高评分景点数量）进行排序
[~, idx] = sort(cell2mat(cityScores(:, 2)), 'descend');
sortedCityScores = cityScores(idx, :);

% 取前10个城市
top10Cities = sortedCityScores(1:min(10, end), :);

% 找到获得最高评分的景点名称和对应的城市
maxScoreSites = sites(scores == maxScore);
maxScoreCities = cities(scores == maxScore);

% 将结果保存为 CSV 文件
outputFilename = fullfile(getenv('USERPROFILE'), 'Desktop', '问题1.csv');
fid = fopen(outputFilename, 'w');
if fid == -1
    error('无法打开文件 %s 进行写入', outputFilename);
end

% 写入最高评分和获得最高评分的景点总数
fprintf(fid, '所有城市中所有景点评分的最高分（BestScore，简称BS）是：,%d\n', maxScore);
fprintf(fid, '全国有,%d,个景点获评了这个最高评分（BS）。\n\n', numMaxScoreSites);

% 写入获得最高评分的景点名称和对应的城市
fprintf(fid, '对应的城市,获得最高评分的景点名称\n');
for row = 1:length(maxScoreSites)
    fprintf(fid, '%s,%s\n', maxScoreCities{row}, maxScoreSites{row});
end

fprintf(fid, '\n');

% 写入前10个城市和最高评分景点数量
fprintf(fid, '前10个城市,最高评分景点数量\n');
for row = 1:size(top10Cities, 1)
    fprintf(fid, '%s,%d\n', top10Cities{row, :});
end

fprintf(fid, '\n');

% 写入所有城市和最高评分景点数量
fprintf(fid, '所有城市,最高评分景点数量\n');
for row = 1:size(sortedCityScores, 1)
    fprintf(fid, '%s,%d\n', sortedCityScores{row, :});
end

fclose(fid);

% 查找缺少的城市
allCities = unique(cities); % 原始数据中的所有城市
missingCities = setdiff(allCities, uniqueCities); % 找出缺少的城市

% 打印缺少的城市
fprintf('缺少的城市:\n');
for i = 1:length(missingCities)
    fprintf('%s\n', missingCities{i});
end