import ballerina/http;
import ballerina/log;

configurable int serviceGatewayPort = 9091;
listener http:Listener serviceGatewayListener = new(serviceGatewayPort);

// HTTP clients for other cell gateways
http:Client corePlatformGatewayClient = check new("http://localhost:8081");
http:Client reliabilityGatewayClient = check new("http://localhost:8085");
http:Client observabilityGatewayClient = check new("http://localhost:9090");

service /service-gateway on serviceGatewayListener {

    // Route for core platform services
    resource function get core(http:Caller caller, http:Request req) {
        var response = corePlatformGatewayClient->forward("/core-platform" + req.getPath(), req);
        handleResponse(response, caller);
    }

    // Route for reliability services
    resource function get reliability(http:Caller caller, http:Request req) {
        var response = reliabilityGatewayClient->forward("/reliability" + req.getPath(), req);
        handleResponse(response, caller);
    }

    // Route for observability services
    resource function get observability(http:Caller caller, http:Request req) {
        var response = observabilityGatewayClient->forward("/observability" + req.getPath(), req);
        handleResponse(response, caller);
    }
}
