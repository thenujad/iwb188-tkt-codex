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
listener http:Listener lbListener = new(8086);

service /loadBalancer on lbListener {

    // POST /balance/request: Route incoming request to the least loaded service
    isolated resource function post balance(http:Caller caller, http:Request req) {
        string selectedService = getLeastLoadedService();
        if (selectedService != "") {
            // Update the service load registry to simulate increasing the load for the selected service
            ServiceLoad? selectedServiceDataOpt = serviceLoadRegistry[selectedService];
            if selectedServiceDataOpt is ServiceLoad {
                ServiceLoad selectedServiceData = selectedServiceDataOpt;
                selectedServiceData.activeRequests += 1;
                serviceLoadRegistry[selectedService] = selectedServiceData;

                json responsePayload = {
                    "message": "Request routed to service",
                    "serviceId": selectedServiceData.serviceId,
                    "serviceName": selectedServiceData.serviceName,
                    "currentLoad": selectedServiceData.activeRequests
                };

                log:printInfo("Request routed to " + selectedServiceData.serviceName + " with current load: " + selectedServiceData.activeRequests.toString());
                // Respond with the routing information
                checkpanic caller->respond(responsePayload);
            
            } else {
                // Service data not found in the registry
                json errorPayload = { "error": "Selected service not found in the registry" };
                checkpanic caller->respond(errorPayload);
            }
        } else {
            // No available services found
            json errorPayload = { "error": "No available services to route the request" };
            checkpanic caller->respond(errorPayload);
        }
    }

    // GET /load/{serviceID}: Retrieve the current load of a specific service
    isolated resource function get load(http:Caller caller, http:Request req, string serviceID) {
        ServiceLoad? serviceDataOpt = serviceLoadRegistry[serviceID];
        if (serviceDataOpt is ServiceLoad) {
            ServiceLoad service = serviceDataOpt;
            json responsePayload = {
                "serviceId": service.serviceId,
                "serviceName": service.serviceName,
                "activeRequests": service.activeRequests
            };

            log:printInfo("Load status of service " + service.serviceName + ": " + service.activeRequests.toString());
            // Respond with the current load of the specified service
            checkpanic caller->respond(responsePayload);
        } else {
            // Service not found in the registry
            json errorPayload = { "error": "Service not found" };
            checkpanic caller->respond(errorPayload);
        }
    }

    // PUT /balance/release: Decrease the load for a given service (when a request completes)
    isolated resource function put balanceRelease(http:Caller caller, http:Request req) {
        json|error requestBody = req.getJsonPayload();
        if (requestBody is json) {
            string serviceId = requestBody.serviceId.toString();

            if (serviceLoadRegistry.hasKey(serviceId)) {
                ServiceLoad service = serviceLoadRegistry[serviceId];
                // Decrease the load for the given service if it is greater than zero
                if (service.activeRequests > 0) {
                    service.activeRequests -= 1;
                    serviceLoadRegistry[serviceId] = service;
                    json responsePayload = {
                        "message": "Service load updated",
                        "serviceId": service.serviceId,
                        "currentLoad": service.activeRequests
                    };

                    log:printInfo("Service load decreased for " + service.serviceName + ", current load: " + service.activeRequests.toString());
                    // Respond with the updated load information
                    checkpanic caller->respond(responsePayload);
                } else {
                    // The service load is already zero
                    json errorPayload = { "error": "Service load is already zero" };
                    checkpanic caller->respond(errorPayload, http:STATUS_BAD_REQUEST);
                }
            } else {
                // Service not found in the registry
                json errorPayload = { "error": "Service not found" };
                checkpanic caller->respond(errorPayload, http:STATUS_NOT_FOUND);
            }
        } else {
            // Invalid request payload
            json errorPayload = { "error": "Invalid request payload" };
            checkpanic caller->respond(errorPayload, http:STATUS_BAD_REQUEST);
        }
    }
}

// Function to select the least loaded service based on the current active requests
isolated function getLeastLoadedService() returns string {
    string leastLoadedService = "";
    int minLoad = 10000;  // Arbitrary large initial value to compare load

    foreach var [serviceID, service] in serviceLoadRegistry.entries() {
        if (service.activeRequests < minLoad) {
            minLoad = service.activeRequests;
            leastLoadedService = serviceID;
        }
    }

    return leastLoadedService;
}
