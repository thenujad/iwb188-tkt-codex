import ballerina/http;
import ballerina/log;

configurable int corePlatformPort = 8081;
listener http:Listener corePlatformListener = new(corePlatformPort);

// HTTP clients for internal microservices
http:Client serviceRegistrationClient = check new("http://localhost:8083");
http:Client taskManagementClient = check new("http://localhost:8082");
http:Client serviceScalingClient = check new("http://localhost:8084");

service /coreplatform on corePlatformListener {

    // Service registration endpoint
    resource function post register(http:Caller caller, http:Request req) {
        http:Response|http:ClientError response = serviceRegistrationClient->forward("/service/register", req);
        handleResponse(response, caller);
    }

    // Task management endpoint
    resource function post tasks(http:Caller caller, http:Request req) {
        http:Response|http:ClientError response = taskManagementClient->forward("/task/schedule", req);
        handleResponse(response, caller);
    }

    // Service scaling endpoint
    resource function post scale(http:Caller caller, http:Request req) {
        http:Response|http:ClientError response = serviceScalingClient->forward("/scaling", req);
        handleResponse(response, caller);
    }

    // Helper function to handle responses
    function handleResponse(http:Response|error response, http:Caller caller) {
        if response is http:Response {
            checkpanic caller->respond(response);
        } else {
            log:printError("Error occurred while forwarding the request", 'error = response);
            checkpanic caller->respond("Internal Server Error");
        }
    }
}
