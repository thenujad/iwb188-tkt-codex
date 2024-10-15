import ballerina/http;
import ballerina/log;

configurable int corePlatformPort = 8081;
listener http:Listener corePlatformListener = new(corePlatformPort);

// HTTP clients for internal microservices
http:Client serviceRegistrationClient = check new("http://localhost:8083");
http:Client taskManagementClient = check new("http://localhost:8082");
http:Client serviceScalingClient = check new("http://localhost:8084");

service /core-platform on corePlatformListener {

    // Service registration endpoint
    resource function get register(http:Caller caller, http:Request req) {
        var response = serviceRegistrationClient->forward("/register", req);
        handleResponse(response, caller);
    }

    // Task management endpoint
    resource function post tasks(http:Caller caller, http:Request req) {
        var response = taskManagementClient->forward("/tasks", req);
        handleResponse(response, caller);
    }

    // Service scaling endpoint
    resource function post scale(http:Caller caller, http:Request req) {
        var response = serviceScalingClient->forward("/scale", req);
        handleResponse(response, caller);
    }
}
