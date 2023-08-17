import ballerina/http;
import ballerinax/mongodb;
import ballerina/regex;

type Citizen record {
    json _id;
    string NIC;
};

configurable mongodb:ConnectionConfig mongoConfig = ?;
//creating a new client
mongodb:Client mongoClient = checkpanic new (mongoConfig);

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowCredentials: true,
        allowMethods: ["*"]
    }
}

service / on new http:Listener(9090) {

    //Check for the given NIC
    resource function get checkNIC/[string NIC]() returns boolean|InvalidNicError?|error? {

        // Validate the NIC format using a regular expression
        string nicPattern = "^(\\d{9}[vVxX]|\\d{12})$"; // NIC pattern with or without 'v' or 'x'
        // Check if the NIC matches the pattern
        boolean isValidNIC = regex:matches(NIC, nicPattern);

        if isValidNIC {

            boolean valid = false;
            map<json> queryString = {"NIC": NIC};
            stream<Citizen, error?> resultData = check mongoClient->find(collectionName = "Citizen", filter = (queryString));

            check resultData.forEach(function(Citizen datas) {

                valid = true;

            });

            return valid;

        } else {
            return {
                body: {
                    errmsg: string `Invalid NIC: ${NIC}`
                }
            };
        }

    }

}

public type InvalidNicError record {|
    *http:BadRequest;
    ErrorMsg body;
|};

public type ErrorMsg record {|
    string errmsg;
|};
