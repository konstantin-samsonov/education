# у нас есть два классификатора, для каждого из них есть roc-кривая, заданная координатами точек
# roc_one = [(x0, y0), (x1, y1), ..., (xn, yn)]
# roc_two = [(x0_, y0_), (x1_, y1_), ..., (xn_, yn_)]
# нужно определить разницу в метрике ROC-AUC


def get_metric(l: list) -> int:
    results = 0
    for id, val in enumerate(l):
        if id < len(l):
            results += (l[id + 1][0] - val[0]) * val[1]

    return results
