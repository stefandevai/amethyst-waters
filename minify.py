#!/bin/env python

import re

with open("source/main.fnl", "r") as fp:
    with open("build/game.min.fnl", "w") as fw:
        headerf = open("source/header.fnl", "r")
        header = headerf.read()
        headerf.close()
        fw.write(header)
        line = fp.readline()
        while line:
            linestr = line.strip()
            if (len(linestr) > 1 or linestr == '}' or linestr == ')') and linestr[:1] != ';':
                linestr = re.sub(';.*', '', linestr)
                fw.write(linestr + ' ')
            line = fp.readline()
        dataf = open("source/data.fnl", "r")
        data = dataf.read()
        dataf.close()
        fw.write(data)

