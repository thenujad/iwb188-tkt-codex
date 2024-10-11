import ballerina/http;
import ballerina/log;
import ballerina/os;

// Sample structure to store service usage statistics
type ServiceUsage record {
    string serviceId;
    string serviceName;
    float cpuUsage;   // CPU usage in percentage
    float memoryUsage; // Memory usage in MB
    int traffic;      // Traffic in requests per second
};

// In-memory storage for service usage data (simulating monitoring stats)
map<ServiceUsage> usageData = {};

// Service Scaling Microservice
service /scaling on new http:Listener(8084) {

    // POST /scale/up: Trigger scaling up for a service
    resource function post scaleUp(http:Caller caller, http:Request req) {
        json payload = checkpanic req.getJsonPayload();

        string serviceId = checkpanic payload.serviceId.toString();
        string serviceName = checkpanic payload.serviceName.toString();

        // Logic to scale up the service (e.g., start new instances, containers)
        log:printInfo("Scaling up service " + serviceName + " (ID: " + serviceId + ")");
        
        // Simulating scaling up with a success message
        json responsePayload = {
            "message": "Service scaled up successfully",
            "serviceId": serviceId,
            "serviceName": serviceName
        };
        checkpanic caller->respond(responsePayload);
    }

    // POST /scale/down: Trigger scaling down for a service
    resource function post scaleDown(http:Caller caller, http:Request req) {
        json payload = checkpanic req.getJsonPayload();

        string serviceId = checkpanic payload.serviceId.toString();
        string serviceName = checkpanic payload.serviceName.toString();

        // Logic to scale down the service (e.g., stop unused instances)
        log:printInfo("Scaling down service " + serviceName + " (ID: " + serviceId + ")");
        
        // Simulating scaling down with a success message
        json responsePayload = {
            "message": "Service scaled down successfully",
            "serviceId": serviceId,
            "serviceName": serviceName
        };
        checkpanic caller->respond(responsePayload);
    }

    // GET /monitor/usage: Monitor and report CPU, memory, and traffic stats
    resource function get monitorUsage(http:Caller caller, http:Request req) {
        // Simulate fetching usage stats from a monitoring system
        json[] usageList = [];
        
        foreach var [serviceId, usage] in usageData.entries() {
            json usageInfo = {
                "serviceId": usage.serviceId,
                "serviceName": usage.serviceName,
                "cpuUsage": usage.cpuUsage,
                "memoryUsage": usage.memoryUsage,
                "traffic": usage.traffic
            };
            usageList.push(usageInfo);
        }

        // Respond with the service usage data
        json responsePayload = {
            "serviceUsageStats": usageList
        };
        checkpanic caller->respond(responsePayload);
    }
}
