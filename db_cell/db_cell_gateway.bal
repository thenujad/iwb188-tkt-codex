import ballerina/http;
import ballerina/log;

configurable int cellDbPort = 7071;
listener http:Listener cellDbListener = new(cellDbPort);

service /cell-db on cellDbListener {

    // Endpoint for database operations
    resource function post dbOperation(http:Caller caller, http:Request req) {
        var response = cellDbServiceClient->forward("/operation", req);
        handleResponse(response, caller);
    }
}
