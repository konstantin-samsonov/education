import sys
import re
from collections import defaultdict


def get_month_string(month_number):
    """Вернет словарь месяцев"""
    month_dict = {
        "01": "Jan", "02": "Feb", "03": "Mar", "04": "Apr", "05": "May",
        "06": "Jun", "07": "Jul", "08": "Aug", "09": "Sep", "10": "Oct",
        "11": "Nov", "12": "Dec"
    }
    return month_dict[month_number]


def parse_event_data(event_data):
    """Вернет словарь мероприятий с датами их проведения"""
    events = {}
    for event in event_data:
        name, year, month, day = event.split()
        date = f"{year}{month}{day}"
        events[date] = name
    return events


def rename_file(filename, events, counters):
    """Вернет новое имя файла"""

    patterns = [
        r'(\d{4})(\d{2})(\d{2})\d{4}-\d+.jpg',  # 202304300924-1.jpg
        r'DCIM-(\d{4})-(\d{2})-(\d{2})-\d+.jpg',  # DCIM-2023-04-30-1.jpg
        r'IMG_(\d{4})(\d{2})(\d{2})_\d{9}.jpg'  # IMG_20230430_092422111.jpg
    ]

    for pattern in patterns:
        match = re.match(pattern, filename)
        if match:
            year, month, day = match.groups()
            date = f"{year}{month}{day}"
            if date in events:
                event_name = events[date]
                month_str = get_month_string(month)
                counter = counters[date]
                counters[date] += 1
                return f"{year}_{month_str}_{day}_{event_name}_{counter}.jpg"

    return None


def main():
    input = sys.stdin.read().strip().split('\n')

    # События
    event_data = []
    for line in input:
        if line.startswith('DCIM') or re.match(r'^\d{4}', line) or line.startswith('IMG'):
            break
        event_data.append(line)

    # Названия файлов
    file_names = input[len(event_data):]

    events = parse_event_data(event_data)
    counters = defaultdict(lambda: 1) # Словарь для подсчета событий в дату мероприятия
    renamed_files = []

    for filename in file_names:
        new_filename = rename_file(filename, events, counters)
        if new_filename:
            renamed_files.append(new_filename)

    renamed_files.sort()

    for file in renamed_files:
        print(file)


if __name__ == "__main__":
    main()
