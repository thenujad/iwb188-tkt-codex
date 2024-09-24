import ballerina/http;

http:Client taskServiceClient = check new ("http://localhost:8081");

service /api on new http:Listener(8080) {

    resource function get tasks(http:Caller caller) returns error? {
        http:Response? response = taskServiceClient->get("/tasks");
        if response is http:Response {
            check caller->respond(response);
        } else {
            check caller->respond({message: "Service unavailable", statusCode: 503});
        }
    }

    resource function post tasks(http:Caller caller, Task task) returns error? {
        http:Response? response = taskServiceClient->post("/tasks", task);
        if response is http:Response {
            check caller->respond(response);
        } else {
            check caller->respond({message: "Service unavailable", statusCode: 503});
        }
    }
}
