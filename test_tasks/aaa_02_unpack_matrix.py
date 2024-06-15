import sys


def read_input():
    """Преобразует входные данные в матрицу."""

    input = sys.stdin.read().strip().split('\n')
    n = int(input[0])
    matrix = [list(map(int, row.split())) for row in input[1:n + 1]]

    return matrix


def spiral_order(matrix):
    """Разворачивает матрицу по спирали."""

    result = []
    while matrix:
        # Берем первую строку матрицы
        result += matrix.pop(0)
        if matrix and matrix[0]:
            # Берем последний элемент каждой оставшейся строки
            for row in matrix:
                result.append(row.pop())
        if matrix:
            # Разворачиваем последнюю строку матрицы
            result += matrix.pop()[::-1]
        if matrix and matrix[0]:
            # Берем первый элемент из каждой оставшейся строки
            for row in matrix[::-1]:
                result.append(row.pop(0))
    return result


def main():
    matrix = read_input()
    result = spiral_order(matrix)
    print(' '.join(map(str, result)))


if __name__ == "__main__":
    main()
