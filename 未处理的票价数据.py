import pandas as pd
import os

# 获取桌面路径
desktop_path = os.path.join(os.path.join(os.environ['USERPROFILE']), 'Desktop')

# 附件文件夹路径
attachments_folder = os.path.join(desktop_path, '附件')

# 获取附件文件夹中所有 CSV 文件的路径
csv_files = [os.path.join(attachments_folder, f) for f in os.listdir(attachments_folder) if f.endswith('.csv')]

# 初始化一个空的数据框用于存储合并结果
merged_df = pd.DataFrame()

# 遍历所有 CSV 文件并合并第一列和第十列
for file_path in csv_files:
    # 打印文件路径以确保路径正确
    print(f"Processing file: {file_path}")
    
    # 读取 CSV 文件
    df = pd.read_csv(file_path, encoding='utf-8')
    
    # 选择需要的列（第一列和第十列）
    selected_columns = df.iloc[:, [0, 9]]
    
    # 合并到结果数据框
    merged_df = pd.concat([merged_df, selected_columns], axis=0)

# 将合并后的结果保存到新的 CSV 文件中
output_file = os.path.join(desktop_path, '未处理的景点门票数据.csv')
merged_df.to_csv(output_file, index=False, encoding='utf-8')

print(f"合并完成并保存到 {output_file} 文件中。")