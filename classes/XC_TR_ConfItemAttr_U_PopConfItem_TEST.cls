/**
* @author
* @date Creation  05/06/2019 
* @description XC_TR_ConfItemAttr_U_PopConfItem_TEST – Test class for XC_TR_ConfItemAttr_U_PopulateConfItem
*/ 
@isTest
public class XC_TR_ConfItemAttr_U_PopConfItem_TEST {
	
    @isTest
    static void onAfterTestPaymentModel() {
        
         OneOrg__c org = new OneOrg__c();
         org.Name='OneOrg (User)';
         org.XC_Spain_Triggers__c=true;
         insert org;
         
         List<NE__OrderItem__c> orderItems=XC_DF_OrderItem.createOrderItems(1);
         insert orderItems;

         NE__Order_Item_Attribute__c orderItemAttribute=XC_DF_OrderItemAttribute.createOrderItemAttribute(orderItems[0], 'Combustible', 'Gas natural');
         orderItemAttribute.Name = Label.XC_CL_ConfigurationItemAttribute_DevPaymentModel;
        orderItemAttribute.NE__Value__c = 'OneShot';
         insert orderItemAttribute;
         orderItemAttribute.NE__Value__c='';
         update orderItemAttribute;
         System.assert(orderItemAttribute!=null);
    }
    
    
    @isTest
    static void onAfterTestFormaDePago() {
        
         OneOrg__c org = new OneOrg__c();
         org.Name='OneOrg (User)';
         org.XC_Spain_Triggers__c=true;
         insert org;
        
         List<NE__OrderItem__c> orderItems=XC_DF_OrderItem.createOrderItems(1);
         insert orderItems;

         NE__Order_Item_Attribute__c orderItemAttribute=XC_DF_OrderItemAttribute.createOrderItemAttribute(orderItems[0], 'Combustible', 'Gas natural');
         orderItemAttribute.Name = Label.XC_CL_ConfigurationItemAttribute_DevFormaDePago;
         insert orderItemAttribute;
         orderItemAttribute.NE__Value__c='';
         update orderItemAttribute;
         System.assert(orderItemAttribute!=null);
    }
    
    @isTest
    static void onAfterTestSize() {
        
         OneOrg__c org = new OneOrg__c();
         org.Name='OneOrg (User)';
         org.XC_Spain_Triggers__c=true;
         insert org;
        
         List<NE__OrderItem__c> orderItems=XC_DF_OrderItem.createOrderItems(1);
         insert orderItems;

         NE__Order_Item_Attribute__c orderItemAttribute=XC_DF_OrderItemAttribute.createOrderItemAttribute(orderItems[0], 'Combustible', 'Gas natural');
         orderItemAttribute.Name = Label.XC_CL_ConfigurationItemAttribute_Size;
         insert orderItemAttribute;
         orderItemAttribute.NE__Value__c='';
         update orderItemAttribute;
         System.assert(orderItemAttribute!=null);
    }
    
     @isTest
    static void onAfterTestSubsidy() {
        
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        
        NE__Product__c pr = new NE__Product__c();
        pr.XC_LIC_Product_Name__c = Label.XC_CL_SubsidyProductName;
        insert pr;
        

        
        List<NE__OrderItem__c> orderItems=XC_DF_OrderItem.createOrderItems(3);        
        orderItems[0].NE__ProdId__c = pr.Id;
        orderItems[0].XC_Product_Subtype__c = Label.XC_CL_ProductSubtypeBoiler;
        /*orderItems[0].XC_RelatedProduct__c = '111';
        orderItems[0].NE__Item_Code__c = '111';
        orderItems[1].XC_RelatedProduct__c = '111';
        orderItems[1].NE__Item_Code__c = '111';*/
        NE__Order__c ord = [SELECT Id, XC_LegalEntity__c FROM NE__Order__c WHERE Id= :orderItems[0].NE__OrderId__c LIMIT 1];
        ord.XC_Segment__c = 'B2C';
        ord.XC_LegalEntity__c = Label.XC_CL_LegalEntity_Italy;
        update ord;
        System.debug('SEGMENT:'+ ord.XC_Segment__c);
        
        insert orderItems[0];
        
        orderItems[1].XC_Product_Subtype__c = Label.XC_CL_ProductSubtypeIncentive;
        orderItems[1].NE__Bundle_Configuration__c = orderItems[0].Id;
        orderItems[1].NE__OneTimeFeeOv__c = 1;
        orderItems[1].NE__OrderId__c = ord.Id;
        insert orderItems[1];

        orderItems[2].XC_Product_Type__c = Label.XC_CL_ProductTypeEquipment;
        orderItems[2].XC_Product_Subtype__c = Label.XC_CL_ProductSubtypeBoiler;
        orderItems[2].NE__Bundle_Configuration__c = orderItems[0].Id;
        orderItems[2].NE__OneTimeFeeOv__c = 1;
        orderItems[2].NE__OrderId__c = ord.Id;
        insert orderItems[2];
        
        
        NE__DynamicPropertyDefinition__c prop = new NE__DynamicPropertyDefinition__c();
        prop.XC_LIC_DynamicPropertyDefinition__c = Label.XC_CL_SubsidyAttributeDevName;
        insert prop;
        
        NE__Family__c family = new NE__Family__c();
        insert family;
        
        NE__ProductFamilyProperty__c famProp = new NE__ProductFamilyProperty__c();
        famProp.NE__PropId__c = prop.Id;
        famProp.NE__FamilyId__c = family.id;
        insert famProp;
       
        
        NE__Order_Item_Attribute__c orderItemAttribute1=XC_DF_OrderItemAttribute.createOrderItemAttribute(orderItems[1], Label.XC_CL_Incentive_Type,'Riqualificazione');
        orderItemAttribute1.Name = Label.XC_CL_SubsidyAttributeDevName;
        orderItemAttribute1.NE__FamPropId__c = famProp.Id;
        NE__Order_Item_Attribute__c orderItemAttribute2=XC_DF_OrderItemAttribute.createOrderItemAttribute(orderItems[1], Label.XC_CL_Incentive_Amount,'65');
        List<NE__Order_Item_Attribute__c> oiaList=new List<NE__Order_Item_Attribute__c>();

        NE__Order_Item_Attribute__c orderItemAttribute3=XC_DF_OrderItemAttribute.createOrderItemAttribute(orderItems[2],Label.XC_CL_Incentive_Amount,'65');
        oiaList.add(orderItemAttribute1);
        oiaList.add(orderItemAttribute2);
        oiaList.add(orderItemAttribute3);
        insert oiaList;
       
        orderItemAttribute1.NE__Value__c='';
        update orderItemAttribute1;
        System.assert(orderItemAttribute1!=null);
    }
    
    @isTest
    static void testIncentiveSurvey(){
        
               
        NE__Product__c pr = new NE__Product__c();
        pr.XC_LIC_Product_Name__c = Label.XC_CL_SubsidyProductName;
        insert pr;
        

        
        List<NE__OrderItem__c> orderItems=XC_DF_OrderItem.createOrderItems(2);
        orderItems[0].NE__ProdId__c = pr.Id;
        /*orderItems[0].XC_RelatedProduct__c = '111';
        orderItems[0].NE__Item_Code__c = '111';
        orderItems[1].XC_RelatedProduct__c = '111';
        orderItems[1].NE__Item_Code__c = '111';*/
        
        NE__Order__c ord = [SELECT Id FROM NE__Order__c WHERE Id= :orderItems[0].NE__OrderId__c LIMIT 1];
        ord.XC_Segment__c = 'B2C';
        update ord;
        
        
        insert orderItems[0];
        
        orderItems[1].XC_Product_Subtype__c = Label.XC_CL_ProductSubtypeIncentive;
        orderItems[1].NE__Bundle_Configuration__c = orderItems[0].Id;
        orderItems[1].NE__OneTimeFeeOv__c = 1;
        orderItems[1].NE__OrderId__c = ord.Id;
        insert orderItems[1];
        
        NE__Order_Item_Attribute__c orderItemAttribute1=XC_DF_OrderItemAttribute.createOrderItemAttribute(orderItems[1], Label.XC_CL_Incentive_Type,'Riqualificazione');
        NE__Order_Item_Attribute__c orderItemAttribute2=XC_DF_OrderItemAttribute.createOrderItemAttribute(orderItems[1], Label.XC_CL_Incentive_Amount,'65');

        List<NE__Order_Item_Attribute__c> oiaList = new List<NE__Order_Item_Attribute__c>{orderItemAttribute1,orderItemAttribute2};
        insert oiaList;
        
    }
        @isTest
        static void copyBillingModel(){
            List<NE__OrderItem__c> orderItems=XC_DF_OrderItem.createOrderItems(2);

            NE__Order__c ord = [SELECT Id, XC_LegalEntity__c FROM NE__Order__c WHERE Id= :orderItems[0].NE__OrderId__c LIMIT 1];
            ord.XC_Segment__c = 'B2B';
            ord.XC_LegalEntity__c = Label.XC_CL_LegalEntity_Italy;
            update ord;
            insert orderItems[0];
            orderItems[1].NE__Root_Order_Item__c = orderItems[0].id;
            insert orderItems[1];
            NE__Order_Item_Attribute__c orderItemAttribute1=XC_DF_OrderItemAttribute.createOrderItemAttribute(orderItems[1], 'Capex','Riqualificazione');
            Map<Id,NE__OrderItem__c> newMapOrd = New Map<Id,NE__OrderItem__c>();

            insert orderItemAttribute1;
            update orderItemAttribute1;
            newMapOrd.put(orderItems[1].id,orderItems[1]);

            List<NE__OrderItem__c> listOrd = new List<NE__OrderItem__c>();
            listOrd = XC_TR_ConfItemAttr_U_PopulateConfItem.copyBillingModelFromFatherToChild(newMapOrd);

        }


        @isTest
        static void onAfterTestOtherBillingModel() {
            
            OneOrg__c org = new OneOrg__c();
            org.Name='OneOrg (User)';
            org.XC_Spain_Triggers__c=true;
            insert org;
            
            List<NE__OrderItem__c> orderItems=XC_DF_OrderItem.createOrderItems(1);
            insert orderItems;

            NE__Order_Item_Attribute__c orderItemAttribute=XC_DF_OrderItemAttribute.createOrderItemAttribute(orderItems[0], 'Combustible', 'Gas natural');
            orderItemAttribute.Name = Label.XC_CL_ConfigurationItemAttribute_DevPaymentModel;
            orderItemAttribute.NE__Value__c = 'By Milestone';
            insert orderItemAttribute;
            orderItemAttribute.NE__Value__c='Billing Plan';
            update orderItemAttribute;
            orderItemAttribute.NE__Value__c='Capex';
            update orderItemAttribute;
            orderItemAttribute.NE__Value__c='Usage';
            update orderItemAttribute;
            orderItemAttribute.NE__Value__c='Installment Plan';
            update orderItemAttribute;
            orderItemAttribute.NE__Value__c='Saving Sharing';
            update orderItemAttribute;
            System.assert(orderItemAttribute!=null);
        }


    
}