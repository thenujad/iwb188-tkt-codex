import ballerina/http;
import ballerina/log;

configurable int reliabilityPort = 8085;
listener http:Listener reliabilityListener = new(reliabilityPort);

// HTTP clients for internal services
http:Client faultToleranceClient = check new("http://localhost:8085");
http:Client loadBalancerClient = check new("http://localhost:8086");
http:Client dbClient = check new("http://localhost:8083");

// Service to handle monitoring and reliability functionalities
service /reliability on reliabilityListener {

    // Fault tolerance management endpoint
    isolated resource function post faults(http:Caller caller, http:Request req) {
        // Forward the request to the fault tolerance service
        http:Response|http:ClientError response = faultToleranceClient->forward("/faultTolerance", req);
        handleResponse(response, caller);
    }

    // Load balancing management endpoint
    isolated resource function get loadBalance(http:Caller caller, http:Request req) {
        http:Response|http:ClientError response = loadBalancerClient->forward("/loadBalancer", req);
        handleResponse(response, caller);
    }

    // Endpoint to get health metrics from the DB cell
    resource function get health(http:Caller caller, http:Request req) {
        var dbResponse = dbClient->get("/db/health");
        handleResponse(dbResponse, caller);
    }

    // Endpoint to retrieve system metrics for observability
    resource function get metrics(http:Caller caller, http:Request req) {
        // Example implementation for aggregating metrics
        json metricsData = {
            "cpuUsage": getCPUUsage(),
            "memoryUsage": getMemoryUsage(),
            "dbStatus": getDBStatus()
        };
        var result = caller->respond(metricsData);
        if (result is error) {
            log:printError("Error responding with metrics", result);
        }
    }

    // Endpoint to log system information
    resource function post logs(http:Caller caller, http:Request req) {
        json|error logEntry = req.getJsonPayload();
        if (logEntry is json) {
            log:printInfo("Received log entry: " + logEntry.toJsonString());
            var result = caller->respond({ "status": "success" });
            if (result is error) {
                log:printError("Error sending response", result);
            }
        } else {
            log:printError("Invalid log entry");
            var result = caller->respond({ "status": "failure", "message": "Invalid log entry" });
            if (result is error) {
                log:printError("Error sending response", result);
            }
        }
    }

    isolated function handleResponse(http:Response|http:ClientError response, http:Caller caller) {
        if (response is http:Response) {
            // If the response is successful, forward it to the client
            checkpanic caller->respond(response);
        } else {
            // If there's an error, respond with a default error message
            http:Response failureResponse = new;
            failureResponse.setTextPayload("Failed to process request due to error");
            failureResponse.statusCode = http:STATUS_BAD_GATEWAY;
            checkpanic caller->respond(failureResponse);
        }
    }

    function getCPUUsage() returns float {
        // Placeholder function to retrieve CPU usage
        return 23.5;
    }

    function getMemoryUsage() returns float {
        // Placeholder function to retrieve memory usage
        return 45.8;
    }

    function getDBStatus() returns string {
        // Placeholder function to check DB health
        return "Healthy";
    }
}
