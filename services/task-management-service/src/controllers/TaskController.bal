import ballerina/http;

Task[] tasks = [];

service /tasks on new http:Listener(8081) {

    resource function get .() returns Task[] {
        return tasks;
    }

    resource function post .(http:Caller caller, Task task) returns error? {
        tasks.push(task);
        check caller->respond({message: "Task created", statusCode: 201});
    }

    resource function put ./[string id](http:Caller caller, Task task) returns error? {
        foreach var t in tasks {
            if t.id == id {
                t.name = task.name;
                t.description = task.description;
                t.status = task.status;
                check caller->respond({message: "Task updated", statusCode: 200});
                return;
            }
        }
        check caller->respond({message: "Task not found", statusCode: 404});
    }
}
