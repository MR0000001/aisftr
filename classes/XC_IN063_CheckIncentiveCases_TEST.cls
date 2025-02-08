/**
 * @description       : 
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 10-08-2020
 * @last modified by  : Francesco Imperioli - fimperioli@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   10-08-2020   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
**/
@isTest
public without sharing class XC_IN063_CheckIncentiveCases_TEST {

    @TestSetup
    static void setup(){
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(acc);
        insert cont;
        List<XC_Address__c> addr = XC_DF_Address.createAddress(acc);
        insert addr;
       	// List<Opportunity> opp = XC_DF_Opportunity.createOpportunity(1, false);
        // opp[0].AccountId = acc[0].Id;
        // opp[0].XC_Contact__c = cont[0].Id;
        // opp[0].XC_Address__c = addr[0].Id;
        // insert opp;


        
       	List<NE__Order__c> order = XC_DF_Order.createOrders(1,Label.XC_CL_Configuration_TypeInOrder);
       	order[0].NE__AccountId__c = acc[0].Id;
        // order[0].NE__OptyId__c = opp[0].Id;
		order[0].XC_DeliveryAddress__c = addr[0].Id;
        order[0].XC_InstallationAddress__c = addr[0].Id;
        insert order;

        NE__OrderItem__c oiItemBundle = XC_DF_OrderItem.createOrderItem(order[0]);
        oiItemBundle.XC_CreditAssignmentAvailable__c = true;
        oiItemBundle.NE__Account__c = acc[0].Id;
        insert oiItemBundle;
        
       	NE__OrderItem__c orderItem = XC_DF_OrderItem.createOrderItem(order[0]);
        orderItem.NE__Account__c = acc[0].Id;
        orderItem.XC_Installation_Address__c = addr[0].Id;
        orderItem.NE__Bundle_Configuration__c = oiItemBundle.Id;
        insert orderItem;
           
        XC_Provisioning_Step__c step = XC_DF_ProvisioningStep.createProvisioningStep(orderItem.Id);
        step.XC_StepLabel__c = 'Documental Check';
        insert step;
        
       	Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_CMD_AdministrativeTask,Label.XC_CL_CMD_CreditTransfer});
        Case case1 = XC_UTIL_Case.initCaseFromCaseSettings(mapCaseSetting.get(Label.XC_CL_CMD_AdministrativeTask));
        //case1.Status = 'ESTA003';
        case1.XC_Segment__c = 'B2C';
        case1.XC_LegalEntity__c = 'EndesaX';
        case1.AccountId = acc[0].Id;
        case1.XC_ProvisioningStep__c = step.Id;
        // case1.ContactId = opp[0].XC_Contact__c;
        case1.XC_OrderItem__c = orderItem.Id;
        Case case2 = XC_UTIL_Case.initCaseFromCaseSettings(mapCaseSetting.get(Label.XC_CL_CMD_CreditTransfer));
        //case2.Status = 'ESTA003';
        case2.XC_Segment__c = 'B2C';
        case2.XC_LegalEntity__c = 'EndesaX';
        case2.AccountId = acc[0].Id;
        case2.XC_ProvisioningStep__c = step.Id;
        // case2.ContactId = opp[0].XC_Contact__c;
        case2.XC_OrderItem__c = orderItem.Id;
        insert new List<Case>{case1,case2};
            
        case1.XC_Resolution__c = 'R001';
        case1.XC_Result__c = 'RS003';
        case1.CaseRemarks__c = 'test chiusura';
        case2.XC_Resolution__c = 'R001';
        case2.XC_Result__c = 'RS003';
        case2.CaseRemarks__c = 'test chiusura';
        update new List<Case>{case1,case2};




    }


    @isTest
    static void checkIfCasesAreClosed_TEST(){

        Test.startTest();
        XC_Provisioning_Step__c step = [SELECT Id FROM XC_Provisioning_Step__c LIMIT 1];
        XC_IN063_CheckIncentiveCases.InputWrapper iw = new XC_IN063_CheckIncentiveCases.InputWrapper();
        iw.stepId = step.Id;
        List<XC_IN063_CheckIncentiveCases.InputWrapper> inputs = new List<XC_IN063_CheckIncentiveCases.InputWrapper>{iw};

        XC_IN063_CheckIncentiveCases.checkClosedCases(inputs);
        Test.stopTest();

    }

}