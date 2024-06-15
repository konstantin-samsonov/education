import sys
import re


def get_month_string(month_number):
    month_dict = {
        "01": "Jan", "02": "Feb", "03": "Mar", "04": "Apr", "05": "May",
        "06": "Jun", "07": "Jul", "08": "Aug", "09": "Sep", "10": "Oct",
        "11": "Nov", "12": "Dec"
    }
    return month_dict[month_number]


def rename_file(filename):
    # Шаблоны регулярок для разных форматов названия файлов
    patterns = [
        r'(\d{4})(\d{2})(\d{2})\d{4}-\d+.jpg',  # 202304300924-1.jpg
        r'DCIM-(\d{4})-(\d{2})-(\d{2})-\d+.jpg',  # DCIM-2023-04-30-1.jpg
        r'IMG_(\d{4})(\d{2})(\d{2})_\d{9}.jpg'  # IMG_20230430_092422111.jpg
    ]

    for pattern in patterns:
        match = re.match(pattern, filename)
        if match:
            year, month, day = match.groups()
            month_str = get_month_string(month)
            return f"{year}_{month_str}_{day}_PYTHON_CONFERENCE.jpg"

    return "Invalid format"


def main():
    input = sys.stdin.read().strip()
    new_filename = rename_file(input)
    print(new_filename)


if __name__ == "__main__":
    main()
