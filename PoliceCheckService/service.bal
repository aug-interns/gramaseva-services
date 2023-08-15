import ballerina/http;
import ballerinax/mongodb;

//Database Connection
configurable mongodb:ConnectionConfig mongoConfig = ?;
mongodb:Client mongoClient = checkpanic new (mongoConfig);

# A service representing a network-accessible API
# bound to port `7070`.

service /police\-check/api on new http:Listener(7070) {

    resource function get status/[string NIC]() returns string|InvalidNicError?|error {
        map<json> filter_query = {"NIC": NIC};
        stream<PoliceEntry, error?> policeEntry = checkpanic mongoClient->find(collectionName = "Police", filter = filter_query, 'limit = 1);

        string status = "";
        check policeEntry.forEach(function(PoliceEntry entry) {
            status = entry.criminalstatus;
        });

        if status is "" {
            return {
                body: {
                    errmsg: string `Invalid NIC: ${NIC}`
                }
            };
        }
        return status;
    }
}

public type PoliceEntry record {
    readonly string NIC;
    string criminalstatus;
};

public type InvalidNicError record {|
    *http:NotFound;
    ErrorMsg body;
|};

public type ErrorMsg record {|
    string errmsg;
|};
