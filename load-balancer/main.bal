import ballerina/http;
import ballerina/log;

// Structure to represent service load
type ServiceLoad record {
    string serviceId;
    string serviceName;
    int activeRequests;  // Number of active requests (load measure)
};

// In-memory store for tracking service loads
map<ServiceLoad> serviceLoadRegistry = {
    "service-001": {serviceId: "service-001", serviceName: "Auth Service", activeRequests: 0},
    "service-002": {serviceId: "service-002", serviceName: "Task Scheduler", activeRequests: 0},
    "service-003": {serviceId: "service-003", serviceName: "Notification Service", activeRequests: 0}
};

// Load Balancer Microservice
service /loadBalancer on new http:Listener(8086) {

    // POST /balance/request: Route incoming request to the least loaded service
    resource function post balance(http:Caller caller, http:Request req) {
        string selectedService = getLeastLoadedService();
        if (selectedService != "") {
            // Simulate increasing the load for the selected service
            ServiceLoad selectedServiceData = serviceLoadRegistry[selectedService];
            selectedServiceData.activeRequests += 1;
            serviceLoadRegistry[selectedService] = selectedServiceData;

            json responsePayload = {
                "message": "Request routed to service",
                "serviceId": selectedServiceData.serviceId,
                "serviceName": selectedServiceData.serviceName,
                "currentLoad": selectedServiceData.activeRequests
            };

            log:printInfo("Request routed to " + selectedServiceData.serviceName + " with current load: " + selectedServiceData.activeRequests.toString());
            checkpanic caller->respond(responsePayload);
        } else {
            // No available services found
            json errorPayload = { "error": "No available services to route the request" };
            checkpanic caller->respond(errorPayload, http:STATUS_SERVICE_UNAVAILABLE);
        }
    }

    // GET /load/{serviceID}: Retrieve the current load of a specific service
    resource function get load(http:Caller caller, http:Request req, string serviceID) {
        if (serviceLoadRegistry.hasKey(serviceID)) {
            ServiceLoad service = serviceLoadRegistry[serviceID];
            json responsePayload = {
                "serviceId": service.serviceId,
                "serviceName": service.serviceName,
                "activeRequests": service.activeRequests
            };

            log:printInfo("Load status of service " + service.serviceName + ": " + service.activeRequests.toString());
            checkpanic caller->respond(responsePayload);
        } else {
            json errorPayload = { "error": "Service not found" };
            checkpanic caller->respond(errorPayload, http:STATUS_NOT_FOUND);
        }
    }
}

// Function to select the least loaded service
function getLeastLoadedService() returns string {
    string leastLoadedService = "";
    int minLoad = 10000;  // Large initial value to compare load

    foreach var [serviceID, service] in serviceLoadRegistry.entries() {
        if (service.activeRequests < minLoad) {
            minLoad = service.activeRequests;
            leastLoadedService = serviceID;
        }
    }

    return leastLoadedService;
}
