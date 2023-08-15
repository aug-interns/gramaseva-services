import MessagingService.Types;
import ballerina/http;
import ballerinax/twilio;
import ballerina/log;

configurable string twilioPhoneNumber = ?;
configurable string accountSID = ?;
configurable string authToken = ?;
twilio:ConnectionConfig twilioConfig = {
    twilioAuth: {
        accountSId: accountSID,
        authToken: authToken
    }
};

twilio:Client twilioClient = check new (twilioConfig);

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    resource function post message(@http:Payload Types:MessageRequest messageRequest) returns string|error {
        twilio:SmsResponse|error smsResponse = twilioClient->sendSms(twilioPhoneNumber, messageRequest.recipient, messageRequest.message);
        if (smsResponse is error) {
            log:printError(smsResponse.toString());
        } else {
            log:printInfo(smsResponse.toJsonString());
        }
        return "success";
    }
}

