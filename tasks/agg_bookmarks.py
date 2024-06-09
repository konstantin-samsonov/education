import pandas as pd
from bs4 import BeautifulSoup


def parse_bookmarks(html_file):
    with open(html_file, 'r', encoding='utf-8') as file:
        soup = BeautifulSoup(file, 'html.parser')

    bookmarks = []
    for link in soup.find_all('a'):
        title = link.get_text()
        url = link.get('href')
        bookmarks.append({'title': title, 'url': url})

    df = pd.DataFrame(bookmarks)
    df['domain'] = df['url'].str.extract('/(?:www\.)?([a-zA-Z0-9.-]+)')
    df = df[['domain', 'title', 'url']]
    df.sort_values('domain', ascending=False, inplace=True)
    df.reset_index(drop=True, inplace=True)

    return df


if __name__ == '__main__':
    html_file = ''
    df = parse_bookmarks(html_file)
    df.to_csv('bookmarks.csv', index=False)
