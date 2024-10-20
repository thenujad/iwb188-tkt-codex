import ballerina/http;
import ballerina/log;
import ballerina/lang.'error;
import ballerina/concurrent;

// Structure for storing service health data
type ServiceStatus record {
    string serviceId;
    string serviceName;
    boolean isHealthy;
};

// In-memory storage for service health data
map<ServiceStatus> serviceRegistry = {
    "service-001": {serviceId: "service-001", serviceName: "Auth Service", isHealthy: true},
    "service-002": {serviceId: "service-002", serviceName: "Task Scheduler", isHealthy: true}
};

// Service to handle fault tolerance operations
service /faultTolerance on new http:Listener(8085) {

    // Endpoint to perform health checks
    isolated resource function get healthcheck(http:Caller caller, http:Request req, string serviceID) {
        if (serviceRegistry.hasKey(serviceID)) {
            ServiceStatus service = serviceRegistry[serviceID];
            json responsePayload = {
                "serviceId": service.serviceId,
                "serviceName": service.serviceName,
                "isHealthy": service.isHealthy
            };
            log:printInfo("Health check for service: " + service.serviceName);
            checkpanic caller->respond(responsePayload);
        } else {
            handleServiceNotFound(caller);
        }
    }

    // Endpoint to restart a failed service
    isolated resource function post restart(http:Caller caller, http:Request req, string serviceID) {
        if (serviceRegistry.hasKey(serviceID)) {
            ServiceStatus service = serviceRegistry[serviceID];
            // Implement logic for orchestrating service restart
            service.isHealthy = restartService(serviceID);
            serviceRegistry[serviceID] = service;
            json responsePayload = {
                "message": "Service restarted",
                "serviceId": service.serviceId,
                "serviceName": service.serviceName
            };
            checkpanic caller->respond(responsePayload);
        } else {
            handleServiceNotFound(caller);
        }
    }

    // Endpoint for triggering failover
    isolated resource function get failover(http:Caller caller, http:Request req, string serviceID) {
        if (serviceRegistry.hasKey(serviceID)) {
            ServiceStatus service = serviceRegistry[serviceID];
            if (!service.isHealthy) {
                string failoverService = findHealthyInstance(serviceID);
                json responsePayload = {
                    "message": "Failover triggered.",
                    "originalServiceId": service.serviceId,
                    "redirectedTo": failoverService
                };
                log:printInfo("Failover from " + service.serviceName + " to " + failoverService);
                checkpanic caller->respond(responsePayload);
            } else {
                json responsePayload = {"message": "Service is healthy. No failover needed."};
                checkpanic caller->respond(responsePayload);
            }
        } else {
            handleServiceNotFound(caller);
        }
    }
}

// Restart service implementation
isolated function restartService(string serviceID) returns boolean {
    log:printInfo("Restarting service " + serviceID);
    // Simulate restart process
    return true;
}

// Handle service not found
isolated function handleServiceNotFound(http:Caller caller) {
    json errorPayload = {"error": "Service not found"};
    checkpanic caller->respond(errorPayload, http:STATUS_NOT_FOUND);
}
