import ballerina/http;
import ballerina/log;

type Task record {
    string taskId;
    string serviceId;
    string taskDescription;
    string status;
};

// In-memory storage for tasks (This could be replaced by a database later)
map<Task> tasks = {};

// Simulate available microservices (in a real scenario, these would be dynamically managed)
string[] availableServices = ["service-1", "service-2", "service-3"];

service /taskscheduler on new http:Listener(8082) {

    // POST /schedule: Schedule a task to an available microservice
    resource function post schedule(http:Caller caller, http:Request req) {
        json payload = checkpanic req.getJsonPayload();

        // Parse task details from the request payload
        string taskDescription = checkpanic payload.taskDescription.toString();
        string serviceId = assignTaskToMicroservice();
        
        if serviceId == "" {
            checkpanic caller->respond("No available services at the moment.");
            return;
        }

        // Create the task
        string taskId = "task-" + (tasks.keys().length() + 1).toString();
        Task task = {
            taskId: taskId,
            serviceId: serviceId,
            taskDescription: taskDescription,
            status: "Assigned"
        };

        // Store the task in in-memory storage
        tasks[taskId] = task;

        // Respond to the user with the assigned service
        json responsePayload = {
            "message": "Task scheduled successfully.",
            "taskId": taskId,
            "serviceId": serviceId
        };
        checkpanic caller->respond(responsePayload);
        log:printInfo("Task " + taskId + " assigned to " + serviceId);
    }

    // GET /status/{serviceID}: Get the status of tasks for a specific service
    resource function get status(http:Caller caller, http:Request req, string serviceID) {
        json[] taskList = [];

        // Iterate through all tasks to find those assigned to the given service ID
        foreach var [taskId, task] in tasks.entries() {
            if task.serviceId == serviceID {
                json taskInfo = {
                    "taskId": task.taskId,
                    "taskDescription": task.taskDescription,
                    "status": task.status
                };
                taskList.push(taskInfo);
            }
        }

        // Return the task list to the user
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

// Function to assign tasks to the next available microservice
function assignTaskToMicroservice() returns string {
    foreach var service in availableServices {
        // In a real-world scenario, we'd check the service's load or availability here
        return service;
    }
    return "";  // No services available
}
