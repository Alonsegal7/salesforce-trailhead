public class TaskTimeHelper {
    public static void run(Task t){
        if(t.Task_Time_Zone__c != null && t.time_zone_offset__c == null){
            t.time_zone_offset__c = getTimeZoneOffsetFromZone(t.Task_Time_Zone__c);
        }else if(t.Task_Time_Zone__c == null && t.time_zone_offset__c != null){
            t.Task_Time_Zone__c = getTimeZoneFromOffset(t.time_zone_offset__c.intValue());
        }
    }
    
    private static Integer getTimeZoneOffsetFromZone(String timeZone){
        switch on timeZone{
            when 'PST'{
                return -8;
            }
            when 'MST'{
                return -7;
            }
            when 'CST'{
                return -6;
            }
            when 'EST'{
                return -5;
            }
            when 'Western Europe'{
                return 0;
            }
            when 'Central Europe'{
                return 1;
            }
            when 'Eastern Europe'{
                return 2;
            }
            when 'Middle East'{
                return 3;
            }
            when 'Central Asia'{
                return 5;
            }
            when 'China'{
                return 8;
            }
            when 'Eastern Asia'{
                return 9;
            }
            when else{
                return null;
            }
            
        }
    }
    
    private static String getTimeZoneFromOffset(Integer offset){
        switch on offset{
            when -8{
                return 'PST';
            }
            when -7{
                return 'MST';
            }
            when -6{
                return 'CST';
            }
            when -5, -4{
                return 'EST';
            }
            when 0{
                return 'Western Europe';
            }
            when 1{
                return 'Central Europe';
            }
            when 2{
                return 'Eastern Europe';
            }
            when 3,4{
                return 'Middle East';
            }
            when 5,6,7{
                return 'Central Asia';
            }
            when 8{
                return 'China';
            }
            when 9{
                return 'Eastern Asia';
            }
            when else{
                return null;
            }
            
        }
    }
}