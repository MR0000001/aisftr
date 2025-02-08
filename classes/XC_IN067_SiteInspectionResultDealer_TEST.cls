/**
 * @author Dario Tramontin dtramonitn@deloitte.it
 * @date Creation 12/01/2021
 * @date Modification 
 * @description  – Test Class of IN067
 */

@isTest
public class XC_IN067_SiteInspectionResultDealer_TEST {

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
        
        List<ServiceAppointment> createServiceAppointments = XC_DF_ServiceAppointment.createServiceAppointment(createWorkOrders);
        insert createServiceAppointments;
        List<NE__Product__c> lp = XC_DF_Product.createProducts(1);
        lp[0].Name = 'RFID';
        insert lp;
        
        ordit.NE__ProdId__c = lp[0].id;
		update ordit;
        
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
        
        XC_IN067_SiteInspectionResultDealerNotif.InputWrapper inw = new XC_IN067_SiteInspectionResultDealerNotif.InputWrapper();
        List<XC_IN067_SiteInspectionResultDealerNotif.InputWrapper> inputWrapperList = new List<XC_IN067_SiteInspectionResultDealerNotif.InputWrapper>();
        inw.stepId = step.Id;
        inputWrapperList.add(inw);
        
        test.startTest();  
        XC_IN067_SiteInspectionResultDealerNotif.emailForUserCreation(inputWrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    }
}