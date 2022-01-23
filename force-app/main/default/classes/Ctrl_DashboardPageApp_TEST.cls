@isTest
public with sharing class Ctrl_DashboardPageApp_TEST {
    @IsTest
    public static void test1() {
        Account company = TestObjectCreator.CreateCompany();
        insert company;

        Account mondayAccount = TestObjectCreator.CreateMondayAccount(company);
        insert mondayAccount;

        Target__c t = TestObjectCreator.CreateTarget(company);
        insert t;

        Ctrl_DashboardPageApp.init(null);
        Ctrl_DashboardPageApp.getCertifications(null);
        Ctrl_DashboardPageApp.initPortfolioManagment(null);
        Ctrl_DashboardPageApp.initARRGSIPortfolioManagment(null);
        Ctrl_DashboardPageApp.initProfileUpdate(null);
        Ctrl_DashboardPageApp.getTargets(null, null);
        Ctrl_DashboardPageApp.getMapp(null);
    }
}