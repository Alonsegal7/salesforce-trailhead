public without sharing class Utilities {
    static map<string,Country_Region_Mapping__c> regionsMapping= null;

    //Sends an email to the Salesforcea admins
    public static void sendDebugEmail(String subject, Exception e, String additionalData){
        list<String> toAddresses=new list<String>{label.SystemNotificationsDL};
        String emailBody=e.getMessage()+'<br/>Line: '+e.getLineNumber()+'<br/>Stack: '+e.getStackTraceString();
        emailBody+='<br/><br/>Timestamp: '+Datetime.now()+'<br/><br/>'+additionalData;
        sendEmail(subject,emailBody,toAddresses);
    }
     
    public static void sendEmail(String subject, String body, list<String> toAddresses){
        Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setHtmlBody(body+'<br/><br/>Timestamp: '+Datetime.now());
        
        try{
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        }catch(Exception e){}
    }
    
    public static void sendEmail(String subject, String body, list<String> toAddresses, list<String> bccAddresses){
        Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(toAddresses);
        mail.setBccAddresses(bccAddresses);
        mail.setSubject(subject);
        mail.setHtmlBody(body+'<br/><br/>Timestamp: '+Datetime.now());
        
        try{
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        }catch(Exception e){}
    }
    
    public static map<Id,list<User>> getDirectSubordinatesByRole(){
        map<Id,list<User>> directSubordinatesByRole=new map<Id,list<User>>();
        
        for (User user :[select Id, IsActive, Name, UserRoleId, UserRole.ParentRoleId, UserRole.Name,
                                ProfileId, Profile.Name
                         from User]){
            if (directSubordinatesByRole.get(user.UserRoleId)==null)
                directSubordinatesByRole.put(user.UserRoleId, new list<User>());
            if (directSubordinatesByRole.get(user.UserRole.ParentRoleId)==null)
                directSubordinatesByRole.put(user.UserRole.ParentRoleId, new list<User>());
            directSubordinatesByRole.get(user.UserRole.ParentRoleId).add(user);
        }
        return directSubordinatesByRole;
    }
    public static String capitalizeString(String str){
        return str.subString(0,1).toUpperCase()+str.subString(1,str.length());
    }
    public static map<string,Country_Region_Mapping__c> getRegionMapping(){
        if(regionsMapping==null){
            regionsMapping= new map<string,Country_Region_Mapping__c>();
            for(Country_Region_Mapping__c rm: [select id,Name,Region__c,Sub_Region__c from Country_Region_Mapping__c])
                regionsMapping.put(rm.Name,rm);
        }
        return regionsMapping;
    }
}