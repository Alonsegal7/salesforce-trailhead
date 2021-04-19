/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class BulkList {
    global List<dfsle.Envelope> copies {
        get;
    }
    global dfsle.UUID docuSignId {
        get;
    }
    global Id id {
        get;
    }
    global String name {
        get;
    }
    global dfsle.Entity source {
        get;
    }
    global static String STATUS_FAILED;
    global static String STATUS_PROCESSING;
    global static String STATUS_QUEUED;
    global static String STATUS_SENT;
    global static dfsle.BulkList newList(String name, List<dfsle.Envelope> copies, dfsle.Entity source) {
        return null;
    }
global class Result {
    global Id bulkStatusId {
        get;
    }
    global List<dfsle.APIError> errors {
        get;
    }
    global Boolean success {
        get;
    }
}
global class Status {
    global Integer batchSize {
        get;
    }
    global dfsle.UUID docuSignId {
        get;
    }
    global Integer failedEnvelopes {
        get;
    }
    global Id id {
        get;
    }
    global Boolean isFinal {
        get;
    }
    global Datetime lastStatusUpdate {
        get;
    }
    global Integer queuedEnvelopes {
        get;
    }
    global Integer sentEnvelopes {
        get;
    }
    global dfsle.Entity source {
        get;
    }
    global Datetime submitted {
        get;
    }
}
}
