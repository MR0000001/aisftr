/**
 * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com &
 *         Marco Rosa - marco.rosa@nttdata.com &
 *         Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @date Creation 11/01/2019
 * @date Modification dd/mm/yyyy
 * @description XC_UTIL_ComplianceMaster --- Util Compliance Master
 */
public without sharing class XC_UTIL_ComplianceMaster {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_ComplianceMaster');

    private static List<String> typeList = new List<String>();
    private static List<String> productCategoryList = new List<String>();
    private static List<String> salesPartnerList = new List<String>();
    private static List<String> originlist = new List<String>();
    private static List<String> billingModelList = new List<String>();
    private static List<String> paymentMethod = new List<String>();
    private static List<Decimal> extraCostList = new List<Decimal>();
    private static List<String> paymentMethodList = new List<String>();
    private static List<String> installerPartnerList = new List<String>();
    private static List<String> countryValueList = new List<String>();
    private static List<String> promotionsList = new List<String>();
    private static List<Boolean> energyList = new List<Boolean>();
    private static List<Boolean> auditList = new List<Boolean>();
    private static List<Decimal> probabilityList = new List<Decimal>();
    private static List<String> signatureAgentList = new List<String>();
    private static List<String> syncStockGloviaList = new List<String>();
    private static List<String> receivingChannelList = new List<String>();

    /** @description Compliance Wrapper */
    public class ComplianceWrapper {
        public String country;
        public String type;
        public String productCategory;
        public String salesPartner;
        public String origin;
        public String billingModel;
        public String paymentMethod;
        public String promotions;
        public Decimal extraCost;
        public String installerPartner;
        public Boolean energy;
        public Boolean audit;
        public Decimal probability;
        public String signatureAgent;
        public String syncStockGlovia;
        public Boolean probabilityChecked = false;
        public String receivingChannel;
    }

    /** @description Compliance Wrapper Result */
    public class ComplianceWrapperResult {
        public Boolean check = false;
        public String queue = null;
        public Boolean mandatory = false;
        public String complianceType = '';
        public XC_ComplianceMaster__c complianceMaster = new XC_ComplianceMaster__c();
    }

    /** @description ComplianceWrapperCheck - Wrapper for Compliance Master for check fields */
    public class ComplianceWrapperCheck {
        public String type;
        public Map<Id, ComplianceWrapperResult> mapConfItemTemplateName;
        public NE__OrderItem__c confItem;
        public List<XC_ComplianceMaster__c> listCompliances;
        public Map<Id, ComplianceWrapper> mapConfItemIdWrapper;
        public List<NE__OrderItem__c> listConfItemNotChecked = new List<NE__OrderItem__c>();
    }

    /** @description Wrapper for Populate Compliance Wrapper Result */
    public class PopulateComplianceResultWrapper {
        public ComplianceWrapperResult cwr;
        public ComplianceWrapper wrapper;
        public ComplianceWrapperCheck wrapperCheck;
        public XC_ComplianceMaster__c complianceMaster;
        public Boolean jump = false;
    }

    /** @description ComplianceValidationWrapperCheck - Wrapper for Compliance Master Validation, to check fields */
    public class ComplianceValidationWrapperCheck {
        public List<WorkOrder> woTovalidate = new List<WorkOrder>();
        public List<String> saSubStatus = new List<String>();
        public List<Id> commercialProductsIds = new List<Id>();
        public List<Decimal> additionalCosts = new List<Decimal>();
    }


    /**
    * @author Marco Rosa - marco.rosa@nttdata.com
    * @date 05/09/2019
    * @description Method to get Document Compliance Master
    * @param type - String
    * @param configurationId - Id
    * @return Map<Id, ComplianceWrapperResult>
    **/
    public static Map<Id, ComplianceWrapperResult> getDocumentComplianceMaster(String type, Id configurationId) {
        if(!Schema.sObjectType.NE__OrderItem__c.isAccessible()) {
            return new Map<Id, ComplianceWrapperResult>(); 
        }
        List<NE__OrderItem__c> listConfItem = [
            SELECT Id, NE__OrderId__r.NE__OptyId__r.XC_Contact__c FROM NE__OrderItem__c
            WHERE NE__OrderId__c =: configurationId AND XC_IsAProduct__c = true
        ];
        List<Id> listIds = XC_UTIL_SObject.getIds(listConfItem);
        return getComplianceMaster(type, listIds);
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com
     * @date 05/09/2019
     * @description Method to get ComplianceMaster for WOValidation type
     * @param complianceWr ComplianceValidationWrapperCheck wrapper
     * @return Map<Id, XC_ComplianceMaster__c>
     **/
    public static List<XC_ComplianceMaster__c> getWOValidationComplianceMaster(ComplianceValidationWrapperCheck complianceWr){
        if(complianceWr.woTovalidate == null || complianceWr.woTovalidate.isEmpty()){
            return new List<XC_ComplianceMaster__c>();
        }

        List<String> woStatus = XC_UTIL_Sobject.getListFieldValues(complianceWr.woTovalidate, 'Status');
        List<String> woTypes = XC_UTIL_Sobject.getListFieldValues(complianceWr.woTovalidate, 'XC_WorkTypeCategory__c');
        List<String> woSubStatus = XC_UTIL_Sobject.getListFieldValues(complianceWr.woTovalidate, 'XC_StatusReason__c'); //'XC_SubStatus__c' /*MC ESCEP-2120*/
        List<String> serviceTypes = XC_UTIL_Sobject.getListFieldValues(complianceWr.woTovalidate, 'XC_ServiceTypeGP__c');
        List<Id> calatogueCategories = XC_UTIL_Sobject.getListFieldValues(complianceWr.woTovalidate, 'XC_CatalogCategory__c');
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@WO Valid@@@ woStatus=' + woStatus);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@WO Valid@@@ woTypes=' + woTypes);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@WO Valid@@@ woStatusReason=' + woSubStatus);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@WO Valid@@@ serviceTypes=' + serviceTypes);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@WO Valid@@@ calatogueCategories=' + calatogueCategories);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@WO Valid@@@ saSubStatus=' + complianceWr.saSubStatus);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@WO Valid@@@ commercialProducts=' + complianceWr.commercialProductsIds);

        XC_UTIL_ComplianceMaster_D.ComplianceWorkOrderValidation complianceWOValidation = new XC_UTIL_ComplianceMaster_D.ComplianceWorkOrderValidation();
        complianceWOValidation.woStatus = new Set<String>(woStatus);
        complianceWOValidation.woTypes = new Set<String>(woTypes);
        complianceWOValidation.woSubStatus = new Set<String>(woSubStatus);
        complianceWOValidation.serviceTypes = new Set<String>(serviceTypes);
        complianceWOValidation.commercialProducts = new Set<Id>(complianceWr.commercialProductsIds);
        complianceWOValidation.calatogueCategories = new Set<Id>(calatogueCategories);
        complianceWOValidation.saSubStatus = new Set<String>(complianceWr.saSubStatus);
        complianceWOValidation.additionalCosts = new Set<Decimal>(complianceWr.additionalCosts);
        
        addSpecialFilterValues(complianceWOValidation);
        
        return XC_UTIL_ComplianceMaster_D.getQueryComplianceMasterWOValidation(complianceWOValidation);
    }

    /**
    * @author Monica Cutillo - monica.cutillo@nttdata.com
    * @description Method to add on ComplianceWorkOrderValidation special value as '*' or null
    * @param complianceWOValidation object to modify
    **/
    private static void addSpecialFilterValues(XC_UTIL_ComplianceMaster_D.ComplianceWorkOrderValidation complianceWOValidation){
        complianceWOValidation.woStatus.add('*');
        complianceWOValidation.woTypes.add('*');
        complianceWOValidation.woSubStatus.add('*');
        complianceWOValidation.serviceTypes.add('*');
        complianceWOValidation.commercialProducts.add(null);
        complianceWOValidation.calatogueCategories.add(null);
        complianceWOValidation.saSubStatus.add('*');
        complianceWOValidation.additionalCosts.add(null);
        complianceWOValidation.additionalCosts.add(0.00);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'addSpecialFilterValues result - complianceWOValidation=' + complianceWOValidation);
    }


    /**
    * @author Marco Rosa - marco.rosa@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @description Method to get ComplianceMaster
    * @param type - String
    * @param listConfigurationItemId - List<Id>
    * @return Map<Id, ComplianceWrapperResult>
    **/
    public static Map<Id, ComplianceWrapperResult> getComplianceMaster(String type, List<Id> listConfigurationItemId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'listConfItem in input ----->' + listConfigurationItemId);
        List<NE__OrderItem__c> orderItemList = getConfigurationItemFields(listConfigurationItemId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ orderItemList ----->' + orderItemList);
        Map<Id, Decimal> extracostMap = XC_UTIL_ComplianceMaster_U_ExtraCost.getExtraCost(orderItemList);
        Map<Id, ComplianceWrapper> mapConfItemIdWrapper = createMapConfItemIdWrapper(type, orderItemList, extracostMap);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapConfItemIdWrapper ----->' + mapConfItemIdWrapper);
        List<XC_ComplianceMaster__c> listCompliances = getComplianceMaster(type, mapConfItemIdWrapper);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'listCompliances ----->' + listCompliances);
        Map<Id, ComplianceWrapperResult> mapConfItemTemplateName = new Map<Id, ComplianceWrapperResult>();
        ComplianceWrapperCheck wrapperCheck = new ComplianceWrapperCheck();
        wrapperCheck.type = type;
        wrapperCheck.mapConfItemTemplateName = mapConfItemTemplateName;
        wrapperCheck.listCompliances = listCompliances;
        wrapperCheck.mapConfItemIdWrapper = mapConfItemIdWrapper;
        for(NE__OrderItem__c confItem : orderItemList) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For Configuration Item To Check ----->' + confItem.Id);
            wrapperCheck.confItem = confItem;
            XC_UTIL_ComplianceMaster_U_ExactMatch.checkComplianceMasterExactMatch(wrapperCheck);
            for(NE__OrderItem__c confItemNotChecked : wrapperCheck.listConfItemNotChecked) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For Configuration Item To Check With Wild Card ----->' + confItemNotChecked.Id);
                wrapperCheck.confItem = confItemNotChecked;
                XC_UTIL_ComplianceMaster_U_WildCardMatch.checkComplianceMasterWildCardMatch(wrapperCheck);
            }
        }
        return wrapperCheck.mapConfItemTemplateName;
    }

    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @description Method to create Map ConfItem-IdWrapper
    * @param type - String
    * @param orderItemList
    * @return Map<Id, ComplianceWrapper>
    **/
    private static Map<Id, ComplianceWrapper> createMapConfItemIdWrapper(String type, List<NE__OrderItem__c> orderItemList, Map<Id,Decimal> extracostMap){
        Map<Id, ComplianceWrapper> mapConfItemIdWrapper = new  Map<Id, ComplianceWrapper>();
        Map<Id, List<NE__Order_Item_Attribute__c> > orderItemAttributeMap = new Map<Id, List<NE__Order_Item_Attribute__c> >();
        List<String> compliance1or5 = new List<String>{Label.XC_CL_Compliance_C1, Label.XC_CL_Compliance_C5};
        for(NE__OrderItem__c orderItem : orderItemList) {
            ComplianceWrapper wrapper = new ComplianceWrapper();
            if(compliance1or5.contains(type) || type == Label.XC_CL_Compliance_C2) {
                wrapper.salesPartner = orderItem.NE__OrderId__r.NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c;
            }
            if(type == Label.XC_CL_Compliance_C2 || type == Label.XC_CL_Compliance_C3){
                wrapper.extraCost = extracostMap.get(orderItem.Id);
            }
            XC_UTIL_ComplianceMaster_U_CheckField.populateComplianceWrapper(type, wrapper, orderItem);
            mapConfItemIdWrapper.put(orderItem.Id, wrapper);
        }
        return mapConfItemIdWrapper;
    }

    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @description Retrieve all values from the Configuration Items in input
    * @param listConfigurationItemId
    * @return List<NE__OrderItem__c>
    **/
    private static List<NE__OrderItem__c> getConfigurationItemFields(List<Id> listConfigurationItemId){
        Map<Id,List<NE__Order_Item_Attribute__c> > orderItemAttributeMap = new Map<Id,List<NE__Order_Item_Attribute__c> >();
        if(!Schema.sObjectType.NE__OrderItem__c.isAccessible()) {
            return new List<NE__OrderItem__c>();
        }
        return XC_UTIL_ComplianceMaster_D.getQueryOrderItems(listConfigurationItemId);
    }

    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * date 05/04/2019
    * @description getComplianceMaster() - Get Compliance Master for type
    * @param type
    * @param mapConfItemIdWrapper
    * @return List<XC_ComplianceMaster__c>
    **/
    public static List<XC_ComplianceMaster__c> getComplianceMaster(String type, Map<Id, ComplianceWrapper> mapConfItemIdWrapper) {

        populateLists(mapConfItemIdWrapper.values()); 
        List<XC_ComplianceMaster__c> listComplianceMaster = new List<XC_ComplianceMaster__c>();
        List<String> compliance1or5 = new List<String>{Label.XC_CL_Compliance_C1, Label.XC_CL_Compliance_C5};
        if(compliance1or5.contains(type)) {
            XC_UTIL_ComplianceMaster_D.ComplianceTypeC1 complianceWrapperC1 = new XC_UTIL_ComplianceMaster_D.ComplianceTypeC1();
            complianceWrapperC1.salesPartnerList = salesPartnerList;
            complianceWrapperC1.typeList = typeList;
            complianceWrapperC1.productCategoryList = productCategoryList;
            complianceWrapperC1.originlist = originlist;
            complianceWrapperC1.auditList = auditList;
            complianceWrapperC1.probabilityList = probabilityList;
            complianceWrapperC1.receivingChannelList = receivingChannelList; 
            listComplianceMaster = XC_UTIL_ComplianceMaster_D.getQueryComplianceMasterC1(complianceWrapperC1);
        }
        if(type == Label.XC_CL_Compliance_C2) {
            XC_UTIL_ComplianceMaster_D.ComplianceTypeC2 compliance2Wrapper = new XC_UTIL_ComplianceMaster_D.ComplianceTypeC2();
            compliance2Wrapper.salesPartnerList = salesPartnerList;
            compliance2Wrapper.typeList = typeList;
            compliance2Wrapper.originlist = originlist;
            compliance2Wrapper.productCategoryList = productCategoryList;
            compliance2Wrapper.promotionsList = promotionsList;
            compliance2Wrapper.paymentMethodList = paymentMethodList;
            compliance2Wrapper.billingModelList = billingModelList;
            compliance2Wrapper.energyList = energyList;
            compliance2Wrapper.auditList = auditList;
            compliance2Wrapper.probabilityList = probabilityList;
            compliance2Wrapper.signatureAgentList = signatureAgentList;
            compliance2Wrapper.receivingChannelList = receivingChannelList;
            listComplianceMaster = XC_UTIL_ComplianceMaster_D.getQueryComplianceMasterC2(compliance2Wrapper);
        }
        if(type == Label.XC_CL_Compliance_C3) {
            XC_UTIL_ComplianceMaster_D.ComplianceTypeC3 compliance3Wrapper = new XC_UTIL_ComplianceMaster_D.ComplianceTypeC3();
            compliance3Wrapper.salesPartnerList = salesPartnerList;
            compliance3Wrapper.typeList = typeList;
            compliance3Wrapper.originlist = originlist;
            compliance3Wrapper.productCategoryList = productCategoryList;
            compliance3Wrapper.promotionsList = promotionsList;
            compliance3Wrapper.paymentMethodList = paymentMethodList;
            compliance3Wrapper.billingModelList = billingModelList;
            compliance3Wrapper.installerPartnerList = installerPartnerList;
            compliance3Wrapper.energyList = energyList;
            compliance3Wrapper.auditList = auditList;
            compliance3Wrapper.probabilityList = probabilityList;
            compliance3Wrapper.receivingChannelList = receivingChannelList;
            populateCompliance3Wrapper(compliance3Wrapper, signatureAgentList, syncStockGloviaList);
            listComplianceMaster = XC_UTIL_ComplianceMaster_D.getQueryComplianceMasterC3(compliance3Wrapper);
        }
        if(type == Label.XC_CL_Compliance_C4) {
            XC_UTIL_ComplianceMaster_D.ComplianceTypeC4 compliance4Wrapper = new XC_UTIL_ComplianceMaster_D.ComplianceTypeC4();
            compliance4Wrapper.typeList = typeList;
            compliance4Wrapper.originlist = originlist;
            compliance4Wrapper.productCategoryList = productCategoryList;
            compliance4Wrapper.auditList = auditList;
            compliance4Wrapper.receivingChannelList = receivingChannelList;
            compliance4Wrapper.probabilityList = probabilityList;
            listComplianceMaster = XC_UTIL_ComplianceMaster_D.getQueryComplianceMasterC4(compliance4Wrapper);
        }
        return listComplianceMaster;
    }

    private static void initLists(){
        typeList = new List<String>();
        productCategoryList = new List<String>();
        salesPartnerList = new List<String>();
        originlist = new List<String>();
        billingModelList = new List<String>();
        paymentMethod = new List<String>();
        extraCostList = new List<Decimal>();
        paymentMethodList = new List<String>();
        installerPartnerList = new List<String>();
        countryValueList = new List<String>();
        promotionsList = new List<String>();
        energyList = new List<Boolean>();
        auditList = new List<Boolean>();
        probabilityList = new List<Decimal>();
        signatureAgentList = new List<String>();
        syncStockGloviaList = new List<String>();
        receivingChannelList = new List<String>();
    }

    private static void populateLists(List<ComplianceWrapper> comWrapperList){
        initLists();
        for(ComplianceWrapper wrapper : comWrapperList) {
            countryValueList.add(wrapper.country);
            typeList.add(wrapper.type);
            productCategoryList.add(wrapper.productCategory);
            salesPartnerList.add(wrapper.salesPartner);
            originlist.add(wrapper.origin);
            billingModelList.add(wrapper.billingModel);
            paymentMethodList.add(wrapper.paymentMethod);
            extraCostList.add(wrapper.extraCost);
            installerPartnerList.add(wrapper.installerPartner);
            promotionsList.add(wrapper.promotions);
            energyList.add(wrapper.energy);
            auditList.add(wrapper.audit);
            probabilityList.add(wrapper.probability);
            signatureAgentList.add(wrapper.signatureAgent);
            syncStockGloviaList.add(wrapper.syncStockGlovia);
            receivingChannelList.add(wrapper.receivingChannel);
        }

        typeList.add('*');
        originlist.add(null);
        billingModelList.add(null);
        paymentMethodList.add(null);
        salesPartnerList.add(null);
        promotionsList.add(null);
        installerPartnerList.add(null);
        signatureAgentList.add(null);
        syncStockGloviaList.add(null);
        receivingChannelList.add(null);
    }

    private static void populateCompliance3Wrapper(XC_UTIL_ComplianceMaster_D.ComplianceTypeC3 compliance3Wrapper, List<String> signatureAgentList, List<String> syncStockGloviaList){
        compliance3Wrapper.signatureAgentList = signatureAgentList;
        compliance3Wrapper.syncStockGloviaList = syncStockGloviaList;
    }
}