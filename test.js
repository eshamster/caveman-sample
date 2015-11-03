angular.module('testApp', []).controller(function ($scope, $http) {
    print(123);
    $scope.test = 100;
    $scope.items = [];
    $scope.getTestData = function () {
        return $http({ 'method' : 'GET', 'url' : 'test.json' }).success(function (data, status, headers, config) {
            var _js21 = data.length;
            for (var i = 0; i <= _js21; i += 1) {
                $scope.items.push(data[i]);
            };
            console.log(status);
            return console.log(data);
        }).error(function (data, status, headers, config) {
            return console.log(status);
        });
    };
    $scope.toggleSelected = function (index) {
        return $scope.selectedId = $scope.selectedId !== index ? (index, -1) : null;
    };
    return $scope.isSelected = function (index) {
        return $scope.selectedId = index;
    };
});