% rebase('base.tpl', title="Task")

<script>
    global_company_id = "{{task['cid']}}";
    global_task_id = "{{task['id']}}";    
</script>

<link rel="stylesheet" type="text/css" href="/static/css/goal_editor.css">

<div ng-controller="GodViewController as god">
    <a href="/" >
        <div id="navi_menu">
            <div id="home_btn" class="menu_home">
        </div>
    </a>
    
        <div id="menu_left">
            <div class="menu_title">
                GOD-[[task_id]]-[[creation_date]] [[task_name]]
            </div>
            <div class="controls">
                <div style="float: left; margin-right: 20px;">File &nbsp; View &nbsp; Share &nbsp; Help</div>  <div id="save_status" ng-show="save_status"> Last save <span  span time-since="save_status" /></span></div>
            </div>


        </div>
        
        <div id="menu_right">
            <div class="user_menu"  ng-show="current_user_id">
               [[user_name]]  - [[user_email]] - <a ng-click="logout()">logout</a> 
            </div>

            <div class="master_controls">
                    <div id="reopen" class="menu_btn_purple control_btn" ng-click="reopenTask()" ng-show="userIsApprover() && (isApproved() || isRejected() || isCompleted())">
                    Reopen
                    </div>

<!--                     <div id="writeupdate" class="menu_btn_purple control_btn" ng-click="statusUpdate()" ng-show="userIsAssignee()">
                        Write update
                    </div>

                    <div id="requpdate" class="menu_btn_purple control_btn" ng-click="reqStatusUpdate()" ng-show="userIsReportingOfficer()">
                        Request status update
                    </div>
 -->
                    <div id="complete" class="menu_btn_purple control_btn" ng-click="complete()" ng-show="(userIsReportingOfficer() || userIsApprover()) && isApproved() && !isCompleted()">
                        Mark as completed
                    </div>

                    <div ng-show="userIsApprover() && approvalRequested() && !(isRejected() || isCompleted() || isApproved())">
                        <div id="reject" class="menu_btn_grey control_btn" ng-click="reject()">
                            Reject
                        </div>

                        <div id="approve" class="menu_btn_purple control_btn" ng-click="approve()">
                            Approve
                        </div>
                    </div>

                    <div id="requestApproval" class="menu_btn_purple control_btn" ng-click="requestApproval()"  ng-show="userIsCreator() && !approvalRequested()">
                        Request Approval
                    </div>                    

<!--                     <div id="share" class="menu_btn_purple control_btn" ng-click="share()">
                        Share
                    </div> -->

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
    

        <div id="status">
                <span ng-show="isApproved() && !(isCompleted() || isRejected())" style="color: green" title="Approved by [[approved_name]], [[approval_date]]">Task Approved</span>
                <span ng-show="isRejected()" style="color: red" title="Rejected by [[rejected_name]], [[rejection_date]]">Task Rejected</span>
                <span ng-show="isCompleted()" style="color: blue" title="Marked as completed by [[completed_name]], [[completion_date]]">Task completed</span>
                <span ng-show="approvalRequested() && !(isApproved() || isRejected() || isCompleted())" style="color: black" title="Pending approval by [[department_approval_by]]">Approval requested</span>

        </div>

    <span dropdown on-toggle="toggled(open)" ng-show="userCanEdit()">
      <a href id="simple-dropdown" dropdown-toggle>
          [[department_title]]
      </a>
      <ul class="dropdown-menu" aria-labelledby="simple-dropdown">
        <li ng-repeat="choice in departments">
          <a href ng-click="setDepartment(choice.id)">[[choice.title]]</a>
        </li>
      </ul>
    </span>
    <span ng-show="!userCanEdit()">
        [[department_title]]
    </span>

    <div ng-show="userCanEdit()">
    <textarea  id="title" name="title" ng-model="task_name" ng-change="outline_changed()" placeholder="Name of task ..."  auto-grow></textarea>  
    </div>
    <div  class="h1" ng-show="!userCanEdit()" id="title">
        [[task_name]]
    </div>
    
    <input type="hidden" id="deadline" ng-model="deadline_date" my-datepicker>
    <p class="deadline">Deadline: <span class="deadline_trigger" ng-show="userCanEdit()">[[deadline_date]]</span><span ng-show="!userCanEdit()">[[deadline_date]]</span></p>


    <b>Task assigned to:
    
    <span dropdown on-toggle="toggled(open)" ng-show="userCanEdit()">
      <a href id="simple-dropdown" dropdown-toggle>
        [[responsible_name]] <span ng-show="userIsAssignee()">(you)</span>
      </a>
      <ul class="dropdown-menu" aria-labelledby="simple-dropdown">
        <li ng-repeat="choice in people">
          <a href ng-click="setTaskResponsible(choice.id)">[[choice.name]]</a>
        </li>
      </ul>
    </span>
    <span ng-show="!userCanEdit()">[[responsible_name]] <span ng-show="userIsAssignee()">(you)</span></span>
    </b> 
    <br>
    Progress report to <span dropdown on-toggle="toggled(open)" ng-show="userCanEdit()">
      <a href id="simple-dropdown" dropdown-toggle>
        [[reporting_to_name]] <span ng-show="userIsReportingOfficer()">(you)</span>
      </a>
      <ul class="dropdown-menu" aria-labelledby="simple-dropdown">
        <li ng-repeat="choice in people">
          <a href ng-click="setReportingOfficer(choice.id)">[[choice.name]]</a>
        </li>
      </ul>

    </span>      <span ng-show="!userCanEdit()">[[reporting_to_name]] <span ng-show="userIsReportingOfficer()">(you)</span></span>
     every <span dropdown on-toggle="toggled(open)" ng-show="userCanEdit()">
      <a href id="simple-dropdown" dropdown-toggle>
        [[reporting_cycle]]
      </a>
      <ul class="dropdown-menu" aria-labelledby="simple-dropdown">
        <li ng-repeat="choice in reporting_days">
          <a href ng-click="setReportingInterval(choice)">[[choice]]</a>
        </li>
      </ul>
    </span> 
      <span ng-show="!userCanEdit()">[[reporting_cycle]]</span>
    days.



    <p></p>
    <br>

    <div class="h3" title="Start at a high level. Every task should have business benefit, expressed in terms such as increased quality, faster response/delivery time, or reduced costs/increased revenue. Most often, the business benefit is quantified in some way to get the project funded and prioritized in the first place. For example, your project may be able to reduce purchasing expenditures, create your product 25 percent faster, or increase company sales by 10 percent. Other times, the benefits are more intangible, such as increased customer satisfaction or better information for decision-making.">Business benefits</div>

    <div ng-show="userCanEdit()">
        <textarea id="outline" placeholder="Explain the purpose and benefits of the task ..." ng-change="outline_changed()" ng-model="outline" auto-grow></textarea>

    </div>
    <div ng-show="!userCanEdit()">
        <div id="outline">[[outline]]</div>
    </div>

    <div class="h3" title="Axioms are specific key requirements that specify the business benefits in detail.">Requirements</div>
    <ol>
        <li ng-repeat="axiom in axioms" class="item">
            <span ng-if="axiom.dependence">
                <span class="headline"><a ng-href="/task/[[axiom.dependence.id]]">[[axiom.dependence.name]]</a></span>
            </span>
            <span ng-if="!axiom.dependence">
                <span class="headline">[[axiom.name]]</span>
                <p class="comment">[[axiom.text]]</p>
            </span>
        </li>

        <div ng-show="userCanEdit()">
            <li ng-show="axiomEditorEnabled">
                <div>
                    <h3 style="padding: 0; margin: 0;"><input ng-model="name_axiom" type="text" name="name_axiom" value="" placeholder="Title of axiom ..." style="font: inherit; width: 100%" id="name_axiom"></h3>
                    <textarea ng-model="text_axiom" name="text_axiom" placeholder="Elaborate on the axiom if needed ..." style="min-height: 60px;"  auto-grow>></textarea>


                <b>OR:</b> <br>
                <h3><span dropdown on-toggle="toggled(open)" ng-show="userCanEdit()">
      <a href id="simple-dropdown" dropdown-toggle>
      [[dependence_axiom.name]]
      </a>
      <ul class="dropdown-menu" aria-labelledby="simple-dropdown">
        <li ng-repeat="choice in all_tasks" ng-if="choice.id != task_id">
          <a href ng-click="setTaskDependence(choice)">[[choice.name]]</a>
        </li>
      </ul>
    </span></h3><br><br>
                <input ng-click="newAxiom()" type="submit" name="newAxiom" value="Add axiom" id="newAxiom" style="float: right">
                <input ng-click="axiomEditorEnabled=!axiomEditorEnabled" value="Cancel" type="submit" style="float: right">
                </div>
            </li>
            <li style="list-style: none;"><a href="#" ng-show="!axiomEditorEnabled" ng-click="axiomEditorEnabled=!axiomEditorEnabled" style=" text-decoration: none; color: #888; font-size: 90%;">New requirement</a></li>
         </div>   
    </ol>

    <br>

    <div class="h3" title="Once you identify the business benefit, you can look at the overall project goals. These are high-level statements that describe what this particular project is going to do to help achieve business benefits. For example, a reengineering project could have goals for shortening work processes, reducing costs, and increasing customer satisfaction.">Goals</div>
    <ol>
        <li ng-repeat="goal in goals" class="item">
            <div>
                <span class="headline">[[goal.name]]</span>
                <p class="comment">[[goal.text]]</p>
            </div>
        </li>

        <div ng-show="userCanEdit()">
            <li ng-show="goalEditorEnabled" class="item">
                <div>
                    <h3 style="padding: 0; margin: 0;"><input ng-model="name_goal" type="text" name="name_goal" value="" placeholder="Title of goal ..." style="font: inherit; width: 100%" id="name_goal"></h3>
                    <textarea ng-model="text_goal" name="text_goal" placeholder="Elaborate on the goal if needed ..." style="min-height: 60px;"  auto-grow>></textarea>

                <input ng-click="newGoal()" type="submit" name="newGoal" value="Add goal" id="newGoal" style="float: right">
                <input ng-click="goalEditorEnabled=!goalEditorEnabled" value="Cancel" type="submit" style="float: right">
                </div>
            </li>
            <li style="list-style: none;"><a href="#" ng-show="!goalEditorEnabled" ng-click="goalEditorEnabled=!goalEditorEnabled" style=" text-decoration: none; color: #888; font-size: 90%;">New goal</a>
            </li>
        </div>
    </ol>
    <br>

    <div class="h3" title="At a more granular level are the objectives statements describing the specific planned results of your project and what it is trying to achieve. When you write an objective, remember the SMART acronym: Each objective should be specific, measurable, achievable, realistic, and timebound.

    The objectives state the meat of what the project is trying to achieve. When the project is complete, you need to be able to show that the objectives have all been satisfied. For example, in our reengineering scenario above, an objective might be to “reduce the time to process a sales order, from receipt to shipment, from ten days to two days, by September 30.” A deliverable to support that objective could be an in-house application that speeds the supply-chain process.

    On the other hand, actively communicating with your customer is not a project objective. It is part of your project approach (or how you execute the project). Likewise, keeping scope change to a minimum is not an objective. It is part of the project management procedures. At times, you may have a vague idea of the goals and objectives but struggle with trying to determine the best way to express them.">Objectives</div>

    <ol>
        <li ng-repeat="objective in objectives" class="item">
            <span class="headline">[[objective.name]]</span>
            <p cass="comment">[[objective.text]]</p>
        </li>


        <div ng-show="userCanEdit()">
            <li ng-show="objEditorEnabled">
                <div>
                    <h3 style="padding: 0; margin: 0;"><input ng-model="name_objective" type="text" name="name_objective" value="" placeholder="Title of objective ..." style="font: inherit; width: 100%" id="name_objective"></h3>
                    <textarea ng-model="text_objective" name="text_objective" placeholder="Elaborate on the objective if needed ..." style="min-height: 60px;"  auto-grow>></textarea>

                <input ng-click="newObjective()" type="submit" name="newObjective" value="Add objective" id="newObjective" style="float: right">
                <input ng-click="objEditorEnabled=!objEditorEnabled" value="Cancel" type="submit" style="float: right">
                </div>
            </li>
            <li style="list-style: none;"><a href="#" ng-show="!objEditorEnabled" ng-click="objEditorEnabled=!objEditorEnabled" style=" text-decoration: none; color: #888; font-size: 90%;">New objective</a></li>
        </div>
    </ol>

    <br>

<style>

</style>
    <div class="h3" title="The objectives should also be achieved through the completion of one or more deliverables, which are the items the project team is expected to provide. If an objective cannot be achieved based on the completion of one or more project deliverables, it is probably written at too high a level or perhaps it is an invalid objective for the project altogether.">Deliverables</div>

    <ol>
            <li ng-repeat="deliverable in deliverables" class="item">
                <div ng-class="{item_done: deliverable.isdelivered}">
                    <input type="checkbox" aria-label="Deliverable done" ng-model="deliverable.isdelivered" ng-checked="deliverable.isdelivered" ng-click="deliveredChanged(deliverable)" ng-show="userIsAssignee()" class="checkbox checkbox-success"> <span class="headline">[[deliverable.name]]</span>
                    <p class="comment">[[deliverable.text]]</p>
                </div>
                <div class="item_controls"><a ng-click="markDeliverableDone(deliverable.id)">Done</a>, <a ng-click="deleteDeliverable(deliverable.id)">Delete</a></div>
            </li>


        <div ng-show="userCanEdit()">
            <li ng-show="editorEnabled">
                <div>
                    <h3 style="padding: 0; margin: 0;"><input ng-model="name_deliverable" type="text" name="name_deliverable" value="" placeholder="Title of deliverable ..." style="font: inherit; width: 100%" id="name_deliverable"></h3>
                    <textarea ng-model="text_deliverable" name="text_deliverable" placeholder="Elaborate on the deliverable if needed ..." style="min-height: 60px;"  auto-grow>></textarea>

                <input ng-click="newDeliverable()" type="submit" name="newDeliverable" value="Add deliverable" id="newDeliverable" style="float: right">
                <input ng-click="editorEnabled=!editorEnabled" value="Cancel" type="submit" style="float: right">
                </div>
            </li>
            <li style="list-style: none;"><a href="#" ng-show="!editorEnabled" ng-click="editorEnabled=!editorEnabled" style=" text-decoration: none; color: #888; font-size: 90%;">New deliverable</a></li>
        </div>
    
    </ol>


    <br>
    <div class="h3" title="Give relevant references to background material and sources to help complete this task.">References</div>
    <ol>
        <li ng-repeat="reference in references" class="item">
            <div>
                <span class="headline"><a ng-href="[[reference.url]]">[[reference.text]]</a></span>
                <p class="comment">[[reference.comment]]</p>
            </div>
        </li>

        <div ng-show="userCanEdit()">
            <li ng-show="refEditorEnabled">
                <div>
                    <h3 style="padding: 0; margin: 0;"><input ng-model="text_ref" type="text" name="text_ref" value="" placeholder="Title of reference ..." style="font: inherit; width: 100%" id="name_ref"></h3>
                    <input ng-model="url_ref" type="text" name="url_ref" value="" placeholder="http:// ..." style="font: inherit; width: 100%" id="url_ref">
                    <textarea ng-model="comment_ref" name="comment_ref" placeholder="Comment on the reference if needed ..." style="min-height: 60px;"  auto-grow>></textarea>

                <input ng-click="newRef()" type="submit" name="newRef" value="Add reference" id="newRef" style="float: right">
                <input ng-click="refEditorEnabled=!refEditorEnabled" value="Cancel" type="submit" style="float: right">
                
                </div>
            </li>
            <li style="list-style: none;"><a href="#" ng-show="!refEditorEnabled" ng-click="refEditorEnabled=!refEditorEnabled" style=" text-decoration: none; color: #888; font-size: 90%;">New reference</a></li>
            </div>
    </ol>
<!-- 
    <div class="h3" >Progress report</div>
    <a ng-href="/task/[[task_id]]/progress_report">Go to Progress report</a>

    <div class="h3" >Final report</div>
    <a ng-href="/task/[[task_id]]/final_report">Go to Final report</a>



 -->    <hr>

    <div class="implicit_rules">
        Department director: [[department_approval_by]] <span ng-show="userIsApprover()">(you)</span><br>
        Task created by: [[created_name]] <span ng-show="userIsCreator()">(you)</span><br>
    </div>

    </div> 
    </div>
</div> 
<script>
$(document).ready(function() {
    $( document ).tooltip();

    // $('textarea').autogrow({vertical: true, horizontal: false});
    
//     $(function() {
//         $( "#deadline" ).datepicker({
//   beforeShowDay: $.datepicker.noWeekends
// });


    $(".deadline_trigger").click(function(){
        console.log("trigger");
        $( "#deadline" ).datepicker();
        $("#deadline").datepicker("show"); 
    }); 




    
    $(".item").on({
        mouseenter: function () {
            //stuff to do on mouse enter
            $(".item_controls",this).show();
        },
        mouseleave: function () {
            //stuff to do on mouse leave
            $(".item_controls", this).hide();
            
        }
    });
    

    //
    // var editor = new wysihtml5.Editor("outline", {
    //   toolbar:     "wysihtml5-editor-toolbar",
    //   stylesheets: ["http://yui.yahooapis.com/2.9.0/build/reset/reset-min.css", "/static/wysihtml5/website/css/editor.css"],
    //   parserRules: wysihtml5ParserRules
    // });
    //
    // editor.on("load", function() {
    //   var composer = editor.composer;
    //   composer.selection.selectNode(editor.composer.element.querySelector("h1"));
    // });

});

</script>


