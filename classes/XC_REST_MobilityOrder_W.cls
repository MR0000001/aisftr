/**
 * The Class XC_REST_MobilityOrder_W.
 *
 * @author            : Nicola Mariniello nmariniello@delotte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 30/04/2019
 * @date Modification : dd/mm/yyyy
 * @description       : UTIL for XC_REST_MobilityOrder
 **/ 


public without sharing class XC_REST_MobilityOrder_W {


    /**
     * The Class WrapperRequest.
     *
     * @description the wrapper request
     */
    public class WrapperRequest { 

        /** The Order. */
        public OrderWrapper Order = new OrderWrapper();
        
        /** The Billing profile. */
        public XC_UTIL_BillingProfile.BillingProfileIFWrapper BillingProfile = new XC_UTIL_BillingProfile.BillingProfileIFWrapper();
    }


    /**
     * The Class WrapperResponse.
     *
     * @description the wrapper response
     */
    public class WrapperResponse {

        /** The Result. */
        public XC_UTIL_Integration.Result Result = new XC_UTIL_Integration.Result();
        
        /** The Order. */
        public OrderWrapper Order; 
    } 


    /**
     * The Class OrderWrapper.
     *
     * @description the wrapper order
     */
    public class OrderWrapper {

        /** The Client System. */
        public String ClientSystem;

        /** The Legal Entity. */
        public String LegalEntity;
          
        /** The Account ID. */
        public String AccountID;
        
        /** The Order status. */
        public String OrderStatus;
        
        /** The Contract code. */
        public String ContractCode;
        
        /** The Contract date. */
        public String ContractDate;
        
        /** The Company code. */
        public String CompanyCode;
        
        /** The Cost center. */
        public String CostCenter;
        
        /** The Total one time fee. */
        public String TotalOneTimeFee;
        
        /** The Payment mode. */
        public String PaymentMode;
        
        /** The Channel. */
        public String Channel;
        
        /** The Sub channel. */
        public String SubChannel;
        
        /** The Registered on recharge app. */
        public Boolean RegisteredOnRechargeApp;
        
        /** The Created date. */
        public String CreatedDate;
        
        /** The Coupon code. */
        public String CouponCode;
        
        /** The Destination code. */
        public String DestinationCode;
        
        /** The Certified email. */
        public String CertifiedEmail;
        
        /** The Order ID. */
        public String OrderID;

        /** The Billing Address ID. */
        public String BillingAddressID;

        /** The Shipping Address ID. */
        public String ShippingAddressID;

        /** The Commodity Billing Cycle Frequency - FOR COMMODITY */
        public String CommodityBillingCycleFrequency;

        /** The Order Type - FOR COMMODITY */
        public String OrderType;

        /** The Deactivation Based On Regulatory - FOR COMMODITY */
        public String DeactivationBasedOnRegulatory;

        /** The Account Fiscal Code - FOR COMMODITY */
        public String AccountFiscalCode;

        /** The Billing Profile Data - FOR COMMODITY */
        public String BillingProfileData;

        /** The Billing Address Data - FOR COMMODITY */
        public String BillingAddressData;

        /** The Installation Address Data - FOR COMMODITY */
        public String InstallationAddressData;

        /** The Activation Country */
        public String ActivationCountry;

        /** The Order item. */
        public OrderItemWrapper OrderItem;

        /** The Order item list. */
        public List<OrderItemWrapper> OrderItemList;

        /** The Order document. - FOR COMMODITY */
        public List<OrderDocumentWrapper> Document;

        public String ExternalOffer; //[ deepti.ramesh@accenture.com, 18/2/2022, R1-2022, AO011249, added new tag]
    }


    /**
     * The Class OrderItemWrapper.
     *
     * @description the wrapper order item
     */
    public class OrderItemWrapper{
        
        /** The Engine code. */
        public String EngineCode;
        
        /** The Catalog item ID. */
        public String CatalogItemID;
        
        /** The Quantity. */
        public Decimal Quantity;

        /** The Old asset ID. */
        public String OldAssetID;
        
        /** The Old subscription ID. */
        public String OldSubscriptionID;
        
        /** The New engine code. */
        public String NewEngineCode;
        
        /** The New catalog item ID. */
        public String NewCatalogItemID;
            
        /** The New quantity. */
        public Decimal NewQuantity;

        /** The Attribute. */
        public List<WrapperAttribute> Attribute;

        /** The OrderItemDiscount. */
        public List<WrapperDiscount> OrderItemDiscount;
    }    


    /**
     * The Class WrapperAttribute.
     *
     * @description the wrapper attribute
     */
    public class WrapperAttribute{

        /** The AttributeID. */
        public String AttributeID;
        
        /** The Name. */
        public String Name;
        
        /** The Value. */
        public String Value;
        
        /** The Product family property ID. */
        public String ProductFamilyPropertyID;
        
    }

    /**
     * The Class OrderDocumentWrapper.
     *
     * @description the wrapper order
     */
    public class OrderDocumentWrapper{

        /** The ContractUrl. */
        public String ContractUrl;
        public String ExternalDocID; //[ deepti.ramesh@accenture.com, 18/2/2022, R1-2022, AO011249, added new tag]
    }
    
    /**
     * The Class WrapperDiscount.
     *
     * @description the wrapper discount
     */
    public class WrapperDiscount{
        /** The OrderItem Discount ID. */
        public String OrderItemDiscountID;   

        /** The Name. */           
        public String Name;  

        /** The OrderItem ID. */
        public String OrderItemID;  
        
        /** The AssetUpdateKey. */
        public String AssetUpdateKey;  

        /** The Code. */
        public String Code;  

        /** The DiscountItem. */
        public String DiscountItem; 

        /** The End Date. */ 
        public Date EndDate;  

        /** The OneTimePercentage. */
        public Decimal OneTimePercentage;

        /** The .OneTimePrice */
        public Decimal OneTimePrice;  

        /** The OneTimeValue. */
        public Decimal OneTimeValue;  
        
        /** The Reason. */
        public String Reason;  

        /** The RecurringPercentage. */
        public Decimal RecurringPercentage;  

        /** The RecurringPrice. */
        public Decimal RecurringPrice;  

        /** The RecurringValue. */
        public Decimal RecurringValue;  

        /** The Sequence. */
        public Decimal Sequence;  

        /** The StartDate. */
        public Date StartDate;

        /** The Status. */  
        public String Status;  

        /** The Type. */
        public String Type;  
    }


    /**
     * CreateOpportunityForOrder.
     *
     * @param infos the configuration Info Map
     * @param legalEntity the legal entity
     * @description method to create Opportunity
     */
    public static void createOpportunityForOrder(Map<String, String> infos, String legalEntity){
        
        String contactId = infos.get('contactId');
        Opportunity oppRM;

        if(String.isNotBlank(infos.get('optyIdRM')) && infos.get('stream') != 'B2C') {
            String optyIdRM = infos.get('optyIdRM');
            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, RecordTypeId, XC_ProductCategory__c, XC_BusinessLine__c, XC_Contact__c, XC_OpportunityDescription__c, XC_SalesChannel__c, XC_SFMTechnicalField__c,
                                                                        XC_Source__c, XC_BusinessModel__c, XC_IndustrialKPI__c, XC_IndustrialKPIfullLife__c, XC_RevenueFullLife__c, XC_GrossMarginFullLife__c, XC_ActivationCountry__c
                                                                    FROM Opportunity WHERE Id =: optyIdRM]);
            oppRM = oppMap.values()[0];
            contactId = oppRM.XC_Contact__c;
        }

        if(String.isBlank(contactId)) {
            Map<Id, Contact> conMap = new Map<Id, Contact>([SELECT Id FROM Contact WHERE AccountId =: infos.get('NE__AccountId__c') AND XC_PrimaryContact__c = true]);
            if(conMap.isEmpty()) {
                return;
            } else {
                contactId = conMap.values()[0].Id;
            }
        }

        String productCategory = '';
        if(oppRM != null) {
            XC_UTIL_DependentPicklist.PicklistWrapper pl = XC_UTIL_DependentPicklist.getDependentPicklist('Opportunity', 'XC_ProductCategoryOfInterest__c', 'XC_ProductCategory__c');
            if(pl.pickListMap.containsKey(infos.get('productCategory'))) {
                List<String> valuesPicklist = pl.pickListMap.get(infos.get('productCategory'));
                if(!valuesPicklist.isEmpty()) {
                    productCategory = valuesPicklist[0];
                    for(String valuePicklist : valuesPicklist) {
                        if(valuePicklist == oppRM.XC_ProductCategory__c) {
                            productCategory = valuePicklist;
                            break;
                        }
                    }
                }
            }
        }
        String transactionId = (!String.isBlank(infos.get('XC_eMobTransactionId__c'))) ? infos.get('XC_eMobTransactionId__c') : infos.get('commodityTransactionID'); //20211111_DD_SO_15
        Id recTypeOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2B_Opportunity_Italy').getRecordTypeId(); //[DeAv 09/11/2021 CR NR2063]
        XC_REST_Account_W.WrapperResponse wrResp = new XC_REST_Account_W.WrapperResponse(); //[ deepti.ramesh@accenture.com, 21/2/2022, R1-2022, AO011249, variable for mapping field values to new tags]
        Opportunity opp = new Opportunity(XC_LegalEntity__c = legalEntity,
                                            AccountId = infos.get('NE__AccountId__c'),
                                            XC_Contact__c = contactId,
                                            XC_ProductCategoryOfInterest__c = ('B2B'.equalsIgnoreCase(infos.get('stream')) && 'CommodityItalyB2C'.equalsIgnoreCase(infos.get('clientSystem'))) ? 'Monitoring & Verification' : (infos.get('productCategory')), //[DeAv 09/11/2021 CR NR2063]
                                            XC_CompanyCode__c = infos.get('XC_Company_Code__c'),
                                            XC_CostCenter__c = infos.get('XC_Cost_Center__c'),
                                            XC_Address__c = infos.get('XC_DeliveryAddress__c'),
                                            StageName = 'Draft',
                                            Name = 'Opportunity ' + infos.get('productCategory'),
                                            CloseDate = System.today().addDays(30),
                                            XC_ReceivingChannel__c = ('B2B'.equalsIgnoreCase(infos.get('stream')) && 'CommodityItalyB2C'.equalsIgnoreCase(infos.get('clientSystem'))) ? 'Phone Channels' : (String.isNotBlank(infos.get('ChannelForOpp'))) ? infos.get('ChannelForOpp') : infos.get('NE__Channel__c'), //[DeAv 09/11/2021 CR NR2063]
                                            XC_ContractStartDate__c = ('B2B'.equalsIgnoreCase(infos.get('stream')) && 'CommodityItalyB2C'.equalsIgnoreCase(infos.get('clientSystem'))) ? Date.Today() : (oppRM != null) ? System.today() : null, //[DeAv 09/11/2021 CR NR2063]
                                            XC_ContractEndDate__c = ('B2B'.equalsIgnoreCase(infos.get('stream')) && 'CommodityItalyB2C'.equalsIgnoreCase(infos.get('clientSystem'))) ? Date.Today().addMonths(25) : (oppRM != null) ? System.today().addDays(30) : null, //[DeAv 09/11/2021 CR NR2063]
                                            XC_ContractualRevenueStartDate__c = ('B2B'.equalsIgnoreCase(infos.get('stream')) && 'CommodityItalyB2C'.equalsIgnoreCase(infos.get('clientSystem'))) ?  Date.Today().addDays(30): (oppRM != null) ? System.today() : null, //[DeAv 09/11/2021 CR NR2063]
                                            XC_ContractualRevenueEndDate__c = ('B2B'.equalsIgnoreCase(infos.get('stream')) && 'CommodityItalyB2C'.equalsIgnoreCase(infos.get('clientSystem'))) ? Date.Today().addMonths(25) : (oppRM != null) ? System.today().addDays(30) : null, //[DeAv 09/11/2021 CR NR2063]
                                            XC_ExpectedSignedContractDate__c = System.today(),
                                            XC_ProductCategory__c = ('B2B'.equalsIgnoreCase(infos.get('stream')) && 'CommodityItalyB2C'.equalsIgnoreCase(infos.get('clientSystem'))) ? 'Customer Insights' : (oppRM != null) ? productCategory : null, //[DeAv 09/11/2021 CR NR2063]
                                            XC_BusinessLine__c = ('B2B'.equalsIgnoreCase(infos.get('stream')) && 'CommodityItalyB2C'.equalsIgnoreCase(infos.get('clientSystem'))) ? 'eIndustry' : (oppRM != null) ? oppRM.XC_BusinessLine__c : null, //[DeAv 09/11/2021 CR NR2063]
                                            XC_OpportunityDescription__c = (oppRM != null) ? oppRM.XC_OpportunityDescription__c : null,
                                            XC_SalesChannel__c = ('B2B'.equalsIgnoreCase(infos.get('stream')) && 'CommodityItalyB2C'.equalsIgnoreCase(infos.get('clientSystem'))) ? 'External Sales Agencies' : (oppRM != null) ? oppRM.XC_SalesChannel__c : null, //[DeAv 09/11/2021 CR NR2063]
                                            XC_Source__c = ('B2B'.equalsIgnoreCase(infos.get('stream')) && 'CommodityItalyB2C'.equalsIgnoreCase(infos.get('clientSystem'))) ? 'Commodity' : (oppRM != null) ? oppRM.XC_Source__c : null,   //[DeAv 09/11/2021 CR NR2063]
                                            XC_BusinessModel__c = ('B2B'.equalsIgnoreCase(infos.get('stream')) && 'CommodityItalyB2C'.equalsIgnoreCase(infos.get('clientSystem'))) ? 'Recurrent Sale' : (oppRM != null) ? oppRM.XC_BusinessModel__c : null, //[DeAv 09/11/2021 CR NR2063]
                                            XC_IndustrialKPI__c = ('B2B'.equalsIgnoreCase(infos.get('stream')) && 'CommodityItalyB2C'.equalsIgnoreCase(infos.get('clientSystem'))) ? '# of data point' : (oppRM != null) ? oppRM.XC_IndustrialKPI__c : null, //[DeAv 09/11/2021 CR NR2063]
                                            XC_IndustrialKPIfullLife__c = ('B2B'.equalsIgnoreCase(infos.get('stream')) && 'CommodityItalyB2C'.equalsIgnoreCase(infos.get('clientSystem'))) ? 1 : (oppRM != null) ? oppRM.XC_IndustrialKPIfullLife__c : null, //[DeAv 09/11/2021 CR NR2063]
                                            XC_RevenueFullLife__c = (oppRM != null) ? oppRM.XC_RevenueFullLife__c : null,
                                            XC_GrossMarginFullLife__c = (oppRM != null) ? oppRM.XC_GrossMarginFullLife__c : null,
                                            XC_PipelineStatus__c = ('B2B'.equalsIgnoreCase(infos.get('stream')) && 'CommodityItalyB2C'.equalsIgnoreCase(infos.get('clientSystem'))) ? 'Opportunity Assigned' : (oppRM != null) ? 'Opportunity Assigned' : null, //[DeAv 09/11/2021 CR NR2063]
                                            XC_OpportunityAssignedDate__c = System.today(),
                                            XC_ActivationCountry__c = (oppRM != null && String.isNotBlank(oppRM.XC_ActivationCountry__c)) ? oppRM.XC_ActivationCountry__c : infos.get('activationCountry')
                                            );
        //[START 23/03/2022 CR NR2355  bulli.bheemanaboyana@accenture.com ]                                   
        If(opp.XC_ProductCategoryOfInterest__c == 'eMobility Recharge Manager'){
            XC_UTIL_DependentPicklist.PicklistWrapper pl = XC_UTIL_DependentPicklist.getDependentPicklist('Opportunity','XC_ProductCategory__c', 'XC_BusinessLine__c');
            String businessline = '';
            if(pl.pickListMap.containsKey(opp.XC_ProductCategory__c)) {
                          List<String> valuesPicklist = pl.pickListMap.get(opp.XC_ProductCategory__c);
                          if(!valuesPicklist.isEmpty()) {
                                        businessline = valuesPicklist[0];
                          }
            }
            opp.XC_BusinessLine__c = businessLine;
            opp.XC_IndustrialKPI__c = '';
        }
        //[END 23/03/2022 CR NR2355  bulli.bheemanaboyana@accenture.com ] 
        
        //[DeAv 09/11/2021 CR NR2063 START]
        if('B2B'.equalsIgnoreCase(infos.get('stream')) && 'CommodityItalyB2C'.equalsIgnoreCase(infos.get('clientSystem'))){
            opp.RecordTypeId = recTypeOpp;
            opp.XC_WeighteIndustry__c =  '99';
            opp.XC_CreditCheck_GB__c = 'OK'; 
            opp.XC_Segment__c = 'B2B';
            opp.XC_BillingModel__c = 'Subscription';
            opp.XC_PaymentMethod__c = 'Direct Debt'.equalsIgnoreCase(infos.get('paymentMethod'))?'Automatic Debt':infos.get('paymentMethod');
            opp.XC_KAM__c = 'CustomerInsights';
        }
        //[DeAv 09/11/2021 CR NR2063 END]    
        if(infos.get('stream') != 'B2C' && legalEntity == 'EnelXMSP'){
            opp.XC_PipelineStatus__c = 'Opportunity Assigned';
            opp.XC_OpportunityAssignedDate__c = System.today();
        } 
        //20211111_DD_SO_15 - start
        opp.XC_TransactionId__c = String.isNotblank(transactionId)?transactionId:'';
        //20211111_DD_SO_15 - end
        XC_UTIL_Sobject.WrapperResult insertResult = XC_UTIL_Sobject.insertRecord(opp);
        System.debug('Result of insert Opportunity -> ' + insertResult.success);
        System.debug('OpportunityID -> ' + opp.Id);
        infos.put('NE__OptyId__c', opp.Id);

        if(!insertResult.success && String.isNotBlank(infos.get('currentStep'))){ // For Market
            infos.put('insertOpportunityResult', insertResult.errorMessage);
        }

        if(insertResult.success && infos.get('stream') != 'B2C') {
            opp.StageName = 'Qualified Potential Opportunity';
            opp.XC_OperaPlanningUse__c = 'Non opera di urbanizzazione primaria';
            XC_UTIL_Sobject.updateRecord(opp);
        }
    }
    
}