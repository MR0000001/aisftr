/**
 * @author Salvatore Scarpato salvatore.scarpato@nttdata.com
 * @date Creation 26/04/2019
 * @date Modification 27/05/2020 by Nicola Mariniello nmariniello@deloitte.it
 * @description  – public class with invocable method. It is invoked by a Flow to generate the activation code (that is the creation of  
 * XC_Voucher__c records based on the quantity of items purchased) and to create a XC_CustomerInteraction record
 */


public without sharing class XC_IN022_EMobility_ActivationCode {


    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN022_EMobility_ActivationCode');


    /** 
     * @description InputWrapper the input wrapper. TEST
     */
    public class InputWrapper{ 
        @Invocablevariable
        public String stepId;       
    }
    

    /** 
     * @description UtilWrapper util wrapper for the class.
     */
    public class UtilWrapper{
        public String stepId;     
        public String customerType;
        public String accountId;
        public String contactId;
        public String contactName;
        public String orderId;
        public String orderItemId;
        public String productId;
        public String optyId;
        public String eMail;
        public String preferredlanguage;
        public Double quantity;
        public String companyCode;
        public String costCenter;
        public String recordTypeId;
        public String product;
        public String productCategory;
        public String catalog;
        public String salesChannel;
        public String legalEntity;
        public String stream;
    }


    /** 
     * @description Invocable method to launch the creation of a customer interaction
     * @param inputWrapperList
     */
    @InvocableMethod 
    public static void emailForUserCreation(List<InputWrapper> inputWrapperList) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering In XC_IN022_EMobility_ActivationCode');
        UtilWrapper utilWr = getParentsInfo(inputWrapperList);
        createVoucher(utilWr);
        createCustomerInteraction(utilWr);
    }


    /**
     * @description Gets the info from step.
     * @param inputWrapperList the input wrapper list
     * @return 
     **/
    public static UtilWrapper getParentsInfo(List<InputWrapper> inputWrapperList) {

        UtilWrapper wrapper = new UtilWrapper();
        List<String> listStepIds = new List<String>(); 
        for(InputWrapper inputWr : inputWrapperList){                
            listStepIds.add(inputWr.stepId);
            wrapper.stepId = inputWr.stepId;
        } 
   
        Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id, XC_Provisioning_Step__c>([SELECT XC_Configuration_Item__c, XC_ConfigurationId__c
                                                                                            FROM XC_Provisioning_Step__c 
                                                                                            WHERE Id IN: listStepIds]);
        List< XC_Provisioning_Step__c> listSteps =  mapSteps.values();

        List<String> configurationItemIds = new List<String>(); 
        for(XC_Provisioning_Step__c step : listSteps){
            if(!String.isBlank(step.XC_Configuration_Item__c)){
                configurationItemIds.add(step.XC_Configuration_Item__c);
            }
        }
        
        Map<Id, NE__OrderItem__c> configurationItemMap = new Map<Id, NE__OrderItem__c>([SELECT Id, XC_CountryFormula__c, NE__OrderId__c , NE__ProdId__c, NE__ProdName__c, NE__Qty__c, NE__OrderId__r.NE__OptyId__c,
                                                                                            NE__OrderId__r.NE__OptyId__r.XC_CompanyCode__c, NE__OrderId__r.NE__OptyId__r.XC_CostCenter__c, NE__CatalogItem__c,
                                                                                            NE__CatalogItem__r.NE__Catalog_Category_Name__c,NE__Catalog__c, NE__OrderId__r.XC_LegalEntity__c, NE__OrderId__r.XC_Segment__c,
                                                                                            (SELECT Id, AccountId, ContactId, Contact.Name, Contact.Email, Contact.XC_Preferredlanguageofcontact__c from Assets__r),
                                                                                            (SELECT Id, NE__Value__c FROM NE__Order_Item_Attributes__r WHERE (XC_DeveloperName__c =: Label.XC_CL_Attribute_ActivationCode OR XC_DeveloperName__c =: Label.XC_CL_SellingChannel) AND NE__Value__c != null) 
                                                                                        FROM NE__OrderItem__c 
                                                                                        WHERE Id IN: configurationItemIds]);
        
        Id recordTypeId = Schema.SObjectType.XC_Voucher__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Voucher_RT_eMobilityActivationCode).getRecordTypeId();
        if(!configurationItemMap.isEmpty()) {
            wrapper.legalEntity = configurationItemMap.values()[0].NE__OrderId__r.XC_LegalEntity__c;
            wrapper.stream = configurationItemMap.values()[0].NE__OrderId__r.XC_Segment__c;
            wrapper.customerType = configurationItemMap.values()[0].NE__ProdName__c;
            wrapper.accountId = configurationItemMap.values()[0].Assets__r[0].AccountId;
            wrapper.contactId = configurationItemMap.values()[0].Assets__r[0].ContactId;
            wrapper.contactName = configurationItemMap.values()[0].Assets__r[0].Contact.Name;
            wrapper.orderId = configurationItemMap.values()[0].NE__OrderId__c;
            wrapper.orderItemId = configurationItemMap.values()[0].Id;
            wrapper.productId = configurationItemMap.values()[0].NE__ProdId__c;
            wrapper.optyId = configurationItemMap.values()[0].NE__OrderId__r.NE__OptyId__c;
            wrapper.eMail = configurationItemMap.values()[0].Assets__r[0].Contact.Email;
            wrapper.preferredlanguage = XC_UTIL_CustomerInteractionGeneration_U.getPreferredLanguage(configurationItemMap.values()[0].Assets__r[0].Contact.XC_Preferredlanguageofcontact__c);
            wrapper.quantity = configurationItemMap.values()[0].NE__Qty__c;
            wrapper.companyCode = configurationItemMap.values()[0].NE__OrderId__r.NE__OptyId__r.XC_CompanyCode__c;
            wrapper.costCenter = configurationItemMap.values()[0].NE__OrderId__r.NE__OptyId__r.XC_CostCenter__c;
            wrapper.salesChannel = (!configurationItemMap.values()[0].NE__Order_Item_Attributes__r.isEmpty()) ? configurationItemMap.values()[0].NE__Order_Item_Attributes__r[0].NE__Value__c : getSalesChannel(new Map<String, String>{'legalEntity' => wrapper.legalEntity, 'companyCode' => wrapper.companyCode, 'costCenter' => wrapper.costCenter, 'childProdId' => configurationItemMap.values()[0].NE__ProdId__c});
            wrapper.recordTypeId = recordTypeId;
            wrapper.product = configurationItemMap.values()[0].NE__CatalogItem__c;
            wrapper.productCategory = configurationItemMap.values()[0].NE__CatalogItem__r.NE__Catalog_Category_Name__c;
            wrapper.catalog = configurationItemMap.values()[0].NE__Catalog__c;
        }

        System.debug('@SS@ wrapper.accountId -->' + wrapper.accountId);
        System.debug('@SS@ wrapper.customerType -->' + wrapper.customerType);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@SS@ wrapper.accountId -->' + wrapper.accountId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@SS@ wrapper.eMail -->' + wrapper.eMail);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@SS@ wrapper.preferredlanguage -->' + wrapper.preferredlanguage);
        return wrapper; 
    }


    /**
     * @description Method to create a Customer Interaction record.
     * @param wrapper
     **/
    private static void createVoucher(UtilWrapper wrapper) {

        List<XC_Voucher__c> voucherListToInsert = new List<XC_Voucher__c>();

        Integer quantity = Integer.valueof(wrapper.quantity);
        for(Integer i = 1; i <= quantity; i++){
            XC_Voucher__c voucher = new XC_Voucher__c();
            voucher.RecordTypeId = wrapper.recordTypeId;
            voucher.XC_B2BCustomer__c = wrapper.accountId;
            voucher.XC_Order__c = wrapper.orderId;
            voucher.XC_Opportunity__c = wrapper.optyId;
            voucher.XC_CompanyCode__c = wrapper.companyCode;
            voucher.XC_CostCenter__c = wrapper.costCenter;
            voucher.XC_Uses__c = 1;
            voucher.XC_Usage_Counter__c = 0;
            voucher.XC_SalesChannel__c = wrapper.salesChannel;
            voucher.XC_StartDate__c = Date.Today();
            voucher.XC_EndDate__c = Date.Today().addYears(1);
            voucher.XC_Amount__c = 0;
            voucher.XC_Product__c = wrapper.product;
            voucher.XC_ProductCategory__c = wrapper.productCategory;
            voucher.XC_Catalog__c  = wrapper.catalog;
            voucher.XC_LegalEntity__c = wrapper.legalEntity;
            voucherListToInsert.add(voucher);
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'voucherListToInsert: ' + voucherListToInsert);
        XC_UTIL_SObject.insertListRecords(voucherListToInsert);
    }


    /**
     * @description Method to create a Customer Interaction record.
     * @param wrapper
     **/
    private static void createCustomerInteraction(UtilWrapper wrapper) {
        
        List<Map<String,Object>> interactions = new List<Map<String,Object>>();
        Map<String,Object> data = new Map<String,Object>();

        String customerType = wrapper.customerType;
        String communicationType = '';
        
        if(customerType.containsIgnoreCase('JuicePack')) {
            communicationType = Label.XC_CL_CustomerInteraction_JuicePackStreetProfilePurchaseEmail;
            data.put('additionalInfo1', getVoucherCodes(wrapper.orderId));
        } else if(customerType.containsIgnoreCase('OpenCharge') || customerType.containsIgnoreCase('Open Charge')) {
            communicationType = Label.XC_CL_CustomerInteraction_ActivationCode;
            data.put('additionalInfo1', getVoucherCodes(wrapper.orderId));
        } else if(customerType.containsIgnoreCase('RFID')) {
            communicationType = Label.XC_CL_CustomerInteraction_RFIDProfilePurchaseEmail;
        } else {
            communicationType = Label.XC_CL_CustomerInteraction_DriverProfilePurchaseEmail;
        }
        
        data.put('customerType', communicationType);
        data.put('email', wrapper.eMail);
        data.put('preferredlanguage', wrapper.preferredlanguage);
        data.put('accountId', wrapper.accountId);
        data.put('contactId', wrapper.contactId);
        data.put('fullName', wrapper.contactName);
        data.put('orderId', wrapper.orderId);
        data.put('orderItemID', wrapper.orderItemID);
        data.put('productId', wrapper.productId);
        data.put('opportunityId', wrapper.optyId);
        data.put('legalEntity', wrapper.legalEntity);
        data.put('segment', wrapper.stream);
        data.put('skipComunication', false);
        data.put('sent', false);

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@SS@ data Map -->' + data);
        interactions.add(data);
        XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromWorkOrder(interactions);
    }


    /**
     * @description Method to get voucher codes.
     * @param orderId
     **/
    private static String getVoucherCodes(String orderId) {

        String codes = '';

        Map<Id, XC_Voucher__c> voucherMap = new Map<Id, XC_Voucher__c>([SELECT Id, XC_VoucherCode__c FROM XC_Voucher__c WHERE XC_Order__c =: orderId]);
        for(XC_Voucher__c coupon : voucherMap.values()) {
            codes += (String.isNotBlank(coupon.XC_VoucherCode__c)) ? coupon.XC_VoucherCode__c + ';' : '';
        }

        return codes.removeEnd(';');
    }


    /**
     * @description Get Sales Channel.
     * @param companyCode the company Code
     * @param costCenter the cost Center
     * @param childProdId the child Prod Id
     * @return the SalesChannel
     **/
    private static String getSalesChannel(Map<String, String> dataMap) {
        
        String legalEntity = dataMap.get('legalEntity');
        String companyCode = dataMap.get('companyCode');
        String costCenter = dataMap.get('costCenter');
        String childProdId = dataMap.get('childProdId');

        String salesChannel = '';
        Asset a;

        List<NE__Product__c> prodList = new List<NE__Product__c>([SELECT Id, (SELECT Id, NE__ProdId__c FROM NE__Asset_Prod__r WHERE XC_CompanyCode__c =: companyCode AND XC_CostCenter__c =: costCenter AND XC_ZQuoteId__c != '' AND NE__Order_Config__r.XC_EmobilityWebAppType__c != '' AND XC_LegalEntity__c =: legalEntity AND NE__ProdId__r.XC_Product_Subtype__c =: Label.XC_CL_ProductSubtype_B2BTariff),
                                                                    (SELECT ID, NE__FamilyId__r.XC_LIC_Family_Name__c FROM NE__ProductFamily__r WHERE NE__FamilyId__r.XC_LIC_Family_Name__c = :Label.XC_CL_Family_JNManager)
                                                                FROM NE__Product__c
                                                                WHERE Id IN (SELECT NE__ProdId__c FROM Asset WHERE XC_CompanyCode__c =: companyCode AND XC_CostCenter__c =: costCenter AND XC_ZQuoteId__c != '' AND NE__Order_Config__r.XC_EmobilityWebAppType__c != '' AND XC_LegalEntity__c =: legalEntity AND NE__ProdId__r.XC_Product_Subtype__c =: Label.XC_CL_ProductSubtype_B2BTariff)]);
        for(NE__Product__c pr : prodList) {
            if(pr.NE__ProductFamily__r.isEmpty()) {
                a = pr.NE__Asset_Prod__r[0];
            }
        }

        if(a == null){
            System.debug('@@@ Asset Father not found');
            return salesChannel;
        }

        List<NE__DocumentationCharacterist__c> docCharList = new List<NE__DocumentationCharacterist__c>([SELECT NE__Product__c, NE__Value__c FROM NE__DocumentationCharacterist__c
                                                                                                            WHERE LicName__c =: Label.XC_CL_SellingChannel AND (NE__Product__c =: a.NE__ProdId__c OR NE__Product__c =: childProdId)]);
        String salesChannelFather = '';
        String salesChannelChild = '';
        for(NE__DocumentationCharacterist__c dc : docCharList) {
            if(dc.NE__Product__c == a.NE__ProdId__c) {
                salesChannelFather = dc.NE__Value__c;
            } else if (dc.NE__Product__c == childProdId) {
                salesChannelChild = dc.NE__Value__c;
            }
        }
        salesChannel = salesChannelFather + '-' + salesChannelChild;
        
        return salesChannel;
    }


    /*private static String getSalesChannel(String companyCode, String costCenter, String childProdId){
        
        String salesChannel = '';

        List<Asset> assetList = new List<Asset>([SELECT XC_BillingModel__c, NE__ProdId__c FROM Asset
                                                    WHERE XC_CompanyCode__c =: companyCode AND XC_CostCenter__c =: costCenter  AND XC_ZQuoteId__c != ''
                                                    AND (XC_Product_Name_LIC__c like '%Recharge%' OR XC_Product_Name_LIC__c like '%Rent%'
                                                        OR XC_Product_Name_LIC__c like '%Fleets%' OR XC_Product_Name_LIC__c like '%Merlin%') LIMIT 1]);
        if(assetList.isEmpty()){
            System.debug('@@@ Asset Father not found');
            return salesChannel;
        }

        List<NE__DocumentationCharacterist__c> docCharList = new List<NE__DocumentationCharacterist__c>([SELECT NE__Product__c, NE__Value__c FROM NE__DocumentationCharacterist__c
                                                                                                            WHERE LicName__c =: Label.XC_CL_SellingChannel AND (NE__Product__c =: assetList[0].NE__ProdId__c OR NE__Product__c =: childProdId)]);
        String salesChannelFather = '';
        String salesChannelChild = '';
        for(NE__DocumentationCharacterist__c dc : docCharList) {
            if(dc.NE__Product__c == assetList[0].NE__ProdId__c) {
                salesChannelFather = dc.NE__Value__c;
            } else if (dc.NE__Product__c == childProdId) {
                salesChannelChild = dc.NE__Value__c;
            }
        }
        salesChannel = salesChannelFather + '-' + salesChannelChild;
        
        /*String billingModel = assetList[0].XC_BillingModel__c;
        if(billingModel == Label.XC_CL_BillingModel_Recurring){
            salesChannel = Label.XC_CL_SalesChannel_FleetManagerFLAT;
        } else {
            salesChannel = Label.XC_CL_SalesChannel_FleetManagerPPU;
        }*/

        /*return salesChannel;
    }*/
}