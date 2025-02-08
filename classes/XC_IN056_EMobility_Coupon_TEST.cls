/**
 * @author Nicola Mariniello nmariniello@deloitte.it
 * @date Creation 01/07/2020
 * @date Modification dd/mm/yyyy
 * @description  – XC_IN056_EMobility_Coupon_TEST - Test class for XC_IN056_EMobility_Coupon
 */ 


@isTest
public without sharing class XC_IN056_EMobility_Coupon_TEST {

    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;

        List<NE__Product__c> prodList = XC_DF_Product.createProducts(3);
        NE__Product__c product1 = prodList[0];
        product1.XC_LIC_Product_Name__c = 'Coupon';
        product1.XC_Product_Subtype__c = Label.XC_CL_OrderItemSubtype_Coupon;  	
        product1.XC_Product_Type__c = Label.XC_CL_OrderItem_ProductType;
        insert prodList;

        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(1);
        NE__OrderItem__c ordIt1 = orderItemList[0];
        ordIt1.NE__ProdId__c = product1.Id;
        ordIt1.XC_Product_Type__c = Label.XC_CL_OrderItem_ProductType;
        ordIt1.XC_Product_Subtype__c = Label.XC_CL_OrderItemSubtype_Coupon;
        insert ordIt1;

        NE__DynamicPropertyDefinition__c d1 = new NE__DynamicPropertyDefinition__c(XC_LIC_DynamicPropertyDefinition__c = Label.XC_CL_OIA_DeveloperName_MaxKwh);
        NE__DynamicPropertyDefinition__c d2 = new NE__DynamicPropertyDefinition__c(XC_LIC_DynamicPropertyDefinition__c = Label.XC_CL_OIA_DeveloperName_ActivationDateline);
        NE__DynamicPropertyDefinition__c d3 = new NE__DynamicPropertyDefinition__c(XC_LIC_DynamicPropertyDefinition__c = Label.XC_CL_OIA_DeveloperName_ExpirationDate);
        List<NE__DynamicPropertyDefinition__c> dList = new List<NE__DynamicPropertyDefinition__c>{d1, d2, d3};
        insert dList;
		
        NE__Family__c f = new NE__Family__c(Name = 'Family');
        insert f;
        
        NE__ProductFamilyProperty__c p1 = new NE__ProductFamilyProperty__c(NE__PropId__c = d1.Id, NE__FamilyId__c = f.Id);
        NE__ProductFamilyProperty__c p2 = new NE__ProductFamilyProperty__c(NE__PropId__c = d2.Id, NE__FamilyId__c = f.Id);
        NE__ProductFamilyProperty__c p3 = new NE__ProductFamilyProperty__c(NE__PropId__c = d3.Id, NE__FamilyId__c = f.Id);
        List<NE__ProductFamilyProperty__c> pList = new List<NE__ProductFamilyProperty__c>{p1, p2, p3};
        insert pList;

        NE__Order_Item_Attribute__c attr1 = new NE__Order_Item_Attribute__c(Name = Label.XC_CL_OIA_DeveloperName_MaxKwh,
                                                                            NE__FamPropId__c = p1.Id,
                                                                            NE__Value__c = '15',
                                                                            NE__Order_Item__c = ordIt1.Id);
        NE__Order_Item_Attribute__c attr2 = new NE__Order_Item_Attribute__c(Name = Label.XC_CL_OIA_DeveloperName_ActivationDateline,
                                                                            NE__FamPropId__c = p2.Id,
                                                                            NE__Value__c = '2020-07-01',
                                                                            NE__Order_Item__c = ordIt1.Id);
        NE__Order_Item_Attribute__c attr3 = new NE__Order_Item_Attribute__c(Name = Label.XC_CL_OIA_DeveloperName_ExpirationDate,
                                                                            NE__FamPropId__c = p3.Id,
                                                                            NE__Value__c = '3020-07-01',
                                                                            NE__Order_Item__c = ordIt1.Id);
        List<NE__Order_Item_Attribute__c> attrList = new List<NE__Order_Item_Attribute__c>{attr1, attr2, attr3};
        insert attrList;
        
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        Asset ast1 = assetList[0];
        ast1.XC_Configuration_Item__c = ordIt1.Id;
        insert ast1;
        
        XC_Provisioning_Step__c provisioningStep1 = new XC_Provisioning_Step__c();
        provisioningStep1.XC_Configuration_Item__c = ordIt1.id;
        provisioningStep1.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep1.XC_Step_Order__c = 1;
        insert provisioningStep1;
    }
    
    static testMethod void createCouponsTEST(){        
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c WHERE XC_Step_Order__c = 1];
        XC_Provisioning_Step__c step = stepsList[0];
        
        XC_IN056_EMobility_Coupon.InputWrapper inw = new XC_IN056_EMobility_Coupon.InputWrapper();
        List<XC_IN056_EMobility_Coupon.InputWrapper> inputWrapperList = new List<XC_IN056_EMobility_Coupon.InputWrapper>();
        inw.stepId = step.Id;
        inputWrapperList.add(inw);
        
        test.startTest();  
        XC_IN056_EMobility_Coupon.createCoupons(inputWrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    }

}