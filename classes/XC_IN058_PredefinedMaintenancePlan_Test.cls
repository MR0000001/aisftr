@IsTest
public class XC_IN058_PredefinedMaintenancePlan_Test {
     @TestSetup
    static void setup(){
        //CreateOrder
         List<NE__Order__c> orderList = XC_DF_Order.createOrders(1, Label.XC_CL_Configuration_TypeInOrder);
        orderList[0].XC_LegalEntity__c='Codensa';
        insert orderList;
        //Account&Contact&Contract
        List<Account> accList= [select id from Account where id=:orderList[0].NE__AccountId__c];
        List<Contact> contList = XC_DF_Contact.createResidentialContacts(accList);
        insert contList;
        contList[0].XC_PrimaryContact__c=true;
        update contList;
        List<Contract> con=XC_DF_Contract.createCondominiumContract(accList);
        con[0].StartDate=system.today();
        con[0].EndDate=con[0].StartDate.addDays(365);
        con[0].XC_Configurations__c=orderList[0].id;
        insert con;
        //Create Order Item
        NE__OrderItem__c orderItemList=XC_DF_OrderItem.createOrderItem(orderList[0]);
       // orderItemList.XC_Segment__c='B2C';   
        insert orderItemList;
        NE__OrderItem__c orderItemListMaintenance=XC_DF_OrderItem.createOrderItem(orderList[0]);
        orderItemListMaintenance.XC_Product_Subtype__c='Maintenance';
        orderItemListMaintenance.NE__Root_Order_Item__c=orderItemList.id;
        insert orderItemListMaintenance;
       // List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(2);
       // insert orderItemList[0];
        //ConfItemMaintenance
       // orderItemList[1].XC_Product_Subtype__c='Maintenance';
       // orderItemList[1].NE__Root_Order_Item__c=orderItemList[0].id;
       // insert orderItemList [1];
        //OrderItemAttribute
        List<NE__Order_Item_Attribute__c> frequencyAttributes=new List<NE__Order_Item_Attribute__c>();
        NE__Order_Item_Attribute__c  frequencyAttribute=new NE__Order_Item_Attribute__c();
        frequencyAttribute.name='Frequency';
        frequencyAttribute.NE__Order_Item__c= orderItemListMaintenance.id;
        frequencyAttribute.NE__Value__c='12';
        frequencyAttributes.add(frequencyAttribute);
        NE__Order_Item_Attribute__c  frequencyTypeAttribute= new NE__Order_Item_Attribute__c();
        frequencyTypeAttribute.Name='Frequency Type';
        frequencyTypeAttribute.NE__Order_Item__c=orderItemListMaintenance.id;
        frequencyTypeAttribute.NE__Value__c='Months';
        frequencyAttributes.add(frequencyTypeAttribute);
        insert frequencyAttributes;
        //Create Provisioning Step
         XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = orderItemList.id;
        provisioningStep.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep.XC_Step_Order__c = 1;
        insert provisioningStep; 
    }     
    static testMethod void maintenancePlan(){
        List<XC_Provisioning_Step__c> stepList=[select XC_Configuration_Item__c,id,XC_Configuration_Item__r.XC_Segment__c,XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c
                                                from XC_Provisioning_Step__c];
         WorkType woPlannedMaintenance=new WorkType();
        woPlannedMaintenance.XC_Segment__c=stepList[0].XC_Configuration_Item__r.XC_Segment__c;
         woPlannedMaintenance.XC_LegalEntity__c=stepList[0].XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c;
         woPlannedMaintenance.name='Planned Maintenance - Generic';
        woPlannedMaintenance.EstimatedDuration=2;
        insert woPlannedMaintenance;
        List<WorkOrder> createWorkOrders=XC_DF_WorkOrder.createWorkOrders(1,'Installation');
        createWorkOrders[0].XC_Configuration_Item__c=stepList[0].XC_Configuration_Item__c;
        insert createWorkOrders;
        //WOli Technical Asset
        WorkOrderLineItem woli = new WorkOrderLineItem();   		  	
        woli.WorkOrderId= createWorkOrders[0].Id;
        woli.XC_WOLIType__c='Technical Asset';
         Id rtIdwoli =Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_TA_WOLI').getRecordTypeId();
         woli.RecordTypeId=rtIdwoli;      
        system.debug('woliRt'+' '+woli.RecordTypeId);
        insert woli;
        //Create Asset
        Id rtIdAsset =Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('TAM_PODMeter').getRecordTypeId();
        List<Account> accList=[select id from Account limit 1];
        List<Asset> assList=XC_DF_Asset.createAssets(accList);
        assList[0].RecordTypeId=rtIdAsset;
        assList[0].serialnumber='1823747';
        assList[0].TAM_IsTechnical__c= true;
        assList[0].TAM_BrandType__c='BrandTest';
        assList[0].	TAM_Make__c='make';
        assList[0].XC_Model__c='model';
        assList[0].TAM_ModelOrPartNumber__c='Number';
        insert assList;
        //Create ProductConsumed
        XC_ProductConsumed__c pc = new XC_ProductConsumed__c();
        pc.XC_WorkOrderLineItem__c = woli.id;
        pc.XC_QuantityConsumed__c=0;
        pc.XC_UnitPrice__c=0;
        pc.XC_WorkOrder__c= createWorkOrders[0].Id;
        pc.TAM_Asset__c=assList[0].id;
        insert pc;        
        List<XC_IN058_PredefinedMaintenancePlan.InputWrapper> inputWrapperList=new List<XC_IN058_PredefinedMaintenancePlan.InputWrapper>();
        XC_IN058_PredefinedMaintenancePlan.InputWrapper wr=new XC_IN058_PredefinedMaintenancePlan.InputWrapper();
        wr.stepId=stepList[0].id;
        inputWrapperList.add(wr);
         XC_IN058_PredefinedMaintenancePlan.maintenancePlan(inputWrapperList);
    }  
}