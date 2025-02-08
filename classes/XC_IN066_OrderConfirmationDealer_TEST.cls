/**
 * @author Dario Tramontin dtramonitn@deloitte.it
 * @date Creation 12/01/2021
 * @date Modification 
 * @description  – Test Class of IN066
 */

@isTest
public class XC_IN066_OrderConfirmationDealer_TEST {
   @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        
        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(1);
        NE__OrderItem__c ordIt = orderItemList[0];

        insert ordIt;
        
        List<WorkOrder> createWorkOrders=XC_DF_WorkOrder.createWorkOrders(1,'Installation');
        createWorkOrders[0].XC_Configuration_Item__c=ordIt.Id;
        insert createWorkOrders;
        
        List<NE__Product__c> lp = XC_DF_Product.createProducts(1);
        lp[0].Name = 'RFID';
        insert lp;
        
        ordit.NE__ProdId__c = lp[0].id;
		update ordit;
        
        NE__DocumentationCharacterist__c docChar = new NE__DocumentationCharacterist__c(
            LicName__c = 'Included kWH',
            LicValue__c = '122',
            NE__Product__c = lp[0].Id
        );
        insert docChar;
        
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        Asset ast = assetList[0];
        ast.XC_Configuration_Item__c = ordIt.Id;
        insert ast;
        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = ordIt.id;
        provisioningStep.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep.XC_Step_Order__c = 1;
        insert provisioningStep;
    }
    
    static testMethod void emailForUserCreationTEST(){        
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];
        
        XC_IN066_OrderConfirmationDealerNotif.InputWrapper inw = new XC_IN066_OrderConfirmationDealerNotif.InputWrapper();
        List<XC_IN066_OrderConfirmationDealerNotif.InputWrapper> inputWrapperList = new List<XC_IN066_OrderConfirmationDealerNotif.InputWrapper>();
        inw.stepId = step.Id;
        inputWrapperList.add(inw);
        
        test.startTest();  
        XC_IN066_OrderConfirmationDealerNotif.emailForUserCreation(inputWrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    }
}