import ballerina/io;
import ballerina/log;
import ballerina/http;
import ballerina/uuid;
import ballerina/time;

service /cli on new http:Listener(8081) {

    resource function post registerService(http:Caller caller, http:Request req) {
        json payload = checkpanic req.getJsonPayload();
        string serviceName = payload.service_name.toString();
        string serviceURL = payload.url.toString();

        // Call the another microservice API to register the service
        http:Client orchestrationService = checkpanic new("http://localhost:8080/registerService");

        json requestPayload = { 
            "service_name": serviceName, 
            "url": serviceURL 
            
        };

        var response = orchestrationService->post("/registerService", requestPayload);
        if response is http:Response {
             checkpanic caller->respond("Service registered successfully: " + response.getText());
        } else {
            check caller->respond("Failed to register the service");

        }


        
    }
    
}