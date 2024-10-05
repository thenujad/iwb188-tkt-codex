import ballerina/http;
import ballerina/log;

type Task record {
    string id;
    string name;
    string description?;
    string status;
    string assignee?;
    string createdAt;
    string updatedAt?;
};
