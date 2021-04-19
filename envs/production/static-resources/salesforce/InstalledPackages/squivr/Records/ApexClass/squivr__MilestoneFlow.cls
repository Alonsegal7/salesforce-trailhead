/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class MilestoneFlow {
    global MilestoneFlow() {

    }
    @InvocableMethod(label='Create Milestones' description='Automatically adds milestones to a record')
    global static List<squivr.MilestoneFlow.CreateMilestoneActionResult> createMilestones(List<squivr.MilestoneFlow.CreateMilestoneActionRequests> requests) {
        return null;
    }
global class CreateMilestoneActionRequests {
    @InvocableVariable(label='End Date Field' description='The API name of the end date field to reference for milestones' required=true)
    global String endDateField;
    @InvocableVariable(label='Records to add Milestones' description='A list of SObjects to create milestones for' required=true)
    global List<SObject> records;
    @InvocableVariable(label='Start Date Field' description='The API name of the start date field to reference for milestones' required=true)
    global String startDateField;
    global CreateMilestoneActionRequests() {

    }
}
global class CreateMilestoneActionResult {
    @InvocableVariable(label='Created Milestones' description='The list of newly created milestones (Tasks)' required=false)
    global List<SObject> insertedMilestones;
    global CreateMilestoneActionResult() {

    }
}
}
