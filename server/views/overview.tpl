% rebase('base.tpl', title='Task Overview')

<script>
    global_company_id = "{{company['cid']}}";
</script>


<link rel="stylesheet" type="text/css" href="/static/css/goal_editor.css">

<div ng-controller="GodOverview as god">

<div class="top_menu">
    <a href="/" >
        <div id="navi_menu">
            <div id="home_btn" class="menu_home">
        </div>
    </a>
    
        <div id="menu_left">
            <div class="menu_title">
                [[company.company_name]]
            </div>
            <div class="controls" ng-show="!userIsAnonymous()">
                <div style="float: left; margin-right: 20px;">

                    <a href="#" ng-click="init_new_task()" style="color: inherit;">New task</a> &nbsp; <a href="/org" style="color: inherit;" >Company structure</a>
                </div>
            </div>


        </div>
        
        <div id="menu_right">
            <div class="user_menu"  ng-show="current_user_id">
               [[user_name]]  - [[user_email]] - <a ng-click="logout()">logout</a>
            </div>
            <div class="master_controls">
            </div>
        </div>

</div>

<div class="new_bob" ng-click="init_new_task()" title="Add new task" ng-show="!userIsAnonymous()"></div>

<!--     <div style="position: absolute; top: 60px; width: 100%; box-shadow: 0px 2px 3px #ccc; height: 30px; border-top: 1px solid #e8e8e8; background-color: #efefef; z-index: 100; padding: 3px; font-weight: bold; color: purple" ng-show="!userIsAnonymous()">
    <span style="float: left; margin-left: 10px; color: #555;"><a href="#" ng-click="init_new_task()" style="color: inherit;">New task</a></span>
    <span style="float: right; color: #555;">
        <a href="#" ng-click="overview_view=1" style="color: inherit;">box</a> – <a href="#" ng-click="overview_view=2" style="color: inherit;">gantt</a> – <a href="#" ng-click="overview_view=3" style="color: inherit;">list</a> - <a href="#" ng-click="overview_view=4" style="color: inherit;">people</a> – <a href="#" ng-click="overview_view=5" style="color: inherit;">flowchart</a> – <a href="#" ng-click="overview_view=6" style="color: inherit;">calendar</a>
    </span>
    </div>         -->
    <div id="paper_frame">
    <div class="paper login_screen" ng-show="userIsAnonymous()">
        <img src="/static/images/padlock.png">
                  <form ng-submit="login_submit()" >
                    <div>[[message]]</div>

                <input ng-model="user_login.username" type="text" name="user" placeholder="Username" /><br>
                <input ng-model="user_login.password" type="password" name="pass" placeholder="Password" /><br>

                <div ng-show="user_login.must_change_pass">
                    <input ng-model="user_login.new_password_1" type="password" name="new_pass_1" placeholder="New password" /><br>
                    <input ng-model="user_login.new_password_2" type="password" name="new_pass_2" placeholder="Retype new password" /><br>
                </div>
                <br>
                <div ng-show="!user_login.change_pass">Change password: <input type='checkbox' ng-model="user_login.must_change_pass" title="change password"></div>
                <br>
                                <input type="submit" value="Login" />
              </form>

    </div>

    <div ng-show="!userIsAnonymous()" style="margin: 70px 30px;">
    
        <div ng-show="overview_view==1" >

        <h2 class="box_view">Active tasks</h2>

        <div class="task_box_wrap">

           <div  ng-repeat="task in tasks | orderBy:'deadlineDue'" ng-show="task.state == 'isApproved'" ng-mouseover="hovered = true" ng-mouseout="hovered = false" class="overview_view_box" ng-class="[{task_box_approved: task.state =='isApproved'}, {task_box_rejected: task.state =='isRejected'}, {task_box_draft: task.state =='isDraft'}, {task_box_completed: task.state =='isCompleted'}, {task_box_pending: task.state =='isPendingApproval'}]" ng-click="gotoTask(task.id)">

                <div class="delBtn" ng-class="{showDeleteBtn:hovered}" ng-confirm-click="delete_task(task.id)" ng-confirm-click-message="Do you want to permanently delete this task?" ></div>

                <span class="task_department">[[task.department_title]]<br></span>

                <span class="task_name" title="[[task.outline]]">[[task.name]]</span><br>
                <br>
                <div class="task_assigned">Task assigned to:<br><b>[[task.responsible_name]]</b></div>
                
                <div class="task_deadline">Deadline by [[task.deadline_date]].</div>
                <div  ng-class="[{deliverables_all_checked: (task.ndelivered-task.ndeliverables)==0 && task.ndeliverables > 0},{status_deliverables: (task.ndelivered-task.ndeliverables)!=0 || task.ndeliverables == 0}]" >
                    <input type="checkbox" checked="checked" disabled> [[task.ndelivered]]/[[task.ndeliverables]]
                </div>
                <div class="task_due_box" ng-class="[{task_due: task.deadlineDue == 0}, {task_overdue: task.deadlineDue < 0}, {task_not_due: task.deadlineDue > 0}]">
                    <span ng-if="(task.deadlineDue < 0) && (task.ndelivered-task.ndeliverables) != 0">Task overdue</span>
                    <span ng-if="task.deadlineDue > 0">Task due in [[task.deadlineDue]] days</span>
                    <span ng-if="task.deadlineDue == 0">Task due today</span>
                </div>

            </div>
        </div>


        <h2 class="box_view">Tasks pending approval</h2>

        <div class="task_box_wrap">

           <div  ng-repeat="task in tasks | orderBy:'deadlineDue'" ng-show="task.state == 'isPendingApproval'" ng-mouseover="hovered = true" ng-mouseout="hovered = false" class="overview_view_box" ng-class="[{task_box_approved: task.state =='isApproved'}, {task_box_rejected: task.state =='isRejected'}, {task_box_draft: task.state =='isDraft'}, {task_box_completed: task.state =='isCompleted'}, {task_box_pending: task.state =='isPendingApproval'}]" ng-click="gotoTask(task.id)">

                <div class="delBtn" ng-class="{showDeleteBtn:hovered}" ng-confirm-click="delete_task(task.id)" ng-confirm-click-message="Do you want to permanently delete this task?" ></div>
                <!-- <div class="task_is_draft" ng-show="task.state =='isDraft'">Draft</div> -->
                <!-- <div class="task_is_pending_approval" ng-show="task.state =='isPendingApproval'">Approval requested</div> -->
                <!-- <div class="task_is_approved" ng-show="task.state =='isApproved'">Approved</div> -->
                <span class="task_department">[[task.department_title]]<br></span>

                <span class="task_name" title="[[task.outline]]">[[task.name]]</span><br>
                <br>
                <div class="task_assigned">Task assigned to:<br><b>[[task.responsible_name]]</b></div>
                
                <div class="task_deadline">Deadline by [[task.deadline_date]].</div>
                <div  ng-class="[{deliverables_all_checked: (task.ndelivered-task.ndeliverables)==0 && task.ndeliverables > 0},{status_deliverables: (task.ndelivered-task.ndeliverables)!=0 || task.ndeliverables == 0}]" >
                    <input type="checkbox" checked="checked" disabled> [[task.ndelivered]]/[[task.ndeliverables]]
                </div>
                <div class="task_due_box" ng-class="[{task_due: task.deadlineDue == 0}, {task_overdue: task.deadlineDue < 0}, {task_not_due: task.deadlineDue > 0}]">
                    <span ng-if="(task.deadlineDue < 0) && (task.ndelivered-task.ndeliverables) != 0">Task overdue</span>
                    <span ng-if="task.deadlineDue > 0">Task due in [[task.deadlineDue]] days</span>
                    <span ng-if="task.deadlineDue == 0">Task due today</span>
                </div>

            </div>
        </div>



        <h2 class="box_view">Drafts</h2>

        <div class="task_box_wrap">

           <div  ng-repeat="task in tasks | orderBy:'deadlineDue'" ng-show="task.state == 'isDraft'" ng-mouseover="hovered = true" ng-mouseout="hovered = false" class="overview_view_box" ng-class="[{task_box_approved: task.state =='isApproved'}, {task_box_rejected: task.state =='isRejected'}, {task_box_draft: task.state =='isDraft'}, {task_box_completed: task.state =='isCompleted'}, {task_box_pending: task.state =='isPendingApproval'}]" ng-click="gotoTask(task.id)">

                <div class="delBtn" ng-class="{showDeleteBtn:hovered}" ng-confirm-click="delete_task(task.id)" ng-confirm-click-message="Do you want to permanently delete this task?" ></div>
                <!-- <div class="task_is_draft" ng-show="task.state =='isDraft'">Draft</div> -->
                <!-- <div class="task_is_pending_approval" ng-show="task.state =='isPendingApproval'">Approval requested</div> -->
                <!-- <div class="task_is_approved" ng-show="task.state =='isApproved'">Approved</div> -->
                <span class="task_department">[[task.department_title]]<br></span>

                <span class="task_name" title="[[task.outline]]">[[task.name]]</span><br>
                <br>
                <div class="task_assigned">Task assigned to:<br><b>[[task.responsible_name]]</b></div>
                
                <div class="task_deadline">Deadline by [[task.deadline_date]].</div>
                <div  ng-class="[{deliverables_all_checked: (task.ndelivered-task.ndeliverables)==0 && task.ndeliverables > 0},{status_deliverables: (task.ndelivered-task.ndeliverables)!=0 || task.ndeliverables == 0}]" >
                    <input type="checkbox" checked="checked" disabled> [[task.ndelivered]]/[[task.ndeliverables]]
                </div>
                <div class="task_due_box" ng-class="[{task_due: task.deadlineDue == 0}, {task_overdue: task.deadlineDue < 0}, {task_not_due: task.deadlineDue > 0}]">
                    <span ng-if="(task.deadlineDue < 0) && (task.ndelivered-task.ndeliverables) != 0">Task overdue</span>
                    <span ng-if="task.deadlineDue > 0">Task due in [[task.deadlineDue]] days</span>
                    <span ng-if="task.deadlineDue == 0">Task due today</span>
                </div>

            </div>
        </div>



        <h2 class="box_view">Completed tasks</h2>

        <div class="task_box_wrap">

           <div  ng-repeat="task in tasks | orderBy:'deadlineDue'" ng-show="task.state == 'isCompleted'" ng-mouseover="hovered = true" ng-mouseout="hovered = false" class="overview_view_box" ng-class="[{task_box_approved: task.state =='isApproved'}, {task_box_rejected: task.state =='isRejected'}, {task_box_draft: task.state =='isDraft'}, {task_box_completed: task.state =='isCompleted'}, {task_box_pending: task.state =='isPendingApproval'}]" ng-click="gotoTask(task.id)">

                <div class="delBtn" ng-class="{showDeleteBtn:hovered}" ng-confirm-click="delete_task(task.id)" ng-confirm-click-message="Do you want to permanently delete this task?" ></div>
                <!-- <div class="task_is_draft" ng-show="task.state =='isDraft'">Draft</div> -->
                <!-- <div class="task_is_pending_approval" ng-show="task.state =='isPendingApproval'">Approval requested</div> -->
                <!-- <div class="task_is_approved" ng-show="task.state =='isApproved'">Approved</div> -->
                <span class="task_department">[[task.department_title]]<br></span>

                <span class="task_name" title="[[task.outline]]">[[task.name]]</span><br>
                <br>
                <div class="task_assigned">Task assigned to:<br><b>[[task.responsible_name]]</b></div>
                
                <div class="task_deadline">Deadline by [[task.deadline_date]].</div>
                <div  ng-class="[{deliverables_all_checked: (task.ndelivered-task.ndeliverables)==0},{status_deliverables: (task.ndelivered-task.ndeliverables)!=0}]">
                    <input type="checkbox" checked="checked" disabled> [[task.ndelivered]]/[[task.ndeliverables]]
                </div>
                <div  ng-class="[{deliverables_all_checked: (task.ndelivered-task.ndeliverables)==0 && task.ndeliverables > 0},{status_deliverables: (task.ndelivered-task.ndeliverables)!=0 || task.ndeliverables == 0}]" >
                    <span ng-if="(task.deadlineDue < 0) && (task.ndelivered-task.ndeliverables) != 0">Task overdue</span>
                    <span ng-if="task.deadlineDue > 0">Task due in [[task.deadlineDue]] days</span>
                    <span ng-if="task.deadlineDue == 0">Task due today</span>
                </div>

            </div>
        </div>


        <h2 class="box_view">Rejected tasks</h2>

        <div class="task_box_wrap">

           <div  ng-repeat="task in tasks | orderBy:'deadlineDue'" ng-show="task.state == 'isRejected'" ng-mouseover="hovered = true" ng-mouseout="hovered = false" class="overview_view_box" ng-class="[{task_box_approved: task.state =='isApproved'}, {task_box_rejected: task.state =='isRejected'}, {task_box_draft: task.state =='isDraft'}, {task_box_completed: task.state =='isCompleted'}, {task_box_pending: task.state =='isPendingApproval'}]" ng-click="gotoTask(task.id)">

                <div class="delBtn" ng-class="{showDeleteBtn:hovered}" ng-confirm-click="delete_task(task.id)" ng-confirm-click-message="Do you want to permanently delete this task?" ></div>
                <!-- <div class="task_is_draft" ng-show="task.state =='isDraft'">Draft</div> -->
                <!-- <div class="task_is_pending_approval" ng-show="task.state =='isPendingApproval'">Approval requested</div> -->
                <!-- <div class="task_is_approved" ng-show="task.state =='isApproved'">Approved</div> -->
                <span class="task_department">[[task.department_title]]<br></span>

                <span class="task_name" title="[[task.outline]]">[[task.name]]</span><br>
                <br>
                <div class="task_assigned">Task assigned to:<br><b>[[task.responsible_name]]</b></div>
                
                <div class="task_deadline">Deadline by [[task.deadline_date]].</div>
                <div  ng-class="[{deliverables_all_checked: (task.ndelivered-task.ndeliverables)==0 && task.ndeliverables > 0},{status_deliverables: (task.ndelivered-task.ndeliverables)!=0 || task.ndeliverables == 0}]" >
                    <input type="checkbox" checked="checked" disabled> [[task.ndelivered]]/[[task.ndeliverables]]
                </div>
                <div class="task_due_box" ng-class="[{task_due: task.deadlineDue == 0}, {task_overdue: task.deadlineDue < 0}, {task_not_due: task.deadlineDue > 0}]">
                    <span ng-if="(task.deadlineDue < 0) && (task.ndelivered-task.ndeliverables) != 0">Task overdue</span>
                    <span ng-if="task.deadlineDue > 0">Task due in [[task.deadlineDue]] days</span>
                    <span ng-if="task.deadlineDue == 0">Task due today</span>
                </div>

            </div>
        </div>


    </div>
    </div>
    <div ng-show="overview_view==2">
        Gantt
    </div>
        <div ng-show="overview_view==3">
        <div class="paper"><div id="grid1" ui-grid="gridOptions" class="grid"></div></div>
        <div class="paper" >
                <h1>List</h1>

            <div>Tasks assigned <b>to</b> me:
    <ul>
        <li ng-repeat="task in tasks" ng-if="task.isAssignee">
            <a href="/task/[[task.id]]">[[task.name]]</a> - due: <span ng-class="[{task_due: task.deadlineDue == 0}, {task_overdue: task.deadlineDue < 0}, {task_not_due: task.deadlineDue > 0}]">[[task.deadlineDue]] days</span>
            <ul ng-repeat="deliverable in task.deliverables">
                <input type="checkbox" aria-label="Deliverable done" ng-model="deliverable.isdelivered" ng-checked="deliverable.isdelivered" ng-click="deliveredChanged(deliverable)"> [[deliverable.name]]
            </ul>
        </li>
    </ul>
    </div>

        </div>
        <div class="paper">
                    <div>Tasks assigned <b>by</b> me:
            <ul>
                <li ng-repeat="task in tasks" ng-if="task.isCreator">
                                <div style="padding: 0px; height: 10px; border: 1px solid #333; display: inline-block; position: relative;">
                        <div ng-repeat="deliverable in task.deliverables | orderBy:'-isdelivered'" ng-class="[{task_done_fill: deliverable.isdelivered}]" style="margin: 0; padding: 0; float: left; width: 10px; height: 100%;  position: relative;"></div>
                    </div> <a href="/task/[[task.id]]">[[task.name]]</a> - due: <span ng-class="[{task_due: task.deadlineDue == 0}, {task_overdue: task.deadlineDue < 0}, {task_not_due: task.deadlineDue > 0}]">[[task.deadlineDue]] days</span> 
                    <ul ng-repeat="deliverable in task.deliverables">
                        <input type="checkbox" aria-label="Deliverable done" ng-model="deliverable.isdelivered" ng-checked="deliverable.isdelivered" ng-click="deliveredChanged(deliverable)"> [[deliverable.name]]
                    </ul>
                </li>

            </div>
            </ul>
        </div>
    </div>
        <div ng-show="overview_view==4">
        People
    </div>
        <div ng-show="overview_view==5">
        Flowchart
    </div>
    <div ng-show="overview_view==6">
        Calendar
    </div>
    </div> <!-- !userIsAnonymous() -->

    <div class="paper"  ng-show="!userIsAnonymous()" style="display: none">


    <h1>Task overview</h1>
    This view should make it easy to see what tasks relevant to you, are in progress.


    <hr>

    <div>Tasks assigned <b>to</b> me:
    <ul>
        <li ng-repeat="task in tasks" ng-if="task.isAssignee">
            <a href="/task/[[task.id]]">[[task.name]]</a> - due: <span ng-class="[{task_due: task.deadlineDue == 0}, {task_overdue: task.deadlineDue < 0}, {task_not_due: task.deadlineDue > 0}]">[[task.deadlineDue]] days</span>
            <ul ng-repeat="deliverable in task.deliverables">
                <input type="checkbox" aria-label="Deliverable done" ng-model="deliverable.isdelivered" ng-checked="deliverable.isdelivered" ng-click="deliveredChanged(deliverable)"> [[deliverable.name]]
            </ul>
        </li>

    </div>
    
    <div>Tasks assigned <b>by</b> me:
    <ul>
        <li ng-repeat="task in tasks" ng-if="task.isCreator">
                        <div style="padding: 0px; height: 10px; border: 1px solid #333; display: inline-block; position: relative;">
                <div ng-repeat="deliverable in task.deliverables | orderBy:'-isdelivered'" ng-class="[{task_done_fill: deliverable.isdelivered}]" style="margin: 0; padding: 0; float: left; width: 10px; height: 100%;  position: relative;"></div>
            </div> <a href="/task/[[task.id]]">[[task.name]]</a> - due: <span ng-class="[{task_due: task.deadlineDue == 0}, {task_overdue: task.deadlineDue < 0}, {task_not_due: task.deadlineDue > 0}]">[[task.deadlineDue]] days</span> 
            <ul ng-repeat="deliverable in task.deliverables">
                <input type="checkbox" aria-label="Deliverable done" ng-model="deliverable.isdelivered" ng-checked="deliverable.isdelivered" ng-click="deliveredChanged(deliverable)"> [[deliverable.name]]
            </ul>
        </li>

    </div>
    
    <div>Tasks approved by me:
    <ul>
        <li ng-repeat="task in tasks" ng-if="task.isApprover && task.isApproved">
            <a href="/task/[[task.id]]">[[task.name]]</a> - due: <span ng-class="[{task_due: task.deadlineDue == 0}, {task_overdue: task.deadlineDue < 0}, {task_not_due: task.deadlineDue > 0}]">[[task.deadlineDue]] days</span>
            <ul ng-repeat="deliverable in task.deliverables">
                <input type="checkbox" aria-label="Deliverable done" ng-model="deliverable.isdelivered" ng-checked="deliverable.isdelivered" ng-click="deliveredChanged(deliverable)"> [[deliverable.name]]
            </ul>
        </li>

    </div>

    <div>Tasks rejected by me:
    <ul>
        <li ng-repeat="task in tasks" ng-if="task.isApprover && task.isRejected">
            <a href="/task/[[task.id]]">[[task.name]]</a> - due: <span ng-class="[{task_due: task.deadlineDue == 0}, {task_overdue: task.deadlineDue < 0}, {task_not_due: task.deadlineDue > 0}]">[[task.deadlineDue]] days</span>
            <ul ng-repeat="deliverable in task.deliverables">
                <input type="checkbox" aria-label="Deliverable done" ng-model="deliverable.isdelivered" ng-checked="deliverable.isdelivered" ng-click="deliveredChanged(deliverable)"> [[deliverable.name]]
            </ul>
        </li>

    </div>

    <div>Tasks marked as completed by me:
    <ul>
        <li ng-repeat="task in tasks" ng-if="task.isApprover && task.isCompleted">
            <a href="/task/[[task.id]]">[[task.name]]</a> - due: <span ng-class="[{task_due: task.deadlineDue == 0}, {task_overdue: task.deadlineDue < 0}, {task_not_due: task.deadlineDue > 0}]">[[task.deadlineDue]] days</span>
            <ul ng-repeat="deliverable in task.deliverables">
                <input type="checkbox" aria-label="Deliverable done" ng-model="deliverable.isdelivered" ng-checked="deliverable.isdelivered" ng-click="deliveredChanged(deliverable)"> [[deliverable.name]]
            </ul>
        </li>

    </div>


    <div>Tasks pending approval by me :
    <ul>
        <li ng-repeat="task in tasks" ng-if="task.isApprover && task.isPendingApproval && !(task.isApproved || task.isRejected || task.isCompleted)">
            <a href="/task/[[task.id]]">[[task.name]]</a> - due: <span ng-class="[{task_due: task.deadlineDue == 0}, {task_overdue: task.deadlineDue < 0}, {task_not_due: task.deadlineDue > 0}]">[[task.deadlineDue]] days</span>
            <ul ng-repeat="deliverable in task.deliverables">
                <input type="checkbox" aria-label="Deliverable done" ng-model="deliverable.isdelivered" ng-checked="deliverable.isdelivered" ng-click="deliveredChanged(deliverable)"> [[deliverable.name]]
            </ul>
        </li>

    </div>








    <h1>Open tasks</h1>

    <table border="1">
        <tr>
            <td>Task</td>
            <td>Status</td>
            <td>Responsible</td>
                <td></td>

        </tr>
        

    <tr ng-repeat="task in tasks">

            <td><a ng-href="/task/[[task.id]]" title="[[task.outline]]">[[task.name]]</a></td>
            <td>[[task.approval_date]]</td>
            <td>[[task.responsible_name]]</td>
            <td><button confirmed-click="delete_task(task.id)" ng-confirm-click="This will permenantly delete the task, sure?">Remove</button></td>
    </tr>

    </table>
    

    <!-- <div gantt data=ganttdata></div> -->
</div>
</div>

</div>