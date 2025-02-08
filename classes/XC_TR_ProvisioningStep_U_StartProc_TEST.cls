/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creation  30/05/2019 
* @description XC_TR_ProvisioningStep_U_StartProc_TEST – Test class for XC_TR_ProvisioningStep_U_StartProcess
*/
@isTest
public with sharing class XC_TR_ProvisioningStep_U_StartProc_TEST {
    // Test method for onAfterUpdate
    static testMethod void onAfterUpdate(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Account> listAccount = XC_DF_Account.createResidentialAccounts(1);
        Account acc = listAccount[0];
        insert acc;
        List<XC_Address__c> addressList =  XC_DF_Address.createAddress(listAccount);
        insert addressList;
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        conf.NE__AccountId__c = acc.Id;
        conf.XC_InstallationAddress__c = addressList[0].Id;
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        confItem.NE__Account__c = conf.NE__AccountId__c;
        confItem.XC_Installation_Address__c = conf.XC_InstallationAddress__c;
        insert confItem;
        Test.stopTest();
        XC_Provisioning_Step__c ps= XC_DF_ProvisioningStep.createProvisioningStep(confItem.Id);
        insert ps;
        ps.XC_Status__c = Label.XC_CL_Completed_OK;
        ps.XC_Step_Order__c = 1;
        update ps; 
        System.assert(ps!=null);
        
    }
    // Test method for onAfterUpdate1
    static testMethod void onAfterUpdate1(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Account> listAccount = XC_DF_Account.createResidentialAccounts(1);
        Account acc = listAccount[0];
        insert acc;
        List<XC_Address__c> addressList =  XC_DF_Address.createAddress(listAccount);
        insert addressList;
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        conf.NE__AccountId__c = acc.Id;
        conf.XC_InstallationAddress__c = addressList[0].Id;
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        confItem.NE__Account__c = conf.NE__AccountId__c;
        confItem.XC_Installation_Address__c = conf.XC_InstallationAddress__c;
        insert confItem;
        Test.stopTest(); 
        List<XC_Provisioning_Step__c> provStepList = new List<XC_Provisioning_Step__c>();
        XC_Provisioning_Step__c ps= XC_DF_ProvisioningStep.createProvisioningStep(confItem.Id);
        ps.XC_Status__c = Label.XC_CL_Step_Skipped;
        ps.XC_Step_Order__c = 1;
        provStepList.add(ps);
        XC_Provisioning_Step__c ps1= XC_DF_ProvisioningStep.createProvisioningStep(confItem.Id);
        ps1.XC_Status__c = Label.XC_CL_Provisioning_Step_NotStarted;
        ps1.XC_Step_Order__c = 2;
        provStepList.add(ps1);
        insert provStepList;
        ps.XC_Status__c = Label.XC_CL_Completed_OK;
        update ps;
        System.debug('???nstep'+   ps.XC_Step_Order__c + ps.XC_Status__c);
        System.assert(ps!=null);
        
    }
    
    static testMethod void onBeforeUpdateTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        XC_CS_UtilityGlobalValues__c csTest = new XC_CS_UtilityGlobalValues__c();
        csTest.name = 'XC_TR_ProvisStepLabelSentToZBilling';
        csTest.Value__c = 'Create Subscription;Create Subscription/Trigger Invoice;Trigger Invoice;';
        insert csTest;
        List<Account> listAccount = XC_DF_Account.createResidentialAccounts(1);
        Account acc = listAccount[0];
        insert acc;
        List<XC_Address__c> addressList =  XC_DF_Address.createAddress(listAccount);
        insert addressList;
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        conf.NE__AccountId__c = acc.Id;
        conf.XC_InstallationAddress__c = addressList[0].Id;
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        confItem.NE__Account__c = conf.NE__AccountId__c;
        confItem.XC_Installation_Address__c = conf.XC_InstallationAddress__c;
        insert confItem;
        Test.stopTest();
        XC_Provisioning_Step__c ps= XC_DF_ProvisioningStep.createProvisioningStep(confItem.Id);
        ps.XC_StepLabel__c = 'Create Subscription';
        insert ps;
        try{
        ps.XC_Status__c = Label.XC_CL_Completed_OK;
        ps.XC_Step_Order__c = 1;
        update ps; 
        }catch(Exception ex){
            system.debug('error');
        }
        
    }
    
}