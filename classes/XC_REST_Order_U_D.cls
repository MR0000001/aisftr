/**
 * @author            : Simone Trenta - strenta@deloitte.com
 * @date Creation     : 24/01/2019
 * @date Modification : 09/04/2019 by Nicola Mariniello nmariniello@delotte.it - Luisana Rocco lrocco@deloitte.it
 * @description       : DAO Class for XC_REST_Order_U
 **/ 

public without sharing class XC_REST_Order_U_D {
 
    /**
     * GetOrderById.
     *
     * @param searchId the search id
     * @return the order by id
     * @description Method to get Order by Id
     */
     /*
    public static List<NE__Order__c> getOrderById(ID searchId){
        List<ID> searchIdList = new List<ID>();
        searchIdList.add(searchId);
        return getOrderByIdList(searchIdList);
    }
    */

 
    /**
     * Gets the order by id list. 
     *
     * @param searchIdList the search id list
     * @return the order by id list
     * @description Method to get Order List by Id
     */
    public static List<NE__Order__c> getOrderByIdList(List<ID> searchIdList){

        Map<Id, NE__Order__c> orderMap = new Map<Id, NE__Order__c>([
            SELECT Id,
            Name,
            NE__OptyId__c,
            XC_Status__c,
            //UniqueID,
            NE__AccountId__c,
            RecordTypeId,
            RecordType.Name,
            NE__BillingProfId__c,
            NE__Contract_Account__c,
            XC_Order_Tracking__c,
            XC_Delivery_ID__c,
            XC_Cancellation_Date__c,
            NE__One_Time_Fee_Total__c,
            NE__Recurring_Charge_Total__c,
            B2WZC__ZStart_Date__c,
            NE__Service_Account_Asset__c,
            NE__Billing_Account_Asset__c,
            XC_AdministrativeTasks__c,
            XC_Mode_of_cancellation__c,
            XC_Type_of_cancellation__c,
            XC_DeliveryType__c,
            XC_InstallationAddress__c,
            XC_InstallationAddress__r.XC_PostalCode__c,
            XC_PracticeNumber__c,
            XC_FinancialApproval__c,
            XC_PracticeStatus__c,
            XC_FinancialRejectReason__c,
            XC_Compliance_Approval__c, // il campo si chiama Compliance 1 Status
            XC_ComplianceRejectReason__c,
            NE__Description__c,
            XC_Cost_Center__c,
            XC_Company_Code__C,
            NE__Type__c,
            CurrencyIsoCode,
            CreatedDate,
            XC_OrderBillingAddress__c,
            XC_Type__c,
            XC_Subtype__c,
            XC_LegalEntity__c,
            XC_Segment__c,
            XC_PaymentTransactionDetails__c,
            XC_PaymentTransactionID__c,
            XC_PaymentTransactionDate__c,
            NE__OptyId__r.XC_Contact__r.Email
            FROM NE__Order__c
            WHERE id in: searchIdList
        ]);

        return orderMap.values();
    }


    /**
     * Gets the order by account.
     *
     * @param mapUtil the map util
     * @return the order by account
     * @description Method to get Order List by Account
     */
    public static List<NE__Order__c> getOrderByAccount(Map<String, String> mapUtil){
        
        String accountId = mapUtil.get('AccountID');
        String recordType = (!String.isBlank(mapUtil.get('recordType'))) ? mapUtil.get('recordType') : 'Order';

        if(!String.isBlank(mapUtil.get('startDate'))){

            String startDate = mapUtil.get('startDate');
            String endDate = mapUtil.get('endDate');
            
            Map<Id, NE__Order__c> orderMap = new Map<Id, NE__Order__c>([
                SELECT 
                    Id,
                    Name,
                    NE__OptyId__c,
                    XC_Status__c,
                    //UniqueID,
                    NE__AccountId__c,
                    RecordTypeId,
                    RecordType.Name,
                    NE__BillingProfId__c,
                    NE__Contract_Account__c,
                    XC_Order_Tracking__c,
                    XC_Delivery_ID__c,
                    XC_Cancellation_Date__c,
                    NE__One_Time_Fee_Total__c,
                    NE__Recurring_Charge_Total__c,
                    B2WZC__ZStart_Date__c,
                    NE__Service_Account_Asset__c,
                    NE__Billing_Account_Asset__c,
                    XC_AdministrativeTasks__c,
                    XC_Mode_of_cancellation__c,
                    XC_Type_of_cancellation__c,
                    XC_DeliveryType__c,
                    XC_InstallationAddress__c,
                    XC_InstallationAddress__r.XC_PostalCode__c,
                    XC_PracticeNumber__c,
                    XC_FinancialApproval__c,
                    XC_PracticeStatus__c,
                    XC_FinancialRejectReason__c,
                    XC_Compliance_Approval__c, // il campo si chiama Compliance 1 Status
                    XC_ComplianceRejectReason__c,
                    NE__Description__c,
                    CreatedDate,
                    XC_Cost_Center__c,
                    XC_Company_Code__c,
                    NE__Type__c,
                    CurrencyIsoCode,
                    XC_OrderBillingAddress__c,
                    XC_Type__c,
                    XC_Subtype__c,
                    XC_LegalEntity__c,
                    XC_Segment__c,
                    XC_PaymentTransactionDetails__c,
                    XC_PaymentTransactionID__c,
                    XC_PaymentTransactionDate__c,
                    NE__OptyId__r.XC_Contact__r.Email
                FROM NE__Order__c
                WHERE NE__AccountId__c =: accountId AND CreatedDate >= :DateTime.valueOf(startDate) AND CreatedDate <= :DateTime.valueOf(endDate) AND RecordType.Name =: recordType
            ]);
            return orderMap.values();

        } else {
            Map<Id, NE__Order__c> orderMap = new Map<Id, NE__Order__c>([
                SELECT 
                    Id,
                    Name,
                    NE__OptyId__c,
                    XC_Status__c,
                    //UniqueID,
                    NE__AccountId__c,
                    RecordTypeId,
                    RecordType.Name,
                    NE__BillingProfId__c,
                    NE__Contract_Account__c,
                    XC_Order_Tracking__c,
                    XC_Delivery_ID__c,
                    XC_Cancellation_Date__c,
                    NE__One_Time_Fee_Total__c,
                    NE__Recurring_Charge_Total__c,
                    B2WZC__ZStart_Date__c,
                    NE__Service_Account_Asset__c,
                    NE__Billing_Account_Asset__c,
                    XC_AdministrativeTasks__c,
                    XC_Mode_of_cancellation__c,
                    XC_Type_of_cancellation__c,
                    XC_DeliveryType__c,
                    XC_InstallationAddress__c,
                    XC_InstallationAddress__r.XC_PostalCode__c,
                    XC_PracticeNumber__c,
                    XC_FinancialApproval__c,
                    XC_PracticeStatus__c,
                    XC_FinancialRejectReason__c,
                    XC_Compliance_Approval__c, // il campo si chiama Compliance 1 Status
                    XC_ComplianceRejectReason__c,
                    NE__Description__c,
                    CreatedDate,
                    XC_Cost_Center__c,
                    XC_Company_Code__c,
                    NE__Type__c,
                    CurrencyIsoCode,
                    XC_OrderBillingAddress__c,
                    XC_Type__c,
                    XC_Subtype__c,
                    XC_LegalEntity__c,
                    XC_Segment__c,
                    XC_PaymentTransactionDetails__c,
                    XC_PaymentTransactionID__c,
                    XC_PaymentTransactionDate__c,
                    NE__OptyId__r.XC_Contact__r.Email
                FROM NE__Order__c
                WHERE NE__AccountId__c =: accountId AND RecordType.Name =: recordType
            ]);

            return orderMap.values();
        }
    }


    /**
     * Gets the order by account.
     *
     * @param mapUtil the map util
     * @return the order by account
     * @description Method to get Order List by Account
     */
    public static List<NE__Order__c> getOrderByOpportunity(String opp){
        
        Map<Id, NE__Order__c> orderMap = new Map<Id, NE__Order__c>([
            SELECT Id,
            Name,
            NE__OptyId__c,
            XC_Status__c,
            //UniqueID,
            NE__AccountId__c,
            RecordTypeId,
            RecordType.Name,
            NE__BillingProfId__c,
            NE__Contract_Account__c,
            XC_Order_Tracking__c,
            XC_Delivery_ID__c,
            XC_Cancellation_Date__c,
            NE__One_Time_Fee_Total__c,
            NE__Recurring_Charge_Total__c,
            B2WZC__ZStart_Date__c,
            NE__Service_Account_Asset__c,
            NE__Billing_Account_Asset__c,
            XC_AdministrativeTasks__c,
            XC_Mode_of_cancellation__c,
            XC_Type_of_cancellation__c,
            XC_DeliveryType__c,
            XC_InstallationAddress__c,
            XC_InstallationAddress__r.XC_PostalCode__c,
            XC_PracticeNumber__c,
            XC_FinancialApproval__c,
            XC_PracticeStatus__c,
            XC_FinancialRejectReason__c,
            XC_Compliance_Approval__c, // il campo si chiama Compliance 1 Status
            XC_ComplianceRejectReason__c,
            NE__Description__c,
            CreatedDate,
            XC_Cost_Center__c,
            XC_Company_Code__c,
            NE__Type__c, 
            CurrencyIsoCode,
            XC_OrderBillingAddress__c,
            XC_Type__c,
            XC_Subtype__c,
            XC_LegalEntity__c,
            XC_Segment__c,
            XC_PaymentTransactionDetails__c,
            XC_PaymentTransactionID__c,
            XC_PaymentTransactionDate__c,
            NE__OptyId__r.XC_Contact__r.Email
            FROM NE__Order__c
            WHERE NE__OptyId__c =: opp
        ]);

        return orderMap.values();
    }

     /**
     * Gets the order by account.
     *
     * @param mapUtil the map util
     * @return the order by account
     * @description Method to get Order List by Account
     */
    public static List<NE__Order__c> getOrderByOpportunity(String opp, string Type){
        
        Map<Id, NE__Order__c> orderMap = new Map<Id, NE__Order__c>([
            SELECT Id,
            Name,
            NE__OptyId__c,
            XC_Status__c,
            //UniqueID,
            NE__AccountId__c,
            RecordTypeId,
            RecordType.Name,
            NE__BillingProfId__c,
            NE__Contract_Account__c,
            XC_Order_Tracking__c,
            XC_Delivery_ID__c,
            XC_Cancellation_Date__c,
            NE__One_Time_Fee_Total__c,
            NE__Recurring_Charge_Total__c,
            B2WZC__ZStart_Date__c,
            NE__Service_Account_Asset__c,
            NE__Billing_Account_Asset__c,
            XC_AdministrativeTasks__c,
            XC_Mode_of_cancellation__c,
            XC_Type_of_cancellation__c,
            XC_DeliveryType__c,
            XC_InstallationAddress__c,
            XC_InstallationAddress__r.XC_PostalCode__c,
            XC_PracticeNumber__c,
            XC_FinancialApproval__c,
            XC_PracticeStatus__c,
            XC_FinancialRejectReason__c,
            XC_Compliance_Approval__c, // il campo si chiama Compliance 1 Status
            XC_ComplianceRejectReason__c,
            NE__Description__c,
            CreatedDate,
            XC_Cost_Center__c,
            XC_Company_Code__c,
            NE__Type__c, 
            CurrencyIsoCode,
            RecordType.DeveloperName,
            XC_OrderBillingAddress__c,
            XC_Type__c,
            XC_Subtype__c,
            XC_LegalEntity__c,
            XC_Segment__c,
            XC_PaymentTransactionDetails__c,
            XC_PaymentTransactionID__c,
            XC_PaymentTransactionDate__c,
            NE__OptyId__r.XC_Contact__r.Email
            FROM NE__Order__c
            WHERE NE__OptyId__c =: opp AND RecordType.DeveloperName =: type AND (XC_Status__c =: 'Draft' OR XC_Status__c = 'Notified to client')
        ]);

        return orderMap.values();
    }



    /** 
     * Gets the order item by order id list.
     *
     * @param orderId the order id
     * @return the order item by order id list
     * @description Method to get Order Item List by OrderID
     */
    public static List<NE__OrderItem__c> getOrderItemByOrderIdList(List<Id> orderId){

        Map<Id, NE__OrderItem__c> orderItemMap = new Map<Id, NE__OrderItem__c>([
            SELECT id,
            XC_BPLIStatus__c,
            XC_BillingProfileLineItem__r.XC_PaymentMethod__c,
            NE__ProdId__c,
            NE__ProdName__c,
            XC_TranslatedProductName__c,
            NE__CatalogItem__c,
            NE__Qty__c,
            NE__BaseRecurringCharge__c,
            NE__BaseOneTimeFee__c,
            NE__StartDate__c,
            NE__OrderId__c,
            XC_ZQuoteId__c,
            NE__CatalogItem__r.NE__Engine_Code__c,
            NE__Catalog__r.XC_LIC_Name__c,
            XC_PaymentMethod__c,
            XC_PaymentType__c,
            XC_BillingModel__c,
            NE__Parent_Order_Item__c,
            NE__Bundle_Configuration__c,
            NE__BillingProfId__c,
            NE__CatalogItem__r.XC_Brand__c,
            NE__CatalogItem__r.XC_ConvergentBillType__c,
            XC_NumPrepayment__c,  
            NE__OrderId__r.XC_LegalEntity__c,
            NE__OrderId__r.XC_Segment__c,
            XC_Product_Type__c,
            XC_Product_Subtype__c,
            NE__Item_Code__c,
            XC_RelatedProduct__c,
            XC_BundleTotalOTAmount__c,
            XC_CreditAssignmentAmount__c,
            XC_CreditAssignmentCustomerAmount__c, 
            XC_CatalogItemCategory__c,
            NE__OrderId__r.NE__OptyId__r.XC_GasContract__c,
            XC_BillingProfileLineItem__r.XC_BillingProfile__c,
            NE__OrderId__r.NE__OptyId__r.XC_ElectricContract__c,
            NE__CatalogItem__r.NE__ProductId__r.XC_LIC_Product_Name__c,
            NE__Parent_Order_Item__r.NE__CatalogItem__r.NE__ProductId__r.XC_LIC_Product_Name__c,
            XC_CreditAssignmentSurvey__c , NE__OneTimeFeeOv__c ,NE__RecurringChargeOv__c, 
            XC_CreditAssignmentAvailable__c, XC_IncentiveName__c, NE__Bundle_Configuration__r.XC_IncentiveName__c,
            XC_DeliveryStatus__c, XC_DeliveryStatusList__c, XC_AllowablePaymentTypes__c,
            XC_ContractGenerated__c, 
            NE__Bundle_Configuration__r.XC_AllowablePaymentTypes__c, NE__Parent_Order_Item__r.XC_AllowablePaymentTypes__c,
            NE__Bundle_Configuration__r.XC_Product_Type__c, NE__Bundle_Configuration__r.XC_Product_Subtype__c,NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_ConvergentBillType__c,
            NE__Parent_Order_Item__r.XC_Product_Type__c, NE__Parent_Order_Item__r.XC_Product_Subtype__c, NE__Parent_Order_Item__r.NE__CatalogItem__r.XC_ConvergentBillType__c,
            NE__OrderId__r.NE__OptyId__r.XC_Contact__r.Email,
            (SELECT Id, NE__Status__c, Name FROM Assets__r),
            (SELECT  Name, NE__Value__c, NE__Old_Value__c, NE__FamPropId__c, IsDeleted, NE__FamPropExtId__c, XC_DeveloperName__c FROM NE__Order_Item_Attributes__r),
            (SELECT XC_StepLabel__c, XC_Step_Order__c, XC_Status__c FROM Provisioning_Steps__r ORDER BY XC_Step_Order__c ASC),
            (SELECT Id, Name, NE__Order_Item__c, NE__Asset_update_key__c, NE__Code__c, NE__Discount_Item__c, NE__End_Date__c,
            NE__One_Time_Percentage__c, NE__One_Time_Price__c, NE__One_Time_Value__c, NE__Reason__c, NE__Recurring_Percentage__c,
            NE__Recurring_Price__c, NE__Recurring_Value__c, NE__Sequence__c, NE__Start_Date__c, NE__Status__c, NE__Type__c FROM NE__Order_Item_Discount__r)
            FROM NE__OrderItem__c
            WHERE NE__OrderId__c in: orderId 
            //AND XC_Product_Type__c != 'Technical' 
        ]);
        
        return orderItemMap.values();
    } 


    /**
     * Gets the order item by order.
     *
     * @param orderId the order id
     * @param ordItemIds the ord item ids
     *@param ordItemAtrrIds
     * @return the order item by order
     * @description Method to get Order Item Map
     */
    public static Map<id, NE__OrderItem__c> getOrderItemByOrder(String orderId, Set<Id> ordItemIds, Set<Id> ordItemAtrrIds){

        Map<Id, NE__OrderItem__c> mapIdOrdItem = new  Map<id, NE__OrderItem__c>([
            SELECT Id, XC_BPLIStatus__c, XC_BillingProfileLineItem__r.XC_PaymentMethod__c, NE__OrderId__r.XC_LegalEntity__c, NE__OrderId__r.XC_Segment__c, XC_NumPrepayment__c, XC_Product_Type__c, XC_Product_Subtype__c, NE__CatalogItem__r.NE__ProductId__r.XC_LIC_Product_Name__c,
            NE__Parent_Order_Item__c, NE__Parent_Order_Item__r.NE__CatalogItem__r.NE__ProductId__r.XC_LIC_Product_Name__c,
            XC_DeliveryStatus__c, XC_DeliveryStatusList__c,
            XC_ContractGenerated__c,
            (SELECT Id, NE__Value__c, NE__Old_Value__c, NE__FamPropExtId__c, XC_DeveloperName__c  FROM NE__Order_Item_Attributes__r WHERE Id IN: ordItemAtrrIds)
            FROM NE__OrderItem__c
            WHERE NE__OrderId__c =: orderId AND Id IN: ordItemIds
        ]);
                
        return mapIdOrdItem;
    }


    /**
     * Gets the order.
     *
     * @param orderId the order id
     * @return the order
     * @description Method to get Order from ID
     */
     /*
    public static List<NE__Order__c> getOrder(String orderId){

        Set<String> setFields = new Set<String>{'Id'};
        return (List<NE__Order__c>) XC_UTIL_Query.selectFieldsList(setFields, orderId);
    }
    */

    /**
     * Gets the asset.
     * @author Nicola Mariniello - nmariniello@delotte.it & Luisana Rocco - lrocco@deloitte.it 
     * @description Method to get Asset
     * @param  assetIds -> assetId list to query
     * @return Map with assetId as Key and Asset as value
     */
    public static Map<Id, Asset> getAssetHistoryAsset(List<Id> assetIds){
        
        Map<Id, Asset> assetMap = new Map<Id, Asset>([
            SELECT id, (SELECT CreatedDate,NewValue, Field  FROM Histories WHERE Field = 'NE__Status__c' ORDER BY CreatedDate asc)
            FROM Asset 
            WHERE id IN: assetIds
        ]);
        
        return assetMap; 
    }

    /**
     * Gets the work order
     * @author Simone Trenta - strenta@deloitte.it
     * @description Method to get workorder
     * @param ordId the order id 
     * @return the workorders
     */
    public static List<WorkOrder> getWorkOrder(List<Id> ordId){
        
        Map<Id,WorkOrder> wos = new Map<Id,WorkOrder>([SELECT id, XC_WorkTypeCategory__c, Status, xc_configuration__c, XC_NumberWorkOrdersDI__c, (select id from ChildWorkOrders) FROM workorder WHERE xc_configuration__c IN: ordId]);
        
        return wos.values(); 
    }

    /**
     * getPaymentTypesList
     * @author Simone Trenta - strenta@deloitte.it
     * @description Method to get payment types
     * @return the XC_DocumentByPaymentMethod__mdt
     */
    public static List<XC_DocumentByPaymentMethod__mdt> getPaymentTypesList(){
        
        Map<Id, XC_DocumentByPaymentMethod__mdt> mdt = new Map<Id, XC_DocumentByPaymentMethod__mdt>([
            SELECT id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, XC_PaymenMethod__c, XC_Legal_Entity__c, XC_PrePayment__c 
            FROM XC_DocumentByPaymentMethod__mdt
            WHERE XC_PrePayment__c = 'Y' ]);   

        return mdt.values();
    }

    /**
     * getDocumentationCharacterist
     * @author Giuseppe Di Bonito - gdibonito@deloitte.it
     * @description Method to get DocumentationCharacterist
     * @return the list of DocumentationCharacterist
     */
    public static List<NE__DocumentationCharacterist__c> getDocCharact(List<String> prodIds){
        
        Map<Id, NE__DocumentationCharacterist__c> dcs = new Map<Id, NE__DocumentationCharacterist__c>([
            SELECT id, NE__Product__c, name, NE__Value__c
            FROM NE__DocumentationCharacterist__c
            WHERE NE__Product__c in :prodIds]);   

        return dcs.values();
    }

        /**
     * getDocumentationCharacterist of Partner
     * @author Dario Tramontin- dtramontin@deloitte.it
     * @description Method to get DocumentationCharacterist filter by Partener
     * @return the map of DocumentationCharacterist
     */
    public static Map<Id, NE__DocumentationCharacterist__c> getDocCharactPartner(List<String> prodIds){

        Map<Id, NE__DocumentationCharacterist__c> dcs = new Map<Id, NE__DocumentationCharacterist__c>([
                SELECT id, NE__Product__c, name, NE__Value__c
                FROM NE__DocumentationCharacterist__c
                WHERE NE__Product__c in :prodIds and Name = 'Partner'
        ]);        

        return dcs;
    }

    /**
     * getDocumentType
     * @author Giuseppe Di Bonito - gdibonito@deloitte.it
     * @description Method to get document type
     * @return the list of DocumentationCharacterist
     */
    public static List<XC_DocumentType__c> getDocumentType(List<String> orderIds){
        
        Map<Id, XC_DocumentType__c> dcs = new Map<Id, XC_DocumentType__c>([
            SELECT id, Category__c, XC_Configuration__c, numberOfFiles__c
            FROM XC_DocumentType__c
            WHERE XC_Configuration__c in: orderIds
            ] 
        );

        return dcs.values();
    }


    /**
     * GetOIwithSameBPDraft
     *
     * @param ccbillingProfileIds the billing profile id list
     * @param legalEntity the legalEntity
     * @return Map<Id, NE__OrderItem__c>
     * @description Method to get the order item with same BP with status draft
     */
    public static Map<Id, NE__OrderItem__c> getOIwithSameBPDraft (Set<Id> ccbillingProfileIds, String legalEntity){
        String rtOrder = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        String rtOpty = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Opty').getRecordTypeId();
        Map<Id, NE__OrderItem__c> sameOiMap = new Map<Id, NE__OrderItem__c>([SELECT Id  FROM NE__OrderItem__c WHERE 
                                                                            XC_BillingProfileLineItem__r.XC_BillingProfile__c  IN: ccbillingProfileIds AND XC_BillingProfileLineItem__r.XC_Status__c =: Label.XC_CL_BillingProfileStatus_Draft AND
                                                                            XC_PaymentMethod__c =: Label.XC_CL_Credit_Card AND NE__OrderId__r.XC_LegalEntity__c =: legalEntity AND (NE__OrderId__r.RecordTypeId =: rtOrder OR NE__OrderId__r.RecordTypeId =: rtOpty) AND NE__OrderId__r.NE__Type__c =: Label.XC_CL_Configuration_TypeInOrder]);
        return sameOiMap; 
    }
}