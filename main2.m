% 四个判断矩阵，
A1 = [1 5 7 2 4 3 1/2  %指标层1的判断矩阵
    1/5 1 2 1/4 1/2 1/4 1/6
    1/7	1/2	1 1/5 1/3 1/5 1/8
    1/2 4 5 1 3 2 1/3
    1/4	2 3 1/3	1 1/2 1/5
    1/3	4 5 1/2	2 1 1/4
    2 6 8 3 5 4 1];        
  
A2 = [1 2 3 
    1/2	1 2
    1/3	1/2 1 ] ;  %城市规模的二级指标
                     
A3 = [1 2 3 
    1/2	1 2
    1/3	1/2 1];    %环境环保的二级指标     

A4 = [1 2 3 
    1/2	1 2
    1/3	1/2 1];    %气候的二级指标⽓   



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
Weight=[0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.1,1.2,1.3,1.4,1.5,1.6,1.7];  %假设的数值

%计算每个指标的最大值和最小值

%数据标准化


