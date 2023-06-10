import numpy as np


def split(line: str):
    a, b, res = str.split(line, ", ")
    a = a[6:]
    b = b[6:]
    res = res[10:]
    return int(a, 16), int(b, 16), int(res, 16)


def validate(a: int, b: int, res: int) -> bool:
    return a * int((np.cbrt(b))) == res


if __name__ == '__main__':
    f = open('log.txt', 'r')

    for line in f:
        a, b, res = split(line)

        if not validate(a, b, res):
            print("error in test: a = {0}, b = {1}, res = {2}".format(a, b, res))
