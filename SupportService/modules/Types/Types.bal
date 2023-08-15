import ballerina/time;

public type SupportRequest record {|
    string nic;
    time:Utc createdAt = time:utcNow();
    string topic;
    string description;
|};