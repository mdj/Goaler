#!/usr/bin/python
# -*- coding: utf-8 -*-

import sqlite3 as lite
import sys
from pprint import pprint

con = None

def dict_factory(cursor, row):
    d = {}
    for idx,col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return d
    
try:
    con = lite.connect('seaborg_god.db')
    con.row_factory = dict_factory
    with con:
        cur = con.cursor()    
        cur.execute("SELECT * FROM tasks")
        tasks = cur.fetchall()
        for task in tasks:
            print 80 * "-"
            pprint(task)
            task_id = task["id"]

            cur.execute("SELECT * FROM axioms WHERE task_id=?", (str(task_id)))
            axioms = cur.fetchall()
            pprint(axioms)

            cur.execute("SELECT * FROM goals WHERE task_id=?", (str(task_id)))
            goals = cur.fetchall()
            print goals

            cur.execute("SELECT * FROM objectives WHERE task_id=?", (str(task_id)))
            objectives = cur.fetchall()
            print objectives


            cur.execute("SELECT * FROM deliverables WHERE task_id=?", (str(task_id)))
            deliverables = cur.fetchall()
            print deliverables

            cur.execute("SELECT * FROM task_references WHERE task_id=?", (str(task_id)))
            references = cur.fetchall()
            print references

            
except lite.Error, e:
    
    print "Error %s:" % e.args[0]
    sys.exit(1)
    
finally:
    
    if con:
        con.close()
