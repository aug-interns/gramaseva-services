import ballerina/http;
import ballerinax/mongodb;

type Citizen record{
    json _id;
    string NIC;
    map<json> address;
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


service /AddressCheck on new http:Listener(9090) {

    //Check for the given Address
    resource function get checkAddress/[string NIC]/[int no]/[string street]/[string village]/[string city]/[int postalcode]() returns boolean|error? {
        boolean valid = false;
        map<json> queryString = {"NIC": NIC, "address": {
            "no": no,
            "street": street,
            "village": village,
            "city": city,
            "postalcode": postalcode
        }};
        stream<Citizen, error?> resultData = check mongoClient->find(collectionName = "Citizen", filter = (queryString));

        check resultData.forEach(function(Citizen datas) {

            valid = true;

        });
        return valid;
    }

}

