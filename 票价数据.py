import pandas as pd
import re
import os

# 获取桌面路径
desktop_path = os.path.join(os.path.join(os.environ['USERPROFILE']), 'Desktop')

# 文件路径
file_path = os.path.join(desktop_path, '景点门票数据.csv')

# 读取 CSV 文件
df = pd.read_csv(file_path, encoding='utf-8')

# 定义提取关键词和数字的函数
def extract_ticket_price(text):
    text = str(text)  # 确保输入是字符串类型
    
    # 处理“具体收费情况以现场公示为主”的情况
    if "具体收费情况以现场公示为主" in text:
        return "待定"
    
    # 处理“免费”或没有字符的情况
    if "免费" in text or not text.strip():
        return "0"
    
    # 优先处理“成人票”关键词及其后面的数字
    match = re.search(r'成人票\s*(\d+)', text)
    if match:
        return match.group(1)
    
    # 查找所有数字
    numbers = re.findall(r'\d+', text)
    
    # 如果有两个以上的数字，且只有一个“¥”符号，提取该符号后的数字
    if len(numbers) > 1:
        yen_match = re.search(r'¥\s*(\d+)', text)
        if yen_match:
            return yen_match.group(1)
        return text
    
    # 如果只有一个数字，返回该数字
    if len(numbers) == 1:
        return numbers[0]
    
    # 尝试匹配“散客”及其后面的数字
    match = re.search(r'散客\s*(\d+)', text)
    if match:
        return match.group(1)
    
    # 如果没有数字，返回0
    return '0'

# 对第二列数据进行处理并创建新列
df['提取结果'] = df.iloc[:, 1].apply(extract_ticket_price)

# 只保留第一列和提取结果列
result_df = df.iloc[:, [0]].copy()
result_df['提取结果'] = df['提取结果']

# 将处理后的结果保存到新的 CSV 文件中
output_file = os.path.join(desktop_path, '处理后的景点门票数据.csv')
result_df.to_csv(output_file, index=False, encoding='utf-8')

print(f"处理完成并保存到 {output_file} 文件中。")