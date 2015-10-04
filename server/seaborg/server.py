#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
    Seaborg GOD Server
    ------------------------------------------------------------
    Morten Dam Jørgensen, 2015
    
"""

import sqlite3
from bottle import route, get, post, put, delete, request, template
import bottle
import json
import uuid
from datetime import datetime, timedelta

bottle.debug(True)

bottle.TEMPLATE_PATH.append("views")

@route("/")
def root_view():
    # bottle.TEMPLATES.clear()    
    print("return template")
    return template("root_view.html")

