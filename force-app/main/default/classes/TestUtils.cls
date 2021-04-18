/*
   Purpose:    Test Data Utility
*/
public with sharing class TestUtils {
   public static User getUserWithoutRole(Profile profileId){
      User user = new User();
      user.LastName = 'Test';
      user.Alias =  getRandomString(8);
      user.Email = 'testuser' + getRandomString(10) + '@testing.com';
      user.Username = 'testuser' + getRandomString(10) + '@testing.com';
      user.CommunityNickname = getRandomString(15);
      user.ProfileId = profileId.Id;
      user.EmailEncodingKey = 'ISO-8859-1';
      user.TimeZoneSidKey = 'GMT';
      user.LocaleSidKey = 'de_DE';
      user.LanguageLocaleKey = 'en_US';
      user.IsActive = true;
      return user;
   }
    
   public static Project__c getProject(String projectName, String projectType, String projectStatus){
      Project__c project = new Project__c();
      project.Name = projectName;
      project.Project_Type__c = projectType;
      project.Project_Status__c = projectStatus;
      return project;
   }

/*
   Global methods used in this TestUtils class
*/
   public static string getRandomString(Integer len){
      string s = '';
      string alphabet = 'abcdefghijklmnopqrstuvwxyz';
      for(Integer i=0; i<len; i++){
         integer randomint = getRandomInteger();
         if(!(randomint + 1 > alphabet.Length())) s = s + alphabet.substring(randomint, randomint + 1);
         else i--;
      }
      return s;
   }
    
   public static integer getRandomInteger(){
      integer multiplier = (Math.round(Math.random()) == 1)?10 : 100;
      return Math.round(Math.random() * multiplier);
   }
}