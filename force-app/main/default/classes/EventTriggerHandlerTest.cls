/*************************************************************************
    * Created by: anastasiyakovalchuk
    * Created date: 11 March 2020
    * Description: 
    * History:
************************************************************************/

@IsTest
private with sharing class EventTriggerHandlerTest {

    @IsTest
    static void test() {
        Event testEvent = new Event(
                Subject = 'Test',
                DurationInMinutes = 10,
                ActivityDateTime = Datetime.now()
        );
        insert testEvent;
    }
}