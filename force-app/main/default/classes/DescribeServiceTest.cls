@isTest
public without sharing class DescribeServiceTest {
    @IsTest
    static void test_globalDescribe(){
        Map<String, Schema.SObjectType> t = DescribeService.globalDescribe;
    }

    @IsTest
    static void test_getSObjDescribe(){
        Schema.DescribeSObjectResult t = DescribeService.getSObjDescribe('Account');
    }
}
