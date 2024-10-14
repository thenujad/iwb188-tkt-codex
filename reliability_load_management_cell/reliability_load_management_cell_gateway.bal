import ballerina/http;
import ballerina/log;

// Reliability Load Management Cell Gateway configuration
configurable int reliabilityPort = 8085;
listener http:Listener reliabilityListener = new(reliabilityPort);

// Clients for microservices within the reliability load management cell
http:Client faultToleranceClient = check new("http://localhost:9099");
http:Client loadBalancerClient = check new("http://localhost:9100");

service /reliability on reliabilityListener {

    // Route for fault tolerance
    resource function get faultTolerance(http:Caller caller, http:Request req) {
        var response = faultToleranceClient->forward("/reliability/fault-tolerance" + req.getPath(), req);
        handleResponse(response, caller);
    }

    // Route for load balancing
    resource function get loadBalance(http:Caller caller, http:Request req) {
        var response = loadBalancerClient->forward("/reliability/load-balancer" + req.getPath(), req);
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
