import ballerina/http;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # Sample resource to test the service
    # + return - string
    resource function get testaddress() returns string {
        return "Address Service Works";
    }
}
