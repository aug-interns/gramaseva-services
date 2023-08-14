import ballerina/time;

public type SupportRequest record {|
    string nic;
    string supportType;
    time:Utc createdAt = time:utcNow();
    string topic;
    string description;
|};