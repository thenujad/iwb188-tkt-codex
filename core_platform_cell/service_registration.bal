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
    resource function post register(http:Caller caller, http:Request req) {
        json payload = checkpanic req.getJsonPayload();

        string serviceName = check payload.serviceName.toString();
        string serviceURL = check payload.serviceURL.toString();
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
    }

    // GET /discover: Retrieve the list of active microservices
    resource function get discover(http:Caller caller, http:Request req) {
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
