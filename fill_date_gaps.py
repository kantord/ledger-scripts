from datetime import datetime, timedelta
import csv
import sys

reader = csv.reader(sys.stdin, delimiter=" ")
writer = csv.writer(sys.stdout, delimiter=" ")


def parse_date(text):
    return datetime.strptime(text, '%Y-%m-%d').date()


def next_date(text):
    return parse_date(text) + timedelta(days=1)


def repeat_line(line):
    old_date, value = line
    new_date = next_date(old_date)
    return (datetime.strftime(new_date, '%Y-%m-%d'), value)


last_line = None
for line in reader:
    if len(line) == 1:
        line = (line[0], 0)
    if last_line:
        while parse_date(line[0]) > next_date(last_line[0]):
            last_line = repeat_line(last_line)
            writer.writerow(last_line)
    writer.writerow(line)
    last_line = line
