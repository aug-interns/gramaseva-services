import ballerina/http;
import ballerinax/mongodb;

//Database Connection
configurable mongodb:ConnectionConfig mongoConfig = ?;
mongodb:Client mongoClient = checkpanic new (mongoConfig);

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(7070) {

    # Sample resource to test the service
    # + return - string
    resource function get testpolice() returns string {
        return "Police Service Works";
    }
}
