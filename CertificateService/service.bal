import ballerina/io;
import ballerina/http;
import ballerinax/mongodb;


configurable mongodb:ConnectionConfig mongoConfig = ?;
//Create a new client
mongodb:Client mongoClient = checkpanic new (mongoConfig);


type requestData record{
    json _id;
    string NIC;
    map<json> address;
    string status;
    string phone;
};


service /request on new http:Listener(8080){
    //creating an entry for user requests
    resource function post newRequestRecord/[string NIC]/[string no]/[string street]/[string village]/[string city]/[int postalcode]/[string phone]() returns boolean|error {

        json address = {
            "no": no,
            "street": street,
            "village": village,
            "city": city,
            "postalcode": postalcode
        };

        map<json> doc = {"NIC": NIC, "address": address, "status": "Pending", "phone": phone};

        error? resultData = check mongoClient->insert(doc, collectionName = "Requests");

        if (resultData !is error) {
            return true;
        }
        return false;

    }


    //Get user requests from the database
    resource function get getRequests() returns requestData[]|error {

        stream<requestData, error?> resultData = check mongoClient->find(collectionName = "Requests");

        requestData[] allData = [];
        int index = 0;
        check resultData.forEach(function(requestData data) {
            allData[index] = data;
            index += 1;

            io:println(data.NIC);
            io:println(data.address);
            io:println(data.status);
            io:println(data.phone);

        });

        return allData;
    }


    //Updating user request status
    resource function put updateRequest/[string NIC]/[string status]() returns int|error {

        map<json> queryString = {"$set": {"status": status}};
        map<json> filter = {"NIC": NIC};

        int|error resultData = check mongoClient->update(queryString, "Requests", filter = filter);

        return resultData;
    }
}
