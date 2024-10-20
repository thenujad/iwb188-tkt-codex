import ballerina/http;
import ballerina/log;

type ServiceUsage record {
    string serviceId;
    string serviceName;
    float cpuUsage;
    float memoryUsage;
    int traffic;
};

map<ServiceUsage> usageData = {};

service /scaling on new http:Listener(8084) {

    // POST /scale/up: Trigger scaling up
    resource function post scaleUp(http:Caller caller, http:Request req) {
        json payload = checkpanic req.getJsonPayload();
        string serviceId = checkpanic payload.serviceId.toString();
        string serviceName = checkpanic payload.serviceName.toString();

        log:printInfo("Scaling up service " + serviceName + " (ID: " + serviceId)"); 

        json responsePayload = {
            "message": "Service scaled up successfully",
            "serviceId": serviceId,
            "serviceName": serviceName
        };
        checkpanic caller->respond(responsePayload);
    }

    // POST /scale/down: Trigger scaling down
    resource function post scaleDown(http:Caller caller, http:Request req) {
        json|error payload = req.getJsonPayload();
        if (payload is json) {
            json? serviceIdJson = payload["serviceId"];
            json? serviceNameJson = payload["serviceName"];
            if (serviceIdJson is string && serviceNameJson is string) {
                string serviceId = serviceIdJson;
                string serviceName = serviceNameJson;

                log:printInfo("Scaling down service " + serviceName + " (ID: " + serviceId + ")");

                json responsePayload = {
                    "message": "Service scaled down successfully",
                    "serviceId": serviceId,
                    "serviceName": serviceName
                };
                checkpanic caller->respond(responsePayload);
            } else {
                checkpanic caller->respond({ "error": "Invalid JSON payload: missing 'serviceId' or 'serviceName'" });
            }
        } else {
            checkpanic caller->respond({ "error": "Invalid JSON payload" });
        }
    }
    // GET /monitor/usage: Report usage stats
    resource function get monitorUsage(http:Caller caller, http:Request req) {
        json[] usageList = [];

        foreach var [_, usage] in usageData.entries() {
            json usageInfo = {
                "serviceId": usage.serviceId,
                "serviceName": usage.serviceName,
                "cpuUsage": usage.cpuUsage,
                "memoryUsage": usage.memoryUsage,
                "traffic": usage.traffic
            };
            usageList.push(usageInfo);
        }

        json responsePayload = {
            "serviceUsageStats": usageList
        };
        checkpanic caller->respond(responsePayload);
    }
}
