import ballerina/http;
import ballerina/log;

configurable int cliPort = 7070;
listener http:Listener cliListener = new(cliPort);

// Client to forward CLI commands to other services
http:Client cliServiceClient = check new("http://localhost:8081");

service /cli on cliListener {

    // Endpoint for CLI commands
    resource isolated function post command(http:Caller caller, http:Request req) {
        // Log the incoming request for observability
        log:printInfo("Received CLI command request.");

         http:Response|http:ClientError response = cliServiceClient->forward("/cli/registerService", req);
        handleResponse(response, caller);
    }
}

// Handles response from service and sends it back to the client
isolated function handleResponse(http:Response|error response, http:Caller caller) {
    if (response is http:Response) {
        log:printInfo("Forwarded request successfully.");
        checkpanic caller->respond(response);
    } else {
        log:printError("Error forwarding request.", response);
        checkpanic caller->respond("Error occurred while processing the request.");
    }
}
