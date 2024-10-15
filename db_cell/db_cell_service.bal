import ballerina/sql;
import ballerina/http;
import ballerina/log;
import ballerina/config;

configurable string dbUrl = "jdbc:mysql://localhost:3306/distributed_platform";
configurable string dbUser = "root";
configurable string dbPassword = "password";

// Define a MySQL connection pool
sql:Client dbClient = check new (dbUrl, dbUser, dbPassword);

// Service to handle database operations
service /db on new http:Listener(7071) {

    // Endpoint to initialize database and create tables
    resource function post init(http:Caller caller, http:Request req) returns json|error {
        // Create tables for different cells
        check createObservabilityTable();
        check createCorePlatformTable();
        check createReliabilityTable();
        check createCLITable();

        return { "status": "success", "message": "Database initialized and tables created." };
    }
}

// Function to create observability table
function createObservabilityTable() returns error? {
    string createQuery = "CREATE TABLE IF NOT EXISTS ObservabilityMetrics ("
                          + "id INT AUTO_INCREMENT PRIMARY KEY, "
                          + "metricName VARCHAR(255) NOT NULL, "
                          + "metricValue DOUBLE NOT NULL, "
                          + "timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
                          + ")";
    check dbClient->execute(createQuery);
    log:printInfo("ObservabilityMetrics table created.");
}

// Function to create core platform tables
function createCorePlatformTable() returns error? {
    string createQuery = "CREATE TABLE IF NOT EXISTS CorePlatformServices ("
                          + "id INT AUTO_INCREMENT PRIMARY KEY, "
                          + "serviceName VARCHAR(255) NOT NULL, "
                          + "serviceUrl VARCHAR(255) NOT NULL, "
                          + "status VARCHAR(50) NOT NULL, "
                          + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
                          + ")";
    check dbClient->execute(createQuery);
    log:printInfo("CorePlatformServices table created.");
}

// Function to create reliability tables
function createReliabilityTable() returns error? {
    string createQuery = "CREATE TABLE IF NOT EXISTS ReliabilityLogs ("
                          + "id INT AUTO_INCREMENT PRIMARY KEY, "
                          + "faultType VARCHAR(255) NOT NULL, "
                          + "timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
                          + ")";
    check dbClient->execute(createQuery);
    log:printInfo("ReliabilityLogs table created.");
}

// Function to create CLI related tables
function createCLITable() returns error? {
    string createQuery = "CREATE TABLE IF NOT EXISTS CLICommands ("
                          + "id INT AUTO_INCREMENT PRIMARY KEY, "
                          + "command VARCHAR(255) NOT NULL, "
                          + "response VARCHAR(255), "
                          + "timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
                          + ")";
    check dbClient->execute(createQuery);
    log:printInfo("CLICommands table created.");
}
