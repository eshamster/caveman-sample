angular.module('testApp', [])
    .controller('testController', function ($scope, $http) {
        $scope.test = 100;
        $scope.items = [];
        
        $scope.getTestData = function () {
            $http({
                method : 'GET',
                url : "test.json"
            }).success(function(data, status, headers, config) {
                for (var i = 0; i < data.length; i++) {
                    $scope.items.push(data[i]);
                }
                console.log(status);
                console.log(data);
            }).error(function(data, status, headers, config) {
                console.log(status);
            });
        };

        $scope.toggleSelected = function (index) {
            $scope.selectedId = ($scope.selectedId != index) ? index : -1;
        };

        $scope.isSelected = function (index) {
            return $scope.selectedId == index;
        }
    });
