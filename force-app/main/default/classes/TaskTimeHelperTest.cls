@isTest
public class TaskTimeHelperTest {
	static testMethod void shouldDoNothing() {
        Test.startTest();
        Task t1 = new Task(Status='Open', Subject='kuku', Task_Time_Zone__c=null, time_zone_offset__c=null);
		TaskTimeHelper.run(t1);
        System.assertEquals(null, t1.Task_Time_Zone__c);
        System.assertEquals(null, t1.time_zone_offset__c);
		Test.stopTest();        
    }
    
    static testMethod void updateTimeZoneOffsetFromTimeZone() {
        Test.startTest();
		Integer [] offsets = new Integer[]{-8 ,-7, -6, -5, 0, 1, 2, 3, 5, 8, 9};
        String [] zones = new String[]{'PST', 'MST', 'CST', 'EST', 'Western Europe', 'Central Europe', 'Eastern Europe', 'Middle East', 'Central Asia', 'China', 'Eastern Asia'};
        for(Integer i=0 ; i<zones.size() ; i++){
        	Task t1 = new Task(Status='Open', Subject='kuku', Task_Time_Zone__c=zones[i], time_zone_offset__c=null);
			TaskTimeHelper.run(t1);
        	System.assertEquals(zones[i], t1.Task_Time_Zone__c);
        	System.assertEquals(offsets[i], t1.time_zone_offset__c);    
        }
        Test.stopTest();        
    }
    
    static testMethod void updateTimeZoneFromOffset() {
        Test.startTest();
		Integer [] offsets = new Integer[]{-8 ,-7, -6, -5, 0, 1, 2, 3, 5, 8, 9};
        String [] zones = new String[]{'PST', 'MST', 'CST', 'EST', 'Western Europe', 'Central Europe', 'Eastern Europe', 'Middle East', 'Central Asia', 'China', 'Eastern Asia'};
        for(Integer i=0 ; i<zones.size() ; i++){
        	Task t1 = new Task(Status='Open', Subject='kuku', Task_Time_Zone__c=null, time_zone_offset__c=offsets[i]);
			TaskTimeHelper.run(t1);
        	System.assertEquals(zones[i], t1.Task_Time_Zone__c);
        	System.assertEquals(offsets[i], t1.time_zone_offset__c);    
        }
        Test.stopTest();        
    }
}