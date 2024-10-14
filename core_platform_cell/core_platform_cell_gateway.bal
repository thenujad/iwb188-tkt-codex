import ballerina/http;
import ballerina/log;

// Core Platform Cell Gateway configuration
configurable int corePlatformPort = 8081;
listener http:Listener corePlatformListener = new(corePlatformPort);

// Clients for the microservices within the core platform cell
http:Client serviceRegistrationClient = check new("http://localhost:8083");
http:Client taskManagementClient = check new("http://localhost:8082");
http:Client serviceScalingClient = check new("http://localhost:8084");

service /core-platform on corePlatformListener {

    // Route for service registration
    resource function get register(http:Caller caller, http:Request req) {
        var response = serviceRegistrationClient->forward("/serviceregistry" + req.getPath(), req);
        handleResponse(response, caller);
    }

    // Route for task management
    resource function get task(http:Caller caller, http:Request req) {
        var response = taskManagementClient->forward("/taskscheduler" + req.getPath(), req);
        handleResponse(response, caller);
    }

    // Route for service scaling
    resource function get scale(http:Caller caller, http:Request req) {
        var response = serviceScalingClient->forward("/scaling" + req.getPath(), req);
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
