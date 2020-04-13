#!/bin/env python

import re

with open("source/main.fnl", "r") as fp:
    with open("build/game.min.fnl", "w") as fw:
        header = open("source/header.fnl", "r").read()
        fw.write(header)
        line = fp.readline()
        while line:
            linestr = line.strip()
            if (len(linestr) > 1 or linestr == '}' or linestr == ')') and linestr[:1] != ';':
                linestr = re.sub(';.*', '', linestr)
                fw.write(linestr + ' ')
            line = fp.readline()
        data = open("source/data.fnl", "r").read()
        fw.write(data)

