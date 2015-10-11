% rebase('base.tpl', title='New task')

GOD Service > <a href="/">Overview</a> > New task

<div ng-controller="GodCreatorController as god">
<br>
<br>

<input style="font-size: 200%;" type="text" ng-model="god.title" name="title" placeholder="New task name" id="title" >

<br>

<label for="speed">Requested by:</label>
    <select ng-model="god.requested_by" name="requested_by" id="requested_by">

% for person in people:
 <option value="{{person['id']}}">{{person['name']}} <Br>
% end
</select>
<input type="hidden"  ng-model="god.requested_by" value="{{active_user['uid']}}">    

<br>
<br>
<label for="speed">Department:</label>
    <select ng-model="god.department" name="department" id="department">
        % for dep in departments:
            <option value="{{dep['id']}}">{{dep['title']}} - (Approval by {{dep['responsible_name']}})</option>
        % end
</select>
<br>
<label for="speed">Task responsible:</label>
    <select ng-model="god.responsible" name="responsible" id="responsible">

% for person in people:
 <option value="{{person['id']}}">{{person['name']}} <Br>
% end
</select>

<br>
<label for="speed">Task reporting to:</label>
    <select ng-model="god.reporting_officer" name="reporting_officer" id="reporting_officer">
% for person in people:
 <option value="{{person['id']}}">{{person['name']}} <Br>
% end
</select>
<br>
Reporting interval:
<select ng-model="god.reporting_cycle">
    <option value="1">Daily</option>
    <option value="2">Bi-daily</option>
    <option value="5">Weekly</option>
    <option value="10">Bi-weekly</option>
    <option value="30">Monthly</option>
</select>

<h2>Outline</h2>
<div class="ui-widget">
	<p>
        <textarea  id="outline" spellcheck="false" wrap="off" autofocus placeholder="Enter something ..."  ng-model="god.outline" name="outline" rows="8" cols="40">
    </textarea>
    </p>
</div>
[[god.outline]]
[[god.title]]
[[god.department]]
<h2>Axioms</h2>
<ol>
      <li ng-repeat="axiom in god.axioms">
          <input type="checkbox" ng-model="axiom.done">
          <span class="done-[[axiom.done]]">[[axiom.text]]</span>
        </li>
</ol>
<form ng-submit="god.addAxiom()">
        <input type="text" ng-model="god.axiomText"  size="30"
               placeholder="add new axiom here">
        <input class="btn-primary" type="submit" value="add">
</form>

<h2>Goals</h2>
<ol>
      <li ng-repeat="goal in god.goals">
          <input type="checkbox" ng-model="goal.done">
          <span class="done-[[goal.done]]">[[goal.text]]</span>
        </li>
</ol>
<form ng-submit="god.addGoal()">
        <input type="text" ng-model="god.goalText"  size="30"
               placeholder="add new goal here">
        <input class="btn-primary" type="submit" value="add">
</form>

<h2>Objectives</h2>
<ol>
      <li ng-repeat="objective in god.objectives">
          <input type="checkbox" ng-model="objective.done">
          <span class="done-[[objective.done]]">[[objective.text]]</span>
        </li>
</ol>
<form ng-submit="god.addObjective()">
        <textarea ng-model="god.objectiveText"  size="30"
               placeholder="add new objective here"></textarea>
        <input class="btn-primary" type="submit" value="add">
</form>

<h2>Deliverables</h2>
<ol>
      <li ng-repeat="deliverable in god.deliverables">
          <input type="checkbox" ng-model="deliverable.done">
          <span class="done-[[deliverable.done]]">[[deliverable.text]]</span>
        </li>
</ol>
<form ng-submit="god.addDeliverable()">
        <input type="text" ng-model="god.deliverableText"  size="30"
               placeholder="add new deliverable here">
        <input class="btn-primary" type="submit" value="add">
</form>

<h2>References</h2>
<ol>
      <li ng-repeat="reference in god.references">
          <input type="checkbox" ng-model="reference.done">
          <span class="done-[[reference.done]]">[[reference.text]]</span>
        </li>
</ol>
<form ng-submit="god.addReference()">
        <input type="text" ng-model="god.referenceText"  size="30"
               placeholder="add new reference here">
        <input class="btn-primary" type="submit" value="add">
</form>

<br>
<button ng-click="god.save()" id="button">Save document</button>
</div>

