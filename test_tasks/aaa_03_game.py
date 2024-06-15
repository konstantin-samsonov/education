import sys


def determine_winner(kostya_move, ksusha_move):
    """Вернет результат каждого ходв"""
    if kostya_move == ksusha_move:
        return 'Draw'
    elif (kostya_move == 'R' and ksusha_move == 'S') or \
            (kostya_move == 'S' and ksusha_move == 'P') or \
            (kostya_move == 'P' and ksusha_move == 'R'):
        return 'Kostya'
    else:
        return 'Ksusha'


def main():
    input = sys.stdin.read().strip().split('\n')
    games = [line.split() for line in input]

    kostya_wins = 0
    ksusha_wins = 0
    draws = 0

    for game in games:
        if len(game) == 2:
            result = determine_winner(game[0], game[1])
            if result == 'Kostya':
                kostya_wins += 1
            elif result == 'Ksusha':
                ksusha_wins += 1
            else:
                draws += 1

    total_games = len(games)
    if total_games == 0:
        # Если игр не будет, то чтобы не делить на 0
        total_games = 1

    kostya_wins_percentage = (kostya_wins / total_games) * 100
    ksusha_wins_percentage = (ksusha_wins / total_games) * 100
    draws_percentage = (draws / total_games) * 100

    if kostya_wins > ksusha_wins:
        winner = 'Костя'
    elif ksusha_wins > kostya_wins:
        winner = 'Ксюша'
    else:
        winner = 'Ничья'

    print(winner)
    print(f'W: {max(kostya_wins_percentage, ksusha_wins_percentage):.2f}%')
    print(f'D: {draws_percentage:.2f}%')
    print(f'L: {min(kostya_wins_percentage, ksusha_wins_percentage):.2f}%')


if __name__ == "__main__":
    main()
