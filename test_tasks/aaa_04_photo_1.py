import sys


def rename_file(filename):
    # Словарь для преобразования месяца из числового формата в строковый
    month_dict = {
        "01": "Jan", "02": "Feb", "03": "Mar", "04": "Apr", "05": "May",
        "06": "Jun", "07": "Jul", "08": "Aug", "09": "Sep", "10": "Oct",
        "11": "Nov", "12": "Dec"
    }

    # Извлечение данных из исходного имени файла: IMG_20230430_092422111.jpg
    parts = filename.split('_')
    date_part = parts[1]
    year = date_part[:4]
    month = date_part[4:6]
    day = date_part[6:8]
    extension = parts[2].split('.')[1]

    # Преобразование месяца в строковый формат
    month_str = month_dict[month]

    # Формирование нового имени файла: 2023_Apr_30_PYTHON_CONFERENCE.jpg
    new_filename = f"{year}_{month_str}_{day}_PYTHON_CONFERENCE.{extension}"

    return new_filename


def main():
    input = sys.stdin.read().strip()
    new_filename = rename_file(input)
    print(new_filename)


if __name__ == "__main__":
    main()
