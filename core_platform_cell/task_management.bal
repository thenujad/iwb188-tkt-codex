import ballerina/http;
import ballerina/log;

type Task record {| 
    string taskId;
    string serviceId;
    string taskDescription;
    string status;
|};

map<Task> tasks = {};
string[] availableServices = ["service-1", "service-2", "service-3"];

service /task on new http:Listener(8082) {

// POST schedule: Schedule a task to an available service
    resource isolated function post schedule(http:Caller caller, http:Request req) {
        json|error payload = req.getJsonPayload();
        if (payload is map<json>) {
            json? taskDescriptionJson = payload.taskDescription;
            if (taskDescriptionJson is string) {
                string taskDescription = taskDescriptionJson;
                string serviceId = assignTaskToMicroservice();

                if (serviceId == "") {
                    checkpanic caller->respond("No available services at the moment.");
                    return;
                }

                string taskId = "task-" + (tasks.keys().length() + 1).toString();
                Task task = {
                    taskId: taskId,
                    serviceId: serviceId,
                    taskDescription: taskDescription,
                    status: "Assigned"
                };

                tasks[taskId] = task;

                json responsePayload = {
                    "message": "Task scheduled successfully",
                    "taskId": taskId,
                    "serviceId": serviceId,
                    "taskDescription": taskDescription,
                    "status": "Assigned"
                };
                checkpanic caller->respond(responsePayload);
            } else {
                checkpanic caller->respond("Invalid JSON payload: missing 'taskDescription'");
            }
        } else {
            checkpanic caller->respond("Invalid JSON payload");
        }
    }

    // GET /status/{serviceID}: Get tasks for a specific service
    resource isolated function get status(http:Caller caller, http:Request req, string serviceID) {
        json[] taskList = [];

        foreach var [_, task] in tasks.entries() {
            if task.serviceId == serviceID {
                json taskInfo = {
                    "taskId": task.taskId,
                    "taskDescription": task.taskDescription,
                    "status": task.status
                };
                taskList.push(taskInfo);
            }
        }

        if taskList.length() == 0 {
            checkpanic caller->respond("No tasks found for service: " + serviceID);
        } else {
            json responsePayload = {
                "serviceId": serviceID,
                "tasks": taskList
            };
            checkpanic caller->respond(responsePayload);
        }
    }
}

// Function to assign a task to a microservice
isolated function assignTaskToMicroservice() returns string {
    foreach var availableService in availableServices {
        return availableService;
    }
    return "";
}
