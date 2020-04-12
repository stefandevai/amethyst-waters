#!/bin/env python

with open("build/game.lua", "r") as fp:
    with open("build/game.min.lua", "w") as fw:
        line = fp.readline()
        while line:
            # print(line.strip())
            linestr = line.strip()
            if linestr[:2] != '--':
                fw.write(linestr + "\n")
            line = fp.readline()
        data = open("data.lua", "r").read()
        fw.write(data)

