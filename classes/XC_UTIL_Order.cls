/**
* @author Riccardo Cossu - riccardo.cossu@nttdata.com
* @date	11/12/2018
* @description XC_UTIL_Order - UTIL CLASS REST Interface for Create/Update a Order/Order Item
**/

public without sharing class XC_UTIL_Order {  

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_Order');

    /** @description Wrapper for Order */ 
    public class OrderIFWrapper {        
        // === MANDATORY FIELDS ===
        public String OpportunityID; 
        public String OrderID;
        public String OrderStatus;
        public String AccountID;
        public String RecordType;
        // ========================
        public String ContractAccount;
        public String PointOfDelivery;
        public String OrderTracking;
        public String DeliveryID;
        public String CancellationDate;
        public String TotalOneTimeFee;
        public String TotalRecurringCharge;
        public String StartDate;
        public String ServiceAccountAsset;
        public String BillingAccountAsset;
        public String AdministrativeTasks;
        public String ModeOfcancellation;
        public String TypeOfcancellation;
        public String DeliveryType;
        public String InstallationAddress;
        public String BillingAddress;
        public String FinancialPracticeNumber;
        public String FinancialApproval;
        public String PracticeStatus;
        public String FinancialRejectReason;
        public String ComplianceApproval;
        public String Compliance1Status;
        public String ComplianceRejectReason;
        public String OrderDescription;  
        public String ContractId;
        public String ContractUrl;
        public String LinkedContract;
        public String LinkedCancellationRequested;
        public String ContractCode;
        public String ContractDate;
        public String CompanyCode;
        public String CostCenter;
        public String PaymentMode;
        public String Channel;
        public String SubChannel;
        public Boolean RegisteredOnRechargeApp;
        public DateTime CreatedDate;
        public String CouponCode;
        public String DestinationCode;
        public String CertifiedEmail;
        public String LegalEntity;
        public Boolean StartProvisioning;
        public Boolean SkipCompliance;
        public String CustomerZipCode;

        public String WorkOrderStatus;
        public Integer WorkOrderExpected;
        public Integer WorkOrderCreated;
        public Boolean AppointmentToBeScheduled;

        public String CurrencyX;

        public String Type;
        public String Subtype;

        public String CampaignPlatform;
        public String CampaignProduct;
        public String CampaignCode;
        public String ConventionCode;

        public String CommodityBillingCycleFrequency; 
        public String OrderType;
        public String DeactivationBasedOnRegulatory;
        public String AccountFiscalCode;
        public String BillingAddressData;
        public String InstallationAddressData;  

        public String ECID;
        public String ExternalOffer;
        public String LeadFormID;
        
        public String IntegrationID;

        public String CatalogID;
        public String CommercialModelID;
        public String TotalRecurringFrequency;
        public String EngineType;
        public String PriceListVersion;
        public String PriceListName;

        public Integer NumGeneratedContract;  
        public String UserNumber;
        public String UserChannelName;
        public String UserChannelCode;
        public String UserSubchannelCode;
        public String UserSubchannelName;
        public String Origin;
        public String PaymentTransactionID;
        public String PaymentTransactionDetails;
        public Date PaymentTransactionDate;
        public String UserIP;

		public string XC_MarketAssetID;//CR UPiscopo 09/11/2021 - Energy Disconnect Romania -- Added new value to the wrapper
        public String OrderSubType;
        public String AssetID;
        public String VASContractExtID;
        public String VASContractNumber;
        public String PartnerSalesChannel;
        public Boolean PartnerContractDelivered;

        public String CommodityContractNum;
        public String CommodityCC; /*20220331 NicoloFodera fix disconnect italy, added OR =CommodityCC*/
        public Date CommodityContractActivationDate;
        public String CommodityBsnLine;
        public String CommodityCancellationReason;
        public String MarketSegment;
        public String ContractedPowerFrom;
        public String ContractedPowerTo;
        public String Tariff;
        public String IBAN;
		public Boolean ActivePortfolio;

        public String OldAccountDNI;
        public String ChangeOwnerReason;
        public String ChangeOwnerType;
        public Boolean MaintainVas;

        public String BillingProfIdUpdateMop; // Used only for technical purposes in the partner event api

        public Date TimeSlotDate;
        public String TimeSlot;
        public String RemoteQuoteAcceptance;
        public String RequestDate;

        public String RemoteQuoteFlow;
        public String ContactEmail;

        //minal.mahavir.patil@accenture.com NR2299 4/5/22  start
        public String MarketLegalEntity;
        //minal.mahavir.patil@accenture.com NR2299 4/5/22 END

        //Children Object
       	public XC_UTIL_Order.OrderItemWrapper[] OrderItem = new List<XC_UTIL_Order.OrderItemWrapper>();
        public List<DocumentWrapper> Document;
        //mario.a.giordano@accenture.com 26112021 START
        public XC_UTIL_Order.AccountWrapper Account; // = new XC_UTIL_Order.AccountWrapper(); 
        //END        
    }
    /** @description AccountWrapper */
    /** @author mario.a.giordano@accenture.com */ 
    
    public class AccountWrapper{
        public String   LastName;
        public String   FirstName;
        public String   BirthDate;
        public String   Energy_Community;
        public String   Community_Tipology;
        public String   Community_Code;
        public String   VatGroupNumber;
        public String   CompanyCode;
        public String   CostCenter;
        public String   GSE_Code;
        public Decimal  Community_Members_Number;
        public String   Community_GSE_Approval_Date;
        public XC_UTIL_Order.AccountChildWrapper[] AccountChild = new List<XC_UTIL_Order.AccountChildWrapper>();
        //[ BEGIN, arjun.raoh@accenture.com, 06/01/2022, Enel X - NR2260 - Energy Communities, ENEL X - r12 ]
        public String Energy_Community_Foundation_date;
        //[ END, arjun.raoh@accenture.com, 06/01/2022, Enel X - NR2260 - Energy Communities, ENEL X - r12 ]
    }

    /*
    /** @description AccountChildWrapper */
    /** @author mario.a.giordano@accenture.com */ 
    
    public class AccountChildWrapper{
        public String LastName;
        public String FirstName;
        public String BirthDate;
        public String MemberTypology;
        public String ParentId;
        public String CustomerNumberEnelEnergia;
        //[ BEGIN, arjun.raoh@accenture.com, 06/01/2022, Enel X - NR2260 - Energy Communities, ENEL X - r12 ]
        public Double Una_tantum_member_fee;
        public Double Annual_member_fee;
        public String Annual_membership_fee_due_date;
        public Double Fix_part_sharing_monthly;
        public Double MISE_incentive;
        public Double Arera_incentive;
        public Double Local_price_incentive;
        //[ END, arjun.raoh@accenture.com, 06/01/2022, Enel X - NR2260 - Energy Communities, ENEL X - r12 ]
        /*[ BEGIN, arjun.raoh@accenture.com, 02/05/2022, NR2453 - Comunità Energetiche
        public String refundMethod;
        [ END, arjun.raoh@accenture.com, 02/05/2022, NR2453 - Comunità Energetiche*/
    }


    /** @description OrderItemWrapper */ 
    public class OrderItemWrapper{
        public String OrderItemID;
        public String ProdName;
        public String ProdID;	
		public String CatalogItemID;
        public Decimal Quantity;
		public Decimal BaseRecurringCharge;	
		public DateTime StartDate;
        public String ZSubscriptionId;
		public String ZChargeNumber;
		public String ZAccountId;
		public String StartDateSubscription;
        public String ParentOrderItem;
        public String ParentOrderItemID;
        public Decimal BaseOneTimeFee;
        public String BillingProfileID;
        public String EngineCode;
        public String PaymentMethod;
        public String PaymentType;
        public String BundleConfiguration;
        public String Brand;
        public String OrderItemType;
        public String OrderItemSubType;
        public String ProvisioningModelSteps;
        public String ActualProvisioninStep;
        public String ActualProvisioningStepStatus; //[ deepti.ramesh@accenture.com, 18/2/2022, R1-2022, AO011249, added new tag]

        //[ START m.c.mohamed.ibrahim@accenture.com, 18/2/2022, R1.1-2022, NR2187, added new tag]

        public String InstallmentsNumber;
        public String InstallmentPlanType;
        public String InstallmentFrequency;
        
        //[ END m.c.mohamed.ibrahim@accenture.com, 18/2/2022, R1.1-2022, NR2187, added new tag]

        public String AllowablePaymentTypes;
        public String BillingProfileLineItemID;
        public String ConvergentBillType;

        public String DeliveryTracking;
        public String NewRequiredDate;
        public String DateDelivery;
        public String CarrierName;

        public String Type;
        public String Subtype;

        public String CNAEContrated;
        public String BusinessLine;
        public String PowerControlModel;
        public String InvoicePeriod;
        public String ContractedPower1;
        public String ContractedPower2; 
        public String ContractedPower3; 
        public String RequestSubtype;
        public String TarifATRContracted; 
        public String ContractType;
        public String LineNumber;
        public String ProdItemId; 
        public String ProductPortId; 
        public String ServicePoint;
        public String AsociatedSTPFlag;

        public String ItemCode;
        public String RelatedProduct;
		
        public String CityCode;
        public String HouseType;
        public String UrbanSection;
        public String Sheet;
        public String Particle;
        public String Subordinate;
        public String DeliveryStatus;
        
        public String BillingProfileData;

        public String DeliveryStatusList;

        public Decimal OneTimeFeeOv;
        public Decimal RecurringChargeOv;
        public String CreditAssignmentSurvey;
        public Boolean CreditAssignmentAvailable;


        public Double OneTimeFeeDiscounted;
        public String PriceListVersionItem;
        public String PenaltyType;
        public String Bundle;
        public Double GoodCost;
        public String BundleElement;
        public Boolean Penalty;
        public String Bit2WINTranslatedProductName;
        public Double PenaltyFee;
        public String RecurringChargeFrequency;
        public String UsageCode;
        public Double RecurringChargeDiscounted;
        
        public String Action;



        public Decimal BundleTotalOTAmount;
        public Decimal CreditAssignmentAmount;
        public Decimal CreditAssignmentCustomerAmount;
        public String CatalogItemCategory;

        public List<WrapperAttribute> Attribute;
        public List<WrapperAsset> Asset;
        public List<WrapperDocuCharact> TechnicalCharacteristic;

        public List<WrapperComponent> Component; 
        public List<WrapperDiscount> OrderItemDiscount;
        public List<WrapperValidationErrors> ValidationErrors;

        /*public OrderItemWrapper(){
			OrderItemID='';
            ProdID='';
            ProdName='';
            CatalogItem='';
            Quantity=0;
            BaseRecurringCharge=0;
            StartDate= Date.today();
        }*/
    }
    //[ START m.c.mohamed.ibrahim@accenture.com, 18/2/2022, R1.1-2022, NR2187, added new Wrapper class]
    public  class optyCheckBeforeNextWrapper {
        @AuraEnabled 
        public Boolean isInCommunity; 
        @AuraEnabled     
        public String resultMessage; 
        @AuraEnabled 
        public Boolean success; 
    }
    //[ END m.c.mohamed.ibrahim@accenture.com, 18/2/2022, R1.1-2022, NR2187, added new Wrapper class]

    /** @description WrapperAttribute */ 
    public class WrapperAttribute{
        public String AttributeID;
        public String Name;
        public String Value;
        public String ProductFamilyPropertyID;
        public String OldValue;
        public Boolean Deleted;
        public String FamPropExtId;
        public String DeveloperName;    
    }

    /** @description WrapperAsset */ 
    public class WrapperAsset{
       public String AssetID;
       public String AssetName;
       public List<WrapperAssetHistory> History;
    }

    /** @description WrapperAssetHistory */ 
    public class WrapperAssetHistory{
        public String AssetStatus;
        public DateTime StatusDate;
    }

    /** @description DocumentWrapper */ 
    public class DocumentWrapper{
        public String DocumentType;
        public Decimal Quantity;
        public string ContractUrl;
        public String ExternalDocID;
    }

    /** @description WrapperDocuCharact */ 
    public class WrapperDocuCharact{
        public String Name;
        public String Value;
    }

    public class WrapperDiscount{
        public String OrderItemDiscountID;              
        public String Name;  
        public String OrderItemID;  
        public String AssetUpdateKey;  
        public String Code;  
        public String DiscountItem;  
        public Date EndDate;  
        public Decimal OneTimePercentage;  
        public Decimal OneTimePrice;  
        public Decimal OneTimeValue;  
        public String Reason;  
        public Decimal RecurringPercentage;  
        public Decimal RecurringPrice;  
        public Decimal RecurringValue;  
        public Decimal Sequence;  
        public Date StartDate;  
        public String Status;  
        public String Type;  
    }

    public class WrapperComponent{
        public String IntegrationID;
        public String ActionCode;
        public String LineNumber;
        public String ProductId;
        public String Value;
    }

    public class WrapperValidationErrors{
        public String ResultCode;
        public String BOTaskID;
        public String ErrorMessage;
    }

    /** 
    * @author Federico Amici - federico.amici@nttdata.com
    * @description The method is used to retrieve an Order ad its sons in a REST callout
    * @param OrderId the id of order
    * @return NE__Order__c
    */
    public static NE__Order__c getOrderById(Id orderId) {
        Map<Id,NE__Order__c> orderMap = new Map<Id,NE__Order__c>([SELECT Id, NE__OptyID__c, XC_Status__c, NE__AccountId__c, NE__BillingProfId__c, NE__Contract_Account__c,
                            XC_Order_Tracking__c, XC_Delivery_ID__c, XC_Cancellation_Date__c, NE__One_Time_Fee_Total__c, NE__Recurring_Charge_Total__c,
                            B2WZC__ZStart_Date__c, NE__Service_Account_Asset__c, NE__Billing_Account_Asset__c, XC_AdministrativeTasks__c, XC_Mode_of_cancellation__c,
                            XC_Type_of_cancellation__c, XC_DeliveryType__c, XC_InstallationAddress__c,XC_PracticeNumber__c, 
                            XC_FinancialApproval__c, XC_PracticeStatus__c, XC_FinancialRejectReason__c, XC_Compliance_Approval__c, XC_ComplianceRejectReason__c,
                            NE__Description__c, RecordType.Name,XC_LegalEntity__c,XC_MarketAssetID__c,
                            (SELECT Id, NE__ProdID__c, NE__ProdName__c, NE__CatalogItem__c,
                            NE__Qty__c, NE__BaseRecurringCharge__c, NE__StartDate__c FROM NE__Order_Items__r) 
                            FROM NE__Order__c WHERE Id = :orderId]);
        NE__Order__c order = orderMap.values()[0];
        return order; 
    }
    
    /**
	* @author Giulio Serra - giserra@deloitte.it
	* @date 23/01/2019 
    * @lastModified 04/04/2019  Nicola Mariniello - nmariniello@delotte.it & Luisana Rocco - lrocco@deloitte.it
	* @description Create a configuration
    * @param wreq - XC_UTIL_Order.OrderIFWrapper
    * @return NE__Order__c
	**/
    public static NE__Order__c createOrder(XC_UTIL_Order.OrderIFWrapper wreq) {
        NE__Order__c newOrder = new NE__Order__c();
        neworder.NE__Configuration_Type__c = Label.XC_CL_Configuration_TypeNew;
  
        Map<String, Object> mapOrderWrapper = new Map<String,Object>{
            'XC_Delivery_ID__c' =>  wreq.DeliveryID,
            'XC_AdministrativeTasks__c' => wreq.AdministrativeTasks,
            'XC_POD__c' => wreq.PointOfDelivery,
            'XC_Order_Tracking__c' => wreq.OrderTracking,
            'XC_CampaignPlatform__c' => wreq.CampaignPlatform,
            'XC_CampaignProduct__c' => wreq.CampaignProduct,
            'XC_CampaignCode__c' => wreq.CampaignCode,
            'XC_ConventionCode__c' => wreq.ConventionCode,
            'XC_LeadFormId__c' => wreq.LeadFormId,
            'NE__CatalogId__c' => wreq.CatalogID, 
            'NE__CommercialModelId__c' => wreq.CommercialModelID, 
            'NE__TotalRecurringFrequency__c' => wreq.TotalRecurringFrequency,
            'NE__EngineType__c' => wreq.EngineType,
            'NE__Price_List_Version__c' => wreq.PriceListVersion,
            'XC_PriceListName__c' => wreq.PriceListName,
            'XC_PaymentTransactionDate__c' =>  wreq.PaymentTransactionDate,
            'XC_PaymentTransactionDetails__c' =>  wreq.PaymentTransactionDetails,
            'XC_PaymentTransactionID__c' =>  wreq.PaymentTransactionID,
            'XC_UserIP__c' => wreq.UserIP,
            'XC_TimeSlot__c' => wreq.TimeSlot,
            'XC_RemoteQuoteAcceptance__c' => (!String.isBlank(wreq.RemoteQuoteAcceptance) ? Boolean.valueOf(wreq.RemoteQuoteAcceptance) : null),
            'XC_RequestDate__c' => wreq.RequestDate,
			'XC_MarketAssetID__c' => wreq.XC_MarketAssetID//CR UPiscopo 09/11/2021 - Energy Disconnect Romania -- Added new value
            };

        for(String key : mapOrderWrapper.keySet()){
            if(mapOrderWrapper.get(key) != null){
                newOrder.put(key, mapOrderWrapper.get(key));
            }
        }  

        if(wreq.SkipCompliance != null && wreq.SkipCompliance == true){
            newOrder.XC_Compliance_Approval__c = Label.XC_CL_Configuration_NotNeeded; // to skip compliance check
        }
        if(String.isBlank(wreq.OrderID)){
            newOrder.RecordTypeID = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByName().get('Opty').getRecordTypeId();
            newOrder.XC_Status__c = 'Draft';
        }else if(!String.isBlank(wreq.OrderStatus)){
            newOrder.XC_Status__c = wreq.OrderStatus;
        }
        if(wreq.StartDate != null){
            newOrder.B2WZC__ZStart_Date__c = Date.ValueOf(wreq.StartDate);
        }
        if(wreq.CancellationDate != null){
            newOrder.XC_Cancellation_Date__c = Date.ValueOf(wreq.CancellationDate);
        }
        if(wreq.TimeSlotDate != null){
            newOrder.XC_TimeSlotDate__c = wreq.TimeSlotDate;
        }        

        XC_UTIL_Order_U.createOrderForB2WFields(wreq, newOrder);
        XC_UTIL_Order_U.createOrderForPreferenceFields(wreq, newOrder);
        XC_UTIL_Order_U.createOrderForApprovalFields(wreq, newOrder);

        return newOrder;
    }
    
    /**
	*@author Simone Trenta - strenta@deloitte.it
	*@date 23/01/2019 LastModified : 04/04/2019  Nicola Mariniello nmariniello@delotte.it - Luisana Rocco lrocco@deloitte.it
    *@return orderItem
    *@param accountId id of account
    *@param orderId id of order
    *@param orderItemWr wrapper 
	*@description create a configuration Item
	**/
    public static NE__OrderItem__c createOrderItemFromOrder (Id accountId, Id orderId, XC_UTIL_Order.OrderItemWrapper orderItemWr){
        NE__OrderItem__c orderItem = new NE__OrderItem__c();

        Map<String, Object> mapOrderItemWrapper = new Map<String,Object>{
            'NE__OrderId__c' => orderId,
            'NE__Account__c' => accountId,
            'NE__ProdId__c' => orderItemWr.ProdID,
            'NE__Qty__c'=> orderItemWr.Quantity,
            'NE__BaseOneTimeFee__c' =>  orderItemWr.BaseOneTimeFee,
            'NE__OneTimeFeeOv__c' =>  orderItemWr.BaseOneTimeFee,
            'NE__BaseRecurringCharge__c' => orderItemWr.BaseRecurringCharge,
            'NE__RecurringChargeOv__c' => orderItemWr.BaseRecurringCharge,
            'XC_Product_Type__c' => orderItemWr.OrderItemType,
            'XC_Product_Subtype__c' => orderItemWr.OrderItemSubType,
            'XC_PaymentMethod__c' => orderItemWr.PaymentType, 
            'XC_BillingProfileLineItem__c' => orderItemWr.BillingProfileLineItemID,
            'NE__BillingProfId__c' => orderItemWr.BillingProfileID,
            'XC_CityCode__c' => orderItemWr.CityCode,
            'XC_HouseType__c' => orderItemWr.HouseType,
            'XC_UrbanSection__c' => orderItemWr.UrbanSection,
            'XC_Sheet__c' => orderItemWr.Sheet,
            'XC_Particle__c' => orderItemWr.Particle,
            'XC_Subordinate__c' => orderItemWr.Subordinate,
            'NE__OneTimeFeeDiscounted__c' => orderItemWr.OneTimeFeeDiscounted, 
            'NE__Price_List_Version_Item__c' => orderItemWr.PriceListVersionItem, 
            'NE__Penalty_Type__c' => orderItemWr.PenaltyType, 
            'NE__Bundle__c' => orderItemWr.Bundle, 
            'XC_Good_Cost__c' => orderItemWr.GoodCost, 
            'NE__Bundle_Element__c' => orderItemWr.BundleElement, 
            'NE__Penalty__c' => orderItemWr.Penalty, 
            'XC_Bit2WIN_TranslatedProductName__c' => orderItemWr.Bit2WINTranslatedProductName, 
            'NE__Penalty_Fee__c' => orderItemWr.PenaltyFee, 
            'NE__RecurringChargeFrequency__c' => orderItemWr.RecurringChargeFrequency, 
            'NE__UsageCode__c' => orderItemWr.UsageCode, 
            'NE__RecurringChargeDiscounted__c' => orderItemWr.RecurringChargeDiscounted       
            };
                                                        
        for(String key : mapOrderItemWrapper.keySet()){
            if(mapOrderItemWrapper.get(key) != null){
                orderItem.put(key, mapOrderItemWrapper.get(key));
            }
        }    
        
        //orderItem.NE__Generate_Asset_Item__c = false;

        if(orderItemWr.StartDate!=null){
            orderItem.NE__StartDate__c = Date.ValueOf(orderItemWr.StartDate);
        } 

        if(String.isNotBlank(orderItemWr.CatalogItemID)){
            orderItem.NE__CatalogItem__c = orderItemWr.CatalogItemID;
        }
        //[ BEGIN, gaurav.tejpal@accenture.com, 06/01/2022, Enel X - NR2187, ENEL X - r12 ]
        if(string.isNotBlank(orderItemWr.InstallmentPlanType)){
            orderItem.XC_InstallmentPlanType__c = orderItemWr.InstallmentPlanType;
        }
        if(string.isNotBlank(orderItemWr.InstallmentFrequency)){
            orderItem.XC_InstallmentFrequency__c = orderItemWr.InstallmentFrequency;
        }
        if(string.isNotBlank(orderItemWr.InstallmentsNumber)){
            orderItem.XC_InstallmentsNumber__c = orderItemWr.InstallmentsNumber;
        }
        //[ END, gaurav.tejpal@accenture.com, 06/01/2022, Enel X - NR2187, ENEL X - r12 ]
        return orderItem;
    }
    
    /**
	*@author Nicola Mariniello nmariniello@delotte.it - Luisana Rocco lrocco@deloitte.it
	*@date 04/04/2019
	*@description   create a configuration item Attribute
    *@param wrAttr
    *@param oiId
    *@return NE__Order_Item_Attribute__c
	**/
    public static NE__Order_Item_Attribute__c createOrdItemAttrFromWrapper(XC_UTIL_Order.WrapperAttribute wrAttr, String oiId){
        NE__Order_Item_Attribute__c oiAttr = new NE__Order_Item_Attribute__c();
        oiAttr.NE__Order_Item__c = oiId;
        oiAttr.Name = wrAttr.Name;
        oiAttr.NE__Value__c = wrAttr.Value;
        oiAttr.NE__FamPropId__c = wrAttr.ProductFamilyPropertyID; 
        return oiAttr;
    }

}