import ballerina/http;
import ballerina/log;

// Observability and Monitoring Cell Gateway configuration
configurable int observabilityPort = 8086;
listener http:Listener observabilityListener = new(observabilityPort);

// Client for the observability service
http:Client observabilityServiceClient = check new("http://localhost:9095");

service /observability on observabilityListener {

    // Route for monitoring
    resource function get monitoring(http:Caller caller, http:Request req) {
        var response = observabilityServiceClient->forward("/observability" + req.getPath(), req);
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
