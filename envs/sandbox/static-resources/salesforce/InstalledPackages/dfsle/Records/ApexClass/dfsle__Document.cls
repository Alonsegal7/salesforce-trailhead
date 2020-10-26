/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global virtual class Document implements System.Comparable {
    global String extension {
        get;
    }
    global Id id {
        get;
    }
    global Datetime lastModified {
        get;
    }
    global String name {
        get;
    }
    global Integer sequence {
        get;
    }
    global Integer size {
        get;
    }
    global String sourceId {
        get;
    }
    global String type {
        get;
    }
    global static String TYPE_DOCUMENT;
    global static String TYPE_FILE;
    global static String TYPE_TEMPLATE;
    global Document(Id id, String type, Integer sequence, String name, String extension, Integer size, Datetime lastModified, String sourceId) {

    }
    global static dfsle.Document fromTemplate(dfsle.UUID docuSignId, String name) {
        return null;
    }
global class Folder {
    global Id id {
        get;
    }
    global String name {
        get;
    }
    global Folder(Id id, String name) {

    }
}
global class Folders {
    global List<dfsle.Document> documents {
        get;
    }
    global List<dfsle.Document.Folder> folders {
        get;
    }
    global Folders(List<dfsle.Document.Folder> folders, List<dfsle.Document> documents) {

    }
}
}
