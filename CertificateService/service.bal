import ballerina/http;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # Sample resource to test the service
    # + return - string
    resource function post requests() returns string {
        return "Added Certificate Request";
    }

    # Sample resource to test the service
    # + return - string
    resource function get requests() returns string {
        return "Get all requests";
    }
}
