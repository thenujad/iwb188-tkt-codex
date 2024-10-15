import ballerina/http;
import ballerina/log;

configurable int reliabilityPort = 8085;
listener http:Listener reliabilityListener = new(reliabilityPort);

// HTTP clients for internal services
http:Client faultToleranceClient = check new("http://localhost:8086");
http:Client loadBalancerClient = check new("http://localhost:8087");

service /reliability on reliabilityListener {

    // Fault tolerance management endpoint
    resource function post faults(http:Caller caller, http:Request req) {
        var response = faultToleranceClient->forward("/faults", req);
        handleResponse(response, caller);
    }

    // Load balancing management endpoint
    resource function get loadBalance(http:Caller caller, http:Request req) {
        var response = loadBalancerClient->forward("/loadBalance", req);
        handleResponse(response, caller);
    }
}
