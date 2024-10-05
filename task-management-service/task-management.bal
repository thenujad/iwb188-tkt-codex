import ballerina/http;
import ballerina/uuid;
import ballerina/time;
import ballerina/io;


// Declare taskStore as a map to hold Task records
map<Task> taskStore = {};

service /task-management on new http:Listener(9090) {

    // task-management-service/tasks
    resource function post .(http:Caller caller, http:Request req) returns error? {
        json payload = check req.getJsonPayload();
        Task newTask = check payload.fromJsonWithType(Task);
        newTask.id = uuid:createType1AsString();
        newTask.createdAt = time:currentTime().toString();
        taskStore[newTask.id] = newTask;
        check caller->respond(newTask);
    }

    resource function get .(http:Caller caller, http:Request req) returns error? {
        string taskId = req.getQueryParamValue("id");
        if taskId == "" {
            check caller->respond(taskStore);
        } else {
            Task? task = taskStore[taskId];
            if task is Task {
                check caller->respond(task);
            } else {
                check caller->respond(http:NOT_FOUND);
            }
        }
    }

    resource function put .(http:Caller caller, http:Request req) returns error? {
        json payload = check req.getJsonPayload();
        Task updatedTask = check payload.fromJsonWithType(Task);
        if taskStore.hasKey(updatedTask.id) {
            taskStore[updatedTask.id] = updatedTask;
            check caller->respond(updatedTask);
        } else {
            check caller->respond(http:NOT_FOUND);
        }
    }
}