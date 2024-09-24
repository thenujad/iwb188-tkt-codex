public type ServiceRecord record {
    string id;
    string name;
    string host;
    int port;
    int load;
};

ServiceRecord[] servicePool = [];

public function balanceRequest() returns ServiceRecord {
    // Simple round-robin or least-load balancing logic
    return servicePool.sort(function (ServiceRecord a, ServiceRecord b) returns int {
        return a.load - b.load;
    })[0];
}

public function registerService(ServiceRecord service) {
    servicePool.push(service);
}
