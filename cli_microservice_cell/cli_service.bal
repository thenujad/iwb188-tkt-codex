import ballerina/http;
import ballerina/log;
import ballerina/time;
import ballerina/uuid;

// Configurations for CLI microservice
configurable int servicePort = 8081;
listener http:Listener cliListener = new(servicePort);

// Service for CLI-related operations
service /cli on cliListener {

    // Register a new service via the CLI
    resource isolated function post registerService(http:Caller caller, http:Request req) {
        json|error payload = req.getJsonPayload();
        if (payload is json) {
            json serviceNameJson = payload.service_name;
            json serviceURLJson = payload.url;
            if(serviceNameJson is string && serviceURLJson is string) {
                string serviceName = serviceNameJson;
                string serviceURL = serviceURLJson;
                string requestID = uuid:createType1AsString();

                log:printInfo("Registering service: " + serviceName + ", RequestID: " + requestID);

                // Call another microservice to register the service
                http:Client orchestrationService = checkpanic new("http://localhost:8080");
                json requestPayload = {
                    "service_name": serviceName,
                    "url": serviceURL,
                    "request_id": requestID,
                    "timestamp": time:currentTime().toString()
                };

                // Send the registration request
                http:Response|http:ClientError response = orchestrationService->post("/registerService", requestPayload);
                if (response is http:Response) {
                    log:printInfo("Service registration response received: " + response.getText());
                    checkpanic caller->respond("Service registered successfully: " + response.getText());
                } else {
                    log:printError("Error in service registration", response);
                    checkpanic caller->respond("Service registration failed.");
                }
            } else {
                log:printError("Invalid JSON payload: missing 'service_name' or 'url'");
                checkpanic caller->respond("Invalid JSON payload: missing 'service_name' or 'url'");
            }
        } else {
            log:printError("Invalid JSON payload", payload);
            checkpanic caller->respond("Invalid request payload.");
        }

    }
}
