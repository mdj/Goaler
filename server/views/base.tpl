<!doctype html>
<html lang="us" ng-app="godApp">
<head>
	<meta charset="utf-8">
	<title>[[Page.title]] - Seaborg Tasks</title>
	<link href="/static/jquery-ui-1.11.4.custom/jquery-ui.css" rel="stylesheet">
	<style>
	body{
        font: 100% "Trebuchet MS", sans-serif;
		margin: 50px;
	}
	.demoHeaders {
		margin-top: 2em;
	}
	#dialog-link {
		padding: .4em 1em .4em 20px;
		text-decoration: none;
		position: relative;
	}
	#dialog-link span.ui-icon {
		margin: 0 5px 0 0;
		position: absolute;
		left: .2em;
		top: 50%;
		margin-top: -8px;
	}
	#icons {
		margin: 0;
		padding: 0;
	}
	#icons li {
		margin: 2px;
		position: relative;
		padding: 4px 0;
		cursor: pointer;
		float: left;
		list-style: none;
	}
	#icons span.ui-icon {
		float: left;
		margin: 0 4px;
	}
	.fakewindowcontain .ui-widget-overlay {
		position: absolute;
	}
	select {
		width: 200px;
	}
	</style>
    
    <script src="/static/jquery-ui-1.11.4.custom/external/jquery/jquery.js"></script>
    <script src="/static/jquery-ui-1.11.4.custom/jquery-ui.js"></script>
    <script src="/static/jquery.ns-autogrow.min.js" type="text/javascript" charset="utf-8"></script>
    
    <script src="//ajax.googleapis.com/ajax/libs/angularjs/1.4.5/angular.js"></script>
    <script src="//ajax.googleapis.com/ajax/libs/angularjs/1.4.5/angular-animate.js"></script>
    <script src="//angular-ui.github.io/bootstrap/ui-bootstrap-tpls-0.13.4.js"></script>

    <link href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css" rel="stylesheet">

    <script src="/static/time_since.js"></script>
    <script src="/static/godApp.js"></script>
    
</head>
<body ng-cloak>
  {{!base}}
</body>
</html>