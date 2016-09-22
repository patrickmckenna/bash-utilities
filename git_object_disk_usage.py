#!/usr/bin/env python3.5


# todo:
#   let user specify repo to check
#   make sure user has perl installed?
#   let user specify where git-du path, whether for reading or writing?
#   optionally omit tree results?
#   let user specify N for top N hogs?
#   optionally write output, top N or otherwise, to disk?
#   optionally take some action based on results?
#       could be simply the name of script to subsequently run
#       or maybe we could git-filter-branch and turn on git-lfs (lots of work)


__doc__ = """
Find out which Git objects take up the most disk space in a given repo.

Please note the caveats in @peff's script. There are some subtleties to take
into account when interpreting these numbers!
"""


import subprocess
import operator
import itertools
import collections
import os.path
import sys

import requests


peff_gist_url = "https://gist.githubusercontent.com/peff/522bf9fb633e9fa5a04e10a127dfec5a/raw/f1865bf03e40611b57a12f15fcc3e9412c18b081/git-du"
peff_gist_name = peff_gist_url.rpartition("/")[2]
give_up = "couldn't find @peff's magic, so I quit!"

if not os.path.isfile(peff_gist_name):
    try:
        response = requests.get(peff_gist_url)
        # raise an error for 4XX and 5XX responses
        response.raise_for_status()
    except requests.exceptions.RequestException as request_exception:
        print(request_exception)
        sys.exit(give_up)
    else:
        # assume (stupidly?) that the write will succeed since there's no name clash
        with open(peff_gist_name, "w") as file:
            file.write(response.text)


try:
    process = subprocess.run("perl {}".format(peff_gist_name),
                             stdout=subprocess.PIPE,
                             shell=True,
                             check=True,
                             universal_newlines=True)
except subprocess.CalledProcessError as process_exception:
    print(process_exception)
    sys.exit(give_up)


# if it ran, get the output of the script
output = process.stdout.split("\n")
# get rid of leading whitespace, and separate disk usage values from paths
all_lines = map(str.split, map(str.lstrip, output))
# remove any empty lines
# should this be "take all" logic instead, or can we assume any empty lines always come at the end?
nonempty_lines = itertools.takewhile(lambda l: len(l) > 0, all_lines)


UsagePath = collections.namedtuple("UsagePath", "disk_usage path".split())

# want disk usage reported as an int, not a string...
numeric_sizes = map(lambda l: UsagePath(int(l[0]), l[1]), nonempty_lines)
# ... to properly sort by disk usage
sorted_line_iter = sorted(numeric_sizes, key=operator.attrgetter("disk_usage"), reverse=True)


print("top 10 (disk) hogs on the farm:\n")
for hog in itertools.islice(sorted_line_iter, 10):
    print(hog)
