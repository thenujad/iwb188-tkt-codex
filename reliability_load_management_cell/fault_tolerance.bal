import ballerina/http;
import ballerina/log;

// Sample structure to store service health data
type ServiceStatus record {
    string serviceId;
    string serviceName;
    boolean isHealthy;
};

// In-memory storage for service health data (simulating status checks)
map<ServiceStatus> serviceRegistry = {
    "service-001": {serviceId: "service-001", serviceName: "Auth Service", isHealthy: true},
    "service-002": {serviceId: "service-002", serviceName: "Task Scheduler", isHealthy: true}
};

// Fault Tolerance Microservice
service /faultTolerance on new http:Listener(8085) {

    // GET /healthcheck/{serviceID}: Perform a health check on a microservice
    isolated resource function get healthcheck(http:Caller caller, http:Request req, string serviceID) {
        if (serviceRegistry.hasKey(serviceID)) {
            ServiceStatus service = serviceRegistry[serviceID];
            
            json responsePayload = {
                "serviceId": service.serviceId,
                "serviceName": service.serviceName,
                "isHealthy": service.isHealthy
            };

            log:printInfo("Health check for service " + service.serviceName + ": " + (service.isHealthy ? "Healthy" : "Unhealthy"));
            checkpanic caller->respond(responsePayload);
        } else {
            // Return a 404 if the service ID doesn't exist
            json errorPayload = { "error": "Service not found" };
            checkpanic caller->respond(errorPayload, http:STATUS_NOT_FOUND);
        }
    }

    // POST /restart/{serviceID}: Restart a failed microservice
    isolated resource function post restart(http:Caller caller, http:Request req, string serviceID) {
        if (serviceRegistry.hasKey(serviceID)) {
            ServiceStatus service = serviceRegistry[serviceID];
            // Logic to restart the service
            log:printInfo("Restarting service " + service.serviceName);
            service.isHealthy = true;  // Simulate that the service is restarted and healthy again
            serviceRegistry[serviceID] = service;

            json responsePayload = {
                "message": "Service restarted successfully",
                "serviceId": service.serviceId,
                "serviceName": service.serviceName
            };
            checkpanic caller->respond(responsePayload);
        } else {
            // Return a 404 if the service ID doesn't exist
            json errorPayload = { "error": "Service not found" };
            checkpanic caller->respond(errorPayload, http:STATUS_NOT_FOUND);
        }
    }

    // GET /failover/{serviceID}: Redirect traffic to a healthy instance in case of failure
    isolated resource function get failover(http:Caller caller, http:Request req, string serviceID) {
        if (serviceRegistry.hasKey(serviceID)) {
            ServiceStatus service = serviceRegistry[serviceID];
            
            if (!service.isHealthy) {
                // Logic to redirect traffic to a healthy instance
                // Here we simulate finding a backup or healthy instance
                string failoverService = findHealthyInstance(serviceID);

                json responsePayload = {
                    "message": "Failover triggered. Redirecting traffic to healthy instance.",
                    "originalServiceId": service.serviceId,
                    "redirectedTo": failoverService
                };
                log:printInfo("Failover for service " + service.serviceName + " to " + failoverService);
                checkpanic caller->respond(responsePayload);
            } else {
                json responsePayload = {
                    "message": "Service is healthy. No failover needed.",
                    "serviceId": service.serviceId,
                    "serviceName": service.serviceName
                };
                checkpanic caller->respond(responsePayload);
            }
        } else {
            // Return a 404 if the service ID doesn't exist
            json errorPayload = { "error": "Service not found" };
            checkpanic caller->respond(errorPayload, http:STATUS_NOT_FOUND);
        }
    }
}

// Simulated function to find a healthy instance for failover
isolated function findHealthyInstance(string failedServiceID) returns string {
    foreach var [serviceID, service] in serviceRegistry.entries() {
        if (serviceID != failedServiceID && service.isHealthy) {
            return service.serviceId;
        }
    }
    return "No healthy instance available";
}