import ballerina/http;
import ballerina/log;
import ballerina/uuid;

type ServiceInfo record {
    string serviceId;
    string serviceName;
    string serviceURL;
    string status;
};

// In-memory storage for registered services (This can be replaced with a persistent store)
map<ServiceInfo> registeredServices = {};

service /serviceregistry on new http:Listener(8083) {

    // POST /register: Register a new microservice
    resource function post register(http:Caller caller, http:Request req) {
        json payload = checkpanic req.getJsonPayload();

        // Parse the service details from the request payload
        string serviceName = checkpanic payload.serviceName.toString();
        string serviceURL = checkpanic payload.serviceURL.toString();
        string serviceId = uuid:createType1AsString();
        
        // Create a new service info record
        ServiceInfo newService = {
            serviceId: serviceId,
            serviceName: serviceName,
            serviceURL: serviceURL,
            status: "active"
        };

        // Store the service in in-memory registry
        registeredServices[serviceId] = newService;

        // Respond with the assigned service ID and details
        json responsePayload = {
            "message": "Service registered successfully.",
            "serviceId": serviceId,
            "serviceName": serviceName,
            "serviceURL": serviceURL
        };
        checkpanic caller->respond(responsePayload);
        log:printInfo("Service " + serviceName + " registered with ID: " + serviceId);
    }

    // GET /discover: Retrieve the list of available microservices
    resource function get discover(http:Caller caller, http:Request req) {
        json[] serviceList = [];

        // Iterate over all registered services and build the response
        foreach var [serviceId, service] in registeredServices.entries() {
            if service.status == "active" {
                json serviceInfo = {
                    "serviceId": service.serviceId,
                    "serviceName": service.serviceName,
                    "serviceURL": service.serviceURL
                };
                serviceList.push(serviceInfo);
            }
        }

        // Return the list of active services
        json responsePayload = {
            "availableServices": serviceList
        };
        checkpanic caller->respond(responsePayload);
    }
}
