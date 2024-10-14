import ballerina/http;
import ballerina/log;
import ballerina/uuid;

// Define structures for logs, metrics, and traces
type LogEntry record {
    string timestamp;
    string serviceId;
    string logLevel;
    string message;
};

type MetricData record {
    string serviceId;
    string serviceName;
    float uptime;           // in seconds
    float responseTime;    // in milliseconds
    int errorRate;         // number of errors per minute
};

type TraceInfo record {
    string requestId;
    string serviceId;
    string operation;
    string timestamp;
    string status;
};

// In-memory storage for logs, metrics, and traces
map<LogEntry[]> serviceLogs = {};
map<MetricData> serviceMetrics = {};
map<TraceInfo[]> requestTraces = {};

// Initialize some dummy data for demonstration
function initDummyData() {
    // Initialize service logs
    serviceLogs["service-001"] = [
        {
            timestamp: "2024-04-27T10:00:00Z",
            serviceId: "service-001",
            logLevel: "INFO",
            message: "Auth Service started successfully."
        },
        {
            timestamp: "2024-04-27T10:05:00Z",
            serviceId: "service-001",
            logLevel: "ERROR",
            message: "Failed to authenticate user."
        }
    ];

    // Initialize service metrics
    serviceMetrics["service-001"] = {
        serviceId: "service-001",
        serviceName: "Auth Service",
        uptime: 3600.5,
        responseTime: 120.3,
        errorRate: 5
    };

    // Initialize request traces
    requestTraces["req-12345"] = [
        {
            requestId: "req-12345",
            serviceId: "service-001",
            operation: "authenticateUser",
            timestamp: "2024-04-27T10:05:00Z",
            status: "FAILED"
        },
        {
            requestId: "req-12345",
            serviceId: "service-002",
            operation: "logFailedAuth",
            timestamp: "2024-04-27T10:05:01Z",
            status: "SUCCESS"
        }
    ];
}

initDummyData();

// Observability & Monitoring Microservice
service /observability on new http:Listener(8087) {

    // GET /logs/{serviceID}: Fetch logs from a specific microservice
    resource function get logs(http:Caller caller, http:Request req, string serviceID) returns error? {
        if serviceLogs.hasKey(serviceID) {
            LogEntry[] logs = serviceLogs[serviceID];
            json responsePayload = { "serviceId": serviceID, "logs": logs };
            log:printInfo("Fetched logs for service ID: " + serviceID);
            check caller->respond(responsePayload);
        } else {
            json errorPayload = { "error": "Service ID not found or no logs available." };
            log:printError("Logs not found for service ID: " + serviceID);
            check caller->respond(errorPayload, http:STATUS_NOT_FOUND);
        }
    }

    // GET /metrics/{serviceID}: Collect metrics for a specific microservice
    resource function get metrics(http:Caller caller, http:Request req, string serviceID) returns error? {
        if serviceMetrics.hasKey(serviceID) {
            MetricData metrics = serviceMetrics[serviceID];
            json responsePayload = {
                "serviceId": metrics.serviceId,
                "serviceName": metrics.serviceName,
                "uptime": metrics.uptime,
                "responseTime": metrics.responseTime,
                "errorRate": metrics.errorRate
            };
            log:printInfo("Fetched metrics for service ID: " + serviceID);
            check caller->respond(responsePayload);
        } else {
            json errorPayload = { "error": "Service ID not found or no metrics available." };
            log:printError("Metrics not found for service ID: " + serviceID);
            check caller->respond(errorPayload, http:STATUS_NOT_FOUND);
        }
    }

    // GET /trace/{requestID}: Trace a specific request through the service architecture
    resource function get trace(http:Caller caller, http:Request req, string requestID) returns error? {
        if requestTraces.hasKey(requestID) {
            TraceInfo[] traces = requestTraces[requestID];
            json responsePayload = { "requestId": requestID, "traces": traces };
            log:printInfo("Fetched trace for request ID: " + requestID);
            check caller->respond(responsePayload);
        } else {
            json errorPayload = { "error": "Request ID not found or no trace available." };
            log:printError("Trace not found for request ID: " + requestID);
            check caller->respond(errorPayload, http:STATUS_NOT_FOUND);
        }
    }

    // Additional endpoints for real-time data updates (optional)
    // These can be used by other microservices to send logs, metrics, and traces
    // POST /logs: Add a new log entry
    resource function post addLog(http:Caller caller, http:Request req) returns error? {
        json payload = check req.getJsonPayload();
        LogEntry newLog = {
            timestamp: check payload.timestamp.toString(),
            serviceId: check payload.serviceId.toString(),
            logLevel: check payload.logLevel.toString(),
            message: check payload.message.toString()
        };
        if !serviceLogs.hasKey(newLog.serviceId) {
            serviceLogs[newLog.serviceId] = [];
        }
        serviceLogs[newLog.serviceId].push(newLog);
        log:printInfo("Added new log for service ID: " + newLog.serviceId);
        json responsePayload = { "message": "Log added successfully." };
        check caller->respond(responsePayload);
    }

    // POST /metrics: Update metrics for a service
    resource function post updateMetrics(http:Caller caller, http:Request req) returns error? {
        json payload = check req.getJsonPayload();
        MetricData updatedMetrics = {
            serviceId: check payload.serviceId.toString(),
            serviceName: check payload.serviceName.toString(),
            uptime: check payload.uptime.toFloat(),
            responseTime: check payload.responseTime.toFloat(),
            errorRate: check payload.errorRate.toInt()
        };
        serviceMetrics[updatedMetrics.serviceId] = updatedMetrics;
        log:printInfo("Updated metrics for service ID: " + updatedMetrics.serviceId);
        json responsePayload = { "message": "Metrics updated successfully." };
        check caller->respond(responsePayload);
    }

    // POST /trace: Add a new trace entry
    resource function post addTrace(http:Caller caller, http:Request req) returns error? {
        json payload = check req.getJsonPayload();
        TraceInfo newTrace = {
            requestId: check payload.requestId.toString(),
            serviceId: check payload.serviceId.toString(),
            operation: check payload.operation.toString(),
            timestamp: check payload.timestamp.toString(),
            status: check payload.status.toString()
        };
        if !requestTraces.hasKey(newTrace.requestId) {
            requestTraces[newTrace.requestId] = [];
        }
        requestTraces[newTrace.requestId].push(newTrace);
        log:printInfo("Added new trace for request ID: " + newTrace.requestId);
        json responsePayload = { "message": "Trace added successfully." };
        check caller->respond(responsePayload);
    }
}

// Optionally, implement periodic tasks or background workers to simulate real-time monitoring
// For example, updating metrics periodically or cleaning up old logs/traces