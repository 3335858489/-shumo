import os
import requests
from bs4 import BeautifulSoup
import pandas as pd
from concurrent.futures import ThreadPoolExecutor, as_completed
import time

# 获取桌面路径
desktop_path = os.path.join(os.path.expanduser('~'), 'Desktop')

# 读取 数据集.xlsx 文件中的城市名称
file_path = os.path.join(desktop_path, '数据集.xlsx')
df = pd.read_excel(file_path)
cities = df.iloc[:, 0]  # 假设城市名称在第一列

# 初始化存储结果的列表
areas = []
populations = []
gdps = []

# 代理服务器设置
proxies = {
    'http': 'http://your_proxy_server:your_proxy_port',
    'https': 'https://your_proxy_server:your_proxy_port',
}

def fetch_city_data(city):
    url = f'https://en.wikipedia.org/wiki/{city}'
    mirror_url = f'https://www.wikipedia.org/wiki/{city}'  # 使用镜像源
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3'}
    
    for attempt in range(3):  # 尝试3次
        try:
            response = requests.get(url, headers=headers, proxies=proxies, timeout=20)  # 增加超时时间到20秒
            response.raise_for_status()  # 如果响应状态码不是200，抛出HTTPError
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # 解析网页内容，提取占地面积、人口数和 GDP
            infobox = soup.find('table', {'class': 'infobox'})
            area = infobox.find('th', text='Area').find_next_sibling('td').text
            population = infobox.find('th', text='Population').find_next_sibling('td').text
            gdp = infobox.find('th', text='GDP').find_next_sibling('td').text
            
            # 仅在所有数据都存在时才返回结果
            if area and population and gdp:
                return city, area, population, gdp
        except (requests.exceptions.RequestException, AttributeError) as e:
            print(f"Error fetching data for {city} from main site: {e}")
            try:
                response = requests.get(mirror_url, headers=headers, proxies=proxies, timeout=20)  # 尝试使用镜像源
                response.raise_for_status()
                soup = BeautifulSoup(response.text, 'html.parser')
                
                infobox = soup.find('table', {'class': 'infobox'})
                area = infobox.find('th', text='Area').find_next_sibling('td').text
                population = infobox.find('th', text='Population').find_next_sibling('td').text
                gdp = infobox.find('th', text='GDP').find_next_sibling('td').text
                
                if area and population and gdp:
                    return city, area, population, gdp
            except (requests.exceptions.RequestException, AttributeError) as e:
                print(f"Error fetching data for {city} from mirror site: {e}")
            time.sleep(2)  # 等待2秒后重试
    
    return city, None, None, None

# 使用 ThreadPoolExecutor 并行处理
max_workers = 10  # 减少并发请求数量
with ThreadPoolExecutor(max_workers=max_workers) as executor:
    future_to_city = {executor.submit(fetch_city_data, city): city for city in cities}
    for future in as_completed(future_to_city):
        city, area, population, gdp = future.result()
        areas.append(area)
        populations.append(population)
        gdps.append(gdp)

# 将结果写入新的 DataFrame
result_df = pd.DataFrame({
    '城市名': cities,
    '占地面积': areas,
    '人口数': populations,
    'GDP': gdps
})

# 将新的 DataFrame 写入新的 Excel 文件
output_file_path = os.path.join(desktop_path, '补充数据.xlsx')
result_df.to_excel(output_file_path, index=False)

print(f'数据已成功写入 {output_file_path}')