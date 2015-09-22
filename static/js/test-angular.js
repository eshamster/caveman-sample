function TestControl ($scope, $http) {
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
}
