/**
 * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @date 21/03/2022
 * @description BLAZE_SC001_DataCleaning_TEST - Test Class for BLAZE_SC001_DataCleaning
 */

@isTest
public class BLAZE_SC001_DataCleaning_TEST {

    @isTest
    static void executeBatchWithError() {
        insert new BLAZE_CS001_Util__c(
            Name = 'Test',
            BLAZE_Countries__c = 'Italy,Spain'
        );
        Database.executeBatch(new BLAZE_SC001_DataCleaning(), 1);
    }

    @isTest
    static void executeBatch() {
        insert new BLAZE_CS001_Util__c(
            Name = 'GeneralSetting',
            BLAZE_Countries__c = 'Italy,Spain'
        );
        insert XC_DF_Asset.createAssets(1);
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1);
        List<NE__Order__c> orderList = [SELECT Id FROM NE__Order__c];
        for(NE__Order__c ord : orderList){
            ord.XC_LegalEntity__c = 'EnelXItalia';
        }
        update orderList;
        insert listOrderItem;
        Database.executeBatch(new BLAZE_SC001_DataCleaning(), 1);
    }

    @isTest
    static void executeBatchOptyWithoutCheckout() {
        insert new BLAZE_CS001_Util__c(
            Name = 'GeneralSetting',
            BLAZE_Countries__c = 'Italy,Spain'
        );
        insert XC_DF_Asset.createAssets(1);
        List<Opportunity> listOfOpp = XC_DF_Opportunity.createOpportunity(1, false);
        List<Account> listOfAccount = new List<Account>();
        Account acc = new Account (Id = listOfOpp[0].AccountId);
        listOfAccount.add(acc);
        List<XC_Address__c> listOfAddress = XC_DF_Address.createItalianAddress(listOfAccount);
        insert listOfAddress;
        listOfOpp[0].XC_LegalEntity__c = 'EnelXItalia';
        listOfOpp[0].XC_Address__c = listOfAddress[0].Id;
        listOfOpp[0].XC_ProductCategoryOfInterest__c = '';
        insert listOfOpp;
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1);
        List<NE__Order__c> orderList = [SELECT Id FROM NE__Order__c];
        orderList[0].NE__OptyId__c = listOfOpp[0].Id;
        update orderList;
        Database.executeBatch(new BLAZE_SC001_DataCleaning(), 1);
    }

    @isTest
    static void executeBatchOptyNotScheduledSiteInspection() {
        insert new BLAZE_CS001_Util__c(
            Name = 'GeneralSetting',
            BLAZE_Countries__c = 'Italy,Spain'
        );
        List<Asset> listAsset = XC_DF_Asset.createAssets(1);
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1);
        List<NE__Order__c> orderList = [SELECT Id FROM NE__Order__c];
        for(NE__Order__c ord : orderList){
            ord.XC_LegalEntity__c = 'EnelXItalia';
        }
        listAsset[0].BLAZE_ToClean__c = 'Y';
        listAsset[0].XC_PaymentMethod__c = Label.XC_CL_PaymentMethod_NoPaymentRequired;
        listAsset[0].NE__Order_Config__c = orderList[0].Id;
        listAsset[0].XC_Configuration_Item__c = listOrderItem[0].Id;
        update orderList;
        insert listOrderItem;
        insert listAsset;
        WorkType wt2 = XC_DF_WorkType.createWorkType(Label.XC_CL_WorkType_SiteInspection);
        wt2.XC_Segment__c = 'B2C';
        wt2.XC_LegalEntity__c = 'EnelXItalia';
        insert wt2;
        WorkOrder workOrderToInsert = new WorkOrder();
        workOrderToInsert.XC_Configuration_Item__c = listOrderItem[0].Id;
        workOrderToInsert.XC_WorkTypeCategory__c = Label.XC_CL_WorkType_SiteInspection;
        workOrderToInsert.WorkTypeId = wt2.Id;
        workOrderToInsert.XC_LegalEntity__c = 'EnelXItalia';
        workOrderToInsert.XC_Segment__c = 'B2C';
        workOrderToInsert.XC_Digitized__c = true;
        workOrderToInsert.XC_ToBeManuallyDigitalized__c = true;
        workOrderToInsert.XC_CreatedAutomaticallyBySystem__c = true;
        workOrderToInsert.XC_Configuration__c = orderList[0].Id;
        insert workOrderToInsert;
        Database.executeBatch(new BLAZE_SC001_DataCleaning(), 1);
    }

    @isTest
    static void executeBatchOptyWithScheduledSiteInspection() {
        insert new BLAZE_CS001_Util__c(
            Name = 'GeneralSetting',
            BLAZE_Countries__c = 'Italy,Spain'
        );
        List<Asset> listAsset = XC_DF_Asset.createAssets(1);
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1);
        List<NE__Order__c> orderList = [SELECT Id FROM NE__Order__c];
        for(NE__Order__c ord : orderList){
            ord.XC_LegalEntity__c = 'EnelXItalia';
        }
        listAsset[0].BLAZE_ToClean__c = 'Y';
        listAsset[0].XC_PaymentMethod__c = Label.XC_CL_PaymentMethod_NoPaymentRequired;
        listAsset[0].NE__Order_Config__c = orderList[0].Id;
        listAsset[0].XC_Configuration_Item__c = listOrderItem[0].Id;
        update orderList;
        insert listOrderItem;
        insert listAsset;
        WorkType wt2 = XC_DF_WorkType.createWorkType(Label.XC_CL_WorkType_SiteInspection);
        wt2.XC_Segment__c = 'B2C';
        wt2.XC_LegalEntity__c = 'EnelXItalia';
        insert wt2;
        WorkOrder workOrderToInsert = new WorkOrder();
        workOrderToInsert.XC_Configuration_Item__c = listOrderItem[0].Id;
        workOrderToInsert.XC_WorkTypeCategory__c = Label.XC_CL_WorkType_SiteInspection;
        workOrderToInsert.WorkTypeId = wt2.Id;
        workOrderToInsert.XC_LegalEntity__c = 'EnelXItalia';
        workOrderToInsert.XC_Segment__c = 'B2C';
        workOrderToInsert.XC_Digitized__c = true;
        workOrderToInsert.XC_ToBeManuallyDigitalized__c = true;
        workOrderToInsert.XC_CreatedAutomaticallyBySystem__c = true;
        workOrderToInsert.XC_Configuration__c = orderList[0].Id;
        insert workOrderToInsert;
        List<WorkOrder> listOfWorkOrder = new List<WorkOrder>();
        listOfWorkOrder.add(workOrderToInsert);
        List<ServiceAppointment> listOfSA = XC_DF_ServiceAppointment.createServiceAppointment(listOfWorkOrder);
        insert listOfSA;
        Database.executeBatch(new BLAZE_SC001_DataCleaning(), 1);
    }

    @isTest
    static void executeBatchOptyWithDeliveryNotScheduled() {
        insert new BLAZE_CS001_Util__c(
            Name = 'GeneralSetting',
            BLAZE_Countries__c = 'Italy,Spain'
        );
        List<Asset> listAsset = XC_DF_Asset.createAssets(1);
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1);
        List<NE__Order__c> orderList = [SELECT Id FROM NE__Order__c];
        for(NE__Order__c ord : orderList){
            ord.XC_LegalEntity__c = 'EnelXItalia';
        }
        listAsset[0].BLAZE_ToClean__c = 'Y';
        listAsset[0].XC_PaymentMethod__c = Label.XC_CL_PaymentMethod_NoPaymentRequired;
        listAsset[0].NE__Order_Config__c = orderList[0].Id;
        listAsset[0].XC_Configuration_Item__c = listOrderItem[0].Id;
        update orderList;
        insert listOrderItem;
        insert listAsset;
        WorkType wt2 = XC_DF_WorkType.createWorkType(Label.XC_CL_WorkType_Delivery);
        wt2.XC_Segment__c = 'B2C';
        wt2.XC_LegalEntity__c = 'EnelXItalia';
        insert wt2;
        WorkOrder workOrderToInsert = new WorkOrder();
        workOrderToInsert.XC_Configuration_Item__c = listOrderItem[0].Id;
        workOrderToInsert.XC_WorkTypeCategory__c = Label.XC_CL_WorkType_Delivery;
        workOrderToInsert.WorkTypeId = wt2.Id;
        workOrderToInsert.XC_LegalEntity__c = 'EnelXItalia';
        workOrderToInsert.XC_Segment__c = 'B2C';
        workOrderToInsert.XC_Digitized__c = true;
        workOrderToInsert.XC_ToBeManuallyDigitalized__c = true;
        workOrderToInsert.XC_CreatedAutomaticallyBySystem__c = true;
        workOrderToInsert.XC_Configuration__c = orderList[0].Id;
        insert workOrderToInsert;
        Database.executeBatch(new BLAZE_SC001_DataCleaning(), 1);
    }

    @isTest
    static void executeBatchOptyWithScheduledDelivery() {
        insert new BLAZE_CS001_Util__c(
            Name = 'GeneralSetting',
            BLAZE_Countries__c = 'Italy,Spain'
        );
        List<Asset> listAsset = XC_DF_Asset.createAssets(1);
        XC_DF_BillingProfile.createBillingProfile(1);
        List<XC_BillingProfileLineItem__c> bpliList = [SELECT Id FROM XC_BillingProfileLineItem__c];
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1);
        listOrderItem[0].XC_BillingProfileLineItem__c = bpliList[0].Id;
        listOrderItem[0].XC_PaymentMethod__c = Label.XC_CL_PaymentMethod_NoPaymentRequired;
        List<NE__Order__c> orderList = [SELECT Id FROM NE__Order__c];
        for(NE__Order__c ord : orderList){
            ord.XC_LegalEntity__c = 'EnelXItalia';
        }
        listAsset[0].BLAZE_ToClean__c = 'Y';
        listAsset[0].XC_PaymentMethod__c = Label.XC_CL_PaymentMethod_NoPaymentRequired;
        listAsset[0].NE__Order_Config__c = orderList[0].Id;
        listAsset[0].XC_Configuration_Item__c = listOrderItem[0].Id;
        update orderList;
        insert listOrderItem;
        insert listAsset;
        WorkType wt2 = XC_DF_WorkType.createWorkType(Label.XC_CL_WorkType_Delivery);
        wt2.XC_Segment__c = 'B2C';
        wt2.XC_LegalEntity__c = 'EnelXItalia';
        insert wt2;
        WorkOrder workOrderToInsert = new WorkOrder();
        workOrderToInsert.XC_Configuration_Item__c = listOrderItem[0].Id;
        workOrderToInsert.XC_WorkTypeCategory__c = Label.XC_CL_WorkType_Delivery;
        workOrderToInsert.WorkTypeId = wt2.Id;
        workOrderToInsert.XC_LegalEntity__c = 'EnelXItalia';
        workOrderToInsert.XC_Segment__c = 'B2C';
        workOrderToInsert.XC_Digitized__c = true;
        workOrderToInsert.XC_ToBeManuallyDigitalized__c = true;
        workOrderToInsert.XC_CreatedAutomaticallyBySystem__c = true;
        workOrderToInsert.XC_Configuration__c = orderList[0].Id;
        insert workOrderToInsert;
        List<WorkOrder> listOfWorkOrder = new List<WorkOrder>();
        listOfWorkOrder.add(workOrderToInsert);
        List<ServiceAppointment> listOfSA = XC_DF_ServiceAppointment.createServiceAppointment(listOfWorkOrder);
        insert listOfSA;
        Database.executeBatch(new BLAZE_SC001_DataCleaning(), 1);
    }
    
    @isTest
    static void executeBatchOptyWithClosedOrder() {
        insert new BLAZE_CS001_Util__c(
            Name = 'GeneralSetting',
            BLAZE_Countries__c = 'Italy,Spain'
        );
        List<Asset> listAsset = XC_DF_Asset.createAssets(1);
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1);
        List<NE__Order__c> orderList = [SELECT Id FROM NE__Order__c];
        for(NE__Order__c ord : orderList){
            ord.XC_LegalEntity__c = 'EnelXItalia';
            ord.XC_Status__c = Label.XC_CL_Configuration_Closed;
        }
        listAsset[0].BLAZE_ToClean__c = 'Y';
        listAsset[0].XC_PaymentMethod__c = Label.XC_CL_PaymentMethod_NoPaymentRequired;
        listAsset[0].NE__Order_Config__c = orderList[0].Id;
        listAsset[0].XC_Configuration_Item__c = listOrderItem[0].Id;
        update orderList;
        insert listOrderItem;
        insert listAsset;
        WorkType wt2 = XC_DF_WorkType.createWorkType(Label.XC_CL_WorkType_SiteInspection);
        wt2.XC_Segment__c = 'B2C';
        wt2.XC_LegalEntity__c = 'EnelXItalia';
        insert wt2;
        WorkOrder workOrderToInsert = new WorkOrder();
        workOrderToInsert.XC_Configuration_Item__c = listOrderItem[0].Id;
        workOrderToInsert.XC_WorkTypeCategory__c = Label.XC_CL_WorkType_SiteInspection;
        workOrderToInsert.WorkTypeId = wt2.Id;
        workOrderToInsert.XC_LegalEntity__c = 'EnelXItalia';
        workOrderToInsert.XC_Segment__c = 'B2C';
        workOrderToInsert.XC_Digitized__c = true;
        workOrderToInsert.XC_ToBeManuallyDigitalized__c = true;
        workOrderToInsert.XC_CreatedAutomaticallyBySystem__c = true;
        workOrderToInsert.XC_Configuration__c = orderList[0].Id;
        workOrderToInsert.Status = 'Complete';
        workOrderToInsert.XC_forSATO__c = true;
        insert workOrderToInsert;
        List<WorkOrder> listOfWorkOrder = new List<WorkOrder>();
        listOfWorkOrder.add(workOrderToInsert);
        List<ServiceAppointment> listOfSA = XC_DF_ServiceAppointment.createServiceAppointment(listOfWorkOrder);
        listOfSA[0].Status = Label.XC_CL_ServiceAppointment_Completed;
        insert listOfSA;
        Database.executeBatch(new BLAZE_SC001_DataCleaning(), 1);
    }


    @isTest
    static void executeRetrieceCaseTypes() {
        insert new BLAZE_CS001_Util__c(
            Name = 'GeneralSetting',
            BLAZE_Countries__c = 'Italy,Spain'
        );
        List<Asset> listAsset = XC_DF_Asset.createAssets(1);
        XC_DF_BillingProfile.createBillingProfile(1);
        List<XC_BillingProfileLineItem__c> bpliList = [SELECT Id FROM XC_BillingProfileLineItem__c];
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1); 
        listOrderItem[0].XC_BillingProfileLineItem__c = bpliList[0].Id;
        listOrderItem[0].XC_PaymentMethod__c = Label.XC_CL_PaymentMethod_NoPaymentRequired;
        insert listOrderItem;
        List<Opportunity> listOfOpp = XC_DF_Opportunity.createOpportunity(1, false);
        List<Account> listOfAccount = new List<Account>();
        Account acc = new Account (Id = listOfOpp[0].AccountId);
        listOfAccount.add(acc);
        List<XC_Address__c> listOfAddress = XC_DF_Address.createItalianAddress(listOfAccount);
        insert listOfAddress;
        listOfOpp[0].XC_LegalEntity__c = 'EnelXItalia';
        listOfOpp[0].XC_Address__c = listOfAddress[0].Id;
        listOfOpp[0].XC_ProductCategoryOfInterest__c = '';
        insert listOfOpp;
        List<NE__Order__c> orderList = [SELECT Id FROM NE__Order__c];
        for(NE__Order__c ord : orderList){
            ord.XC_LegalEntity__c = 'EnelXItalia';
            ord.NE__OptyId__c = listOfOpp[0].Id;
        }
        update orderList;
        WorkType wt2 = XC_DF_WorkType.createWorkType(Label.XC_CL_WorkType_Delivery);
        wt2.XC_Segment__c = 'B2C';
        wt2.XC_LegalEntity__c = 'EnelXItalia';
        insert wt2;
        WorkOrder workOrderToInsert = new WorkOrder();
        workOrderToInsert.XC_Configuration_Item__c = listOrderItem[0].Id;
        workOrderToInsert.XC_WorkTypeCategory__c = Label.XC_CL_WorkType_Delivery;
        workOrderToInsert.WorkTypeId = wt2.Id;
        workOrderToInsert.XC_LegalEntity__c = 'EnelXItalia';
        workOrderToInsert.XC_Segment__c = 'B2C';
        workOrderToInsert.XC_Digitized__c = true;
        workOrderToInsert.XC_ToBeManuallyDigitalized__c = true;
        workOrderToInsert.XC_CreatedAutomaticallyBySystem__c = true;
        workOrderToInsert.XC_Configuration__c = orderList[0].Id;
        insert workOrderToInsert;
        List<WorkOrder> listOfWorkOrder = new List<WorkOrder>();
        listOfWorkOrder.add(workOrderToInsert);
        List<ServiceAppointment> listOfSA = XC_DF_ServiceAppointment.createServiceAppointment(listOfWorkOrder);
        insert listOfSA;
        listAsset[0].BLAZE_ToClean__c = 'Y';
        listAsset[0].XC_PaymentMethod__c = Label.XC_CL_PaymentMethod_NoPaymentRequired;
        listAsset[0].NE__Order_Config__c = orderList[0].Id;
        listAsset[0].XC_Configuration_Item__c = listOrderItem[0].Id;
        insert listAsset;
        List<Asset> listOfAsset = new List<Asset>([SELECT Id, NE__Order_Config__c, XC_Configuration_Item__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.Id, AccountId, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_Country__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_CustomerAccount__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_BillingAddress__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_ExternalKey__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_BillingProfile__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_BillToAddress__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_BillToContactId__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_LegalEntity__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_DocumentType__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_Status__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_InvoicePreferredLanguage__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_InvoiceDeliveryPreference__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_PEC__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_RecipientCodeB2B__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_OfficeCode__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_RecipientCode__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_TPBCode__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_BillingProfileCopy__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_SoldToAddress__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_SoldToContactId__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_BillingProfileName__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_DocumentNumber__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_DocumentCountry__c FROM Asset]);

        Map<String, BLAZE_SC001_DataCleaning.WrapperObject> mapResult = BLAZE_SC001_DataCleaning.retrieveCaseTypeWrapper(listOfAsset, listOrderItem, new List<String>{'Italy','Spain'}, true, true, false);
    }

    @isTest
    static void executeCheckMethods() {
        insert new BLAZE_CS001_Util__c(
            Name = 'GeneralSetting',
            BLAZE_Countries__c = 'Italy,Spain'
        );
        List<Asset> listAsset = XC_DF_Asset.createAssets(1);
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1); 
        insert listOrderItem;
        listAsset[0].XC_Configuration_Item__c = listOrderItem[0].Id;
        insert listAsset;
        List<XC_BatchErrorLog__c> listLogsToInsert = new List<XC_BatchErrorLog__c>();
        BLAZE_SC001_DataCleaning.WrapperObjectToUpdate wrapperToUpdate = new BLAZE_SC001_DataCleaning.WrapperObjectToUpdate();
        BLAZE_SC001_DataCleaning.WrapperObject wrObj = new BLAZE_SC001_DataCleaning.WrapperObject();
        BLAZE_SC001_DataCleaning.checkOptyWithoutCheckout(wrObj, wrapperToUpdate, listLogsToInsert);
        BLAZE_SC001_DataCleaning.checkOptyWithCheckoutWithoutWorkOrder(wrObj, wrapperToUpdate, listLogsToInsert);
        BLAZE_SC001_DataCleaning.checkOptyWithScheduledSiteInspection(wrObj, wrapperToUpdate, listLogsToInsert);
        BLAZE_SC001_DataCleaning.checkOptyWithSiteInspectionNotScheduled(wrObj, wrapperToUpdate, listLogsToInsert);
        BLAZE_SC001_DataCleaning.checkOptyWithScheduledDelivery(wrObj, wrapperToUpdate, listLogsToInsert);
        BLAZE_SC001_DataCleaning.checkOptyWithDeliveryNotScheduled(wrObj, wrapperToUpdate, listLogsToInsert);
        BLAZE_SC001_DataCleaning.checkOptyWithOtherWorkOrder(wrObj, wrapperToUpdate, listLogsToInsert);
        BLAZE_SC001_DataCleaning.checkOptyWithClosedOrder(wrObj, wrapperToUpdate, listLogsToInsert);
        BLAZE_SC001_DataCleaning.checkAssetWithoutOrder(wrObj, wrapperToUpdate, listLogsToInsert);
    }

    @isTest
    static void executeCheckMethodsItems() {
        insert new BLAZE_CS001_Util__c(
            Name = 'GeneralSetting',
            BLAZE_Countries__c = 'Italy,Spain',
            BLAZE_ManageGlovia__c = true,
            BLAZE_CaseOrderItemNoCase__c = true
        );
        List<Asset> listAsset = XC_DF_Asset.createAssets(1);
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1); 
        insert listOrderItem;
        listAsset[0].XC_Configuration_Item__c = listOrderItem[0].Id;
        insert listAsset;
        List<XC_BatchErrorLog__c> listLogsToInsert = new List<XC_BatchErrorLog__c>();
        BLAZE_SC001_DataCleaning.WrapperObjectToUpdate wrapperToUpdate = new BLAZE_SC001_DataCleaning.WrapperObjectToUpdate();
        BLAZE_SC001_DataCleaning.WrapperObject wrObj = new BLAZE_SC001_DataCleaning.WrapperObject();
        BLAZE_SC001_DataCleaning.checkOptyWithoutCheckout(wrObj, wrapperToUpdate, listLogsToInsert);
        BLAZE_SC001_DataCleaning.checkOptyWithCheckoutWithoutWorkOrder(wrObj, wrapperToUpdate, listLogsToInsert);
        BLAZE_SC001_DataCleaning.checkOptyWithScheduledSiteInspection(wrObj, wrapperToUpdate, listLogsToInsert);
        BLAZE_SC001_DataCleaning.checkOptyWithSiteInspectionNotScheduled(wrObj, wrapperToUpdate, listLogsToInsert);
        BLAZE_SC001_DataCleaning.checkOptyWithScheduledDelivery(wrObj, wrapperToUpdate, listLogsToInsert);
        BLAZE_SC001_DataCleaning.checkOptyWithDeliveryNotScheduled(wrObj, wrapperToUpdate, listLogsToInsert);
        BLAZE_SC001_DataCleaning.checkOptyWithOtherWorkOrder(wrObj, wrapperToUpdate, listLogsToInsert);
        BLAZE_SC001_DataCleaning.checkOptyWithClosedOrder(wrObj, wrapperToUpdate, listLogsToInsert);
        BLAZE_SC001_DataCleaning.checkAssetWithoutOrder(wrObj, wrapperToUpdate, listLogsToInsert);
        BLAZE_SC001_DataCleaning.cleanWrapperFromDuplicatedUpdate(wrapperToUpdate);
        BLAZE_SC001_DataCleaning.manageGlovia(wrObj, wrObj, wrapperToUpdate, listLogsToInsert);
    }

    @isTest
    static void executeUtilMethod() {
        insert new BLAZE_CS001_Util__c(
            Name = 'GeneralSetting',
            BLAZE_Countries__c = 'Italy,Spain'
        );
        List<Asset> listAsset = XC_DF_Asset.createAssets(1);
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1);
        List<NE__Order__c> orderList = [SELECT Id FROM NE__Order__c];
        for(NE__Order__c ord : orderList){
            ord.XC_LegalEntity__c = 'EnelXItalia';
        }
        update orderList;
        insert listOrderItem;
        listAsset[0].XC_Configuration_Item__c = listOrderItem[0].Id;
        insert listAsset;
        List<XC_BatchErrorLog__c> listLogsToInsert = new List<XC_BatchErrorLog__c>();
        WorkType wt1 = XC_DF_WorkType.createWorkType(Label.XC_CL_WorkType_DeliveryInstallation);
        WorkType wt2 = XC_DF_WorkType.createWorkType(Label.XC_CL_WorkType_DeliveryInstallation);
        wt1.XC_Segment__c = 'B2C';
        wt2.XC_Segment__c = 'B2C';
        wt1.XC_LegalEntity__c = 'EnelXItalia';
        wt2.XC_LegalEntity__c = 'EnelXMobilityItalia';
        insert wt1;
        insert wt2;
        WorkOrder workOrderToInsert = new WorkOrder();
        workOrderToInsert.XC_Configuration_Item__c = listOrderItem[0].Id;
        workOrderToInsert.XC_WorkTypeCategory__c = Label.XC_CL_WorkType_DeliveryInstallation;
        workOrderToInsert.WorkTypeId = wt1.Id;
        workOrderToInsert.XC_LegalEntity__c = 'EnelXItalia';
        workOrderToInsert.XC_Segment__c = 'B2C';
        workOrderToInsert.XC_Digitized__c = true;
        workOrderToInsert.XC_ToBeManuallyDigitalized__c = true;
        workOrderToInsert.XC_CreatedAutomaticallyBySystem__c = true;
        insert workOrderToInsert;
        Account acc = [SELECT Id FROM Account LIMIT 1];
        XC_LegalEntityConsent__c lec = new XC_LegalEntityConsent__c();
        lec.XC_LeCountry__c = 'Italy';
        lec.XC_GiveDataToNew__c = 'Yes';
        lec.XC_MarketingConsent__c = 'No';
        lec.XC_CollectionDateMarketing__c = Date.newInstance(2021, 06, 12);
        lec.XC_IndividualLegalEntity__c = 'Individual Legal Entity';
        lec.XC_UpdateAboutProducts__c = 'Yes';
        lec.XC_ConsentToDataProcessing__c = 'No';
        lec.XC_CompanyConsentVersion__c = '1.0';
        lec.XC_MarketingConsentVersion__c = '1.0';
        lec.XC_ProfilingConsentVersion__c = '1.0';
        lec.XC_CollectionChannelMarketing__c = 'Internal User';
        lec.XC_CollectionUserMarketing__c = null;
        lec.XC_CollectionDateProfiling__c = Date.newInstance(2021, 06, 12);
        lec.XC_CollectionChannelProfiling__c = 'Internal User';
        lec.XC_CollectionUserProfiling__c = null;
        lec.XC_ConsentDescription__c = null;
        lec.XC_ExternalId__c = '';
        lec.XC_GiveDataTo__c = false;
        lec.XC_ExpirationDateProfilingConsent__c = Date.newInstance(2021, 07, 12);
        lec.XC_ExpirationDateMarketingConsent__c = Date.newInstance(2021, 07, 12);
        lec.XC_Status__c = 'Active';
        lec.XC_NotCustomerConsent__c = '';
        lec.XC_ThirdProductsMarketingConsent__c = '';
        lec.XC_NotCustomerConsentVersion__c = '';
        lec.XC_ThirdProductsMarketingConsentVersion__c = '';
        lec.XC_CollectionDateNotCustomer__c = Date.newInstance(2021, 07, 12);
        lec.XC_CollectionDateThirdProductsMarketing__c = Date.newInstance(2021, 07, 12);
        lec.XC_CollectionChannelNotCustomer__c = '';
        lec.XC_CollectionChannelThirdProdMarketing__c = '';
        lec.XC_CollectionUserNotCustomer__c = null;
        lec.XC_CollectionUserThirdProductsMarketing__c = null;
        lec.XC_FromAPI__c = false;
        BLAZE_SC001_DataCleaning.listWorkOrderToDiscoveryWT.addAll([SELECT Id, XC_LegalEntity__c, XC_Segment__c, XC_WorkTypeLabel__c FROM WorkOrder]);
        BLAZE_SC001_DataCleaning.mapAccountIndividual.put(acc.Id, null);
        BLAZE_SC001_DataCleaning.mapAccountBPLI.put((String) [SELECT Id FROM Account LIMIT 1].Id, new XC_BillingProfileLineItem__c());
        BLAZE_SC001_DataCleaning.mapKeyLEC.put('nullEnelXItalia', lec);
        BLAZE_SC001_DataCleaning.getNewLegalEntity('EnelXItalia');
        BLAZE_SC001_DataCleaning.getNewLegalEntity('test');
        BLAZE_SC001_DataCleaning.insertBatchErrorLog('test', 'test');
        BLAZE_SC001_DataCleaning.createAccountInfo([SELECT Id FROM Account LIMIT 1].Id, 'EnelXItalia');
        BLAZE_SC001_DataCleaning.createLegalEntityConsent(acc.Id, 'EnelXMobilityItalia', 'EnelXItalia');
        BLAZE_SC001_DataCleaning.createBillingProfileLineItem([SELECT Id FROM Account LIMIT 1].Id, 'EnelXMobilityItalia', listLogsToInsert);
        BLAZE_SC001_DataCleaning.getStringListObject(listOrderItem);
        BLAZE_SC001_DataCleaning.getStringListString(new List<String>{'test1','test2'});
        BLAZE_SC001_DataCleaning.getMoreInfoBPLI(new List<String>(), listLogsToInsert);
        BLAZE_SC001_DataCleaning.saveNewWorkType();
    }

    @isTest
    static void executeUtilMethodWBE() {
        insert new BLAZE_CS001_Util__c(
            Name = 'GeneralSetting',
            BLAZE_Countries__c = 'Italy,Spain'
        );
        List<Asset> listAsset = XC_DF_Asset.createAssets(1);
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1); 
        insert listOrderItem;
        listAsset[0].XC_Configuration_Item__c = listOrderItem[0].Id;
        insert listAsset;
        BLAZE_SC001_DataCleaning.recalculateWBE(XC_UTIL_Sobject.getIds(listOrderItem), XC_UTIL_Sobject.getIds(listOrderItem));
    }

    @isTest
    static void executedeleteObjectForRollback() {
        insert new BLAZE_CS001_Util__c(
            Name = 'GeneralSetting',
            BLAZE_Countries__c = 'Italy,Spain'
        );
        List<Asset> listAsset = XC_DF_Asset.createAssets(1);
        XC_DF_BillingProfile.createBillingProfile(1);
        List<XC_BillingProfileLineItem__c> bpliList = [SELECT Id, XC_BillingProfile__c FROM XC_BillingProfileLineItem__c];
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1);
        listOrderItem[0].XC_BillingProfileLineItem__c = bpliList[0].Id;
        listOrderItem[0].XC_PaymentMethod__c = Label.XC_CL_PaymentMethod_NoPaymentRequired;
        List<NE__Order__c> orderList = [SELECT Id FROM NE__Order__c];
        for(NE__Order__c ord : orderList){
            ord.XC_LegalEntity__c = 'EnelXItalia';
        }
        update orderList;
        insert listOrderItem;
        Individual ind = new Individual();
        ind.FirstName = 'TEST';
        ind.LastName = 'CLASS';
        insert ind;
        XC_LegalEntityConsent__c lec = new XC_LegalEntityConsent__c();
        lec.XC_LeCountry__c = 'Italy';
        lec.XC_GiveDataToNew__c = 'Yes';
        lec.XC_MarketingConsent__c = 'No';
        lec.XC_CollectionDateMarketing__c = Date.newInstance(2021, 06, 12);
        lec.XC_IndividualLegalEntity__c = 'Individual Legal Entity';
        lec.XC_UpdateAboutProducts__c = 'Yes';
        lec.XC_ConsentToDataProcessing__c = 'No';
        lec.XC_CompanyConsentVersion__c = '1.0';
        lec.XC_MarketingConsentVersion__c = '1.0';
        lec.XC_ProfilingConsentVersion__c = '1.0';
        lec.XC_CollectionChannelMarketing__c = 'Internal User';
        lec.XC_CollectionUserMarketing__c = null;
        lec.XC_CollectionDateProfiling__c = Date.newInstance(2021, 06, 12);
        lec.XC_CollectionChannelProfiling__c = 'Internal User';
        lec.XC_CollectionUserProfiling__c = null;
        lec.XC_ConsentDescription__c = null;
        lec.XC_ExternalId__c = '';
        lec.XC_GiveDataTo__c = false;
        lec.XC_ExpirationDateProfilingConsent__c = Date.newInstance(2021, 07, 12);
        lec.XC_ExpirationDateMarketingConsent__c = Date.newInstance(2021, 07, 12);
        lec.XC_Status__c = 'Active';
        lec.XC_NotCustomerConsent__c = '';
        lec.XC_ThirdProductsMarketingConsent__c = '';
        lec.XC_NotCustomerConsentVersion__c = '';
        lec.XC_ThirdProductsMarketingConsentVersion__c = '';
        lec.XC_CollectionDateNotCustomer__c = Date.newInstance(2021, 07, 12);
        lec.XC_CollectionDateThirdProductsMarketing__c = Date.newInstance(2021, 07, 12);
        lec.XC_CollectionChannelNotCustomer__c = '';
        lec.XC_CollectionChannelThirdProdMarketing__c = '';
        lec.XC_CollectionUserNotCustomer__c = null;
        lec.XC_CollectionUserThirdProductsMarketing__c = null;
        lec.XC_FromAPI__c = false;
        lec.XC_Individual__c = ind.Id;
        lec.XC_LegalEntity__c = 'EnelXItalia';
        insert lec;
        BLAZE_SC001_DataCleaning.mapBPLIRollbackOldLE.put(bpliList[0].XC_BillingProfile__c, 'EnelXItalia');
        BLAZE_SC001_DataCleaning.mapConsentOldRollback.put(ind.Id, 'EnelXItalia');
        List<XC_BatchErrorLog__c> listLogsToInsert = new List<XC_BatchErrorLog__c>();
        BLAZE_SC001_DataCleaning.deleteObjectForRollback(listLogsToInsert);
    }

    @isTest
    static void debugCoverage (){
        BLAZE_SC001_DataCleaning.debugCoverage();
    }
}