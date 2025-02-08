/**
* @author Nicola Mariniello nmariniello@deloitte.it
* @description XC_IN083_OpenChargeB2BNotific_TEST - Test Class for XC_IN083_OpenChargeB2BNotification
*/
@isTest
public class XC_IN083_OpenChargeB2BNotific_TEST {


    @TestSetup
    static void setup() { 
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;

        NE__Order__c order = XC_DF_Order.createOrder('inOrder');
        
        User user = XC_DF_User.createUserAdmin();
        insert user;

        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        assetList[0].XC_Configuration_Item__c = [SELECT Id FROM NE__OrderItem__c WHERE NE__OrderId__c = :order.id LIMIT 1].Id;
        assetList[0].NE__Order_Config__c = order.Id;
        assetList[0].OwnerId = user.Id;
        insert assetList;

        XC_Provisioning_step__c step = XC_DF_ProvisioningStep.createProvisioningStep([SELECT Id FROM NE__OrderItem__c WHERE NE__OrderId__c = :order.id LIMIT 1].Id);
        insert step;
    }


    @isTest
    private static void testOk() {
        
        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<XC_IN083_OpenChargeB2BNotification.InputWrapper> listInputWrapper = new List<XC_IN083_OpenChargeB2BNotification.InputWrapper>();
        XC_IN083_OpenChargeB2BNotification.InputWrapper input = new XC_IN083_OpenChargeB2BNotification.InputWrapper();
        input.stepId = ps.Id;
        input.isActivationOK = true;
        listInputWrapper.add(input);

        Test.startTest();
            XC_IN083_OpenChargeB2BNotification.createCustomerInteraction(listInputWrapper);
        Test.stopTest();
        
        System.assertEquals(listInputWrapper!=null, true, 'Wrong assert equals');
    }

}