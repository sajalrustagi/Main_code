# -*- coding: utf-8 -*-
"""
Created on Mon Oct 12 01:16:58 2015

@author: sajal
"""
def cube(x):
    return x**3
import time

import multiprocessing as mp
pool = mp.Pool(processes=32)
print "%.20f" % time.time()
results = pool.map(cube, range(1,10000000))
print "%.20f" % time.time()
#print(results)
cubes=[]
for i in range(1,100000) :
    cubes=cubes+[cube(i)]
print "%.20f" % time.time()
