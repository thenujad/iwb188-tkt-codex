public function retryRequest(function () returns error fn, int retries) returns error? {
    error? result;
    foreach int i in 0...retries {
        result = fn();
        if result is () {
            return ();
        }
    }
    return result;
}
