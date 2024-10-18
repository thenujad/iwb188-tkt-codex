import ballerina/http;
import ballerina/log;

configurable int reliabilityPort = 8085;
listener http:Listener reliabilityListener = new(reliabilityPort);

// HTTP clients for internal services
http:Client faultToleranceClient = check new("http://localhost:8085");
http:Client loadBalancerClient = check new("http://localhost:8086");
service /reliability on reliabilityListener {

    // Fault tolerance management endpoint
    isolated resource function post faults(http:Caller caller, http:Request req) {
        // Forward the request to the fault tolerance service
        http:Response|http:ClientError response = faultToleranceClient->forward("/faultTolerance", req);
        handleResponse(response, caller);
    }

    // Load balancing management endpoint
    isolated resource function get loadBalance(http:Caller caller, http:Request req) {
        http:Response|http:ClientError response = loadBalancerClient->forward("/loadBalancer", req);
        handleResponse(response, caller);
    }

    isolated function handleResponse(http:Response|http:ClientError response, http:Caller caller) {
        if (response is http:Response) {
            // If the response is successful, forward it to the client
            checkpanic caller->respond(response);
        } else {
            // If there's an error, respond with a default error message
            http:Response failureResponse = new;
            failureResponse.setTextPayload("Failed to process request due to error");
            failureResponse.statusCode = http:STATUS_BAD_GATEWAY;
            checkpanic caller->respond(failureResponse);
        }
    }
}
