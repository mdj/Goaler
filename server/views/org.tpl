% rebase('base.tpl')

<script>
    global_company_id = "{{company['cid']}}";
</script>

<link rel="stylesheet" type="text/css" href="/static/css/goal_editor.css">
<style>
table {
    border-collapse: inherit; /* to avoid bootstrap.css interfering with google chart */
}
</style>

<div ng-controller="OrgOverview as god">

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

    <div id="paper_frame">

    <div class="paper login_screen" ng-show="userIsAnonymous()">
        <img src="/static/images/padlock.png" style="width: 100px; height: auto; margin-bottom: 30px;">
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
        <h2>Company structure</h2>
        <p>The following chart show how the approval structure is organised. The assigned people reflect the person approving tasks in the respective category.</p>
            <div google-chart chart="chart"//>
        </div>



</div>  <!-- controller -->