/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 31/05/2019
* @date Modification dd/mm/yyyy
* @description  – XC_IN007_PayAndBill_TEST - Test class for XC_IN007_PayAndBill
*/ 
@isTest
public class XC_IN007_PayAndBill_TEST {
    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation  31/05/2019 
    * @description insert records
    */ 
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
    }
    
    static testMethod void payAndBillTEST(){        
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];
        
        XC_IN007_PayAndBill.InputWrapper inw = new XC_IN007_PayAndBill.InputWrapper();
        List<XC_IN007_PayAndBill.InputWrapper> inputWrapperList = new List<XC_IN007_PayAndBill.InputWrapper>();
        inw.stepId = step.Id;
        inputWrapperList.add(inw);
        
        test.startTest();  
        XC_IN007_PayAndBill.payAndBill(inputWrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    }
    
 	static testMethod void checkIfItalyAndMixedVATTEST(){        
        List<NE__Order__c> orList = [SELECT Id FROM NE__Order__c LIMIT 1];
        NE__Order__c order = orList[0];
        order.XC_LegalEntity__c = 'EnelXItalia';
        update order;
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];
        
        XC_IN007_PayAndBill.InputWrapper inw = new XC_IN007_PayAndBill.InputWrapper();
        List<XC_IN007_PayAndBill.InputWrapper> inputWrapperList = new List<XC_IN007_PayAndBill.InputWrapper>();
        inw.stepId = step.Id;
        inputWrapperList.add(inw);
        
        test.startTest();  
        XC_IN007_PayAndBill.payAndBill(inputWrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    }
    
}