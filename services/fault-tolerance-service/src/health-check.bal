import ballerina/http;

public function healthCheck(string serviceUrl) returns boolean {
    http:Client client = check new(serviceUrl);
    http:Response? response = client->get("/");
    return response is http:Response && response.statusCode == 200;
}
