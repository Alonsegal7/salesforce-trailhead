/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global virtual class Recipient implements System.Comparable {
    global dfsle.Recipient.Authentication authentication {
        get;
    }
    global String email {
        get;
    }
    global dfsle.Recipient.EmailSettings emailSettings {
        get;
    }
    global String hostEmail {
        get;
    }
    global String hostName {
        get;
    }
    global Id id {
        get;
    }
    global Boolean isSigningGroup {
        get;
    }
    global String name {
        get;
    }
    global String note {
        get;
    }
    global String phone {
        get;
    }
    global Boolean readOnly {
        get;
    }
    global Boolean required {
        get;
    }
    global dfsle.Recipient.Role role {
        get;
    }
    global Integer routingOrder {
        get;
    }
    global Integer sequence {
        get;
    }
    global dfsle.SigningGroup signingGroup {
        get;
    }
    global Boolean signNow {
        get;
    }
    global dfsle.Entity source {
        get;
    }
    global static String STATUS_CANCELED;
    global static String STATUS_COMPLETED;
    global static String STATUS_CREATED;
    global static String STATUS_DECLINED;
    global static String STATUS_DELIVERED;
    global static String STATUS_SENT;
    global static String STATUS_SIGNED;
    global String type {
        get;
    }
    global static String TYPE_AGENT;
    global static String TYPE_CARBON_COPY;
    global static String TYPE_CERTIFIED_DELIVERY;
    global static String TYPE_EDITOR;
    global static String TYPE_EMBEDDED_SIGNER;
    global static String TYPE_IN_PERSON_SIGNER;
    global static String TYPE_INTERMEDIARY;
    global static String TYPE_SIGNER;
    global Recipient(Id id, String type, Integer sequence, Integer routingOrder, dfsle.Recipient.Role role, String name, String email, dfsle.SigningGroup signingGroup, String phone, dfsle.Recipient.Authentication authentication, String note, dfsle.Recipient.EmailSettings emailSettings, String hostName, String hostEmail, Boolean signNow, dfsle.Entity source, Boolean readOnly, Boolean required) {

    }
    global static dfsle.Recipient fromSource(String name, String email, String phone, String role, dfsle.Entity source) {
        return null;
    }
    global static dfsle.Recipient newBulkRecipient(String name, String email, dfsle.Entity source) {
        return null;
    }
    global static dfsle.Recipient newEmbeddedSigner() {
        return null;
    }
    global static dfsle.Recipient newEmbeddedSigner(String name, String email, Id sourceId) {
        return null;
    }
    global dfsle.Recipient withAuthentication(dfsle.Recipient.Authentication authentication) {
        return null;
    }
    global dfsle.Recipient withEmailSettings(dfsle.Recipient.EmailSettings emailSettings) {
        return null;
    }
    global dfsle.Recipient withNote(String note) {
        return null;
    }
    global dfsle.Recipient withRole(dfsle.Recipient.Role role) {
        return null;
    }
    global dfsle.Recipient withRoutingOrder(Integer routingOrder) {
        return null;
    }
global class Authentication {
    global String accessCode {
        get;
    }
    global Boolean idCheckRequired {
        get;
    }
    global List<String> smsPhoneNumbers {
        get;
    }
    global Authentication(String accessCode, Boolean idCheckRequired, List<String> smsPhoneNumbers) {

    }
}
global class EmailSettings {
    global String language {
        get;
    }
    global String languageLabel {
        get;
    }
    global String message {
        get;
    }
    global String subject {
        get;
    }
    global EmailSettings(String language, String languageLabel, String subject, String message) {

    }
}
global class ResendResult {
    global String email {
        get;
    }
    global dfsle.APIError error {
        get;
    }
    global Integer routingOrder {
        get;
    }
    global Integer sequence {
        get;
    }
}
global class Role implements System.Comparable {
    global String name {
        get;
    }
    global Integer value {
        get;
    }
    global Role(String name, Integer value) {

    }
}
global class Status implements System.Comparable {
    global Datetime completed {
        get;
    }
    global String email {
        get;
    }
    global Id id {
        get;
    }
    global Datetime lastStatusUpdate {
        get;
    }
    global String name {
        get;
    }
    global String reason {
        get;
    }
    global Integer routingOrder {
        get;
    }
    global Datetime sent {
        get;
    }
    global Integer sequence {
        get;
    }
    global dfsle.Entity source {
        get;
    }
    global String status {
        get;
    }
    global String type {
        get;
    }
    global Status(Id id, dfsle.Entity source, String type, Integer sequence, String status, String name, String email, Integer routingOrder, Datetime sent, Datetime completed, String reason, Datetime lastStatusUpdate) {

    }
}
}
