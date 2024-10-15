import ballerina/http;
import ballerina/log;

configurable int observabilityPort = 9090;
listener http:Listener observabilityListener = new(observabilityPort);

service /observability on observabilityListener {

    // Route for retrieving system metrics
    resource function get metrics(http:Caller caller, http:Request req) {
        var response = observabilityServiceClient->forward("/metrics", req);
        handleResponse(response, caller);
    }
    
    // Route for logging system information
    resource function post logs(http:Caller caller, http:Request req) {
        var response = observabilityServiceClient->forward("/logs", req);
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
        log:printError("Error handling the request", response);
        var errorResult = caller->respond(response.message());
        if (errorResult is error) {
            log:printError("Error sending error response", errorResult);
        }
    }
}
