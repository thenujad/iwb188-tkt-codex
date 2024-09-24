import ballerina/log;

public function logMetric(string metricName, float value) {
    log:printInfo("Metric: " + metricName + " Value: " + value.toString());
}

public function traceRequest(string serviceName) {
    log:printInfo("Tracing request for service: " + serviceName);
}
