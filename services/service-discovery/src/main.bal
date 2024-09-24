import ballerina/http;
import ballerina/log;

service /registry on new http:Listener(8082) {

    resource function post /register(http:Caller caller, ServiceRecord service) returns error? {
        registerService(service);
        log:printInfo("Registered Service: " + service.name);
        check caller->respond({message: "Service registered", statusCode: 201});
    }

    resource function get /lookup/[string name](http:Caller caller) returns error? {
        ServiceRecord? service = getService(name);
        if service is ServiceRecord {
            check caller->respond(service);
        } else {
            check caller->respond({message: "Service not found", statusCode: 404});
        }
    }
}
