public without sharing class CoSellRequest_SurveyReminderSch implements Schedulable{
    public void execute(SchedulableContext SC) {
        try{
            CoSellRequestService.dailyFillSurveyReminder();
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Co-Sell Daily Survey Reminders Scheduled Job', e, e.getMessage());   
        }
    }
}