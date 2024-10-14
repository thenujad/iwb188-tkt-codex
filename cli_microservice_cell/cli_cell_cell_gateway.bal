import ballerina/http;
import ballerina/log;

// CLI Cell Gateway configuration
configurable int cliPort = 8087;
listener http:Listener cliListener = new(cliPort);

// Client for the CLI service
http:Client cliServiceClient = check new("http://localhost:9101");

service /cli on cliListener {

    // Route for CLI operations
    resource function get cliOperation(http:Caller caller, http:Request req) {
        var response = cliServiceClient->forward("/cli" + req.getPath(), req);
        handleResponse(response, caller);
    }
}

// Utility function to handle responses
function handleResponse(http:Response|error response, http:Caller caller) {
    if (response is http:Response) {
        var result = caller->respond(response);
        if (result is error) {
            log:printError("Error sending response", result);
        }
    } else {
        log:printError("Error calling the service", response);
        var errorResult = caller->respond(response.message());
        if (errorResult is error) {
            log:printError("Error sending error response", errorResult);
        }
    }
}
