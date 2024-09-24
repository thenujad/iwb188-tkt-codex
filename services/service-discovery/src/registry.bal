public type ServiceRecord record {
    string id;
    string name;
    string host;
    int port;
};

ServiceRecord[] registry = [];

public function registerService(ServiceRecord service) {
    registry.push(service);
}

public function getService(string name) returns ServiceRecord? {
    foreach var service in registry {
        if service.name == name {
            return service;
        }
    }
    return ();
}
