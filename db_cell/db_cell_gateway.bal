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

service /celldb on cellDbListener {

    // Endpoint for database operations
    resource isolated function post dbOperation(http:Caller caller, http:Request req) {
        http:Response|http:ClientError response = dbCellServiceClient->forward("/db/operation", req);
        handleResponse(response, caller);
    }

    // Endpoint to initialize the database
    resource isolated function post init(http:Caller caller, http:Request req) {
        http:Response|http:ClientError response = dbCellServiceClient->forward("/db/init", req);
        handleResponse(response, caller);
    }

    // Endpoint for orchestrating health checks of connected cells
    resource isolated function get health(http:Caller caller, http:Request req) {
        json coreHealth = check checkOrchestrateHealthCheck(corePlatformClient);
        json monitoringHealth = check checkOrchestrateHealthCheck(monitoringClient);
        json reliabilityHealth = check checkOrchestrateHealthCheck(reliabilityClient);

        json healthStatus = {
            "Core Platform Cell": coreHealth,
            "Monitoring Cell": monitoringHealth,
            "Reliability Cell": reliabilityHealth
        };

        check caller->respond(healthStatus);
    }
}
// Helper function to handle responses
isolated function handleResponse(http:Response|http:ClientError response, http:Caller caller) {
    if (response is http:Response) {
        checkpanic caller->respond(response);
    } else {
        log:printError("Error forwarding request.", response);
        checkpanic caller->respond("Error occurred while processing the request.");
    }
}

// Helper function to orchestrate health checks
isolated function checkOrchestrateHealthCheck(http:Client client) returns json|error {
    http:Response|http:ClientError response = client->get("/health");
    if (response is http:Response) {
        return response.getJsonPayload();
    } else {
        log:printError("Error checking health.", response);
        return { "status": "unhealthy" };
    }
}