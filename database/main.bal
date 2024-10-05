import ballerina/sql;
import ballerina/mysql;

public function main() returns error? {
    sql:Client dbClient = check new (mysql:Client, "localhost", "root", "password", "TasksDB");

    _ = check dbClient->execute(`CREATE DATABASE IF NOT EXISTS TasksDB;`);
    _ = check dbClient->execute(`
        CREATE TABLE IF NOT EXISTS TasksDB.Tasks (
            id              INTEGER AUTO_INCREMENT PRIMARY KEY,
            title           VARCHAR(255) NOT NULL,
            description     TEXT,
            assignedTo      VARCHAR(255),
            dueDate         TIMESTAMP,
            status          VARCHAR(20) NOT NULL
        );
    `);
}