import sys


def rotate_matrix_90_degrees(matrix):
    n = len(matrix)
    # Новая матрица, где строки станут столбцами исходной матрицы
    transposed_matrix = [[matrix[j][i] for j in range(n)] for i in range(n)]

    # Разворачиваем каждый ряд в новой матрике
    rotated_matrix = [row[::-1] for row in transposed_matrix]

    return rotated_matrix


def main():
    # Получаем входные данные как строку
    input_data = sys.stdin.read()

    # Разбиваем полученную строку на строки матрицы и меняем тип данных
    matrix = [list(map(int, line.split())) for line in input_data.strip().split('\n')]

    # Разворачиваем матрицу
    rotated_matrix = rotate_matrix_90_degrees(matrix)

    # Печатаем результат
    for row in rotated_matrix:
        print(' '.join(map(str, row)))


if __name__ == "__main__":
    main()
