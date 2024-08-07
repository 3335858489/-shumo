import os
import pandas as pd

desktop_path = os.path.join(os.path.join(os.environ['USERPROFILE']), 'Desktop')

# 文件路径
data_file = os.path.join(desktop_path, '50个城市票价数据.csv')
rating_file = os.path.join(desktop_path, 't1.xlsx')
output_file = os.path.join(desktop_path, 't3.csv')

# 读取“50个城市票价数据.csv”文件
data_df = pd.read_csv(data_file, encoding='gbk')

# 读取“t1.xlsx”文件，并获取评分数据
rating_df = pd.read_excel(rating_file)

# 假设 t1.xlsx 的第二列是匹配列，第三列是评分
# 将 t1.xlsx 的第二列和第三列提取出来
rating_df = rating_df.iloc[:, [1, 2]]
rating_df.columns = ['匹配列', '评分']

# 将评分数据合并到 data_df 中
merged_df = pd.merge(data_df, rating_df, left_on=data_df.columns[1], right_on='匹配列', how='left')

# 删除多余的匹配列
merged_df = merged_df.drop(columns=['匹配列'])