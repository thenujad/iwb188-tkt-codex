import ballerina/http;
import ballerina/log;

// Reading values from the Config.toml file
configurable int serviceGatewayPort = 9091;
configurable string corePlatformServiceURL = ?;
configurable string reliabilityServiceURL = ?;
configurable string observabilityServiceURL = ?;

// HTTP Listener for the service gateway
listener http:Listener serviceGatewayListener = new(serviceGatewayPort);

// HTTP clients for other cell gateways, using configuration values
http:Client reliabilityGatewayClient = check new("http://localhost:8085");


// Service gateway for routing requests to other services
service /servicegateway on serviceGatewayListener {

    // Route for reliability services
    isolated resource function get reliability(http:Caller caller, http:Request req) returns error? {
        string path = req.getPath();
         http:Response|error response = reliabilityGatewayClient->forward("/reliability" + path, req);
         check handleResponse(response, caller);
    }

}

// Utility function to handle the responses from other services
isolated function handleResponse(http:Response|error response, http:Caller caller) {
    if (response is http:Response) {
        var result = caller->respond(response);
        if (result is error) {
            log:printError("Error sending response to caller", 'error = result);
        }
    } else {
        log:printError("Error in forwarding request", 'error = response);
        var result = caller->respond(http:STATUS_INTERNAL_SERVER_ERROR);
        if (result is error) {
            log:printError("Error sending error response to caller", 'error = result);
        }
    }
}
