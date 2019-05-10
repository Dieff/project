import re
import csv
import argparse


class Poem:
    def __init__(self, author, book, title, text):
        self.author = author
        self.title = title
        self.book = book
        self.text = text

    def __repr__(self):
        return f"{self.title} \n \n {self.text} \n \n \n"


def normalize_line(line):
    new_chars = []
    found_body = False
    last_spaces = 0
    for char in line:
        if char == " " and not(found_body):
            continue
        if char == " ":
            last_spaces += 1
            if (last_spaces > 3):
                continue
        if last_spaces < 5:
            found_body = True
            new_chars.append(char)
            last_spaces = 0
            continue
        else:
            print("too long", line)

    return "".join(new_chars)


title_blacklist = set([
    "",
    "PREFACE.",
    "TRANSCRIBER'S NOTE",
    "TRANSCRIBER'S NOTES",
    "LIST OF ILLUSTRATIONS",
    "_PREFACE_",
    "COPYRIGHT",
    "CONTENTS",
    "INDEX TO FIRST LINES",
    "Corrections",
    "NOTE",
    "CONTENTS.",
    "_NOTES_"
])


class BookParse:
    def __init__(self, text):
        self.text = text
        self.poems = []
        self.author = ""
        self.title = ""

        self.on_header = True
        self.on_body = False

        self.blanks = 0

        self.curPoemTitle = ""
        self.curPoemLines = []

    def reset_poem(self):
        self.curPoemTitle = ""
        self.curPoemLines.clear()

    def set_poem(self):
        if (len(self.curPoemLines) < 3):
            return
        self.poems.append(Poem(self.author, self.title,
                               self.curPoemTitle, "\n".join(self.curPoemLines)))

    def process_line(self, line):
        if (self.on_header):
            if (re.search("Title: ", line)):
                self.title = re.split("Title: ", line)[1]
            if (re.search("Author: ", line)):
                self.author = re.split("Author: ", line)[1]
            if (re.search("(\*\*\* START OF THIS PROJECT)|(\*\*\* START OF THE PROJECT)", line)):
                self.on_header = False
                self.on_body = True
                return
        if (self.on_body):
            if (re.search("(\*\*\* END OF THIS PROJECT GUTENBERG)|(\*\*\* END OF THE PROJECT GUTENBERG)", line)):
                self.on_body = False
                return

            reg_line = normalize_line(line)
            if (len(reg_line) < 2):
                self.blanks += 1
                return

            if (re.search("([A-Z]{2,}_?(\.|!)$)|(^[A-Z]\.$)", reg_line) or self.blanks > 3):
                if (not(self.curPoemTitle in title_blacklist)):
                    self.set_poem()
                self.reset_poem()
                self.blanks = 0
                self.curPoemTitle = reg_line
                return

            self.curPoemLines.append(reg_line)
            self.blanks = 0

            # print(reg_line)

    def __repr__(self):
        return f"{self.title} - {self.author}"


def main():
    parser = argparse.ArgumentParser(
        description='Read poetry book and convert them to useful data.')
    parser.add_argument('book', type=str,
                        help='path to a book file')

    args = parser.parse_args()
    path = args.book

    books = []

    with open(path, "r") as file:
        text = file.read()
        books.append(text)

    t = BookParse(books[0])
    for line in t.text.split("\n"):
        t.process_line(line)

    with open("res.csv", "w") as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(["Author", "Book", "PoemTitle", "Poem"])
        for poem in t.poems:
            row = [poem.author, poem.book, poem.title, poem.text]
            print(row)
            writer.writerow(row)


if __name__ == "__main__":
    main()
