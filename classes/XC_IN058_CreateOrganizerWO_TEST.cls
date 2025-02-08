/**
* @author dpalamides
* @date 07/08/2020
* @description: classes.XC_IN058_CreateOrganizerWO_TEST
*/

@isTest
public without sharing class XC_IN058_CreateOrganizerWO_TEST {
    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;

        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(1);
        NE__OrderItem__c ordIt = orderItemList[0];
        insert ordIt;
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        Asset ast = assetList[0];
        ast.XC_Configuration_Item__c = ordIt.Id;
        insert ast;
        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = ordIt.id;
        provisioningStep.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep.XC_Step_Order__c = 1;
        insert provisioningStep;

        List<WorkOrder> listWo = XC_DF_WorkOrder.createWorkOrders(1, 'Installation');
        listWo[0].XC_Configuration_Item__c = ordIt.Id;
        //listWo[0].XC_WorkTypeLabel__c = 'Installation - Photovoltaic';
        listWo[0].XC_WorkTypeCategory__c = 'Installation';
        listWo[0].XC_LegalEntity__c = 'EnelXItalia';
        listWo[0].XC_Segment__c = 'B2B';
        listWo[0].RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId();
        insert listWo[0];
        listWo[0].XC_WorkTypeLabel__c = 'Installation - Photovoltaic';
        update listWo[0];
    }

    static testMethod void callTEST1(){
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];

        XC_IN058_CreateOrganizerWO.InputWrapper inw = new XC_IN058_CreateOrganizerWO.InputWrapper();
        List<XC_IN058_CreateOrganizerWO.InputWrapper> inputWrapperList = new List<XC_IN058_CreateOrganizerWO.InputWrapper>();
        inw.stepId = step.Id;
        inw.stepType = 'Partner Engagement';
        inputWrapperList.add(inw);

        test.startTest();
        XC_IN058_CreateOrganizerWO.createOrganizerWO(inputWrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    }

    static testMethod void callTEST2(){
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];

        XC_IN058_CreateOrganizerWO.InputWrapper inw = new XC_IN058_CreateOrganizerWO.InputWrapper();
        List<XC_IN058_CreateOrganizerWO.InputWrapper> inputWrapperList = new List<XC_IN058_CreateOrganizerWO.InputWrapper>();
        inw.stepId = step.Id;
        inw.stepType = 'Technical Asset';
        inputWrapperList.add(inw);

        test.startTest();
        XC_IN058_CreateOrganizerWO.createOrganizerWO(inputWrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    }


}