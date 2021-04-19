/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class Envelope {
    global List<dfsle.CustomField> customFields {
        get;
    }
    global List<dfsle.Document> documents {
        get;
    }
    global dfsle.UUID docuSignId {
        get;
    }
    global String emailMessage {
        get;
    }
    global String emailSubject {
        get;
    }
    global Id envelopeConfigurationId {
        get;
    }
    global dfsle.APIError error {
        get;
    }
    global Id id {
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
    global Datetime sent {
        get;
    }
    global dfsle.Entity source {
        get;
    }
    global static String STATUS_COMPLETED;
    global static String STATUS_CREATED;
    global static String STATUS_DECLINED;
    global static String STATUS_DELIVERED;
    global static String STATUS_SENT;
    global static String STATUS_VOIDED;
    global Envelope(Id id, String name, dfsle.UUID docuSignId, Id envelopeConfigurationId, List<dfsle.Document> documents, List<dfsle.Recipient> recipients, List<dfsle.CustomField> customFields, dfsle.Notifications notifications, String emailSubject, String emailMessage, dfsle.Entity source, Datetime sent) {

    }
    global static dfsle.Envelope newBulkCopy(dfsle.Recipient recipient) {
        return null;
    }
    global dfsle.Envelope withCustomFields(List<dfsle.CustomField> customFields) {
        return null;
    }
    global dfsle.Envelope withDocuments(List<dfsle.Document> documents) {
        return null;
    }
    global dfsle.Envelope withEmail(String emailSubject, String emailMessage) {
        return null;
    }
    global dfsle.Envelope withNotifications(dfsle.Notifications notifications) {
        return null;
    }
    global dfsle.Envelope withRecipients(List<dfsle.Recipient> recipients) {
        return null;
    }
global class Status implements System.Comparable {
    global Datetime completed {
        get;
    }
    global dfsle.UUID docuSignId {
        get;
    }
    global String emailSubject {
        get;
    }
    global Datetime expires {
        get;
    }
    global Id id {
        get;
    }
    global Datetime lastStatusUpdate {
        get;
    }
    global String reason {
        get;
    }
    global List<dfsle.Recipient.Status> recipients {
        get;
    }
    global String senderEmail {
        get;
    }
    global String senderName {
        get;
    }
    global Datetime sent {
        get;
    }
    global dfsle.Entity source {
        get;
    }
    global String status {
        get;
    }
    global Status(Id id, dfsle.Entity source, dfsle.UUID docuSignId, String status, String senderName, String senderEmail, List<dfsle.Recipient.Status> recipients, Datetime sent, Datetime expires, Datetime completed, String emailSubject, String reason, Datetime lastStatusUpdate) {

    }
}
}
