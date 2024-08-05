import pandas as pd
import os
import re

# 获取桌面路径
desktop_path = os.path.join(os.path.join(os.environ['USERPROFILE']), 'Desktop')

# 附件文件夹路径
attachments_folder = os.path.join(desktop_path, '附件')

# 获取附件文件夹中所有 CSV 文件的路径
csv_files = [os.path.join(attachments_folder, f) for f in os.listdir(attachments_folder) if f.endswith('.csv')]

# 初始化一个空的数据框用于存储合并结果
merged_df = pd.DataFrame()

# 遍历所有 CSV 文件并合并第一列和第七列
for file_path in csv_files:
    # 打印文件路径以确保路径正确
    print(f"Processing file: {file_path}")
    
    # 读取 CSV 文件
    df = pd.read_csv(file_path, encoding='utf-8')
    
    # 选择需要的列（第一列和第七列）
    selected_columns = df.iloc[:, [0, 6]]
    
    # 将第七列转换为数值类型，无法转换的设置为NaN
    selected_columns.iloc[:, 1] = pd.to_numeric(selected_columns.iloc[:, 1], errors='coerce')
    
    # 过滤第七列数据，只保留大于等于0的数据
    selected_columns = selected_columns[selected_columns.iloc[:, 1] >= 0]
    
    # 提取文件名中的汉字部分
    file_name = os.path.basename(file_path)
    chinese_characters = ''.join(re.findall(r'[\u4e00-\u9fff]+', file_name))
    
    # 添加文件名列
    selected_columns.insert(0, '文件名', chinese_characters)
    
    # 合并到结果数据框
    merged_df = pd.concat([merged_df, selected_columns], axis=0)

# 将合并后的结果保存到新的 CSV 文件中
output_file = os.path.join(desktop_path, '评分数据_处理后.csv')
merged_df.to_csv(output_file, index=False, encoding='utf-8')

print(f"合并完成并保存到 {output_file} 文件中。")