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
http:FailoverClient httpEp = check new ();
http:FailoverClient httpEp1 = check new ();
http:FailoverClient httpEp2 = check new ();
http:FailoverClient httpEp3 = check new ();
http:FailoverClient httpEp4 = check new ();
http:FailoverClient httpEp5 = check new ();
http:FailoverClient httpEp6 = check new ();
http:FailoverClient httpEp7 = check new ();
http:FailoverClient httpEp8 = check new ();
http:FailoverClient httpEp9 = check new ();
http:FailoverClient httpEp10 = check new ();
http:FailoverClient httpEp11 = check new ();
http:FailoverClient httpEp12 = check new ();
http:FailoverClient httpEp13 = check new ();
http:FailoverClient httpEp14 = check new ();
http:FailoverClient httpEp15 = check new ();
http:FailoverClient httpEp16 = check new ();
http:FailoverClient httpEp17 = check new ();
http:FailoverClient httpEp18 = check new ();
http:FailoverClient httpEp19 = check new ();
http:FailoverClient httpEp20 = check new ();
http:FailoverClient httpEp21 = check new ();
http:FailoverClient httpEp22 = check new ();
http:FailoverClient httpEp23 = check new ();
http:FailoverClient httpEp24 = check new ();
http:FailoverClient httpEp25 = check new ();
http:FailoverClient httpEp26 = check new ();
http:FailoverClient httpEp27 = check new ();
http:FailoverClient httpEp28 = check new ();
http:FailoverClient httpEp29 = check new ();
http:FailoverClient httpEp30 = check new ();
http:FailoverClient httpEp31 = check new ();
