/**
*@Author: Francesco Imperioli fimperioli@deloitte.it
*@Date creation: 21-10-2019
*@Description: testclass for XC_LCC166_CaseDictamenCardController
**/
@isTest
public  class XC_LCC166_CaseDictamenCardCtrl_TEST {

    @TestSetup
    static void setup(){

       WorkOrder wo = XC_DF_WorkOrder.createWorkOrders(1,'General')[0];
       insert wo;
       XC_DictamenItem__c dictamen = new XC_DictamenItem__c();
       dictamen.XC_WorkOrder__c = wo.Id;
       insert dictamen;

    }

    @isTest
    static void getDictamenRecordIdTest(){
        Test.startTest();
            WorkOrder wo = [SELECT ID FROM WorkOrder LIMIT 1];
            XC_LCC166_CaseDictamenCardController.getDictamenRecordId(wo.Id);
        Test.stopTest();

    }

    @isTest
    static void getFieldsTest(){
        Test.startTest();
            XC_LCC166_CaseDictamenCardController.getFields('XC_ESP_Account_New_PersonalData', 'Account');
        Test.stopTest();
    }

}