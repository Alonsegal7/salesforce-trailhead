/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class Template {
    global List<dfsle.CustomField> customFields {
        get;
    }
    global String emailMessage {
        get;
    }
    global String emailSubject {
        get;
    }
    global dfsle.UUID id {
        get;
    }
    global Datetime lastModified {
        get;
    }
    global String name {
        get;
    }
    global dfsle.Notifications notifications {
        get;
    }
    global List<dfsle.Recipient> recipients {
        get;
    }
    global Template(dfsle.UUID id, String name, List<dfsle.CustomField> customFields, dfsle.Notifications notifications, String emailSubject, String emailMessage, List<dfsle.Recipient> recipients, Datetime lastModified) {

    }
}
