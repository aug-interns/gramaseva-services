import ballerina/http;
import ballerina/log;
import SupportService.Types;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    resource function post request(@http:Payload Types:SupportRequest request) returns string|error {
        log:printInfo(request.toJsonString());
        return "Success";
    }
}
