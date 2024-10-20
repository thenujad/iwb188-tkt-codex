import ballerina/http;
import ballerina/log;

// Reading values from the Config.toml file
configurable int serviceGatewayPort = 9091;
configurable string corePlatformServiceURL = ?;
configurable string reliabilityServiceURL = ?;
configurable string observabilityServiceURL = ?;
configurable string cliMicroserviceURL = ?;
configurable string dbServiceURL = ?;

// HTTP Listener for the service gateway
listener http:Listener serviceGatewayListener = new(serviceGatewayPort);

// HTTP clients for other cell gateways, using configuration values
http:Client corePlatformClient = check new(corePlatformServiceURL);
http:Client reliabilityClient = check new(reliabilityServiceURL);
http:Client observabilityClient = check new(observabilityServiceURL);
http:Client cliMicroserviceClient = check new(cliMicroserviceURL);
http:Client dbClient = check new(dbServiceURL);

// Service gateway for routing requests to other services
service /servicegateway on serviceGatewayListener {

    // Route for core platform services
    isolated resource function get corePlatform(http:Caller caller, http:Request req) returns error? {
        string path = req.getPath();
        http:Response|error response = corePlatformClient->forward("/coreplatform" + path, req);
        check handleResponse(response, caller);
    }

    // Route for reliability services
    isolated resource function get reliability(http:Caller caller, http:Request req) returns error? {
        string path = req.getPath();
        http:Response|error response = reliabilityClient->forward("/reliability" + path, req);
        check handleResponse(response, caller);
    }

    // Route for observability services
    isolated resource function get observability(http:Caller caller, http:Request req) returns error? {
        string path = req.getPath();
        http:Response|error response = observabilityClient->forward("/observability" + path, req);
        check handleResponse(response, caller);
    }

    // Route for CLI microservices
    isolated resource function get cliMicroservice(http:Caller caller, http:Request req) returns error? {
        string path = req.getPath();
        http:Response|error response = cliMicroserviceClient->forward("/cli" + path, req);
        check handleResponse(response, caller);
    }

    // Route for database services
    isolated resource function get database(http:Caller caller, http:Request req) returns error? {
        string path = req.getPath();
        http:Response|error response = dbClient->forward("/database" + path, req);
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
