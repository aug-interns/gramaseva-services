import ballerina/http;
import ballerina/log;
import SupportService.Types;
import ballerinax/slack;
import ballerina/time;
import ballerina/regex;

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
            text: "",
            blocks: [
                {
                    "type": "section",
                    "text": {
                        "type": "mrkdwn",
                        "text": "Support Ticket:\n*" + request.topic + "*"
                    }
                },
                {
                    "type": "section",
                    "fields": [
                        {
                            "type": "mrkdwn",
                            "text": "*Created:*\n " + time:utcToEmailString(request.createdAt)
                        },
                        {
                            "type": "mrkdwn",
                            "text": "*NIC:*\n " + request.nic
                        }
                    ]
                },
                {
                    "type": "section",
                    "text": {
                        "type": "mrkdwn",
                        "text": "*Description*:\n" + request.description
                    }
                },
                {
                    "type": "actions",
                    "elements": [
                        {
                            "type": "button",
                            "text": {
                                "type": "plain_text",
                                "emoji": true,
                                "text": "Message"
                            },
                            "style": "primary",
                            "value": "click_me_123"
                        },
                        {
                            "type": "button",
                            "text": {
                                "type": "plain_text",
                                "emoji": true,
                                "text": "Discard"
                            },
                            "style": "danger",
                            "value": "click_me_123"
                        }
                    ]
                }
            ]
        };

        string|error messageResponse = slackClient->postMessage(message);
        if (messageResponse is error) {
            log:printError(string `Slack Message Failed: ${messageResponse.toString()}`);
            return messageResponse;
        } else {
            log:printInfo(string `Slack Message Success: ${messageResponse}`);
            string msgUrl = regex:replaceAll(messageResponse, "\\.", "");
            msgUrl = string `https://zetcco.slack.com/messages/C05NBLBQGHW/p${msgUrl}`;
            return msgUrl;
        }
    }
}
