#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
    Seaborg GOD Server
    ------------------------------------------------------------
    Morten Dam Jørgensen, 2015
    
"""

import sqlite3
from bottle import route, run, debug, template, request, static_file, error, response
import bottle
from pprint import pprint

import json
import jwt
# only needed when you run Bottle on mod_wsgi
from bottle import default_app

debug(True)
bottle.TEMPLATE_PATH.append("views")

def dict_factory(cursor, row):
    d = {}
    for idx,col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return d


import uuid
import hashlib
 
def hash_password(password):
    # uuid is used to generate a random number
    salt = uuid.uuid4().hex
    return hashlib.sha256(salt.encode() + password.encode()).hexdigest() + ':' + salt
    
def check_password(hashed_password, user_password):
    password, salt = hashed_password.split(':')
    return password == hashlib.sha256(salt.encode() + user_password.encode()).hexdigest()



from cStringIO import StringIO
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.header import Header
from email import Charset
from email.generator import Generator
import smtplib
import textwrap

from dateutil.parser import parse as parseDate




def mail(to, to_name, subject, message):

    gmail_user = 'god@reactive.dk'
    gmail_pwd = 'FDSfh2@##52dsdmjb!@%@#jfdkwvmnr'
    # Example address data
    from_address = [u'Goals Server', 'god@reactive.dk']
    recipient = [to_name, to]
    subject = subject
     
    # body
    html = textwrap.dedent(message)
    text = textwrap.dedent(message)
     
    # Default encoding mode set to Quoted # printable. Acts globally!
    Charset.add_charset('utf-8', Charset.QP, Charset.QP, 'utf-8')
     
    # 'alternative’ MIME type – HTML and plain text bundled in one e-mail message
    msg = MIMEMultipart('alternative')
    msg['Subject'] = "%s" % Header(subject, 'utf-8')
    # Only descriptive part of recipient and sender shall be encoded, not the email address
    msg['From'] = "\"%s\" <%s>" % (Header(from_address[0], 'utf-8'), from_address[1])
    msg['To'] = "\"%s\" <%s>" % (Header(recipient[0], 'utf-8'), recipient[1])
     
    # Attach both parts
    htmlpart = MIMEText(html, 'html', 'UTF-8')
    textpart = MIMEText(text, 'plain', 'UTF-8')
    msg.attach(htmlpart)
    msg.attach(textpart)
     
    # Create a generator and flatten message object to 'file’
    str_io = StringIO()
    g = Generator(str_io, False)
    g.flatten(msg)
    # str_io.getvalue() contains ready to sent message
     
    # Optionally - send it – using python's smtplib
    # or just use Django's

    # disabled for debugging

    # s = smtplib.SMTP('smtp.gmail.com', 587)
    # s.ehlo()
    # s.starttls()
    # s.ehlo()
    # s.login(gmail_user, gmail_pwd)
    # s.sendmail("", recipient[1], str_io.getvalue())




@route("/authenticate", method="POST")
def auth_user():

    #TODO validate req.body.username and req.body.password
    # if is invalid, return 401
    login_data =  request.json

    print login_data

    conn = sqlite3.connect('seaborg_god.db')
    conn.row_factory = dict_factory
    c = conn.cursor()

    c.execute("SELECT * FROM people WHERE company_id LIKE ? AND username LIKE ?", (login_data['cid'], login_data['username']))
    person = c.fetchone() 

    if person:

        if 'send_pass' in login_data:
            print "send pass word"
            subject = "Your password for goals.seaborg.co"
            msg = '''
            {person.name}

            '''.format(person=person)
            print msg
            return

        if check_password(person['password'], login_data['password']):
            print "login successful!"

            if person['must_change_pw'] or ('new_password_1' in login_data and 'new_password_2' in login_data and len(login_data['new_password_1']) > 7):
                print "users password expired"

                if ('new_password_1' in login_data and 'new_password_2' in login_data) and len(login_data['new_password_1']) > 7:
                    if login_data['new_password_1'] == login_data['new_password_2']:
                        print "new password supplied, encoding and saving"
                        print login_data['new_password_1']
                        new_pass = hash_password(login_data['new_password_1'])
                        print new_pass
                        c.execute("UPDATE people SET password = ?, must_change_pw = 0 WHERE id = ?", (new_pass, person['id']))
                        conn.commit()
                else:
                    return {"change_pass": True}

            del person['password'] # remove to avoid passing it around

            c.execute("SELECT * FROM companies WHERE id LIKE ?", (login_data['cid']))
            company_info = c.fetchone()    

            encoded = jwt.encode(person, company_info['jwt_secret'], algorithm='HS256')
            # print 'encoded', encoded
            return {"token" : encoded, "userinfo": person}            

    response.status = 403
    return {'error' : 403}


@route('/authenticate/change_pass', method="POST")
def change_password():

    login_data =  request.json
    print login_data
    return {"pass_changed" : True}





##
# overview
##

@route("/overview/json", method="GET")
def overview_json():
    # for head in request.headers:
        # print head, request.headers.get(head)
    auth = request.headers.get("Authorization")
    if not auth:
        return authenticate({'code': 'authorization_header_missing', 'description': 'Authorization header is expected'})

    parts = auth.split()


    if parts[0].lower() != 'bearer':
        return {'code': 'invalid_header', 'description': 'Authorization header must start with Bearer'}
    elif len(parts) == 1:
        return {'code': 'invalid_header', 'description': 'Token not found'}
    elif len(parts) > 2:
        return {'code': 'invalid_header', 'description': 'Authorization header must be Bearer + \s + token'}

    token = parts[1]
    try:

        company_id = "1"

        conn = sqlite3.connect('seaborg_god.db')
        conn.row_factory = dict_factory
        c = conn.cursor()
        c.execute("SELECT * FROM companies WHERE id LIKE ?", (company_id))
        company_info = c.fetchone()    

        payload = jwt.decode(
            token,
            company_info['jwt_secret']
            #audience=client_id
        )
    except jwt.ExpiredSignature:
        return authenticate({'code': 'token_expired', 'description': 'token is expired'})
    except jwt.InvalidAudienceError:
        return authenticate({'code': 'invalid_audience', 'description': 'incorrect audience, expected: ' + client_id})
    except jwt.DecodeError:
        return authenticate({'code': 'token_invalid_signature', 'description': 'token signature is invalid'})

    date_sent = parseDate(request.query.date_today)
    # print date_sent
    # print request.query.cid
    # print request.forms.get('cid')
    # print request.json
    # print "decoded", payload
    # # print "loading task id", item
    conn = sqlite3.connect('seaborg_god.db')
    conn.row_factory = dict_factory
    c = conn.cursor()

    c.execute("""SELECT i.name
          ,i.id
          ,i.outline
          ,i.creation_date
          ,i.approval_date
          ,i.rejection_date
          ,i.completion_date
          ,i.proposal_date
          ,i.created_by
          ,i.approved_by
          ,i.rejected_by
          ,i.completed_by
          ,i.proposed_by
          ,i.responsible
          ,i.reporting_to
          ,i.reporting_cycle
          ,i.progress_report_id
          ,i.final_report_id
          ,i.budget_id
          ,i.department_owner
          ,i.last_save
          ,i.deadline_date
          ,i.approval_requested
          ,e1.name AS created_name
          ,e2.name AS approved_name
          ,e3.name AS rejected_name
          ,e4.name AS completed_name
          ,e5.name AS proposed_name
          ,e6.name AS responsible_name
          ,e7.name AS reporting_to_name
          ,departments.title AS department_title
          ,departments.department_head AS department_head_id
          ,departments.parent_department AS parent_department_id
          ,depHeadPerson.name as department_approval_by
    FROM   tasks i 

    LEFT JOIN people e1 ON e1.id = i.created_by
    LEFT JOIN people e2 ON e2.id = i.approved_by
    LEFT JOIN people e3 ON e3.id = i.rejected_by
    LEFT JOIN people e4 ON e4.id = i.completed_by
    LEFT JOIN people e5 ON e5.id = i.proposed_by
    LEFT JOIN people e6 ON e6.id = i.responsible
    LEFT JOIN people e7 ON e7.id = i.reporting_to
    LEFT JOIN departments ON departments.id = i.department_owner
    LEFT JOIN people depHeadPerson ON departments.department_head = depHeadPerson.id
        WHERE i.company_id LIKE ?
    """, (str(payload['company_id']),))

    tasks = c.fetchall()


    c.execute("SELECT axioms.* FROM axioms, tasks WHERE axioms.task_id = tasks.id AND tasks.company_id LIKE ?", (str(payload['company_id']),))
    axioms = c.fetchall()
    for axiom in axioms:
        if axiom['task_dependence_id']:
            print "the task has a depenendence"
            c.execute("SELECT name, deadline_date FROM tasks WHERE id = ?", (axiom['task_dependence_id'],))
            axiom_task = c.fetchone()
            axiom['dependence'] = {
                "name" : axiom_task['name'],
                "id" : axiom['task_dependence_id'],
                "deadline_date" : axiom_task['deadline_date']            
            }


    c.execute("SELECT goals.* FROM goals, tasks WHERE goals.task_id = tasks.id AND tasks.company_id LIKE ?", (str(payload['company_id']),))
    goals = c.fetchall()

    c.execute("SELECT deliverables.* FROM deliverables, tasks WHERE deliverables.task_id = tasks.id AND tasks.company_id LIKE ?", (str(payload['company_id']),))
    deliverables = c.fetchall()

    c.execute("SELECT objectives.* FROM objectives, tasks WHERE objectives.task_id = tasks.id AND tasks.company_id LIKE ?", (str(payload['company_id']),))
    objectives = c.fetchall()

    for task in tasks:
        objs = [obj for obj in axioms if obj['task_id'] == task['id']]
        task['axioms'] = objs

        objs = [obj for obj in goals if obj['task_id'] == task['id']]
        task['goals'] = objs

        objs = [obj for obj in deliverables if obj['task_id'] == task['id']]
        for obj in objs:
            if obj['isdelivered'] == 1:
                obj['isdelivered'] = True
            else:
                obj['isdelivered'] = False
        task['deliverables'] = objs


        objs = [obj for obj in objectives if obj['task_id'] == task['id']]
        task['objectives'] = objs

        if task['name'] == "": task['name'] = "Untitled task"
        task['isCompleted'] = task['completion_date'] is not None and task['completion_date'] != ""
        task['isApproved'] = task['approval_date'] is not  None and task['approval_date'] != ""
        task['isRejected'] = task['rejection_date'] is not  None and task['rejection_date'] != ""       
        task['isPendingApproval'] = task['approval_requested'] is not None and task['approval_requested'] != ""
        task['isCreator'] = payload['id'] == task['created_by']
        task['isApprover'] = payload['id'] == task['department_head_id']
        task['isAssignee'] = payload['id'] == task['responsible']
        task['isRaportingOfficer'] = payload['id'] == task['reporting_to']
        task['deadlineDue'] = (parseDate(task['deadline_date']) - parseDate(request.query.date_today)).days

        # Task state
        if task['isCompleted']:
            task['state'] = 'isCompleted'
        elif task['isApproved']:
            task['state'] = 'isApproved'
        elif task['isRejected']:
            task['state'] = 'isRejected'
        elif task['isPendingApproval']:
            task['state'] = 'isPendingApproval'
        else:
            task['state'] = 'isDraft'


    c.execute("SELECT company_name, owner as company_owner_id, url_name as company_url FROM companies WHERE id = ?", (str(payload['company_id']),))
    company_info = c.fetchone()

    conn.close()

    overview = {"tasks" : tasks, "company" : company_info}
    return overview



@route('/org/json', method="GET")
def org_json():
    auth = request.headers.get("Authorization")

    conn = sqlite3.connect('seaborg_god.db')
    conn.row_factory = dict_factory
    c = conn.cursor()

    if not auth:
        return authenticate({'code': 'authorization_header_missing', 'description': 'Authorization header is expected'})

    parts = auth.split()


    if parts[0].lower() != 'bearer':
        return {'code': 'invalid_header', 'description': 'Authorization header must start with Bearer'}
    elif len(parts) == 1:
        return {'code': 'invalid_header', 'description': 'Token not found'}
    elif len(parts) > 2:
        return {'code': 'invalid_header', 'description': 'Authorization header must be Bearer + \s + token'}

    token = parts[1]
    try:
        c.execute("SELECT * FROM goal_system order by id desc limit 1")
        goal_system = c.fetchone()    

        payload = jwt.decode(
            token,
            goal_system['jwt_secret']
            #audience=client_id
        )
    except jwt.ExpiredSignature:
        return authenticate({'code': 'token_expired', 'description': 'token is expired'})
    except jwt.InvalidAudienceError:
        return authenticate({'code': 'invalid_audience', 'description': 'incorrect audience, expected: ' + client_id})
    except jwt.DecodeError:
        return authenticate({'code': 'token_invalid_signature', 'description': 'token signature is invalid'})

    print "decoded", payload



    c.execute("SELECT departments.*, people.name as head_name, people.email as head_email FROM departments, people WHERE departments.department_head = people.id AND departments.company_id = ?", (payload['company_id'],))
    departments = c.fetchall()


    c.execute("SELECT company_name, owner as company_owner_id, url_name as company_url FROM companies WHERE id = ?", (str(payload['company_id']),))
    company_info = c.fetchone()



    conn.close()




    return {"departments": departments, "company" : company_info}


@route('/org')
def org():
    return template('org', company={"cid": 1})


###
# Deliverables 
###

@route('/task/<task_id:int>/deliverable/<id:int>/delete', method="GET")
def delete_deliverable(task_id, id):
    # print "Deleting Deliverable with ID", id
    conn = sqlite3.connect('seaborg_god.db')
    conn.row_factory = dict_factory
    c = conn.cursor()
    c.execute("DELETE FROM deliverables WHERE id = ?", (id,))
    conn.commit()
    conn.close()
    return {"status" : "ok"}
    
    
@route('/task/<task_id:int>/deliverable/<id:int>/update', method="POST")
def update_deliverable(task_id, id):
    """Update content of deliverable"""

    data = request.json
    if data:
        # pprint(data)
        # print "ID", id, "deliv,", int(data['isdelivered'])

        conn = sqlite3.connect('seaborg_god.db')
        conn.row_factory = dict_factory
        c = conn.cursor()
        c.execute("UPDATE deliverables SET isdelivered = ? WHERE id LIKE ?", (int(data['isdelivered']),id))
        conn.commit()
        conn.close()
        return {"status" : "ok"}


@route('/task/<task_id:int>/deliverable/add', method="POST")
def add_deliverable(task_id):
    """Update content of deliverable"""

    data = request.json
    if data:

        # print(data)
        # print "task_ID", task_id
        
        if task_id != int(data['task_id']):
            # print "ERROR task id mismatch", data['task_id'], task_id
            return {"status" : "nok"}
            
        conn = sqlite3.connect('seaborg_god.db')
        conn.row_factory = dict_factory
        c = conn.cursor()

        c.execute("INSERT INTO deliverables (task_id, name, defined_by, definition_date, isdelivered, priority, customer, text) VALUES (?,?,?,?,?,?,?,?)", (task_id, data['name'], data['defined_by'],data['definition_date'], data['isdelivered'], data['priority'], data['customer'], data['text']))
        conn.commit()
        conn.close()
        return {"status" : "ok"}



## 
# Axioms
##

@route('/task/<task_id:int>/axiom/add', method="POST")
def add_axiom(task_id):
    """Update content of axiom"""

    data = request.json
    if data:
        print(data)
        # print "task_ID", task_id
        
        if task_id != int(data['task_id']):
            # print "ERROR task id mismatch", data['task_id'], task_id
            return {"status" : "nok"}
        
        conn = sqlite3.connect('seaborg_god.db')
        conn.row_factory = dict_factory
        c = conn.cursor()

        c.execute("INSERT INTO axioms (task_id, name, defined_by, definition_date, text, task_dependence_id) VALUES (?,?,?,?,?,?)", (task_id, data['name'], data['defined_by'],data['definition_date'],data['text'],data['task_dependence_id']))
        conn.commit()
        conn.close()
        return {"status" : "ok"}


## 
# Goals
##

@route('/task/<task_id:int>/goal/add', method="POST")
def add_goal(task_id):
    """Update content of goal"""

    data = request.json
    if data:
        # print(data)
        # print "task_ID", task_id
        
        if task_id != int(data['task_id']):
            # print "ERROR task id mismatch", data['task_id'], task_id
            return {"status" : "nok"}
            
        conn = sqlite3.connect('seaborg_god.db')
        conn.row_factory = dict_factory
        c = conn.cursor()

        c.execute("INSERT INTO goals (task_id, name, defined_by, definition_date, text) VALUES (?,?,?,?,?)", (task_id, data['name'], data['defined_by'],data['definition_date'],data['text']))
        conn.commit()
        conn.close()
        return {"status" : "ok"}


## 
# Objectives
##

@route('/task/<task_id:int>/objective/add', method="POST")
def add_objective(task_id):
    """Update content of objective/add"""

    data = request.json
    if data:
        # print(data)
        # print "task_ID", task_id
        
        if task_id != int(data['task_id']):
            # print "ERROR task id mismatch", data['task_id'], task_id
            return {"status" : "nok"}
            
        conn = sqlite3.connect('seaborg_god.db')
        conn.row_factory = dict_factory
        c = conn.cursor()

        c.execute("INSERT INTO objectives (task_id, name, defined_by, definition_date, text) VALUES (?,?,?,?,?)", (task_id, data['name'], data['defined_by'],data['definition_date'],data['text']))
        conn.commit()
        conn.close()
        return {"status" : "ok"}


## 
# References
##

@route('/task/<task_id:int>/reference/add', method="POST")
def add_reference(task_id):
    """Update content of reference/add"""

    data = request.json
    if data:
        # print(data)
        # print "task_ID", task_id
        
        if task_id != int(data['task_id']):
            # print "ERROR task id mismatch", data['task_id'], task_id
            return {"status" : "nok"}
            
        conn = sqlite3.connect('seaborg_god.db')
        conn.row_factory = dict_factory
        c = conn.cursor()

        c.execute("INSERT INTO task_references (task_id, text, created_by, creation_date, url, comment) VALUES (?,?,?,?,?,?)", (task_id, data['text'], data['defined_by'],data['definition_date'],data['url'], data['comment']))
        conn.commit()
        conn.close()
        return {"status" : "ok"}





## 
# Task
##

def authenticate(error):
    response.status = 401
    return error



@route("/task/<task_id:int>/delete", method="POST")
def delete_task(task_id):
    data = request.json

    auth = request.headers.get("Authorization")
    if not auth:
        return authenticate({'code': 'authorization_header_missing', 'description': 'Authorization header is expected'})

    parts = auth.split()


    if parts[0].lower() != 'bearer':
        return {'code': 'invalid_header', 'description': 'Authorization header must start with Bearer'}
    elif len(parts) == 1:
        return {'code': 'invalid_header', 'description': 'Token not found'}
    elif len(parts) > 2:
        return {'code': 'invalid_header', 'description': 'Authorization header must be Bearer + \s + token'}

    token = parts[1]
    try:

        company_id = "1"

        conn = sqlite3.connect('seaborg_god.db')
        conn.row_factory = dict_factory
        c = conn.cursor()
        c.execute("SELECT * FROM companies WHERE id LIKE ?", (company_id))
        company_info = c.fetchone()    

        payload = jwt.decode(
            token,
            company_info['jwt_secret']
            #audience=client_id
        )
    except jwt.ExpiredSignature:
        return authenticate({'code': 'token_expired', 'description': 'token is expired'})
    except jwt.InvalidAudienceError:
        return authenticate({'code': 'invalid_audience', 'description': 'incorrect audience, expected: ' + client_id})
    except jwt.DecodeError:
        return authenticate({'code': 'token_invalid_signature', 'description': 'token signature is invalid'})

    # print "decoded", payload



    # print "Deleting task with ID", task_id

    conn = sqlite3.connect('seaborg_god.db')
    conn.row_factory = dict_factory
    c = conn.cursor()

    try:
        c.execute("DELETE FROM axioms WHERE task_id = ?", (task_id,))
        c.execute("DELETE FROM deliverables WHERE task_id = ?", (task_id,))
        c.execute("DELETE FROM goals WHERE task_id = ?", (task_id,))
        c.execute("DELETE FROM objectives WHERE task_id = ?", (task_id,))
        c.execute("DELETE FROM task_references WHERE task_id = ?", (task_id,))
        c.execute("DELETE FROM tasks WHERE id = ?", (task_id,))

        conn.commit()
        conn.close()
    except sqlite3.Error as e:
            # print "An error occurred:", e.args[0]
            conn.close()
            return {"status" : "error", "message": e.args[0]}


    return {"status" : "ok"}

@route("/task/<task_id:int>/command", method="POST")
def task_command(task_id):
    """docstring for task_command"""
    data = request.json

    # # # print [item for item in request.headers]
    # for item in request.headers.items():
    #     # print item

    auth = request.headers.get("Authorization")
    if not auth:
        return authenticate({'code': 'authorization_header_missing', 'description': 'Authorization header is expected'})

    parts = auth.split()


    if parts[0].lower() != 'bearer':
        return {'code': 'invalid_header', 'description': 'Authorization header must start with Bearer'}
    elif len(parts) == 1:
        return {'code': 'invalid_header', 'description': 'Token not found'}
    elif len(parts) > 2:
        return {'code': 'invalid_header', 'description': 'Authorization header must be Bearer + \s + token'}

    token = parts[1]
    try:

        company_id = "1"

        conn = sqlite3.connect('seaborg_god.db')
        conn.row_factory = dict_factory
        c = conn.cursor()
        c.execute("SELECT * FROM companies WHERE id LIKE ?", (company_id))
        company_info = c.fetchone()    

        payload = jwt.decode(
            token,
            company_info['jwt_secret']
            #audience=client_id
        )
    except jwt.ExpiredSignature:
        return authenticate({'code': 'token_expired', 'description': 'token is expired'})
    except jwt.InvalidAudienceError:
        return authenticate({'code': 'invalid_audience', 'description': 'incorrect audience, expected: ' + client_id})
    except jwt.DecodeError:
        return authenticate({'code': 'token_invalid_signature', 'description': 'token signature is invalid'})

    # print "decoded", payload




    if data:
        # print(data)
        
        conn = sqlite3.connect('seaborg_god.db')
        conn.row_factory = dict_factory
        c = conn.cursor()
        c.execute("""SELECT i.name
              ,i.id
              ,i.outline
              ,i.creation_date
              ,i.approval_date
              ,i.rejection_date
              ,i.completion_date
              ,i.proposal_date
              ,i.created_by
              ,i.approved_by
              ,i.rejected_by
              ,i.completed_by
              ,i.proposed_by
              ,i.responsible
              ,i.reporting_to
              ,i.reporting_cycle
              ,i.progress_report_id
              ,i.final_report_id
              ,i.budget_id
              ,i.department_owner
              ,i.last_save
              ,i.deadline_date
              ,i.approval_requested
            ,e1.name AS created_name
            ,e1.email AS created_email
            ,e2.name AS approved_name
            ,e2.email AS approved_email
            ,e3.name AS rejected_name
            ,e3.email AS rejected_email
            ,e4.name AS completed_name
            ,e4.email AS completed_email

            ,e5.name AS proposed_name
            ,e5.email AS proposed_email
            ,e6.name AS responsible_name
            ,e6.email AS responsible_email
            ,e7.name AS reporting_to_name
            ,e7.email AS reporting_to_email
            ,departments.title AS department_title
            ,departments.department_head AS department_head_id
            ,departments.parent_department AS parent_department_id
            ,depHeadPerson.name as department_approval_by
            ,depHeadPerson.email as department_approval_email
        FROM   tasks i 

        LEFT JOIN people e1 ON e1.id = i.created_by
        LEFT JOIN people e2 ON e2.id = i.approved_by
        LEFT JOIN people e3 ON e3.id = i.rejected_by
        LEFT JOIN people e4 ON e4.id = i.completed_by
        LEFT JOIN people e5 ON e5.id = i.proposed_by
        LEFT JOIN people e6 ON e6.id = i.responsible
        LEFT JOIN people e7 ON e7.id = i.reporting_to
        LEFT JOIN departments ON departments.id = i.department_owner
        LEFT JOIN people depHeadPerson ON departments.department_head = depHeadPerson.id
            WHERE i.id LIKE ?
        """, (task_id,))
        # c.execute("SELECT tasks.*  FROM tasks, people WHERE id = ?", (task_id,))
        task = c.fetchone()
        # # print( task)

        created_email = task['created_email']
        approver_email = task['department_approval_email']
        assignee_email = task['responsible_email']
        reporting_to_email = task['reporting_to_email']

        # print "Director:",approver_email
        # print "Created by:", created_email
        # print "Assigned to:", assignee_email
        # print "Reporting to:", reporting_to_email

        # Fecthing head of department in question
        c.execute("SELECT department_head FROM departments WHERE id = ?", (str(task['department_owner'])))
        department_head = c.fetchone()
        
        response_data = {} # data returned

        
            
        if data['action'] == "approve" and (int(department_head['department_head']) ==  int(payload['id'])):
            # print "Ready to approve"
            c.execute("UPDATE tasks SET approval_date = ?, approved_by = ?, rejection_date = '', rejected_by = '' WHERE id LIKE ?", (data['approval_date'], payload['id'], task_id))
            conn.commit()

            response_data['approval_date'] = data['approval_date']
            response_data['approved_by'] = data['current_user_id']
            response_data['approved_name'] = payload['name']


            # Send emails to: creator, responsible, reporting officer, approver


            ## 
            # Mail to assignee
            ##

            subject = u"Assignment: Task GOD-{task_id}-{task_date} was approved by {approver}".format(task_id=task_id, task_date=task['creation_date'], approver=task['department_approval_by'])
            text = u"""
            {responsible_name},

            You are responsible for task GOD-{task_id}-{task_date} that has been approved on {approval_date}.

            Please find more information at: {base_url}/task/{task_id}.

            The deadline is set to {deadline}.
            You must report on the status of the task to {reporting_officer} every {reporting_cycle} days.


            Best,

            {approver}
            {approver_email}
            (your approver)

            This message was sent by the GOD system: {base_url}.
            """.format(task_id=task_id, 
                responsible_name=task['responsible_name'],
                task_date=task['creation_date'], 
                approval_date=data['approval_date'], 
                base_url="http://localhost:8080", 
                deadline=task['deadline_date'], 
                reporting_officer=task['reporting_to_name'],
                reporting_cycle=task['reporting_cycle'],
                approver=task['department_approval_by'],
                approver_email=approver_email)

            # print text
            mail("mdam@gluino.com", task['responsible_name'], subject, text) # to the responsible
    

            ##
            # Mail to Reportin officer
            ##
            subject = u"Reporting officer: Task GOD-{task_id}-{task_date} was approved by {approver}".format(task_id=task_id, task_date=task['creation_date'], approver=task['department_approval_by'])
            text = u"""
            {reporting_officer},

            You are the reporting officer for task GOD-{task_id}-{task_date} that has been approved on {approval_date}.

            Please find more information at: {base_url}/task/{task_id}.

            The responsible for this task is {responsible_name}, who should report to you every {reporting_cycle} days.
            The deadline is set to {deadline}.

            Please keep {approver} up to date on developments that may push the deadline or incur risk to the company.
            When the task is done, please inform {approver} that the task should be marked as done.


            Best,

            {approver}
            {approver_email}
            (your approver)

            This message was sent by the GOD system: {base_url}.
            """.format(task_id=task_id, 
                responsible_name=task['responsible_name'],
                task_date=task['creation_date'], 
                approval_date=data['approval_date'], 
                base_url="http://localhost:8080", 
                deadline=task['deadline_date'], 
                reporting_officer=task['reporting_to_name'],
                reporting_cycle=task['reporting_cycle'],
                approver=task['department_approval_by'],
                approver_email=approver_email)

            # print text
            mail("mdam@gluino.com", task['reporting_to_name'], subject, text) # to the reporting officer





            ##
            # Mail to creator
            ###
            subject = u"Task GOD-{task_id}-{task_date} was approved by {approver}".format(task_id=task_id, task_date=task['creation_date'], approver=task['department_approval_by'])
            text = u"""
            {creator_name},

            Your task GOD-{task_id}-{task_date} has been approved on {approval_date}.

            Please find more information at: {base_url}/task/{task_id}.

            The responsible for this task is {responsible_name}, who should report to {reporting_officer} every {reporting_cycle} days.
            The deadline is set to {deadline}.


            Best,

            {approver}
            {approver_email}
            (your approver)

            This message was sent by the GOD system: {base_url}.
            """.format(task_id=task_id, 
                responsible_name=task['responsible_name'],
                task_date=task['creation_date'], 
                approval_date=data['approval_date'], 
                base_url="http://localhost:8080", 
                deadline=task['deadline_date'], 
                reporting_officer=task['reporting_to_name'],
                reporting_cycle=task['reporting_cycle'],
                approver=task['department_approval_by'],
                approver_email=approver_email,
                creator_name=task['created_name'])

            # print text
            mail("mdam@gluino.com", task['created_name'], subject, text) # to the creator


            ##
            # Mail to approver
            ###
            subject = u"Task GOD-{task_id}-{task_date} was approved by you".format(task_id=task_id, task_date=task['creation_date'], approver=task['department_approval_by'])
            text = u"""
            {approver},

            You approved task GOD-{task_id}-{task_date} on {approval_date}.

            Please find more information at: {base_url}/task/{task_id}.

            The responsible for this task is {responsible_name}, who should report to {reporting_officer} every {reporting_cycle} days.
            The deadline is set to {deadline}.

            This message was sent by the GOD system: {base_url}.
            """.format(task_id=task_id, 
                responsible_name=task['responsible_name'],
                task_date=task['creation_date'], 
                approval_date=data['approval_date'], 
                base_url="http://localhost:8080", 
                deadline=task['deadline_date'], 
                reporting_officer=task['reporting_to_name'],
                reporting_cycle=task['reporting_cycle'],
                approver=task['department_approval_by'],
                approver_email=approver_email,
                creator_name=task['created_name'])

            # print text
            mail("mdam@gluino.com", task['department_approval_by'], subject, text) # to the creator




        elif data['action'] == "reject" and (int(department_head['department_head']) ==  int(payload['id'])):
            # print "Ready to reject"
            c.execute("UPDATE tasks SET rejection_date = ?, rejected_by = ?, approval_date = '', approved_by = '' WHERE id LIKE ?", (data['rejection_date'], payload['id'], task_id))
            conn.commit()

            response_data['rejection_date'] = data['rejection_date']
            response_data['rejected_by'] = data['current_user_id']
            response_data['rejected_name'] = payload['name']

            # Send emails to: creator, responsible, reporting officer, approver

        elif data['action'] == "completed" and (int(department_head['department_head']) ==  int(payload['id'])):
            # print "Ready to complete"
            c.execute("UPDATE tasks SET completion_date = ?, completed_by = ? WHERE id LIKE ?", (data['completion_date'], payload['id'], task_id))
            conn.commit()

            response_data['completion_date'] = data['completion_date']
            response_data['completed_by'] = data['current_user_id']
            response_data['completed_name'] = payload['name']

            # Send emails to: creator, responsible, reporting officer, approver

        elif data['action'] == "reopenTask" and (int(department_head['department_head']) ==  int(payload['id'])):

            c.execute("UPDATE tasks SET completion_date = '', completed_by = '', rejection_date = '', rejected_by = '', approval_date = '', approved_by = '', approval_requested = '' WHERE id LIKE ?", (task_id,))
            conn.commit()

            # Send emails to: creator, approver

        elif data['action'] == "requestApproval":
            # print u"Approval requested by", payload['name']
            if task['created_by'] == payload['id']:
                # print "Approval request accepted from creator"
                c.execute("UPDATE tasks SET approval_requested = ?  WHERE id LIKE ?", (data['req_approval_date'], task_id))
                conn.commit()

                # Send emails to: creator, responsible, reporting officer, approver
                mail("mdam@gluino.com", task['department_approval_by'], "A message from GOD", "You have a request for approval at http://god.seaborg.com/tasks/%s"  % str(task_id))


        else:
            pass
            # print "Unknown command", data
            
        c.close()
    
        return response_data


@route('/task/<task_id:int>/update', method="POST")
def update_deliverable(task_id):
    """Update content of task"""
    # print "UPDATING\n\n"
    data = request.json
    if data:
        # print(data)
        # print "ID", task_id

        conn = sqlite3.connect('seaborg_god.db')
        conn.row_factory = dict_factory
        c = conn.cursor()
        c.execute("UPDATE tasks SET name = ?, outline = ?, last_save = ?, deadline_date = ?, department_owner = ?, reporting_to = ?, responsible = ?, reporting_cycle = ? WHERE id LIKE ?", (data['name'], data['outline'], data['last_save'], data['deadline_date'], data['department_owner'], data['reporting_to'], data['responsible'], data['reporting_cycle'], task_id))
        conn.commit()
        conn.close()
        return {"status" : "ok"}





@route('/task/<item:int>/json')#'/<uid:int>')
def show_task(item):#, uid):
    
    auth = request.headers.get("Authorization")
    if not auth:
        return authenticate({'code': 'authorization_header_missing', 'description': 'Authorization header is expected'})

    parts = auth.split()


    if parts[0].lower() != 'bearer':
        return {'code': 'invalid_header', 'description': 'Authorization header must start with Bearer'}
    elif len(parts) == 1:
        return {'code': 'invalid_header', 'description': 'Token not found'}
    elif len(parts) > 2:
        return {'code': 'invalid_header', 'description': 'Authorization header must be Bearer + \s + token'}

    token = parts[1]
    try:

        company_id = "1"

        conn = sqlite3.connect('seaborg_god.db')
        conn.row_factory = dict_factory
        c = conn.cursor()
        c.execute("SELECT * FROM companies WHERE id LIKE ?", (company_id))
        company_info = c.fetchone()    

        payload = jwt.decode(
            token,
            company_info['jwt_secret']
            #audience=client_id
        )
    except jwt.ExpiredSignature:
        return authenticate({'code': 'token_expired', 'description': 'token is expired'})
    except jwt.InvalidAudienceError:
        return authenticate({'code': 'invalid_audience', 'description': 'incorrect audience, expected: ' + client_id})
    except jwt.DecodeError:
        return authenticate({'code': 'token_invalid_signature', 'description': 'token signature is invalid'})

    # print "decoded", payload
    # print "loading task id", item
    conn = sqlite3.connect('seaborg_god.db')
    conn.row_factory = dict_factory
    c = conn.cursor()

    c.execute("""SELECT i.name
          ,i.id
          ,i.outline
          ,i.creation_date
          ,i.approval_date
          ,i.rejection_date
          ,i.completion_date
          ,i.proposal_date
          ,i.created_by
          ,i.approved_by
          ,i.rejected_by
          ,i.completed_by
          ,i.proposed_by
          ,i.responsible
          ,i.reporting_to
          ,i.reporting_cycle
          ,i.progress_report_id
          ,i.final_report_id
          ,i.budget_id
          ,i.department_owner
          ,i.last_save
          ,i.deadline_date
          ,i.approval_requested
          ,e1.name AS created_name
          ,e2.name AS approved_name
          ,e3.name AS rejected_name
          ,e4.name AS completed_name
          ,e5.name AS proposed_name
          ,e6.name AS responsible_name
          ,e7.name AS reporting_to_name
          ,departments.title AS department_title
          ,departments.department_head AS department_head_id
          ,departments.parent_department AS parent_department_id
          ,depHeadPerson.name as department_approval_by
    FROM   tasks i 

    LEFT JOIN people e1 ON e1.id = i.created_by
    LEFT JOIN people e2 ON e2.id = i.approved_by
    LEFT JOIN people e3 ON e3.id = i.rejected_by
    LEFT JOIN people e4 ON e4.id = i.completed_by
    LEFT JOIN people e5 ON e5.id = i.proposed_by
    LEFT JOIN people e6 ON e6.id = i.responsible
    LEFT JOIN people e7 ON e7.id = i.reporting_to
    LEFT JOIN departments ON departments.id = i.department_owner
    LEFT JOIN people depHeadPerson ON departments.department_head = depHeadPerson.id
        WHERE i.id LIKE ?
    """, (item,))

    task = c.fetchone()

    if not task:
        c.close()
        return 'This item number does not exist!'
        

    task_id = str(item)
    # print "task_id", task_id
    c.execute("SELECT axioms.*, people.name as responsible_name, people.email as responsible_email FROM axioms, people WHERE axioms.task_id LIKE ? AND axioms.defined_by = people.id", (task_id,))
    axioms = c.fetchall()

    for axiom in axioms:
        if axiom['task_dependence_id']:
            print "the task has a depenendence"
            c.execute("SELECT name FROM tasks WHERE id = ?", (axiom['task_dependence_id'],))
            axiom_task = c.fetchone()
            axiom['dependence'] = {
                "name" : axiom_task['name'],
                "id" : axiom['task_dependence_id']
            }

    c.execute("SELECT * FROM goals WHERE task_id=?", (str(task_id),))
    goals = c.fetchall()
    # print goals

    c.execute("SELECT * FROM objectives WHERE task_id=?", (str(task_id),))
    objectives = c.fetchall()
    # print objectives


    c.execute("SELECT * FROM deliverables WHERE task_id=?", (str(task_id),))
    deliverables = c.fetchall()

    for obj in deliverables:
        if obj['isdelivered'] == 1:
            obj['isdelivered'] = True
        else:
            obj['isdelivered'] = False



    c.execute("SELECT * FROM task_references WHERE task_id=?", (str(task_id),))
    references = c.fetchall()
    # print references
    
    c.close()
    task['goals'] = goals    
    task['objectives'] = objectives
    task['references'] = references
    task['deliverables'] = deliverables
    task['axioms'] = axioms
    
    # TODO compute booleans: canEdit, canView, isApproved, isPending, isRejected, isProposer, isActive, isCompleted
    
    
    # output = template('view_task', task=task, active_user={"uid" : 1, "user_name" : "Morten Dam", "user_email" : "mdam@seaborg.co", "role_level" : role})
    # return {
    #     "user_id" : uid,
    #     "created_by_user" : task['created_by'] == uid
    # }
    return task

@route('/task/<item:re:[0-9]+>/delete')
def delete_task(item):
    return {"deleted" : item}
@route('/task/<item:re:[0-9]+>')
def show_task(item):
    return  template('view_task', task={"id" : item, "cid" : 1})


# @route('/task/new')
# def new_task():    
#         return template('view_task', task={"name" : "New task", "id" : "XX", "cid": 1})

@route('/task/new/submit', method="POST")
def new_task_submit():

    auth = request.headers.get("Authorization")
    if not auth:
        # print "auth failed"
        return authenticate({'code': 'authorization_header_missing', 'description': 'Authorization header is expected'})

    parts = auth.split()


    if parts[0].lower() != 'bearer':
        return {'code': 'invalid_header', 'description': 'Authorization header must start with Bearer'}
    elif len(parts) == 1:
        return {'code': 'invalid_header', 'description': 'Token not found'}
    elif len(parts) > 2:
        return {'code': 'invalid_header', 'description': 'Authorization header must be Bearer + \s + token'}

    token = parts[1]
    try:

        company_id = "1"

        conn = sqlite3.connect('seaborg_god.db')
        conn.row_factory = dict_factory
        c = conn.cursor()
        c.execute("SELECT * FROM companies WHERE id LIKE ?", (company_id))
        company_info = c.fetchone()    

        payload = jwt.decode(
            token,
            company_info['jwt_secret']
            #audience=client_id
        )
    except jwt.ExpiredSignature:
        return authenticate({'code': 'token_expired', 'description': 'token is expired'})
    except jwt.InvalidAudienceError:
        return authenticate({'code': 'invalid_audience', 'description': 'incorrect audience, expected: ' + client_id})
    except jwt.DecodeError:
        return authenticate({'code': 'token_invalid_signature', 'description': 'token signature is invalid'})

    # print "decoded", payload

    conn = sqlite3.connect('seaborg_god.db')
    conn.row_factory = dict_factory
    c = conn.cursor()

    data = request.json
    inval = (data["name"], data["outline"], data["creation_date"], data["created_by"], data["last_save"], data["deadline_date"], data["department_owner"], data["reporting_to"], data["responsible"], data["reporting_cycle"], payload['company_id'])
    c.execute("INSERT INTO tasks (name, outline, creation_date, created_by, last_save, deadline_date, department_owner, reporting_to, responsible, reporting_cycle, company_id) VALUES (?,?,?,?,?,?,?,?,?,?,?)", inval)
    conn.commit()
    task_id = c.lastrowid
    conn.close()


    return {"task_id" : task_id}

@route('/departments/json')
def get_departments():
    """docstring for get_people"""
    conn = sqlite3.connect('seaborg_god.db')
    conn.row_factory = dict_factory
    c = conn.cursor()
    c.execute("SELECT departments.*, people.name as responsible_name FROM departments, people WHERE departments.department_head = people.id;")
    departments = c.fetchall()    
    
    c.close()
    
    return {"departments" : departments}
    
@route('/people/json')
def get_people():
    """docstring for get_people"""
    conn = sqlite3.connect('seaborg_god.db')
    conn.row_factory = dict_factory
    c = conn.cursor()
    c.execute("SELECT departments.*, people.name as responsible_name FROM departments, people WHERE departments.department_head = people.id;")
    departments = c.fetchall()
    
    
    c.execute("SELECT * from people ORDER by name;");
    people = c.fetchall()
    c.close()
    
    return {"people" : people}
    


@route('/')
def overview():
    conn = sqlite3.connect('seaborg_god.db')
    conn.row_factory = dict_factory
    c = conn.cursor()
    c.execute("SELECT tasks.id, tasks.name, outline, responsible, approval_date, rejection_date, completion_date, people.name as responsible_name FROM tasks, people WHERE tasks.responsible = people.id")
    result = c.fetchall()
    c.close()

    output = template('overview', rows=result, company={"cid": 1})
    return output
    


@route('/static/<filepath:path>')
def server_static(filepath):
    return static_file(filepath, root='static')
    
@error(403)
def mistake403(code):
    return 'There is a mistake in your url!'

@error(404)
def mistake404(code):
    return 'Sorry, this page does not exist!'



if __name__ == '__main__':
    run(reloader=True, host='0.0.0.0', port=8087)
