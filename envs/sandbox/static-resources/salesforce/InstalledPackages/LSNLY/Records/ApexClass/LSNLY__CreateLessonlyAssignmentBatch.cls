/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class CreateLessonlyAssignmentBatch implements Database.AllowsCallouts, Database.Batchable<Integer>, Database.Stateful {
    global Integer iAssignmentsToProcess {
        get;
        set;
    }
    global Integer iPages {
        get;
        set;
    }
    global Integer iPerPageSize {
        get;
        set;
    }
    global CreateLessonlyAssignmentBatch() {

    }
    global void execute(Database.BatchableContext oBatchableContext, List<Integer> lPages) {

    }
    global void finish(Database.BatchableContext oBatchableContext) {

    }
    global System.Iterable start(Database.BatchableContext BC) {
        return null;
    }
}
