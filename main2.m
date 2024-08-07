% 四个判断矩阵，
A1=[1	2	1/8	1/4	1/2	1/5	1/6  %指标层的七大指标
    1/2	1	1/6	1/5	1/4	1/6	1/8
    6	8	1	3	4	2	1/2
    4	5	1/3	1	2	1/2	1/4
    2	4	1/4	1/2	1	1/3	1/5
    5	6	1/2	2	3	1	1/3
    6	8	2	4	5	3	1];        
  
A2=[1	1/2	1/3 
    2	1	1/2
    3	2	1 ] ;  %城市规模的二级指标
                     
A3=[1	2	4
    1/2	1	3
    1/4	1/3	1];    %环境环保的二级指标     

A4=[1	2	3 
    1/2	1	2
    1/3	1/2	1];    %气候的二级指标⽓   



% 判断是否通过一致性检验
A_list = {A1, A2, A3, A4};  % 将 A, A1, A2, A3 放入一个单元格数组

% 存储结果的变量
lambda_max_list = zeros(1, numel(A_list));  % 存储最大特征值
CR_list = zeros(1, numel(A_list));          % 存储一致性比例CR
weights_list = cell(1, numel(A_list));      % 存储权重向量
RI=[0,0,0.5275,0.8824,1.1075,1.2468,1.3394,1.4039];   

% 计算每个判断矩阵的最大特征值和一致性检验
for i = 1:numel(A_list)   %用循环判断四个矩阵
    A_current = A_list{i};
    
    lambda_max_current = max(eig(A_current));
    [~, n_current] = size(A_current);
    
    CI_current = (lambda_max_current - n_current) / (n_current - 1);
    CR_current = CI_current / RI(n_current);
    
    lambda_max_list(i) = lambda_max_current;
    CR_list(i) = CR_current;
    
    % 计算权重
    normalized_A_current = bsxfun(@rdivide, A_current, sum(A_current, 1)); % 按列归一化矩阵
    weights_current = sum(normalized_A_current, 2) / size(A_current, 1);   % 按行求和并除以n，得到权重
    weights_list{i} = weights_current;
    
    % 输出每个矩阵的一致性检验结果和权重
    disp(['判断矩阵 A', num2str(i), ':']);
    if CR_current < 0.10
        disp('通过一致性检验');
    else
        disp('未通过一致性检验');
    end
    
    disp(['矩阵 A', num2str(i), ' 的权重为：']);
    disp(weights_current);
    
    disp(' ');  % 空行分隔每个矩阵的输出结果
end

%设置计算完的指标权重
Weight = [0.03907 0.07091 0.12855 0.02446 0.01406 0.00538 0.01445 0.01445 0.07790 0.07790 0.03654 0.02016 0.01111 0.05700 0.05700 0.17555 0.17555]; 

% 导入数据
filename = 'data.xlsx';

% 设置读取选项
opts = detectImportOptions(filename);
opts.VariableNamingRule = 'preserve';  % 保留原始列标题作为表变量名称

% 使用readtable函数导入xlsx文件
dataTable = readtable(filename, opts);

% 提取第一列（汉字列）和其他列（数字列）
city_data = dataTable{:, 1};  % 提取第一列城市数据为列向量
num_data = dataTable{:, 2:end};  % 提取第二列及其后的所有列数据为矩阵或数组

% 计算每个指标的最大值和最小值
min_num = min(num_data);
max_num = max(num_data);

%数据标准化
Standard = (num_data - min_num) ./ (max_num - min_num);

%对于PM2.5等数据越低越好，气温等数据越适中越好，在这里进行处理 
column_data1 = Standard(:, 5);  %需要处理第5列数据PM2.5
transformed_column1 = 1 - column_data1;  
Standard(:, 5) = transformed_column1;  %将变换后的列数据替换回标准化矩阵 Standard

column_data2 = Standard(:, 12); %同理处理第12列数据降水量
transformed_column2 = 1 - column_data2;
Standard(:, 12) = transformed_column2;

column_data3 = Standard(:, 11); %需要处理第11列数据气温
transformed_column3 = 1 - 2 * abs(column_data3 - 0.5); %越靠近中值分越高
Standard(:, 11) = transformed_column3;% 将处理后的列数据替换回原始矩阵的相应列

column_data4 = Standard(:, 13); %同理处理第13列数据湿度
transformed_column4 = 1 - 2 * abs(column_data4 - 0.5); %越靠近中值分越高
Standard(:, 13) = transformed_column4;

% 计算综合得分
sum_score = Standard * Weight';

% 将 city_data 和 sum_score 合并为一个表
dataTable = table(city_data, sum_score, 'VariableNames', {'City', 'Score'});

% 对表格按 Score 列进行降序排序并提取前50项
sortedTable = sortrows(dataTable, 'Score', 'descend');
top_50 = sortedTable(1:min(50, height(sortedTable)), :);

% 将结果保存为 CSV 文件
outputFilename = fullfile(getenv('USERPROFILE'), 'Desktop', '问题2.csv');
fid = fopen(outputFilename, 'w');
if fid == -1
    error('无法打开文件 %s 进行写入', outputFilename);
end

% 将排名前50的城市数据写入 CSV 文件
writetable(top_50, outputFilename, 'Delimiter', ',');