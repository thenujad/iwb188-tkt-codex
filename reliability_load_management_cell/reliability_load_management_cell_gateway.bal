import ballerina/http;
import ballerina/log;

configurable int reliabilityPort = 8085;
listener http:Listener reliabilityListener = new(reliabilityPort);

// HTTP clients for internal services
http:Client faultToleranceClient = check new("http://localhost:8085");
http:Client loadBalancerClient = check new("http://localhost:8086");

service /reliability on reliabilityListener {

    // Endpoint for fault tolerance operations
    isolated resource function post faults(http:Caller caller, http:Request req) {
        http:Response|http:ClientError response = faultToleranceClient->forward("/faultTolerance", req);
        handleResponse(response, caller);
    }

    // Endpoint for load balancing operations
    isolated resource function post loadBalance(http:Caller caller, http:Request req) {
        http:Response|http:ClientError response = loadBalancerClient->forward("/loadBalancer", req);
        handleResponse(response, caller);
    }

    // Common response handler
    isolated function handleResponse(http:Response|http:ClientError response, http:Caller caller) {
        if (response is http:Response) {
            checkpanic caller->respond(response);
        } else {
            http:Response failureResponse = new;
            failureResponse.setTextPayload("Failed to process request");
            failureResponse.statusCode = http:STATUS_BAD_GATEWAY;
            checkpanic caller->respond(failureResponse);
        }
    }
}
