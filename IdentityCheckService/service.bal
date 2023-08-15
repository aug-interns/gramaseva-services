import ballerina/http;
import ballerinax/mongodb;

type Citizen record{
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


service /IdentityCheck on new http:Listener(9090) {

    //Check for the given NIC
    resource function get checkNIC/[string NIC]() returns boolean|error? {

        boolean valid = false;
        map<json> queryString = {"NIC": NIC};
        stream<Citizen, error?> resultData = check mongoClient->find(collectionName = "Citizen", filter = (queryString));

        check resultData.forEach(function(Citizen datas) {

            valid = true;

        });
        return valid;
    }

}
