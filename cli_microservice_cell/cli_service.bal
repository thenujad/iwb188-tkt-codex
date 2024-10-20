import ballerina/http;
import ballerina/log;
import ballerina/time;
import ballerina/uuid;

configurable int servicePort = 8081;

listener http:Listener cliListener = new(servicePort);

// Service registration endpoint
service /cli on cliListener {

    resource isolated function post registerService(http:Caller caller, http:Request req) {
        json|error payload = req.getJsonPayload();
        if (payload is map<json>) {
            json serviceNameJson = payload["service_name"];
            json serviceURLJson = payload["url"];
            if (serviceNameJson is string && serviceURLJson is string) {
                string serviceName = serviceNameJson.toString();
                string serviceURL = serviceURLJson.toString();
                string requestID = uuid:createType1AsString();

                log:printInfo("Registering service: " + serviceName + ", RequestID: " + requestID);
                http:Client orchestrationService = checkpanic new("http://localhost:8080");
                json requestPayload = {
                    "service_name": serviceName,
                    "url": serviceURL,
                    "request_id": requestID,
                    "timestamp": time:format(time:currentTime(),"yyyy-MM-dd'T'HH:mm:ss.SSSZ")
                };

                http:Response|http:ClientError response = orchestrationService->post("/registerService", requestPayload);
                if (response is http:Response) {
                    string responseText = checkpanic response.getTextPayload();
                    log:printInfo("Service registration response received: " + responseText);
                    checkpanic caller->respond("Service registered successfully: " + responseText);
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
