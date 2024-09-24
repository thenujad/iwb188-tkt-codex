import ballerina/log;

public function scaleUp(string serviceName) {
    log:printInfo("Scaling up service: " + serviceName);
}

public function scaleDown(string serviceName) {
    log:printInfo("Scaling down service: " + serviceName);
}
