/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class MassActionListWOShare implements System.Schedulable {
    global MassActionListWOShare(List<SObject> ll, zaapit.MassActionInterface action1, Integer batchSize1, String MassActJobName1) {

    }
    global void execute(System.SchedulableContext SC) {

    }
    global static zaapit.MassActionListWOShare.DeleteAction getDeleteAction(Boolean sendEmail) {
        return null;
    }
    global static zaapit.MassActionListWOShare.InsertAction getInsertAction(Boolean sendEmail) {
        return null;
    }
    global static zaapit.MassActionListWOShare.UpdateAction getUpdateAction(Boolean sendEmail) {
        return null;
    }
    global static List<String> whoIsRunning(String str) {
        return null;
    }
global class DeleteAction implements zaapit.MassActionInterface {
    global Boolean sendEmail;
    global DeleteAction() {

    }
    global DeleteAction(Boolean sendEmail1) {

    }
}
global class InsertAction implements zaapit.MassActionInterface {
    global Boolean sendEmail;
    global InsertAction() {

    }
    global InsertAction(Boolean sendEmail1) {

    }
}
global class UpdateAction implements zaapit.MassActionInterface {
    global Boolean sendEmail;
    global UpdateAction() {

    }
    global UpdateAction(Boolean sendEmail1) {

    }
}
}
