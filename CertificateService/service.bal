import ballerina/io;
import ballerina/http;
import ballerina/log;
import ballerinax/mongodb;
import CertificateService.Types;
import ballerinax/twilio;

configurable mongodb:ConnectionConfig mongoConfig = ?;

configurable string twilioPhoneNumber = ?;
configurable string accountSID = ?;
configurable string authToken = ?;
twilio:ConnectionConfig twilioConfig = {
    twilioAuth: {
        accountSId: accountSID,
        authToken: authToken
    }
};

//Create a new client
mongodb:Client mongoClient = checkpanic new (mongoConfig);
twilio:Client twilioClient = check new (twilioConfig);

type requestData record {
    json _id;
    string NIC;
    map<json> address;
    string status;
    string phone;
};

service / on new http:Listener(8080) {
    //creating an entry for user requests
    resource function post newRequestRecord(@http:Payload Types:CertificateRequest request) returns boolean|error {
        log:printInfo(request.toJsonString());

        map<json> doc = {
            "NIC": request.NIC,
            "address": {
                "no": request.no,
                "street": request.street,
                "village": request.village,
                "city": request.city,
                "postalcode": request.postalcode
            },
            "status": "pending",
            "phone": request.phone
        };

        error? insertResult = check mongoClient->insert(doc, collectionName = "Requests");
        if (insertResult !is error) {
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

    //Get a specific record
    resource function get getReqRecord/[string NIC]() returns requestData[]|error? {

        map<json> queryString = {"NIC": NIC};
        stream<requestData, error?> resultData = check mongoClient->find(collectionName = "Requests", filter = (queryString));
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

        if (status == "completed") {
            map<json> filter_query = {"NIC": NIC};
            stream<requestData, error?> entry_details = checkpanic mongoClient->find(collectionName = "Requests", filter = filter_query, 'limit = 1);

            string phone_number = "";
            check entry_details.forEach(function(requestData entry) {
                phone_number = entry.phone;
            });

            log:printInfo(phone_number.toJsonString());

            twilio:SmsResponse|error smsResponse = twilioClient->sendSms(twilioPhoneNumber, phone_number, "your CertificateService request is completed");
            if (smsResponse is error) {
                log:printError(smsResponse.toString());
            } else {
                log:printInfo(smsResponse.toJsonString());
            }
        }

        return resultData;
    }
}
