/**
* @author Valeria Martino - valeria.martino@nttdata.com
* @date Creation 07/10/2019
* @description XC_IN033_SendToAssista_TEST test class for XC_IN033_SendToAssista
*/
@isTest 
public class XC_IN033_SendToAssista_TEST   {
    @testSetup  
    private static void setup() {
        
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        org.XC_Spain_ValidationRules__c = true;
        insert org;
 
        List<Contact> listContact = XC_DF_Contact.createResidentialContacts(1);
        insert listContact;
        List<Account> listAccount = XC_DF_Account.createResidentialAccounts(1);
        Account acc = listAccount[0];
        insert acc;
        List<XC_Address__c> addressList =  XC_DF_Address.createAddress(listAccount);
        insert addressList;
        /*XC_Address__c addressAccount = [SELECT Id FROM XC_Address__c LIMIT 1];
        addressAccount.XC_Account__c = acc.Id;
        update addressAccount;*/
        List<Opportunity> o = XC_DF_Opportunity.createOpportunity(1, false);
        Opportunity opport = o[0];
        opport.XC_NumberOfConfiguration__c= 1;
        opport.StageName = 'Draft';
        insert opport;
        opport.StageName = 'In Progress';
        update opport;
        opport.StageName = 'Closed Won';
        update opport;
        //NE__Order__c ord = XC_DF_Order.createOrderWithAddress('InOrder',addressList[0].Id,acc.Id,opport.Id);
        
        NE__Order__c order = new NE__Order__c();
        order.XC_DeliveryAddress__c = addressList[0].Id;
        order.XC_InstallationAddress__c = addressList[0].Id;
        order.NE__AccountId__c = acc.Id;
        order.NE__OptyId__c = opport.Id;
        Id quote = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        order.RecordTypeId = quote; 
        order.XC_Status__c = 'Accepted';
        order.NE__Type__c = 'InOrder';
        order.XC_Country__c = 'Spain';
        insert order;
        
        NE__OrderItem__c ordIt = XC_DF_OrderItem.createOrderItem(order); 
        ordIt.XC_Installation_Address__c = order.XC_InstallationAddress__c;
        ordIt.NE__Account__c = order.NE__AccountId__c;
        insert ordIt;
        
        //ord.NE__OptyId__c = opport.id;
        //listOrder[0].NE__AccountId__c = acc.id;
        //listOrder[0].XC_DeliveryAddress__c = addressAccount.Id;
        //insert ord;
        //NE__Order__c order = listOrder[0];
        /*NE__OrderItem__c ordIt = XC_DF_OrderItem.createOrderItem(ord);
        ordIt.NE__Account__c = acc.Id;
        ordIt.XC_Installation_Address__c = addressList[0].Id;
        insert ordIt;*/
        //NE__OrderItem__c ordIt = [SELECT Id FROM NE__OrderItem__c WHERE NE__Account__c =: acc.Id ];
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_SiteInspection);
        listWorkOrder[0].XC_Configuration_Item__c =  ordIt.Id;
        insert listWorkOrder;
        Asset asst = new Asset();
        asst.Name = 'Test 1';
        asst.AccountId = listAccount[0].id;
        asst.ContactId = listContact[0].id;
        asst.XC_Configuration_Item__c = ordIt.Id;
        asst.NE__Order_Config__c = order.id;
        insert asst;
        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = ordIt.id;
        provisioningStep.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep.XC_Step_Order__c = 1;
        insert provisioningStep;
    }
    @isTest
    public static void sendToAssista() {
         List<XC_Provisioning_Step__c> psList = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];
        XC_Provisioning_Step__c ps = psList[0];
        List<XC_IN033_SendToAssista.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        Test.startTest();
        XC_IN033_SendToAssista.createSendToAssistaCase(listInputWrapper);
        Test.stopTest();
        System.assertEquals(1, psList.size());
    }
    
    private static List<XC_IN033_SendToAssista.InputWrapper> generateInputWrapper(XC_Provisioning_Step__c ps) {

        List<XC_IN033_SendToAssista.InputWrapper> listWrapperInput = new List<XC_IN033_SendToAssista.InputWrapper>();
        XC_IN033_SendToAssista.InputWrapper wr = new XC_IN033_SendToAssista.InputWrapper();
        wr.stepId = ps.Id;
        listWrapperInput.add(wr);
        
        return listWrapperInput;

    }

}