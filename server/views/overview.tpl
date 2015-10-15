% rebase('base.tpl', title='Task Overview')

<script>
    global_company_id = "{{company['cid']}}";
</script>


<link rel="stylesheet" type="text/css" href="/static/css/goal_editor.css">

<div ng-controller="GodOverview as god">


    <a href="/" >
        <div id="navi_menu">
            <div id="home_btn" class="menu_home">
        </div>
    </a>
    
        <div id="menu_left">
            <div class="menu_title">
                Goals, Objectives and Deliverables
            </div>
            <div class="controls">
                <div style="float: left; margin-right: 20px;">
                    <a href="" ng-click="init_new_task()">New task</a>
                    <a href="/org" >Company</a>
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

    <div id="paper_frame">
    <div class="paper login_screen" ng-show="userIsAnonymous()">
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
    <div class="paper"  ng-show="!userIsAnonymous()">
    
    <div>Tasks assigned to me:
    <ul>
        <li ng-repeat="task in tasks" ng-if="task.isAssignee">
            <a href="/task/[[task.id]]">[[task.name]]</a> - deadline: [[task.deadlineDue]] days
            <ul ng-repeat="deliverable in task.deliverables">
                <input type="checkbox" aria-label="Deliverable done" ng-model="deliverable.isdelivered" ng-checked="deliverable.isdelivered" ng-click="deliveredChanged(deliverable)"> [[deliverable.name]]
            </ul>
        </li>

    </div>
    
    <div>Tasks assigned by me:
    <ul>
        <li ng-repeat="task in tasks" ng-if="task.isCreator">
            <a href="/task/[[task.id]]">[[task.name]]</a> - due: <span ng-class="[{task_due: task.deadlineDue == 0}, {task_overdue: task.deadlineDue < 0}, {task_not_due: task.deadlineDue > 0}]">[[task.deadlineDue]] days</span>
            <ul ng-repeat="deliverable in task.deliverables">
                <input type="checkbox" aria-label="Deliverable done" ng-model="deliverable.isdelivered" ng-checked="deliverable.isdelivered" ng-click="deliveredChanged(deliverable)"> [[deliverable.name]]
            </ul>
        </li>

    </div>
    
    <div>Tasks approved by me:
    <ul>
        <li ng-repeat="task in tasks" ng-if="task.isApprover && task.isApproved">
            <a href="/task/[[task.id]]">[[task.name]]</a> - deadline: [[task.deadlineDue]] days
            <ul ng-repeat="deliverable in task.deliverables">
                <input type="checkbox" aria-label="Deliverable done" ng-model="deliverable.isdelivered" ng-checked="deliverable.isdelivered" ng-click="deliveredChanged(deliverable)"> [[deliverable.name]]
            </ul>
        </li>

    </div>

    <div>Tasks rejected by me:
    <ul>
        <li ng-repeat="task in tasks" ng-if="task.isApprover && task.isRejected">
            <a href="/task/[[task.id]]">[[task.name]]</a> - deadline: [[task.deadlineDue]] days
            <ul ng-repeat="deliverable in task.deliverables">
                <input type="checkbox" aria-label="Deliverable done" ng-model="deliverable.isdelivered" ng-checked="deliverable.isdelivered" ng-click="deliveredChanged(deliverable)"> [[deliverable.name]]
            </ul>
        </li>

    </div>

    <div>Tasks marked as completed by me:
    <ul>
        <li ng-repeat="task in tasks" ng-if="task.isApprover && task.isCompleted">
            <a href="/task/[[task.id]]">[[task.name]]</a> - deadline: [[task.deadlineDue]] days
            <ul ng-repeat="deliverable in task.deliverables">
                <input type="checkbox" aria-label="Deliverable done" ng-model="deliverable.isdelivered" ng-checked="deliverable.isdelivered" ng-click="deliveredChanged(deliverable)"> [[deliverable.name]]
            </ul>
        </li>

    </div>


    <div>Tasks pending approval by me :
    <ul>
        <li ng-repeat="task in tasks" ng-if="task.isApprover && task.isPendingApproval && !(task.isApproved || task.isRejected || task.isCompleted)">
            <a href="/task/[[task.id]]">[[task.name]]</a> - deadline: [[task.deadlineDue]] days
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
    
</div>
</div>

</div>