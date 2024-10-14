import ballerina/http;
import ballerina/log;

service /gateway on new http:Listener(8080) {

    // POST /gateway/request: Forward a client request to the relevant microservice
    resource function post request(http:Caller caller, http:Request req) returns error? {
        // Extract the target service URL from the request (assumed to be passed in the body)
        json payload = check req.getJsonPayload();
        string serviceUrl = check payload.serviceUrl.toString();
        json requestBody = payload.requestBody;
        
        // Create a new HTTP client for forwarding the request
        http:Client serviceClient = check new (serviceUrl);

        // Forward the request to the target microservice
        http:Request forwardedReq = new;
        forwardedReq.setJsonPayload(requestBody);
        http:Response serviceResponse = check serviceClient->post("/", forwardedReq);

        // Send back the response from the service to the caller
        check caller->respond(serviceResponse);
    }

    // GET /gateway/status: Get the status of the gateway and the services connected to it
    resource function get status(http:Caller caller, http:Request req) returns error? {
        json status = {
            "gatewayStatus": "active",
            "connectedServices": ["auth-service", "inventory-service", "order-service", "observability-service"]
        };

        // Respond with the current status of the gateway and its connected services
        check caller->respond(status);
    }
}