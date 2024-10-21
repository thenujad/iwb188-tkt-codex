import ballerina/sql;
import ballerina/http;
import ballerina/log;

configurable string dbUrl = "jdbc:mysql://localhost:3306/distributed_platform";
configurable string dbUser = "root";
configurable string dbPassword = "password";

// Define a MySQL connection pool
sql:Client dbClient = check new (dbUrl, dbUser, dbPassword);

// Service to handle database operations
service /db on new http:Listener(7071) {

    // Endpoint to initialize database and create tables
    resource function post init(http:Caller caller, http:Request req) returns json|error {
        json response = {};
        json initResponses = check initializeDatabase();
        response["initResults"] = initResponses;
        check caller->respond(response);
    }

    // Endpoint for generic database operations (insert, update, delete)
    resource function post operation(http:Caller caller, http:Request req) {
        json|error payload = req.getJsonPayload();
        if payload is json {
            var dbResponse = performDbOperation(payload);
            handleDbResponse(dbResponse, caller);
        } else {
            check caller->respond({ "status": "error", "message": "Invalid request payload" });
        }
    }
}

// Helper function to initialize database tables
isolated function initializeDatabase() returns json|error {
    json response = {
        "ObservabilityTable": check createObservabilityTable(),
        "CorePlatformTable": check createCorePlatformTable(),
        "ReliabilityTable": check createReliabilityTable(),
        "CLITable": check createCLITable()
    };
    log:printInfo("All database tables initialized successfully.");
    return response;
}

// Database operations functions (insert, update, delete)
isolated function performDbOperation(json payload) returns json|error {
    string operationType = check payload.get("operation").toString();
    string query = check payload.get("query").toString();
    if operationType == "insert" || operationType == "update" || operationType == "delete" {
        check dbClient->execute(query);
        return { "status": "success", "message": "Operation completed successfully." };
    }
    return { "status": "failed", "message": "Unsupported operation type." };
}

// Handle response for database operations
isolated function handleDbResponse(json|error response, http:Caller caller) {
    if response is json {
        check caller->respond(response);
    } else {
        log:printError("Database operation failed", response);
        check caller->respond({ "status": "error", "message": "Database operation failed." });
    }
}

// Function to create observability table
isolated function createObservabilityTable() returns json|error {
    string createQuery = "CREATE TABLE IF NOT EXISTS ObservabilityMetrics ("
                          + "id INT AUTO_INCREMENT PRIMARY KEY, "
                          + "metricName VARCHAR(255) NOT NULL, "
                          + "metricValue DOUBLE NOT NULL, "
                          + "timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
                          + ")";
    var result = check dbClient->execute(createQuery);
    log:printInfo("CLI table created.");
    return { "status": "success", "table": "CLI" };
}

// Function to create CorePlatformTable
isolated function createCorePlatformTable() returns json|error {
    string createQuery = "CREATE TABLE IF NOT EXISTS CorePlatform (" 
                          + "id INT AUTO_INCREMENT PRIMARY KEY, "
                          + "componentName VARCHAR(255) NOT NULL, "
                          + "status VARCHAR(50) NOT NULL, "
                          + "lastChecked TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
                          + ")";
    var result = check dbClient->execute(createQuery);
    log:printInfo("Core Platform table created.");
    return { "status": "success", "table": "CorePlatform" };
}

// Function to create ReliabilityTable
isolated function createReliabilityTable() returns json|error {
    string createQuery = "CREATE TABLE IF NOT EXISTS ReliabilityMetrics ("
                          + "id INT AUTO_INCREMENT PRIMARY KEY, "
                          + "serviceName VARCHAR(255) NOT NULL, "
                          + "uptimePercentage DOUBLE NOT NULL, "
                          + "lastDowntime TIMESTAMP"
                          + ")";
    var result = check dbClient->execute(createQuery);
    log:printInfo("Reliability Metrics table created.");
    return { "status": "success", "table": "ReliabilityMetrics" };
}

// Function to create CLITable
isolated function createCLITable() returns json|error {
    string createQuery = "CREATE TABLE IF NOT EXISTS CLICommands ("
                          + "id INT AUTO_INCREMENT PRIMARY KEY, "
                          + "command VARCHAR(255) NOT NULL, "
                          + "description TEXT, "
                          + "executionCount INT DEFAULT 0"
                          + ")";
    var result = check dbClient->execute(createQuery);
    log:printInfo("CLI Commands table created.");
    return { "status": "success", "table": "CLICommands" };
}
