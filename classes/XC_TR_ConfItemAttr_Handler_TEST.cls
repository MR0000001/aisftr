/**
* @author Andrea Bravaccino - andrea.bravaccino@nttdata.com
* @date Creation  24/06/2019 
* @description XC_TR_ConfItemAttr_Handler_TEST – Test class for XC_TR_ConfigurationItemAttribute_Handler
*/ 
@isTest
public class XC_TR_ConfItemAttr_Handler_TEST {
    @TestSetup
    	static void setup(){
         List<User> user=[SELECT Id FROM USER WHERE Id =: UserInfo.getUserId()];
        user[0].XC_EnabledToSkip__c = true;
        update user;

        System.runAs(user[0]){
        OneOrg__c org            = new OneOrg__c(); 
        org.Name                 = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org; 
        Integer n = 1; 
        List<XC_Provisioning_Step__c> provStepList = new List<XC_Provisioning_Step__c>();
        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(n);
        insert orderItemList;
        NE__Family__c fam = new NE__Family__c();
        insert fam;    
        NE__DynamicPropertyDefinition__c prop = new NE__DynamicPropertyDefinition__c(Name = Label.XC_CL_ConfigurationItemAttribute_DevPaymentModel, XC_LIC_DynamicPropertyDefinition__c = label.XC_CL_ConfigurationItemAttribute_DevPaymentModel);
        insert prop;    
        NE__ProductFamilyProperty__c prodFam = new NE__ProductFamilyProperty__c(); 
        prodFam.NE__FamilyId__c = fam.Id;
        prodFam.NE__PropId__c = prop.Id; 
        insert prodFam;    
        List<NE__Order_Item_Attribute__c> listAttribute = new List<NE__Order_Item_Attribute__c>();   
        NE__Order_Item_Attribute__c attr = new NE__Order_Item_Attribute__c();
        attr.NE__Value__c = '3 years renting';
        attr.NE__Order_Item__c = orderItemList[0].Id;
        attr.NE__FamPropId__c = prodFam.Id;    
        listAttribute.add(attr);
        insert listAttribute;
        System.debug('@@@@@@@Dev name ' +listAttribute[0].XC_DeveloperName__c);    
        List<Asset> astList = XC_DF_Asset.createAssets(n);
        for(Integer i = 0; i<n; i++){
            astList[i].XC_Configuration_Item__c = orderItemList[i].Id;
            astList[i].XC_Original_Creation_OrderItem__c = orderItemList[i].Id;
            astList[i].NE__Order_Config__c = orderItemList[i].NE__OrderId__c;
        }
        insert astList;
        for(Integer i = 0; i<n; i++){
            XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
            provisioningStep.XC_Configuration_Item__c = orderItemList[i].id;
            provisioningStep.XC_Status__c = Label.XC_CL_Completed_OK;
            provisioningStep.XC_Step_Order__c = 1;
            provStepList.add(provisioningStep);
        }
        insert provStepList;
    } 
        }
    @isTest
    static void test1(){
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        Id stepId = stepsList[0].Id;
        XC_IN014_ChangeProv_BillingPenalty.InputWrapper inputWr = new XC_IN014_ChangeProv_BillingPenalty.InputWrapper();
        inputWr.stepId = stepId;
        List<XC_IN014_ChangeProv_BillingPenalty.InputWrapper> wrapperList = new List<XC_IN014_ChangeProv_BillingPenalty.InputWrapper>();
        wrapperList.add(inputWr);
        test.startTest();
        XC_IN014_ChangeProv_BillingPenalty.billingPenalty(wrapperList);
        test.stopTest();
        System.assert(stepId!=null);
    }

    @isTest
    static void test2(){
        List<NE__Order_Item_Attribute__c> confItemAttList = [SELECT ID FROM NE__Order_Item_Attribute__c];
        confItemAttList[0].Name = 'TTT';
        update confItemAttList;
        delete confItemAttList;
        System.assert(!confItemAttList.isEmpty());
    }


}