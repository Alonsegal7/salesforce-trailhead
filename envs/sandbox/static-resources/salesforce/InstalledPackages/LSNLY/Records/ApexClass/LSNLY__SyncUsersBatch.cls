/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class SyncUsersBatch implements Database.AllowsCallouts, Database.Batchable<SObject>, Database.Stateful {
    global Integer iBatchSize {
        get;
        set;
    }
    global Integer iProcessedUsers {
        get;
        set;
    }
    global Integer iUsersToProcess {
        get;
        set;
    }
    global List<User> lBatch {
        get;
        set;
    }
    global SyncUsersBatch() {

    }
    global void execute(Database.BatchableContext oBatchableContext, List<User> lUsers) {

    }
    global void finish(Database.BatchableContext oBatchableContext) {

    }
    global Database.QueryLocator start(Database.BatchableContext oBatchableContext) {
        return null;
    }
}
