/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 17/04/2019
* @date Modification dd/mm/yyyy
* @description XC_UTIL_ComplianceMaster_D - DAO Class
*/ 

public without sharing class XC_UTIL_ComplianceMaster_D {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_ComplianceMaster_D');

    /** @description Wrapper for Compliance Type1 */
    public class ComplianceTypeC1 {
        public List<String> salesPartnerList = new List<String>();
        public List<String> typeList = new List<String>();
        public List<String> productCategoryList = new List<String>();
        public List<String> originlist = new List<String>();
        public List<Boolean> auditList = new List<Boolean>();
        public List<Decimal> probabilityList = new List<Decimal>(); 
        public List<String> receivingChannelList = new List<String>(); 
    }

    /** @description Wrapper for Compliance Type2 */
    public class ComplianceTypeC2 {
        public List<String> salesPartnerList = new List<String>();
        public List<String> typeList = new List<String>();
        public List<String> originlist = new List<String>();
        public List<String> productCategoryList = new List<String>();
        public List<String> promotionsList = new List<String>();
        public List<String> paymentMethodList = new List<String>();
        public List<String> billingModelList = new List<String>();
        public List<Boolean> energyList = new List<Boolean>();
        public List<Boolean> auditList = new List<Boolean>();
        public List<Decimal> probabilityList = new List<Decimal>();
        public List<String> signatureAgentList = new List<String>();
        public List<String> receivingChannelList = new List<String>(); 
    }

    /** @description Wrapper for Compliance Type3 */
    public class ComplianceTypeC3 {
        public List<String> salesPartnerList = new List<String>();
        public List<String> typeList = new List<String>();
        public List<String> originlist = new List<String>();
        public List<String> productCategoryList = new List<String>();
        public List<String> promotionsList = new List<String>();
        public List<String> paymentMethodList = new List<String>();
        public List<String> billingModelList = new List<String>();
        public List<String> installerPartnerList = new List<String>(); 
        public List<Boolean> energyList = new List<Boolean>();
        public List<Boolean> auditList = new List<Boolean>();
        public List<Decimal> probabilityList = new List<Decimal>();
        public List<String> signatureAgentList = new List<String>();
        public List<String> syncStockGloviaList = new List<String>();
        public List<String> receivingChannelList = new List<String>(); 
    }

    /** @description Wrapper for Compliance Type4 */
    public class ComplianceTypeC4 {
        public List<String> typeList = new List<String>();
        public List<String> originlist = new List<String>();
        public List<String> productCategoryList = new List<String>();
        public List<Boolean> auditList = new List<Boolean>();
        public List<Decimal> probabilityList = new List<Decimal>();
        public List<String> receivingChannelList = new List<String>(); 
    }


    /** @description Wrapper for Compliance Type > Work Order Validation */
    public class ComplianceWorkOrderValidation {
        public Set<String> woTypes = new Set<String>();
        public Set<String> woStatus = new Set<String>();
        public Set<String> woSubStatus = new Set<String>();
        public Set<String> saSubStatus = new Set<String>();
        public Set<Id> commercialProducts = new Set<Id>();
        public Set<Id> calatogueCategories = new Set<Id>();
        public Set<String> serviceTypes = new Set<String>();
        public Set<Decimal> additionalCosts = new Set<Decimal>();
    }


    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 17/04/2019
    * @description Get query result for OrderItem
    * @param listConfigurationItemId - List<Id>
    * @return List<NE__OrderItem__c>
    */ 
    public static List<NE__OrderItem__c> getQueryOrderItems(List<Id> listConfigurationItemId) {
        String fieldsName = String.escapeSingleQuotes(XC_UTIL_SObject.selectAllFieldsGetSelect('NE__OrderItem__c'));
        String query = String.escapeSingleQuotes('SELECT Id, XC_BillingModel__c, NE__Bundle_Configuration__c , XC_PaymentMethod__c,XC_CountryFormula__c, NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c,  NE__OrderId__r.NE__OptyId__r.XC_Source__c, NE__OrderId__r.NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c, NE__BillingProfId__r.NE__Payment__c, NE__OrderId__r.NE__OptyId__r.XC_Contact__c, NE__OrderId__r.NE__OptyId__r.XC_ReceivingChannel__c, ' +
                                                '(SELECT Id, Name, NE__Value__c, XC_DeveloperName__c FROM NE__Order_Item_Attributes__r), ' +
                                                '(SELECT Id,XC_InstallationAssignedResource__r.XC_Account__c FROM Assets__r) ' +
                                                'FROM NE__OrderItem__c WHERE id IN : listConfigurationItemId');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ getQueryComplianceMasterC1 ---> ' + query);
        return Database.query(query);
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 17/04/2019
    * @description Get result query for Compliance Master Type C1
    * @param complianceWrapperC1 - ComplianceTypeC1
    * @return List<XC_ComplianceMaster__c>
    */ 
    public static List<XC_ComplianceMaster__c> getQueryComplianceMasterC1(ComplianceTypeC1 complianceWrapperC1) {
        List<String> salesPartnerList = complianceWrapperC1.salesPartnerList;
        List<String> typeList = complianceWrapperC1.typeList;
        List<String> productCategoryList = complianceWrapperC1.productCategoryList;
        List<String> originlist = complianceWrapperC1.originlist;
        List<String> receivingChannelList = complianceWrapperC1.receivingChannelList;        
        //List<Decimal> probabilityList = complianceWrapperC1.probabilityList;
        //List<Boolean> auditList = complianceWrapperC1.auditList;
        String query;
        if(!Schema.sObjectType.XC_ComplianceMaster__c.isAccessible()){
            return new List<XC_ComplianceMaster__c>(); 
        }
        query = String.escapeSingleQuotes('SELECT Id, XC_ReceivingChannel__c, XC_Probability__c, Name,XC_BillingModel__c,XC_ExtrasCost__c,XC_Mandatory__c,XC_PaymentMethod__c, XC_ComplianceType__c, XC_ProductCategory__c,XC_PromotionId__c,XC_Queue__c,XC_SalesPartnerId__c, XC_InstallerPartnerId__c, XC_Country__c, XC_Source__c,XC_SkipCaseCreation__c ' +
                        'FROM XC_ComplianceMaster__c ' +
                        'WHERE XC_ComplianceType__c IN: typeList ' +
                        'AND XC_ProductCategory__c IN: productCategoryList ');
                        // 'AND XC_Audit__c IN: auditList' +
                        //'AND XC_Source__c IN: originlist' 
        if(originlist[0] != null) {
            query = String.escapeSingleQuotes(query + 'AND (XC_Source__c IN: originlist OR XC_Source__c = null)');
        }
        if(salesPartnerList[0] != null) {
            query = String.escapeSingleQuotes(query + 'AND (XC_SalesPartnerId__c IN: salesPartnerList OR XC_SalesPartnerId__c = null)');
        }
        if(receivingChannelList[0] != null) {
            query = String.escapeSingleQuotes(query + 'AND (XC_ReceivingChannel__c IN: receivingChannelList OR XC_ReceivingChannel__c = null)');
        }        
        query = String.escapeSingleQuotes(query + ' order by XC_OrderOfEvaluation__c asc');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ getQueryComplianceMasterC1 ---> ' + query);
        return Database.query(query);
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 17/04/2019
    * @description Get result query for Compliance Master Type C2
    * @param compliance2Wrapper - ComplianceTypeC2
    * @return List<XC_ComplianceMaster__c>
    */ 
    public static List<XC_ComplianceMaster__c> getQueryComplianceMasterC2(ComplianceTypeC2 compliance2Wrapper) {
        List<String> salesPartnerList = compliance2Wrapper.salesPartnerList;
        List<String> typeList = compliance2Wrapper.typeList;
        List<String> originlist = compliance2Wrapper.originlist;
        List<String> productCategoryList = compliance2Wrapper.productCategoryList;
        List<String> promotionsList = compliance2Wrapper.promotionsList;
        List<String> paymentMethodList = compliance2Wrapper.paymentMethodList;
        List<String> billingModelList = compliance2Wrapper.billingModelList;
        List<String> receivingChannelList = compliance2Wrapper.receivingChannelList;          
        //List<Boolean> energyList = compliance2Wrapper.energyList;
        //List<Boolean> auditList = compliance2Wrapper.auditList;
        //List<Decimal> probabilityList = compliance2Wrapper.probabilityList;
        //List<String> signatureAgentList = compliance2Wrapper.signatureAgentList;
        if(!Schema.sObjectType.XC_ComplianceMaster__c.isAccessible()){
            return new List<XC_ComplianceMaster__c>();
        }
        String query = String.escapeSingleQuotes('SELECT Id, XC_ReceivingChannel__c, XC_Probability__c, Name,XC_BillingModel__c,XC_ExtrasCost__c,XC_Mandatory__c,XC_PaymentMethod__c, XC_ComplianceType__c, XC_ProductCategory__c,XC_PromotionId__c,XC_Queue__c,XC_SalesPartnerId__c, XC_InstallerPartnerId__c, XC_Country__c, XC_Source__c,XC_SkipCaseCreation__c ' +
                        'FROM XC_ComplianceMaster__c ' +
                        'WHERE XC_ComplianceType__c IN: typeList ' +
                        'AND XC_ProductCategory__c IN: productCategoryList ');
                        //'AND XC_ExtrasCost__c IN: extraCostList' +
                        //'AND XC_Source__c IN: originlist ' +
                        //'AND XC_BillingModel__c IN: billingModelList ' +
                        //'AND XC_PaymentMethod__c IN: paymentMethodList ' +
                        //'AND XC_Energy__c IN: energyList' +
                        //'AND XC_Audit__c IN: auditList' +

        if(billingModelList[0] != null) {
            query = String.escapeSingleQuotes(query + 'AND (XC_BillingModel__c IN: billingModelList OR XC_BillingModel__c = null)');
        }
        if(paymentMethodList[0] != null) {
            query = String.escapeSingleQuotes(query + 'AND (XC_PaymentMethod__c IN: paymentMethodList OR XC_PaymentMethod__c = null)');
        }
        if(originlist[0] != null) {
            query = String.escapeSingleQuotes(query + 'AND (XC_Source__c IN: originlist OR XC_Source__c = null)');
        }
        if(salesPartnerList[0] != null) {
            query = String.escapeSingleQuotes(query + 'AND (XC_SalesPartnerId__c IN: salesPartnerList OR XC_SalesPartnerId__c = null)');
        }
        if(promotionsList[0] != null) {
            query = String.escapeSingleQuotes(query + 'AND (XC_PromotionId__c IN: promotionsList OR XC_PromotionId__c = null)');
        }
        if(receivingChannelList[0] != null) {
            query = String.escapeSingleQuotes(query + 'AND (XC_ReceivingChannel__c IN: receivingChannelList OR XC_ReceivingChannel__c = null)');
        }           
        /*
        if(signatureAgentList[0] != null) {
            query = String.escapeSingleQuotes(query + 'AND XC_SignaturePartner__c  IN: signatureAgentList ');
        }    
        */
        query = String.escapeSingleQuotes(query + ' order by XC_OrderOfEvaluation__c asc');
        return Database.query(query);
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 17/04/2019
    * @description Get result query for Compliance Master Type C3
    * @param compliance3Wrapper - ComplianceTypeC3
    * @return List<XC_ComplianceMaster__c>
    */ 
    public static List<XC_ComplianceMaster__c> getQueryComplianceMasterC3(ComplianceTypeC3 compliance3Wrapper) {
        List<String> salesPartnerList = compliance3Wrapper.salesPartnerList;
        List<String> typeList = compliance3Wrapper.typeList;
        List<String> originlist = compliance3Wrapper.originlist;
        List<String> productCategoryList = compliance3Wrapper.productCategoryList;
        List<String> promotionsList = compliance3Wrapper.promotionsList;
        List<String> paymentMethodList = compliance3Wrapper.paymentMethodList;
        List<String> billingModelList = compliance3Wrapper.billingModelList;
        List<String> installerPartnerList = compliance3Wrapper.installerPartnerList;
        List<String> receivingChannelList = compliance3Wrapper.receivingChannelList;         
        //List<Boolean> energyList = compliance3Wrapper.energyList;
        //List<Boolean> auditList = compliance3Wrapper.auditList;
        //List<String> signatureAgentList = compliance3Wrapper.signatureAgentList;

        if(!Schema.sObjectType.XC_ComplianceMaster__c.isAccessible()){
            return new List<XC_ComplianceMaster__c>();
        }
        String query = String.escapeSingleQuotes('SELECT Id, XC_ReceivingChannel__c, XC_Probability__c, Name,XC_BillingModel__c,XC_ExtrasCost__c,XC_Mandatory__c,XC_PaymentMethod__c, XC_ComplianceType__c, XC_ProductCategory__c,XC_PromotionId__c,XC_Queue__c,XC_SalesPartnerId__c, XC_InstallerPartnerId__c, XC_Country__c, XC_Source__c,XC_SkipCaseCreation__c ' +
                        'FROM XC_ComplianceMaster__c ' +
                        'WHERE XC_ComplianceType__c IN: typeList ' +
                        'AND XC_ProductCategory__c IN: productCategoryList ');
                        // 'AND XC_Source__c IN: originlist ' +
                        //'AND XC_BillingModel__c IN: billingModelList ' +
                        //'AND XC_PaymentMethod__c IN: paymentMethodList '+
                        //'AND XC_ExtrasCost__c IN: extraCostList '+
                        //'AND XC_Energy__c IN: energyList' +
                        //'AND XC_Audit__c IN: auditList' + 
                        //'AND XC_Probability__c  IN: probabilityList'
        if(billingModelList[0] != null) {
            query = String.escapeSingleQuotes(query + 'AND (XC_BillingModel__c IN: billingModelList OR XC_BillingModel__c = null) ');
        }
        if(paymentMethodList[0] != null) {
            query = String.escapeSingleQuotes(query + 'AND (XC_PaymentMethod__c IN: paymentMethodList OR XC_PaymentMethod__c = null) ');
        }
        if(originlist[0] != null) {
            query = String.escapeSingleQuotes(query + 'AND (XC_Source__c IN: originlist OR XC_Source__c = null) ');
        }
        if(salesPartnerList[0] != null) {
            query = String.escapeSingleQuotes(query + 'AND (XC_SalesPartnerId__c IN: salesPartnerList OR XC_SalesPartnerId__c = null)');
        }
        if(promotionsList[0] != null) {
            query = String.escapeSingleQuotes(query + 'AND (XC_PromotionId__c IN: promotionsList OR XC_PromotionId__c = null)');
        }
        if(installerPartnerList[0] != null) {
            query = String.escapeSingleQuotes(query + 'AND (XC_InstallerPartnerId__c IN: installerPartnerList OR XC_InstallerPartnerId__c = null)');
        }
        if(receivingChannelList[0] != null) {
            query = String.escapeSingleQuotes(query + 'AND (XC_ReceivingChannel__c IN: receivingChannelList OR XC_ReceivingChannel__c = null)');
        }        
        /*
        if(signatureAgentList[0] != null) {
            query = String.escapeSingleQuotes(query + 'AND XC_SignaturePartner__c  IN: signatureAgentList ');
        }    
        */
        query = String.escapeSingleQuotes(query + ' order by XC_OrderOfEvaluation__c asc');
        return Database.query(query);
    }


    /**
    * @author Anna Maria Rosanova - annamaria.rosanova@nttdata.com
    * @date Creation 30/07/2019
    * @description Get result query for Compliance Master Type C4
    * @param compliance4Wrapper - ComplianceTypeC4
    * @return List<XC_ComplianceMaster__c>
    */ 
    public static List<XC_ComplianceMaster__c> getQueryComplianceMasterC4(ComplianceTypeC4 compliance4Wrapper) {
        List<String> typeList = compliance4Wrapper.typeList;
        List<String> originlist = compliance4Wrapper.originlist;
        List<String> productCategoryList = compliance4Wrapper.productCategoryList;
        List<String> receivingChannelList = compliance4Wrapper.receivingChannelList;         
        if(!Schema.sObjectType.XC_ComplianceMaster__c.isAccessible()){
            return new List<XC_ComplianceMaster__c>();
        }
        String query = String.escapeSingleQuotes('SELECT Id,XC_ReceivingChannel__c, XC_Probability__c, Name,XC_BillingModel__c,XC_ExtrasCost__c,XC_Mandatory__c,XC_PaymentMethod__c, XC_ComplianceType__c, XC_ProductCategory__c,XC_PromotionId__c,XC_Queue__c,XC_SalesPartnerId__c, XC_InstallerPartnerId__c, XC_Country__c, XC_Source__c,XC_SkipCaseCreation__c ' +
                        'FROM XC_ComplianceMaster__c ' +
                        'WHERE XC_ComplianceType__c IN: typeList ' +
                        'AND XC_ProductCategory__c IN: productCategoryList ');
                        //'AND XC_ExtrasCost__c IN: extraCostList' + 
                        //'AND XC_Source__c IN: originlist ' +
                        //'AND XC_BillingModel__c IN: billingModelList ' +
                        //'AND XC_PaymentMethod__c IN: paymentMethodList ' +
                        //'AND XC_Energy__c IN: energyList' +
                        //'AND XC_Audit__c IN: auditList' 
        
        if(originlist[0] != null) {
            query = String.escapeSingleQuotes(query + 'AND (XC_Source__c IN: originlist OR  XC_Source__c = null) ');
        }
        if(receivingChannelList[0] != null) {
            query = String.escapeSingleQuotes(query + 'AND (XC_ReceivingChannel__c IN: receivingChannelList OR XC_ReceivingChannel__c = null)');
        }          
        query = String.escapeSingleQuotes(query + ' order by XC_OrderOfEvaluation__c asc');
        return Database.query(query);
    }


    /**
    * @author Monica Cutillo - monica.cutillo@nttdata.com
    * @date Creation 04/09/2019
    * @description Get result query for Compliance Master Type Work Order Validation
    * @param complianceWOValidation - ComplianceWorkOrderValidation
    * @return List<XC_ComplianceMaster__c>
    */ 
    public static List<XC_ComplianceMaster__c> getQueryComplianceMasterWOValidation(ComplianceWorkOrderValidation complianceWOValidation) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'GET ComplianceMasterWOValidatio input=' + complianceWOValidation);
        Id recTypeId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_ComplianceMasterRT_WOValidation).getRecordTypeId();
        Map<Id, XC_ComplianceMaster__c> complianceData = new Map<Id, XC_ComplianceMaster__c>(
            [SELECT Id, Name, RecordTypeId, XC_OrderOfEvaluation__c, XC_ComplianceTypePicklist__c, XC_Probability__c, XC_WorkOrder_Status__c, XC_WorkType__c, 
                    XC_WorkOrder_SubStatus__c, XC_ServiceAppointment_SubStatus__c, XC_CommercialProductId__c, XC_CatalogCategoryId__c, 
                    XC_CommercialCode__c, XC_Urgent_Repair__c, XC_WarrantyPossibility__c, XC_Digitized__c, XC_ServiceType__c, 
                    XC_MaintenanceAndRepair__c, XC_AdditionalCostAmount__c 
               FROM XC_ComplianceMaster__c 
              WHERE RecordTypeId =: recTypeId 
                AND XC_ComplianceTypePicklist__c =: Label.XC_CL_ComplianceType_WorkOrderValidation
                AND XC_WorkOrder_Status__c IN: complianceWOValidation.woStatus 
                AND XC_WorkType__c IN: complianceWOValidation.woTypes
                AND XC_WorkOrder_SubStatus__c IN: complianceWOValidation.woSubStatus
                AND XC_ServiceAppointment_SubStatus__c IN: complianceWOValidation.saSubStatus
                AND XC_CommercialProductId__c IN: complianceWOValidation.commercialProducts
                AND XC_CatalogCategoryId__c IN: complianceWOValidation.calatogueCategories
                AND XC_ServiceType__c IN: complianceWOValidation.serviceTypes
                AND XC_AdditionalCostAmount__c IN: complianceWOValidation.additionalCosts
                ORDER BY XC_OrderOfEvaluation__c ASC ]
        );
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'getQueryComplianceMasterWOValidation result=' + complianceData.values());
        return complianceData.values();
    }

    /**
    * @author Monica Cutillo - monica.cutillo@nttdata.com
    * @date Creation 06/09/2019
    * @description Get result query Map of ServiceResource from its ids
    * @param srIds - ServiceResource ids
    * @return Map<Id,ServiceResource>
    */ 
    public static Map<Id,ServiceResource> getDataMapServiceResouces(Set<Id> srIds){
        return new Map<Id,ServiceResource>(
            [SELECT id, Account.Id, Account.XC_CommercialCode__c 
               FROM ServiceResource 
              WHERE Id IN: srIds ]
        );
    }

}