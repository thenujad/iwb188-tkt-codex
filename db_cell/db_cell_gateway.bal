import ballerina/http;
import ballerina/log;

configurable int cellDbPort = 7071;
listener http:Listener cellDbListener = new(cellDbPort);

// Service client to communicate with `db_cell_service`
http:Client dbCellServiceClient = check new ("http://localhost:7071");

// Service client for interaction with other cells
http:Client corePlatformClient = check new ("http://localhost:8082");
http:Client monitoringClient = check new ("http://localhost:8085");
http:Client reliabilityClient = check new ("http://localhost:8086");

service /cell-db on cellDbListener {

    // Endpoint for database operations
    resource function post dbOperation(http:Caller caller, http:Request req) {
        var response = dbCellServiceClient->forward("/db/operation", req);
        handleResponse(response, caller);
    }

    // Endpoint to initialize the database
    resource function post init(http:Caller caller, http:Request req) {
        var response = dbCellServiceClient->forward("/db/init", req);
        handleResponse(response, caller);
    }

    // Endpoint for orchestrating health checks of connected cells
    resource function get health(http:Caller caller, http:Request req) {
        json coreHealth = checkOrchestrateHealthCheck(corePlatformClient);
        json monitoringHealth = checkOrchestrateHealthCheck(monitoringClient);
        json reliabilityHealth = checkOrchestrateHealthCheck(reliabilityClient);

        json healthStatus = {
            "Core Platform Cell": coreHealth,
            "Monitoring Cell": monitoringHealth,
            "Reliability Cell": reliabilityHealth
        };

        check caller->respond(healthStatus);
    }
}

// Helper function to check the health of other cells
function checkOrchestrateHealthCheck(http:Client client) returns json {
    var response = client->get("/health");
    if (response is http:Response) {
        return response.getJsonPayload();
    }
    return { "status": "unreachable" };
}

// Helper function to handle responses
function handleResponse(http:Response|error response, http:Caller caller) {
    if (response is http:Response) {
        check caller->respond(response);
    } else {
        log:printError("Error occurred in processing request", response);
        check caller->respond({ "status": "error", "message": "Request failed" });
    }
}
