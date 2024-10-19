import ballerina/http;
import ballerina/log;
import ballerina/uuid;

type ServiceInfo record {
    string serviceId;
    string serviceName;
    string serviceURL;
    string status;
};

map<ServiceInfo> registeredServices = {};

// Service Registration Microservice
service /serviceregistration on new http:Listener(8083) {

    // POST /register: Register a new microservice
resource isolated function post register(http:Caller caller, http:Request req) {
        json|error payload = req.getJsonPayload();
        if (payload is json) {
            json serviceNameJson = payload.serviceName;
            json serviceURLJson = payload.serviceURL;
            if (serviceNameJson is string && serviceURLJson is string) {
                string serviceName = serviceNameJson;
                string serviceURL = serviceURLJson;
                string serviceId = uuid:createType1AsString();

                ServiceInfo newService = {
                    serviceId: serviceId,
                    serviceName: serviceName,
                    serviceURL: serviceURL,
                    status: "active"
                };

                registeredServices[serviceId] = newService;

                json responsePayload = {
                    "message": "Service registered successfully.",
                    "serviceId": serviceId,
                    "serviceName": serviceName,
                    "serviceURL": serviceURL
                };
                checkpanic caller->respond(responsePayload);
                log:printInfo("Service " + serviceName + " registered with ID: " + serviceId);
            } else {
                json errorPayload = { "error": "Invalid JSON payload: missing 'serviceName' or 'serviceURL'" };
                checkpanic caller->respond(errorPayload);
            }
        } else {
            json errorPayload = { "error": "Invalid JSON payload" };
            checkpanic caller->respond(errorPayload);
        }
    }
    // GET /discover: Retrieve the list of active microservices
    resource isolated function get discover(http:Caller caller, http:Request req) {
        json[] serviceList = [];

        foreach var [_, serviceregistration] in registeredServices.entries() {
            if serviceregistration.status == "active" {
                json serviceInfo = {
                    "serviceId": serviceregistration.serviceId,
                    "serviceName": serviceregistration.serviceName,
                    "serviceURL": serviceregistration.serviceURL
                };
                serviceList.push(serviceInfo);
            }
        }

        json responsePayload = {
            "availableServices": serviceList
        };
        checkpanic caller->respond(responsePayload);
    }
}
