import ballerina/http;

# A service representing a network-accessible API
# bound to port `7070`.

service /police\-check/api on new http:Listener(7070) {

    resource function get testpolice() returns string {
        return "Police Service Api Works";
    }

    resource function get status/[string ID]() returns CitizenEntry |InvalidIsoCodeError {
        CitizenEntry? citizenEntry = citizenTable[ID];
        if citizenEntry is () {
            return {
                body: {
                    errmsg: string `Invalid ID: ${ID}`
                }
            };
        }
        return citizenEntry;
    }
}

public type CitizenEntry record {|
    readonly string ID;
    string regin;
    decimal cases;
|};

public final table<CitizenEntry> key(ID) citizenTable = table [
    {ID: "1", regin: "Kodikamam", cases: 2},
    {ID: "2", regin: "Chavakachcheri", cases: 1},
    {ID: "3", regin: "Jaffna", cases: 2}
];

public type ConflictingIsoCodesError record {|
    *http:Conflict;
    ErrorMsg body;
|};

public type InvalidIsoCodeError record {|
    *http:NotFound;
    ErrorMsg body;
|};

public type ErrorMsg record {|
    string errmsg;
|};