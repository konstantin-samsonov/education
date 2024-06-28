# Task 01.
# Given a number 𝑛, write a formula that returns n!.
# In case you forgot the factorial formula, n!=n*(n−1)*(n−2)*...2*1.
# For example, 5!=5*4*3*2*1=120 so we'd return 120.
# Assume is n is a non-negative integer.

# Test cases:
# None -> None
# 0 -> 1
# 1 -> 1

# A simple option:
# - Processing: None, 0, 1;
# - Make the range up to the entered value of n;
# - We multiply all the elements of the sequence sequentially;

def factorial(n: int = None):
    if n is None:
        return 'Please enter a number'

    if n < 0:
        return 'Please enter a non-negative number'

    if n in (0, 1):
        return 1

    result = 1
    for i in range(1, n + 1):
        result = + result * i

    return result


# Task 02.
# Given an list of integers called input, return True if any value appears at least twice in the array.
# Return False if every element in the input list is distinct.
# For example, if the input list was [1,3,5,7,1], then return True because the number 1 shows up twice.
# However, if the input was [1,3,5,7] then return False, because every element of the list is distinct

# Test cases:
# None or 0 elements -> None
# 1 element -> 1 element
# [1,3,5,7,1] -> [1,3,5,7] -> True
# [1,3,5,7] -> [1,3,5] -> False

# A simple option:
# - Processing: None, 0 elements, 1 element;
# - Go through the list and make each element a dictionary key;
# - If the key is already found in the dictionary, then add +1 to it;
# - We translate the dictionary into a set and delete 1. If something remains, then there were repetitions in the list.
def contains_duplicate(input: list = None) -> bool:
    answer: bool
    result: dict = {}

    if input is None or len(input) == 0:
        return 'Enter an array of numbers'

    for i in input:
        if i not in result.keys():
            result.setdefault(i, 1)
        else:
            result[i] = result[i] + 1

    result_set = set(result.values())
    result_set.discard(1)

    if len(result_set) == 0:
        answer = False
    else:
        answer = True
    return answer


# It's good that I didn't even think about nested loops, but immediately decided to use a dictionary.
# It's a pity that I didn't figure out how to simplify everything. I spied in the analysis after my decision.
def contains_duplicate_2(input: list = None) -> bool:
    seen = {}
    for i in input:
        if i in seen:
            return True
        seen[i] = True
    return False


# Task 03.
# Given an list of integers called input, and an integer target,
# return the index of the two numbers which sum up to the target.
# Do not use the same list element twice.
#
# Clarifications:
# - Assume there aren't multiple valid solutions.
# - In case there is no valid solution, return [-1, -1].
# - Return the indexes in increasing order (i.e. [1,3], NOT [3,1]).

# Example #1
# Input: input = [1, 4, 6, 10], target = 10
# Output: [1, 2]

# Example #2
# Input: input = [1, 4, 6, 10], target = 11
# Output: [0, 3]

# Example #3
# **Input: **input = [1, 4, 6, 10], target = 2
# Output: [-1, -1]

def get_index_v1(input: list = None, target: int = None) -> list:
    n = len(input)
    for i in range(n):
        for j in range(i + 1, n):
            if input[i] + input[j] == target:
                return [i, j]
    return [-1, -1]


# The previous option is not the most optimal, so here is an alternative way. With one pass of the list.
def get_index_v2(input: list = None, target: int = None) -> list:
    index_map = {}

    for i, num in enumerate(input):
        delta = target - num
        if delta in index_map:
            return [index_map[delta], i]
        index_map[num] = i

    return [-1, -1]


if __name__ == '__main__':
    print(factorial(5))
    print(contains_duplicate([1, 3, 5, 7, 1]))
    print(get_index_v1([1, 4, 6, 10], 2))
    print(get_index_v2([1, 4, 6, 10], 11))
