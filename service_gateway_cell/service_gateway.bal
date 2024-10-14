import ballerina/http;
import ballerina/log;
import ballerina/observe;

// Configuration for the service gateway
configurable int gatewayPort = 8080;

// HTTP listener for the API Gateway
listener http:Listener gatewayListener = new(gatewayPort);

// Circuit breaker configuration for different microservices
http:ClientConfig commonConfig = {
    circuitBreaker: {
        rollingWindow: {
            timeWindow: 10, // 10 seconds time window
            bucketSize: 2    // 2 buckets for rolling window
        },
        failureThreshold: 0.3, // 30% failure threshold
        resetTime: 5           // Reset time for the circuit breaker
    },
    retryConfig: {
        count: 3,              // Retry up to 3 times
        interval: 2            // 2 seconds interval between retries
    }
};

// HTTP clients for microservices in each cell
http:Client observabilityServiceClient = new("http://localhost:9095", commonConfig);
http:Client serviceRegistrationClient = new("http://localhost:9096", commonConfig);
http:Client taskManagementClient = new("http://localhost:9097", commonConfig);
http:Client serviceScalingClient = new("http://localhost:9098", commonConfig);
http:Client faultToleranceClient = new("http://localhost:9099", commonConfig);
http:Client loadBalancerClient = new("http://localhost:9100", commonConfig);
http:Client cliServiceClient = new("http://localhost:9101", commonConfig);
http:Client cellDbServiceClient = new("http://localhost:9102", commonConfig);

// Enable observability: Configure metrics and tracing
observe:MetricsConfig metricsConfig = {
    enabled: true,
    prometheus: {
        port: 9797
    }
};

service /api on gatewayListener {

    // Route for monitoring observability service
    resource function get monitoring(http:Caller caller, http:Request req) {
        var response = observabilityServiceClient->forward("/observability" + req.getPath(), req);
        handleResponse(response, caller);
    }

    // Route for service registration in the core platform cell
    resource function get register(http:Caller caller, http:Request req) {
        var response = serviceRegistrationClient->forward("/core-platform/register" + req.getPath(), req);
        handleResponse(response, caller);
    }

    // Route for task management in the core platform cell
    resource function get task(http:Caller caller, http:Request req) {
        var response = taskManagementClient->forward("/core-platform/task" + req.getPath(), req);
        handleResponse(response, caller);
    }

    // Route for service scaling in the core platform cell
    resource function get scale(http:Caller caller, http:Request req) {
        var response = serviceScalingClient->forward("/core-platform/scale" + req.getPath(), req);
        handleResponse(response, caller);
    }

    // Route for fault tolerance in the reliability load management cell
    resource function get faultTolerance(http:Caller caller, http:Request req) {
        var response = faultToleranceClient->forward("/reliability/fault-tolerance" + req.getPath(), req);
        handleResponse(response, caller);
    }

    // Route for load balancing in the reliability load management cell
    resource function get loadBalance(http:Caller caller, http:Request req) {
        var response = loadBalancerClient->forward("/reliability/load-balancer" + req.getPath(), req);
        handleResponse(response, caller);
    }

    // Route for CLI microservice
    resource function get cli(http:Caller caller, http:Request req) {
        var response = cliServiceClient->forward("/cli" + req.getPath(), req);
        handleResponse(response, caller);
    }

    // Route for cell DB service
    resource function get db(http:Caller caller, http:Request req) {
        var response = cellDbServiceClient->forward("/db" + req.getPath(), req);
        handleResponse(response, caller);
    }
}

// Utility function to handle responses
function handleResponse(http:Response|error response, http:Caller caller) {
    if (response is http:Response) {
        var result = caller->respond(response);
        if (result is error) {
            log:printError("Error sending response", result);
        }
    } else {
        log:printError("Error calling the service", response);
        var errorResult = caller->respond(response.message());
        if (errorResult is error) {
            log:printError("Error sending error response", errorResult);
        }
    }
}
