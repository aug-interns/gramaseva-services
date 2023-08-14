import ballerina/http;
import ballerina/log;
import SupportService.Types;
import ballerinax/slack;

configurable string slackAuthToken = ?;
slack:ConnectionConfig slackConfig = {
    auth : {
        token : slackAuthToken
    }
};

slack:Client slackClient = check new(slackConfig);

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    resource function post request(@http:Payload Types:SupportRequest request) returns string|error {
        log:printInfo(request.toJsonString());

        slack:Message message = {
            channelName: "gramasevaka-supoort",
            text: request.description
        };

        string|error messageResponse = slackClient->postMessage(message);
        if (messageResponse is error) {
            log:printError(string `Slack Message Failed: ${messageResponse.toString()}`);
        } else {
            log:printInfo(string `Slack Message Success: ${messageResponse}`);
        }

        return "Success";
    }
}
