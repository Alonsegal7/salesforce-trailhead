/*************************************************************************
    * Created by: anastasiyakovalchuk
    * Created date: 11 March 2020
    * Description: 
    * History:
************************************************************************/

@IsTest
private with sharing class TaskTriggerHandlerTest {

    @IsTest
    static void test() {
        Task testTask = new Task(
                Subject = 'Test'
        );
        insert testTask;
    }
}