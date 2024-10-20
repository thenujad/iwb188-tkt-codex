import ballerina/http;
import ballerina/log;
import ballerina/lang.'error;

// Structure representing service load
type ServiceLoad record {
    string serviceId;
    string serviceName;
    int activeRequests;
};

// Storage for tracking service load
map<ServiceLoad> serviceLoadRegistry = {
    "service-001": {serviceId: "service-001", serviceName: "Auth Service", activeRequests: 0},
    "service-002": {serviceId: "service-002", serviceName: "Task Scheduler", activeRequests: 0}
};

// Load Balancer service
listener http:Listener lbListener = new(8086);

service /loadBalancer on lbListener {

    // Endpoint to balance load
    isolated resource function post balance(http:Caller caller, http:Request req) {
        string service = getLeastLoadedService();
        if (service != "") {
            ServiceLoad serviceLoad = serviceLoadRegistry[service];
            serviceLoad.activeRequests += 1;
            serviceLoadRegistry[service] = serviceLoad;
            json responsePayload = {
                "message": "Routed to service",
                "serviceId": serviceLoad.serviceId
            };
            log:printInfo("Request routed to: " + serviceLoad.serviceName);
            checkpanic caller->respond(responsePayload);
        } else {
            handleServiceUnavailable(caller);
        }
    }

    // Endpoint for retrieving service load
    isolated resource function get load(http:Caller caller, http:Request req, string serviceID) {
        ServiceLoad? serviceOpt = serviceLoadRegistry[serviceID];
        if (serviceOpt is ServiceLoad) {
            json responsePayload = {
                "serviceId": serviceOpt.serviceId,
                "currentLoad": serviceOpt.activeRequests
            };
            checkpanic caller->respond(responsePayload);
        } else {
            handleServiceUnavailable(caller);
        }
    }

    // Function to find the least loaded service
    isolated function getLeastLoadedService() returns string {
        string leastLoaded = "";
        int minLoad = 10000;
        foreach var [id, svc] in serviceLoadRegistry.entries() {
            if (svc.activeRequests < minLoad) {
                minLoad = svc.activeRequests;
                leastLoaded = id;
            }
        }
        return leastLoaded;
    }
}

// Handle service not available
isolated function handleServiceUnavailable(http:Caller caller) {
    json errorPayload = {"error": "Service unavailable"};
    checkpanic caller->respond(errorPayload, http:STATUS_SERVICE_UNAVAILABLE);
}
