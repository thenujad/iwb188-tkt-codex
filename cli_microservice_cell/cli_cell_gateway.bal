import ballerina/http;
import ballerina/log;

configurable int cliPort = 7070;
listener http:Listener cliListener = new(cliPort);

service /cli on cliListener {

    // Endpoint for CLI commands
    resource function post command(http:Caller caller, http:Request req) {
        var response = cliServiceClient->forward("/command", req);
        handleResponse(response, caller);
    }
}
