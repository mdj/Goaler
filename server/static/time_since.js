var timeSinceModule = angular.module("timeSince", []);

timeSinceModule.now = function() {
    return new Date();
}

timeSinceModule.ONE_SECOND_IN_MILLISECONDS  = 1000;
timeSinceModule.ONE_MINUTE_IN_MILLISECONDS  = timeSinceModule.ONE_SECOND_IN_MILLISECONDS * 60,
timeSinceModule.ONE_HOUR_IN_MILLISECONDS    = timeSinceModule.ONE_MINUTE_IN_MILLISECONDS * 60,
timeSinceModule.ONE_DAY_IN_MILLISECONDS     = timeSinceModule.ONE_HOUR_IN_MILLISECONDS * 24;

timeSinceModule.directive("timeSince", function($timeout) {
    return {
        restrict: "A",
        scope: false,
        link: function(scope, element, attrs) {
            var when,
                timeoutId;

            function timeSince(date) {
                if (!date instanceof Date) {
                    date = new Date(date);
                }
                var milliseconds = timeSinceModule.now() - date;
                var interval, unit;

                var getIntervalBy = function(n) {
                    return Math.floor(milliseconds / n);
                };

                if (milliseconds < 0) {
                    return "in the future";
                } else if ((interval = getIntervalBy(timeSinceModule.ONE_DAY_IN_MILLISECONDS)) >= 1) {
                    unit = "day";

                } else if ((interval = getIntervalBy(timeSinceModule.ONE_HOUR_IN_MILLISECONDS)) >= 1) {
                    unit = "hour";

                } else if ((interval = getIntervalBy(timeSinceModule.ONE_MINUTE_IN_MILLISECONDS)) >= 1) {
                    unit = "minute";

                } else {
                    unit = "second";
                    interval = getIntervalBy(timeSinceModule.ONE_SECOND_IN_MILLISECONDS);
                }

                // pluralize if not 1
                if(interval !== 1) {
                    unit += "s";
                }

                return interval + " " + unit + " ago";
            }

            function updateTimeSince() {
                try {
                    element.text(timeSince(when));   
                } catch (error) {
                    console.log(error);
                    element.text("in the future");
                }
            }

            scope.$watch(attrs.timeSince, function(value) {
                when = value;
                updateTimeSince();
            });

            function updateLater() {
                timeoutId = $timeout(function() {
                    updateTimeSince();
                    updateLater();
                }, 1000);
            }

            element.bind('$destroy', function() {
                $timeout.cancel(timeoutId);
            });

            updateLater();
        }
    }
});