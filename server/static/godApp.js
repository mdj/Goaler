var app = angular.module('godApp', ['ui.bootstrap','timeSince','googlechart','ui.grid'],function($interpolateProvider) {
    // set custom delimiters for angular templates
    $interpolateProvider.startSymbol('[[');
    $interpolateProvider.endSymbol(']]');
});


app.directive('orgchart', function() {
      return {
        restrict: 'E',
        link: function($scope, $elm) {

          // Instantiate and draw our chart, passing in some options.
          var chart = new google.visualization.OrgChart($elm[0]);
          chart.draw($scope.orgChartData);
        }
    }
  });
    

app.factory('authInterceptor', function ($rootScope, $q, $window) {
  return {
    request: function (config) {
      config.headers = config.headers || {};
      if ($window.sessionStorage.token) {
        config.headers.Authorization = 'Bearer ' + $window.sessionStorage.token;
      }
      return config;
    },
    response: function (response) {
      if (response.status === 401) {
        // handle the case where the user is not authenticated
      }
      return response || $q.when(response);
    }
  };
});

app.config(function ($httpProvider) {
  $httpProvider.interceptors.push('authInterceptor');
});


app.directive('myDatepicker', function ($parse) {
    return function (scope, element, attrs, controller) {
        var ngModel = $parse(attrs.ngModel);
        $(function(){
            element.datepicker({
                // showOn:"both",
                // changeYear:true,
                // changeMonth:true,
                dateFormat:'yy-mm-dd',
                // maxDate: new Date(),
                // yearRange: '1920:2012',
                onSelect:function (dateText, inst) {
                    scope.$apply(function(scope){
                        // Change binded variable
                        ngModel.assign(scope, dateText);
                        scope.outline_changed(); // added to trigger save
                        
                    });
                }
            });
        });
    }
});

app.directive('ngConfirmClick', [
  function() {
    return {
      priority: 1,
      link: function(scope, element, attr) {
        var msg = attr.ngConfirmClickMessage || "Are you sure?";
        var clickAction = attr.ngConfirmClick;
        attr.ngClick = "";
        element.bind('click', function(event) {
          console.log("confirm click", msg);
          if (confirm(msg)) {
            console.log("confirmed");
            scope.$apply(clickAction)
          }
          console.log("bubble");
          event.stopImmediatePropagation();
          event.preventDefault();

        });
      }
    };
  }
]);


app.directive('autoGrow', function() {
    return function(scope, element, attr) {
        var minHeight, paddingLeft, paddingRight, $shadow = null;

        function createShadow(){

            minHeight = element[0].offsetHeight;
            if (minHeight === 0)
                return ;
            paddingLeft = element.css('paddingLeft');
            paddingRight = element.css('paddingRight');

            $shadow = angular.element('<div></div>').css({
                position: 'absolute',
                top: -10000,
                left: -10000,
                width: element[0].offsetWidth - parseInt(paddingLeft ? paddingLeft : 0, 10) - parseInt(paddingRight ? paddingRight : 0, 10),
                fontSize: element.css('fontSize'),
                fontFamily: element.css('fontFamily'),
                lineHeight: element.css('lineHeight'),
                resize: 'none'
            });
            angular.element(document.body).append($shadow);

        }

        var update = function() {
            if ($shadow === null)
                createShadow();
            if ($shadow === null)
                return ;
            var times = function(string, number) {
                for (var i = 0, r = ''; i < number; i++) {
                    r += string;
                }
                return r;
            };

            var val = element.val().replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/&/g, '&amp;')
                .replace(/\n$/, '<br/>&nbsp;')
                .replace(/\n/g, '<br/>')
                .replace(/\s{2,}/g, function(space) { return times('&nbsp;', space.length - 1) + ' '; });
            $shadow.html(val);

            element.css('height', Math.max($shadow[0].offsetHeight + 30, minHeight) + 'px');
        };

        element.bind('keyup keydown keypress change focus', update);
        scope.$watch(attr.ngModel, update);
        scope.$watch(function(){ return element[0].style.display != 'none'; }, update);
    };
});

app.factory('Page', function() {
   var title = 'default';
   return {
     title: function() { return title; },
     setTitle: function(newTitle) { title = newTitle; }
   };
});

app.controller('MainCtrl', ['$scope','Page', function($scope, Page) {
  $scope.Page = Page;
}]);


app.controller('OrgOverview', ['$scope', '$http', '$timeout', '$log', '$location','$window','Page', function($scope, $http, $timeout, $log, $location, $window,Page) {

    Page.setTitle('Organisational overview');

    $scope.msg = "tits";

    $scope.company_id  = global_company_id;
    $scope.user_email = ($window.sessionStorage.email) ? $window.sessionStorage.email : "";
    $scope.user_name = ($window.sessionStorage.person_name) ? $window.sessionStorage.person_name : "Anonymous visitor";
    $scope.person_company_id = ($window.sessionStorage.person_company_id) ? $window.sessionStorage.person_company_id : "";
    $scope.current_user_id = ($window.sessionStorage.uid) ? $window.sessionStorage.uid : "";

    $scope.tasks = [];

    $scope.logout = function() {
            delete $window.sessionStorage.token;
            delete $window.sessionStorage.uid;
            delete $window.sessionStorage.email;
            delete $window.sessionStorage.person_name;
            delete $window.sessionStorage.person_company_id;

            $scope.user_email = "";
            $scope.user_name = "Anonymous visitor";
            $scope.person_company_id = "";
            $scope.current_user_id = "";
    }

  $scope.user_login = {username: '', password: '', 'cid': $scope.company_id}; // cid is company id needed later
  $scope.message = '';


  $scope.login_submit = function () {
    $http
      .post('/authenticate', $scope.user_login)
      .success(function (data, status, headers, config) {
        // console.log(data, status, headers, config);

        if (data.change_pass) {
            $scope.message = 'Please supply a new password (min. 8 characters):'
            $scope.user_login.must_change_pass = true;
            return;
        }
        // Save to session storage
        $window.sessionStorage.token = data.token;
        $window.sessionStorage.uid = data.userinfo.id;
        $window.sessionStorage.email = data.userinfo.email;
        $window.sessionStorage.person_name = data.userinfo.name;
        $window.sessionStorage.person_company_id = data.userinfo.company_id;

        // Update state variables
        $scope.user_email = $window.sessionStorage.email;
        $scope.user_name = $window.sessionStorage.person_name;
        $scope.person_company_id = $window.sessionStorage.person_company_id;
        $scope.current_user_id = $window.sessionStorage.uid;

        $scope.message = 'Welcome ' + $scope.user_name;
        $scope.load_departments();

      })
      .error(function (data, status, headers, config) {
        // Erase the token if the user fails to log in
        $scope.logout();
        // Handle login errors here
        $scope.message = 'Error: Invalid user or password';
      });
  };
    
        $scope.userIsAnonymous = function() {
            return ($scope.current_user_id == "undefined" || $scope.current_user_id == "");
    }

$scope.load_departments = function() {
    console.log("loading departments");
    $http({
      url: "/org/json",
      method: "GET",
      // headers: { 'Content-Type': 'application/json' },
      params: {cid : 1, date_today: new Date().toISOString().slice(0, 10)}//JSON.stringify({"cid" : $scope.company_id})
    }).success(function(data) {
      console.log("data", data);
      $scope.departments = data.departments;

      var org_data = {
      "cols" : [
          {"label": "Name", "pattern": "", "type": "string"},
          {"label": "Manager", "pattern": "", "type": "string"},
          {"label": "ToolTip", "pattern": "", "type": "string"}
      ], 
      "rows" : []
    };
    for (var i = data.departments.length - 1; i >= 0; i--) {
        org_data.rows.push(
            { "c": [ 
              {"v": data.departments[i].id, "f": data.departments[i].title + '<div style="color:blue; font-style:italic">' + data.departments[i].head_name + '</div>' },
              {"v": data.departments[i].parent_department},
              {"v": data.departments[i].head_name}
          ]}
        );
    }
        $scope.chart = {
          type: "OrgChart",
          data: org_data,
          options: {allowHtml: true}
        };
    });
}


if ($scope.current_user_id != "") {
    $scope.load_departments();
}


}]);


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


app.controller('GodOverview', ['$scope', '$http', '$timeout', '$log', '$location','$window','Page', function($scope, $http, $timeout, $log, $location, $window,Page) {

    Page.setTitle('Goals overview');

    $scope.company_id  = global_company_id;
    $scope.user_email = ($window.sessionStorage.email) ? $window.sessionStorage.email : "";
    $scope.user_name = ($window.sessionStorage.person_name) ? $window.sessionStorage.person_name : "Anonymous visitor";
    $scope.person_company_id = ($window.sessionStorage.person_company_id) ? $window.sessionStorage.person_company_id : "";
    $scope.current_user_id = ($window.sessionStorage.uid) ? $window.sessionStorage.uid : "";

    $scope.tasks = [];
    $scope.company = {company_name : "Goaler.net"};

    $scope.overview_view = 1; // box view as default

    $scope.logout = function() {
            delete $window.sessionStorage.token;
            delete $window.sessionStorage.uid;
            delete $window.sessionStorage.email;
            delete $window.sessionStorage.person_name;
            delete $window.sessionStorage.person_company_id;

            $scope.user_email = "";
            $scope.user_name = "Anonymous visitor";
            $scope.person_company_id = "";
            $scope.current_user_id = "";
    }

  $scope.user_login = {username: '', password: '', 'cid': $scope.company_id}; // cid is company id needed later
  $scope.message = '';


$scope.gotoTask = function(tid) {
  $window.location.href  = "/task/" + tid;
};

$scope.gridOptions = {
  };
  $scope.gridOptions.columnDefs = [
      // {name:'id'},
      {name:'Task', field:'name'},
      {name:'Deadline', field:'deadline_date'},
        {name:'Responsible', field:'responsible_name'},
      // {field:'age'}, // showing backwards compatibility with 2.x.  you can use field in place of name
      // {name: 'address.city'},
      // {name: 'age again', field:'age'}
    ];
   


  $scope.login_submit = function () {
    $http
      .post('/authenticate', $scope.user_login)
      .success(function (data, status, headers, config) {
        // console.log(data, status, headers, config);

        if (data.change_pass) {
            $scope.message = 'Please supply a new password (min. 8 characters):'
            $scope.user_login.must_change_pass = true;
            return;
        }
        // Save to session storage
        $window.sessionStorage.token = data.token;
        $window.sessionStorage.uid = data.userinfo.id;
        $window.sessionStorage.email = data.userinfo.email;
        $window.sessionStorage.person_name = data.userinfo.name;
        $window.sessionStorage.person_company_id = data.userinfo.company_id;

        // Update state variables
        $scope.user_email = $window.sessionStorage.email;
        $scope.user_name = $window.sessionStorage.person_name;
        $scope.person_company_id = $window.sessionStorage.person_company_id;
        $scope.current_user_id = $window.sessionStorage.uid;

        $scope.message = 'Welcome ' + $scope.user_name;
        $scope.load_overview();

      })
      .error(function (data, status, headers, config) {
        // Erase the token if the user fails to log in
        $scope.logout();
        // Handle login errors here
        $scope.message = 'Error: Invalid user or password';
      });
  };
    
        $scope.userIsAnonymous = function() {
            return ($scope.current_user_id == "undefined" || $scope.current_user_id == "");
    }



$scope.delete_task = function(task_id) {
      for (var i = $scope.tasks.length - 1; i >= 0; i--) {
          if ($scope.tasks[i].id == task_id) {

              $http({
                url: "/task/" + task_id + "/delete",
                method: "POST",
                headers: { 'Content-Type': 'application/json' },
                data: JSON.stringify({})
              }).success(function(data) {
                  $scope.tasks.splice(i, 1); // remove locally
              });

              break;
          }
      
      }

}

$scope.load_overview = function() {

        $http({
          url: "/overview/json",
          method: "GET",
          // headers: { 'Content-Type': 'application/json' },
          params: {cid : 1, date_today: new Date().toISOString().slice(0, 10)}//JSON.stringify({"cid" : $scope.company_id})
        }).success(function(data) {
          // console.log(data)
          $scope.tasks = data.tasks;
          $scope.company = data.company;

          for (var j = $scope.tasks.length - 1; j >= 0; j--) {
            
            var ndeliverables = $scope.tasks[j].deliverables.length;
            var ndelivered = 0;
            for (var i = $scope.tasks[j].deliverables.length - 1; i >= 0; i--) {
              if ($scope.tasks[j].deliverables[i].isdelivered) ndelivered += 1;
            }
            // console.log("Deliverables: ", ndeliverables, "Delivered: ", ndelivered);
            $scope.tasks[j].ndelivered = ndelivered;
            $scope.tasks[j].ndeliverables = ndeliverables;

          }

          $scope.gridOptions.data = $scope.tasks; // for tables

        });
}


$scope.deliveredChanged = function(deli) {

    console.log(deli);

    var data = {
        "isdelivered" : deli.isdelivered
    };
    console.log(data);

    $http({
      url: "/task/" + deli.task_id + "/deliverable/" + deli.id + "/update",
      method: "POST",
      headers: { 'Content-Type': 'application/json' },
      data: JSON.stringify(data)
    }).success(function(data) {
          console.log(data)
        $scope.save_status = new Date().toISOString();
    });

}

// $scope.$watch("name", function(newValue, oldValue) {
//     if ($scope.name.length > 0) {
//       $scope.greeting = "Greetings " + $scope.name;
//     }
//   });



  $scope.init_new_task = function() {
    console.log("new task startng");
    $http.get("/departments/json")
        .success(function(response) {
        $scope.departments = response.departments;
        console.log($scope.departments);
        $http.get("/people/json")
        .success(function(response) {
            $scope.people = response.people;

            $scope.outline = "";
            $scope.task_name = "";
            $scope.deliverables = "";
            $scope.axioms = "";
            $scope.goals = "";
            $scope.objectives = "";
            $scope.references = "";
            $scope.save_status = "";

            $scope.created_name = $scope.user_name;
            $scope.approval_date = "";
            $scope.reporting_cycle = 5;
            $scope.creation_date = new Date().toISOString().slice(0, 10);
            $scope.completion_date = "";
            $scope.proposed_name = "";
            $scope.department_owner = $scope.departments[0].id;
            $scope.responsible = $scope.current_user_id;
            $scope.completed_name = "";
            $scope.created_by = $scope.current_user_id;
            $scope.approved_by = "";
            $scope.final_report_id = "";
            $scope.rejection_date = "";
            $scope.rejected_by = "";
            $scope.department_head_id =$scope.departments[0].department_head;
            $scope.proposed_by = "";
            $scope.proposal_date = "";
            $scope.approved_name = "";
            $scope.approval_requested = "";
            $scope.department_approval_by = "";
            $scope.progress_report_id = "";
            $scope.reporting_to_name = $scope.user_name;
            $scope.completed_by = "";
            $scope.department_title = $scope.departments[0].title;
            $scope.responsible_name = $scope.user_name;
            $scope.reporting_to = $scope.current_user_id;
            $scope.rejected_name = "";
            $scope.deadline_date = new Date().toISOString().slice(0, 10);
            $scope.budget_id = "";
            $scope.parent_department_id = 0;



            var data = {
                "name" : $scope.task_name, 
                "outline" : $scope.outline, 
                "creation_date" : $scope.creation_date,
                "created_by" : $scope.created_by,
                "last_save" : new Date(),
                "deadline_date" : $scope.deadline_date, 
                "department_owner" : $scope.department_owner,
                "reporting_to" : $scope.reporting_to,
                "responsible" : $scope.responsible,
                "reporting_cycle" : $scope.reporting_cycle
            };

        
            $http({
              url: "/task/new/submit",
              method: "POST",
              headers: { 'Content-Type': 'application/json' },
              data: JSON.stringify(data)
            }).success(function(response) {
              // console.log(data)
                $scope.save_status = data.last_save;
                // console.log("new task iD", response.task_id);
                $scope.task_id = response.task_id;
                $window.location.href  = "/task/" + $scope.task_id;
            });



        });


    });

    }

if ($scope.current_user_id != "") {
    $scope.load_overview();
}


}]);


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




app.controller('GodViewController', ['$scope', '$http', '$timeout', '$log', '$location','$window','Page', function($scope, $http, $timeout, $log, $location, $window,Page) {

    Page.setTitle('Task');
    
// .controller('GodViewController', function ($scope, $http) {
    // console.log("Location", $location);
    
    $scope.company_id = global_company_id;   
    $scope.task_id = global_task_id;

    $scope.new_task = false;

    if ($scope.task_id == "XX") {
        $scope.new_task = true;
    }
    
    $scope.user_email = ($window.sessionStorage.email) ? $window.sessionStorage.email : "";
    $scope.user_name = ($window.sessionStorage.person_name) ? $window.sessionStorage.person_name : "Anonymous visitor";
    $scope.person_company_id = ($window.sessionStorage.person_company_id) ? $window.sessionStorage.person_company_id : "";
    $scope.current_user_id = ($window.sessionStorage.uid) ? $window.sessionStorage.uid : "";

    $scope.user_level = "";//global_current_user_role_level;

    $scope.name_objective = '';
    $scope.text_objective = '';

    $scope.name_axiom = '';
    $scope.text_axiom = '';

    $scope.name_goal = '';
    $scope.text_goal = '';

    $scope.name_deliverable = '';
    $scope.text_deliverable = '';

    $scope.comment_ref = '';
    $scope.text_ref = '';
    $scope.url_ref = '';



    $scope.isRejected = function() {
        var isRej = !($scope.rejection_date == "undefined" || $scope.rejection_date == null || $scope.rejection_date == "");
        // console.log("isRejected?", isRej);
        return isRej;

    }

    $scope.isApproved = function() {
        var isAppr = !($scope.approval_date == "undefined" || $scope.approval_date == null || $scope.approval_date == "");
        // console.log("isApproved?", isAppr);
        return isAppr;
    }

    $scope.isCompleted = function() {
        var isComp = !($scope.completion_date == "undefined" || $scope.completion_date == null || $scope.completion_date == "");
        // console.log("isCompl?", isComp);
        return isComp;

    }

    $scope.approvalRequested = function() {
        // alert($scope.approval_requested);
        var isReq = !($scope.approval_requested == "undefined" || $scope.approval_requested == null || $scope.approval_requested == "");
        // console.log("approvalRequested?", isReq );
        return isReq;

    }

    $scope.userCanEdit = function() { 

        var canEdit = false;
        // conditions where the creator can edit
        if ($scope.userIsCreator() && !($scope.isRejected() || $scope.isApproved()  || $scope.isCompleted())) {
            canEdit = true;
        }
        // conditions where the approver can edit

        // conditions where the reporitng officer can edit

        // conditions where the assignee can edit

        // (current_user_id == created_by || current_user_id == proposed_by) && current_user_id != department_head_id
        return canEdit; 
    };

    $scope.userIsApprover = function() { 

        var isApprover = ($scope.department_head_id == $scope.current_user_id);
        return isApprover; 
    };

    $scope.userIsCreator = function() { 

        var isCreator = ($scope.created_by == $scope.current_user_id);
        return isCreator; 
    };
    $scope.userIsReportingOfficer = function() { 

        var isReportingOfficer = ($scope.reporting_to == $scope.current_user_id);
        return isReportingOfficer; 
    };
    $scope.userIsReader = function() { 

        var isReader = !($scope.userIsApprover() ||
                        $scope.userIsCreator() ||
                        $scope.userIsReportingOfficer() ||
                        $scope.userIsAssignee());

        return isReader; 
    };

    $scope.userIsAssignee = function() { 
        var isAssignee = ($scope.responsible == $scope.current_user_id);
        return isAssignee; 
    };

    $scope.userIsAnonymous = function() {

        return ($scope.current_user_id == "undefined" || $scope.current_user_id == "");
    }




    $scope.logout = function() {
            delete $window.sessionStorage.token;
            delete $window.sessionStorage.uid;
            delete $window.sessionStorage.email;
            delete $window.sessionStorage.person_name;
            delete $window.sessionStorage.person_company_id;

            $scope.user_email = "";
            $scope.user_name = "Anonymous visitor";
            $scope.person_company_id = "";
            $scope.current_user_id = "";
    }

  $scope.user_login = {username: '', password: '', 'cid': $scope.company_id}; // cid is company id needed later
  $scope.message = '';


  $scope.init_new_task = function() {
    console.log("new task startng");
    $http.get("/departments/json")
        .success(function(response) {
        $scope.departments = response.departments;
        console.log($scope.departments);
        $http.get("/people/json")
        .success(function(response) {
            $scope.people = response.people;

            $scope.outline = "";
            $scope.task_name = "";
            $scope.deliverables = "";
            $scope.axioms = "";
            $scope.goals = "";
            $scope.objectives = "";
            $scope.references = "";
            $scope.save_status = "";

            $scope.created_name = $scope.user_name;
            $scope.approval_date = "";
            $scope.reporting_cycle = 5;
            $scope.creation_date = new Date().toISOString().slice(0, 10);
            $scope.completion_date = "";
            $scope.proposed_name = "";
            $scope.department_owner = $scope.departments[0].id;
            $scope.responsible = $scope.current_user_id;
            $scope.completed_name = "";
            $scope.created_by = $scope.current_user_id;
            $scope.approved_by = "";
            $scope.final_report_id = "";
            $scope.rejection_date = "";
            $scope.rejected_by = "";
            $scope.department_head_id =$scope.departments[0].department_head;
            $scope.proposed_by = "";
            $scope.proposal_date = "";
            $scope.approved_name = "";
            $scope.approval_requested = "";
            $scope.department_approval_by = "";
            $scope.progress_report_id = "";
            $scope.reporting_to_name = $scope.user_name;
            $scope.completed_by = "";
            $scope.department_title = $scope.departments[0].title;
            $scope.responsible_name = $scope.user_name;
            $scope.reporting_to = $scope.current_user_id;
            $scope.rejected_name = "";
            $scope.deadline_date = new Date().toISOString().slice(0, 10);
            $scope.budget_id = "";
            $scope.parent_department_id = 0;



            var data = {
                "name" : $scope.task_name, 
                "outline" : $scope.outline, 
                "creation_date" : $scope.creation_date,
                "created_by" : $scope.created_by,
                "last_save" : new Date(),
                "deadline_date" : $scope.deadline_date, 
                "department_owner" : $scope.department_owner,
                "reporting_to" : $scope.reporting_to,
                "responsible" : $scope.responsible,
                "reporting_cycle" : $scope.reporting_cycle
            };

        
            $http({
              url: "/task/new/submit",
              method: "POST",
              headers: { 'Content-Type': 'application/json' },
              data: JSON.stringify(data)
            }).success(function(response) {
              // console.log(data)
                $scope.save_status = Date.parse(data.last_save);
                // console.log("new task iD", response.task_id);
                $scope.task_id = response.task_id;
                $window.location.href  = "/task/" + $scope.task_id;
            });



        });


    });

    }

    $scope.load_overview = function() {

        $http({
          url: "/overview/json",
          method: "GET",
          // headers: { 'Content-Type': 'application/json' },
          params: {cid : $scope.person_company_id, date_today: new Date().toISOString().slice(0, 10)}//JSON.stringify({"cid" : $scope.company_id})
        }).success(function(data) {
          $scope.all_tasks = data.tasks;
        });
    }


$scope.load_task = function() {

    $scope.load_overview();

    $http.get("/departments/json")
        .success(function(response) {
        $scope.departments = response.departments;
    });

    $http.get("/people/json")
        .success(function(response) {
        $scope.people = response.people;
    });

    $http.get("/task/" + global_task_id + "/json")
        .success(function(response) {
            $scope.data = response;
            // console.log(response);
            
            $scope.outline = response.outline;
            $scope.task_name = response.name;
            $scope.deliverables = response.deliverables; 
            $scope.axioms = response.axioms;
            $scope.goals = response.goals;
            $scope.objectives = response.objectives;
            $scope.references = response.references;
            $scope.save_status = Date.parse(response.last_save);
            
            $scope.created_name = response.created_name;
            $scope.approval_date = response.approval_date;
            $scope.reporting_cycle = response.reporting_cycle;
            $scope.creation_date = response.creation_date;
            $scope.completion_date = response.completion_date;
            $scope.proposed_name = response.proposed_name;
            $scope.department_owner = response.department_owner;
            $scope.responsible = response.responsible;
            $scope.completed_name = response.completed_name;
            $scope.created_by = response.created_by;
            $scope.approved_by = response.approved_by;
            $scope.final_report_id = response.final_report_id;
            $scope.rejection_date = response.rejection_date;
            $scope.rejected_by = response.rejected_by;
            $scope.department_head_id = response.department_head_id;
            $scope.proposed_by = response.proposed_by;
            $scope.proposal_date = response.proposal_date;
            $scope.approved_name = response.approved_name;
            $scope.approval_requested = response.approval_requested;
            $scope.department_approval_by = response.department_approval_by;
            $scope.progress_report_id = response.progress_report_id;
            $scope.reporting_to_name = response.reporting_to_name;
            $scope.completed_by = response.completed_by;
            $scope.department_title = response.department_title;
            $scope.responsible_name = response.responsible_name;
            $scope.reporting_to = response.reporting_to;
            $scope.rejected_name = response.rejected_name;
            $scope.deadline_date = response.deadline_date;
            $scope.budget_id = response.budget_id;
            $scope.parent_department_id = response.parent_department_id;
            
            Page.setTitle('GOD-' + $scope.task_id + "-" + $scope.creation_date + " " + $scope.task_name);
    

            
            $timeout(expand, 0);

            // $timeout(function () {
            //     $scope.$watch('deadline_date', function() {
            //         $scope.outline_changed();
            //      });
            //
            // },0);
            
        }
    );

  }

  $scope.login_submit = function () {
    $http
      .post('/authenticate', $scope.user_login)
      .success(function (data, status, headers, config) {

        if (data.change_pass) {
            $scope.message = 'Please supply a new password (min. 8 characters):'
            $scope.user_login.must_change_pass = true;
            return;
        }
        // Save to session storage
        $window.sessionStorage.token = data.token;
        $window.sessionStorage.uid = data.userinfo.id;
        $window.sessionStorage.email = data.userinfo.email;
        $window.sessionStorage.person_name = data.userinfo.name;
        $window.sessionStorage.person_company_id = data.userinfo.company_id;

        // Update state variables
        $scope.user_email = $window.sessionStorage.email;
        $scope.user_name = $window.sessionStorage.person_name;
        $scope.person_company_id = $window.sessionStorage.person_company_id;
        $scope.current_user_id = $window.sessionStorage.uid;

        $scope.message = 'Welcome ' + $scope.user_name;
        $scope.load_task();

      })
      .error(function (data, status, headers, config) {
        // Erase the token if the user fails to log in
        $scope.logout();
        // Handle login errors here
        $scope.message = 'Error: Invalid user or password';
      });
  };
    
    
    $scope.save_status = "Loading";
    $scope.departments = [];
    

    $scope.setDepartment = function(department_id) {

        
        for (var i = $scope.departments.length - 1; i >= 0; i--) {
            if ($scope.departments[i].id == department_id) {
                // console.log("Found name of department " + $scope.departments[i].title)
                // console.log($scope.departments[i]);
                $scope.department_title = $scope.departments[i].title;
                $scope.department_head_id = $scope.departments[i].department_head;
                $scope.department_owner = department_id;
                $scope.department_approval_by = $scope.departments[i].responsible_name;
                $scope.outline_changed(); // update
                return;
                
            }
        }
    };
    

    $scope.people = [ ];
    
    
    $scope.setReportingOfficer = function (uid) {
        for (var i = $scope.people.length - 1; i >= 0; i--) {
            if ($scope.people[i].id == uid) {
                // console.log("found person" + $scope.people[i].name);
                $scope.reporting_to = uid;
                $scope.reporting_to_name = $scope.people[i].name;
                $scope.outline_changed(); // update
            }
        }
    }
    
    $scope.setTaskResponsible = function (uid) {
        for (var i = $scope.people.length - 1; i >= 0; i--) {
            if ($scope.people[i].id == uid) {
                // console.log("found person" + $scope.people[i].name);
                $scope.responsible = uid;
                $scope.responsible_name = $scope.people[i].name;
                $scope.outline_changed(); // update
            }
        }
        
    }
    
    
    $scope.reporting_days = [
        1,3,5, 14, 30
    ];

    $scope.setReportingInterval = function (days) {
        $scope.reporting_cycle = days;
        $scope.outline_changed(); // update
        
    }

     $scope.toggleDropdown = function($event) {
       $event.preventDefault();
       $event.stopPropagation();
       $scope.status.isopen = !$scope.status.isopen;
     };
     
    

    if ($window.sessionStorage.uid) {
        if ($scope.new_task) {
            $scope.init_new_task();
        } else {
            $scope.load_task();
        }
    }


    // Auto expand teaxarea upon load
    $scope.autoExpand = function(e) {
          var element = typeof e === 'object' ? e.target : document.getElementById(e);
          // console.log(element);
      		var scrollHeight = element.scrollHeight -0; // replace 60 by the sum of padding-top and padding-bottom
          element.style.height =  scrollHeight + "px";    
      };   
      
    function expand() {
      $scope.autoExpand('outline');
      $scope.autoExpand('title');
      
    }    
       
       
      
    $scope.outline_timer = null;
    $scope.outline_changed = function () {
        if (!$scope.userCanEdit) {
            alert("You don't have access to make changes.");
            return;
        }

        // console.log("outline_changed");
        window.clearTimeout($scope.outline_timer);
        
        $scope.outline_timer = window.setTimeout(function () {
            var data = {
                "name" : $scope.task_name, 
                "outline" : $scope.outline, 
                "last_save" : new Date(),
                "deadline_date" : $scope.deadline_date, 
                "department_owner" : $scope.department_owner,
                "reporting_to" : $scope.reporting_to,
                "responsible" : $scope.responsible,
                "reporting_cycle" : $scope.reporting_cycle
            };
        
            $http({
              url: "/task/" + global_task_id + "/update",
              method: "POST",
              headers: { 'Content-Type': 'application/json' },
              data: JSON.stringify(data)
            }).success(function(response) {
              // console.log(data)
                $scope.save_status = Date.parse(data.last_save);
            });
            
        }, 2000); // 2 sec timer for saving

        
    };
    
    
    $scope.reopenTask = function() {
        payload = {"action" : "reopenTask"};
        $http({
          url: "/task/" + global_task_id + "/command",
          method: "POST",
          headers: { 'Content-Type': 'application/json' },
          data: JSON.stringify(payload)
        }).success(function(response) {
            // console.log(response)

            $scope.approval_requested = ""

            console.log("Task reopened");
            $scope.approved_by = "";
            $scope.approval_date = "";
            $scope.approved_name = "";

            $scope.rejected_name = "";
            $scope.rejected_by = "";
            $scope.rejection_date = "";
            
            $scope.completed_name = "";
            $scope.completed_by = "";
            $scope.completion_date = "";

        });

    }

    $scope.requestApproval = function() {
        payload = {"action" : "requestApproval", "current_user_id" : $scope.current_user_id, "req_approval_date" : new Date().toISOString().slice(0, 10)};
        $http({
          url: "/task/" + global_task_id + "/command",
          method: "POST",
          headers: { 'Content-Type': 'application/json' },
          data: JSON.stringify(payload)
        }).success(function(response) {
            // console.log(response)

            $scope.approval_requested = payload['req_approval_date'];

            console.log("Approval requested" + $scope.approval_requested);

            
        });
        
    }


    $scope.approve = function () {
        payload = {"action" : "approve", "current_user_id" : $scope.current_user_id, "approval_date" : new Date().toISOString().slice(0, 10)};
        $http({
          url: "/task/" + global_task_id + "/command",
          method: "POST",
          headers: { 'Content-Type': 'application/json' },
          data: JSON.stringify(payload)
        }).success(function(response) {
            // console.log(response)

            $scope.approved_by = response.approved_by;
            $scope.approval_date = response.approval_date;
            $scope.approved_name = response.approved_name;

            $scope.rejected_name = "";
            $scope.rejected_by = "";
            $scope.rejection_date = "";

            // console.log("Approved");

            
        });
        
        
    }

    $scope.reject = function () {
        payload = {"action" : "reject", "current_user_id" : $scope.current_user_id, "rejection_date" : new Date().toISOString().slice(0, 10)};
        
        $http({
          url: "/task/" + global_task_id + "/command",
          method: "POST",
          headers: { 'Content-Type': 'application/json' },
          data: JSON.stringify(payload)
        }).success(function(response) {
          // console.log(response)


            $scope.approved_by = "";
            $scope.approval_date = "";
            $scope.approved_name = "";

            $scope.rejected_name = response.rejected_name;
            $scope.rejected_by = response.rejected_by;
            $scope.rejection_date = response.rejection_date;
        // console.log("Reject");
            
        });
        
    }
    $scope.complete = function () {
        payload = {"action" : "completed", "current_user_id" : $scope.current_user_id, "completion_date" : new Date().toISOString().slice(0, 10)};
        
        $http({
          url: "/task/" + global_task_id + "/command",
          method: "POST",
          headers: { 'Content-Type': 'application/json' },
          data: JSON.stringify(payload)
        }).success(function(response) {
          // console.log(response)
            $scope.completed_name = response.completed_name;
            $scope.completed_by = response.completed_by;
            $scope.completion_date = response.completion_date;
                    console.log("Task completed");

        });
    }
    
    $scope.deleteDeliverable = function (id) {
        // alert("deleting " + id);
        
        for (var i = $scope.deliverables.length - 1; i >= 0; i--) {
            if ($scope.deliverables[i].id == id) {
        
                $http({
                  url: "/task/" + global_task_id + "/deliverable/" + id + "/delete",
                  method: "GET",
                  headers: { 'Content-Type': 'application/json' },
                  data: JSON.stringify({"delete" : id})
                }).success(function(data) {
                  // console.log(data)
                    if (data.status == "ok") {
                        $scope.deliverables.splice(i, 1); // remove locally
                        $scope.save_status = new Date().toISOString();
                    }
                });
                return;
            }
        }        
        
    };
    
    $scope.markDeliverableDone = function (id) {
        // alert(id);
        for (var i = $scope.deliverables.length - 1; i >= 0; i--) {
            if ($scope.deliverables[i].id == id) {
                $scope.deliverables[i].isdelivered = !$scope.deliverables[i].isdelivered;
                
                var data = {
                    "isdelivered" : $scope.deliverables[i].isdelivered
                };
                
                $http({
                  url: "/task/" + global_task_id + "/deliverable/" + id + "/update",
                  method: "POST",
                  headers: { 'Content-Type': 'application/json' },
                  data: JSON.stringify(data)
                }).success(function(data) {
                  // console.log(data)
                    $scope.save_status = new Date().toISOString();
                });
                
                return;
            }
        }
    };

    $scope.deliveredChanged = function(deli) {

    console.log(deli);

    var data = {
        "isdelivered" : deli.isdelivered
    };
    console.log(data);

    $http({
      url: "/task/" + deli.task_id + "/deliverable/" + deli.id + "/update",
      method: "POST",
      headers: { 'Content-Type': 'application/json' },
      data: JSON.stringify(data)
    }).success(function(data) {
          console.log(data)
        $scope.save_status = new Date();
    });

}

    
    $scope.newDeliverable = function () {
        // alert($scope.name_deliverable + " " +  $scope.text_deliverable);
        
        var new_deliverable = {"name" : $scope.name_deliverable, 
            "text" : $scope.text_deliverable, 
            "task_id" : $scope.task_id, 
            "defined_by": $scope.current_user_id, 
            "definition_date" : new Date().toISOString(), 
            "isdelivered" : 0, 
            "priority": 1, 
            "customer" : 1
        };
                
        $http({
          url: "/task/" + global_task_id + "/deliverable/add",
          method: "POST",
          headers: { 'Content-Type': 'application/json' },
          data: JSON.stringify(new_deliverable)
        }).success(function(data) {
          // console.log(data)
            if (data['status'] == "ok") {
                $scope.deliverables.push(new_deliverable);
                $scope.editorEnabled = false;
                $scope.name_deliverable = '';
                $scope.text_deliverable = '';
                $scope.save_status = Date.parse(new_deliverable.definition_date);
                
            }
        });
    };
    


    // Task dependence
    $scope.name_axiom = '';
    $scope.text_axiom = '';
    $scope.dependence_axiom = {name: "Task dependence", id : null};    
    $scope.setTaskDependence = function(choice) {
      console.log("Requirement depdencence selected", choice);
        $scope.dependence_axiom = choice;
    }

    $scope.newAxiom = function () {

        var new_axiom = {"name" : $scope.name_axiom, 
            "text" : $scope.text_axiom, 
            "task_id" : $scope.task_id, 
            "defined_by": $scope.current_user_id, 
            "definition_date" : new Date().toISOString(),
            "task_dependence_id" : $scope.dependence_axiom.id
        };

            
        $http({
          url: "/task/" + global_task_id + "/axiom/add",
          method: "POST",
          headers: { 'Content-Type': 'application/json' },
          data: JSON.stringify(new_axiom)
        }).success(function(data) {
          // console.log(data)
            if (data['status'] == "ok") {
                if ($scope.dependence_axiom.id != null) {
                    new_axiom.dependence = $scope.dependence_axiom;
                }
                $scope.axioms.push(new_axiom);
                $scope.axiomEditorEnabled = false;
                $scope.name_axiom = '';
                $scope.text_axiom = '';
                $scope.dependence_axiom = {name: "Task dependence", id : null};    
                $scope.save_status = Date.parse(new_axiom.definition_date);
            
            }
        });

        
    };
    
    $scope.newGoal = function () {
        
        var new_goal = {"name" : $scope.name_goal, 
            "text" : $scope.text_goal, 
            "task_id" : $scope.task_id, 
            "defined_by": $scope.current_user_id, 
            "definition_date" : new Date().toISOString()
        };
        
        $http({
          url: "/task/" + global_task_id + "/goal/add",
          method: "POST",
          headers: { 'Content-Type': 'application/json' },
          data: JSON.stringify(new_goal)
        }).success(function(data) {
          // console.log(data)
            if (data['status'] == "ok") {
                $scope.goals.push(new_goal);
                $scope.goalEditorEnabled = false;
                $scope.name_goal = '';
                $scope.text_goal = '';
                $scope.save_status = new Date();
        
            }
        });
        
        
    };
    
    $scope.newObjective = function () {
        
        var new_objective = {"name" : $scope.name_objective, 
            "text" : $scope.text_objective, 
            "task_id" : $scope.task_id, 
            "defined_by": $scope.current_user_id, 
            "definition_date" : new Date().toISOString()
        };
    
        $http({
          url: "/task/" + global_task_id + "/objective/add",
          method: "POST",
          headers: { 'Content-Type': 'application/json' },
          data: JSON.stringify(new_objective)
        }).success(function(data) {
          // console.log(data)
            if (data['status'] == "ok") {
                $scope.objectives.push(new_objective);
                $scope.objectiveEditorEnabled = false;
                $scope.name_objective = '';
                $scope.text_objective = '';
                $scope.save_status = new Date();
    
            }
        });
    };
    
    $scope.newRef = function () {
        
        var new_ref = {"text" : $scope.text_ref, 
            "comment" : $scope.comment_ref, 
            "task_id" : $scope.task_id, 
            "url" : $scope.url_ref,
            "defined_by": $scope.current_user_id, 
            "definition_date" : new Date().toISOString()
        };

        $http({
          url: "/task/" + global_task_id + "/reference/add",
          method: "POST",
          headers: { 'Content-Type': 'application/json' },
          data: JSON.stringify(new_ref)
        }).success(function(data) {
          // console.log(data)
            if (data['status'] == "ok") {
                $scope.references.push(new_ref);
                $scope.refEditorEnabled = false;
                $scope.comment_ref = '';
                $scope.text_ref = '';
                $scope.url_ref = '';
                $scope.save_status = new Date();

            }
        });
    };
    
    
    
}]); // Controller





