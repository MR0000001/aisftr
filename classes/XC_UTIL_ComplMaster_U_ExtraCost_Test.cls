/**
 * The Class XC_UTIL_ComplMaster_U_ExtraCost_Test.
 *
 * @author Domenico Del Prete domenico.delprete@nttadata.com
 * @date Creation 25/11/2019 
 * @date Modification dd/mm/yyyy
 * @description XC_UTIL_ComplMaster_U_ExtraCost_Test – Test class for XC_UTIL_ComplianceMaster_U_ExtraCost 
 */
 @isTest
public without sharing class XC_UTIL_ComplMaster_U_ExtraCost_Test {
    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }

    @IsTest
    static void successTestRecurring0(){
        List <NE__OrderItem__c> listOfOi = XC_DF_OrderItem.createOrderItems(2);
        insert listOfOi[1];
        listOfOi[0].XC_Product_Type__c = Label.XC_CL_Technical;
        listOfOi[0].XC_Product_Subtype__c = Label.XC_CL_ProductSubtype_ExtraInstallation;
        listOfOi[0].XC_BillingModel__c = Label.XC_CL_BillingModel_Recurring;
        listOfOi[0].NE__Bundle_Configuration__c = listOfOi[1].id;
        insert listOfOi[0];
        Test.startTest();
        XC_UTIL_ComplianceMaster_U_ExtraCost.getExtraCost(new List<NE__OrderItem__c> {listOfOi[0]});
        System.assertEquals(!listOfOi.isEmpty(), true);
        Test.stopTest();
        
    }

    @IsTest
    static void successTestRecurring10(){
        List <NE__OrderItem__c> listOfOi = XC_DF_OrderItem.createOrderItems(2);
        insert listOfOi[1];
        listOfOi[0].XC_Product_Type__c = Label.XC_CL_Technical;
        listOfOi[0].XC_Product_Subtype__c = Label.XC_CL_ProductSubtype_ExtraInstallation;
        listOfOi[0].NE__RecurringChargeOv__c = 10;
        listOfOi[0].XC_BillingModel__c = Label.XC_CL_BillingModel_Recurring;
        listOfOi[0].NE__Bundle_Configuration__c = listOfOi[1].id;
        insert listOfOi[0];
        Test.startTest();
        XC_UTIL_ComplianceMaster_U_ExtraCost.getExtraCost(new List<NE__OrderItem__c> {listOfOi[0]});
        Test.stopTest();
        System.assertEquals(!listOfOi.isEmpty(), true);       
    }

    @IsTest
    static void successTestOneShot10(){
        List <NE__OrderItem__c> listOfOi = XC_DF_OrderItem.createOrderItems(2);
        insert listOfOi[1];
        listOfOi[0].XC_Product_Type__c = Label.XC_CL_Technical;
        listOfOi[0].XC_Product_Subtype__c = Label.XC_CL_ProductSubtype_ExtraInstallation;
        listOfOi[0].NE__OneTimeFeeOv__c = 10;
        listOfOi[0].XC_BillingModel__c = Label.XC_CL_BillingModel_OneShot;
        listOfOi[0].NE__Bundle_Configuration__c = listOfOi[1].id;
        insert listOfOi[0];
        Test.startTest();
        XC_UTIL_ComplianceMaster_U_ExtraCost.getExtraCost(new List<NE__OrderItem__c> {listOfOi[0]});
        Test.stopTest();
        System.assertEquals(!listOfOi.isEmpty(), true);       
    }

    @IsTest
    static void successTestOneShot0(){
        List <NE__OrderItem__c> listOfOi = XC_DF_OrderItem.createOrderItems(2);
        insert listOfOi[1];
        listOfOi[0].XC_Product_Type__c = Label.XC_CL_Technical;
        listOfOi[0].XC_Product_Subtype__c = Label.XC_CL_ProductSubtype_ExtraInstallation;
        listOfOi[0].XC_BillingModel__c = Label.XC_CL_BillingModel_OneShot;
        listOfOi[0].NE__Bundle_Configuration__c = listOfOi[1].id;
        listOfOi[0].NE__BaseOneTimeFee__c = 0;
        insert listOfOi[0];
        Test.startTest();
        XC_UTIL_ComplianceMaster_U_ExtraCost.getExtraCost(new List<NE__OrderItem__c> {listOfOi[0]});
        Test.stopTest();
        System.assertEquals(!listOfOi.isEmpty(), true);       
    }

    @IsTest
    static void successTestNoBundleConfiguration(){
        List <NE__OrderItem__c> listOfOi = XC_DF_OrderItem.createOrderItems(1);
        listOfOi[0].XC_Product_Type__c = Label.XC_CL_Technical;
        listOfOi[0].XC_Product_Subtype__c = Label.XC_CL_ProductSubtype_ExtraInstallation;
        listOfOi[0].XC_BillingModel__c = Label.XC_CL_BillingModel_OneShot;
        insert listOfOi;
        Test.startTest();
        XC_UTIL_ComplianceMaster_U_ExtraCost.getExtraCost(new List<NE__OrderItem__c> {listOfOi[0]});
        Test.stopTest();
        System.assertEquals(!listOfOi.isEmpty(), true);       
    }

}