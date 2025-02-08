/**
 * The Class XC_IN018_CreateZQuote_D.
 *
 * @author      	  : Federico Amici - federico.amici@nttdata.com
 * @date Creation 	  : 27/03/2019
 * @date Modification : 13/08/2019 by Nicola Mariniello nmariniello@deloitte.it
 * @description 	  : DAO for XC_IN018_CreateZQuote_D
 */


public without sharing class XC_IN018_CreateZQuote_D {

    /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @description retrieve the configuration items
     * @param confItemId the conf item id
     * @return the item
     */
    public static NE__OrderItem__c retrieveConfigItemData(String confItemId){

			Map<Id, NE__OrderItem__c> item = 
				new Map<Id, NE__OrderItem__c>([SELECT Id,XC_BillingModel__c, XC_BillingProfileLineItem__c, XC_BillingProfileLineItem__r.XC_CustomerAccount__r.Zuora__Zuora_Id__c,XC_BillingProfileLineItem__r.XC_Status__c, NE__BillingProfId__r.NE__Payment__c, XC_BillingProfileLineItem__r.XC_CustomerAccount__c,NE__StartDate__c,
														NE__CatalogItem__c, NE__CatalogItem__r.XC_AutoRenewal__c, XC_Duration__c, NE__BillingProfId__r.B2WZC__Zuora_MethodPaymentId__c,NE__ProdId__r.Manage_Complex_Product_B2C__c,
														NE__BillingProfId__r.Zuora_Account_Id__c, NE__OrderId__r.B2Wzc__ZPaymentMethodId__c, NE__Discount_Perc_OneTimeFee__c, XC_ProvisioningSpareParts__c,
														NE__Discount_Perc_RecurringCharge__c, NE__RecurringChargeOv__c, NE__OneTimeFeeOv__c, NE__CatalogItem__r.CurrencyIsoCode, CurrencyIsoCode,NE__CatalogItem__r.XC_Mixed_VAT__c,NE__OrderId__r.NE__OptyId__r.XC_Milestone_Management__c,
														NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c,  NE__Bundle_Configuration__c, XC_PaymentMethod__c, NE__ProdId__c, NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c,
														NE__Bundle_Configuration__r.XC_CreditAssignmentAmount__c, NE__Bundle_Configuration__r.XC_BundleTotalOTAmount__c, NE__Bundle_Configuration__r.XC_CreditAssignmentAvailable__c, NE__OrderId__r.XC_ActivationDateOverride__c,
														XC_Product_Type__c, XC_Product_Subtype__c, NE__Item_Code__c, NE__OrderId__c, NE__OrderId__r.XC_Segment__c, NE__OrderId__r.NE__AccountId__r.XC_RecordTypeDeveloperName__c, NE__OrderId__r.NE__OptyId__c,
														XC_BillingProfileLineItem__r.XC_BillingProfile__r.XC_CommodityCupsID__c, NE__CatalogItem__r.NE__Catalog_Id__r.XC_LIC_Name__c,XC_BankTransferCode__c,NE__RecurringChargeFrequency__c, XC_RecurringDuration__c,
														XC_InstallmentPlanType__c, InstallmentDivisionTax__c, XC_InstallmentFrequency__c, XC_InstallmentsNumber__c, 	 XC_InstallmentRate__c, NE__OrderId__r.XC_Annex__c, NE__OrderId__r.XC_PossibleCompensation__c, NE__OrderId__r.XC_PossibleCompensationNew__c,XC_Interests_Index__c,
														NE__ProdName__c, NE__OrderId__r.NE__OptyId__r.XC_CompanyCode__c, NE__OrderId__r.NE__OptyId__r.XC_CostCenter__c, NE__OrderId__r.NE__OptyId__r.XC_ActivationCountry__c, NE__OrderId__r.NE__OptyId__r.XC_ProtocolDate__c, NE__OrderId__r.NE__OptyId__r.XC_ProtocolType__c, NE__OrderId__r.NE__OptyId__r.XC_NumeroProtocolloEsportatoreAbituale__c, NE__OrderId__r.XC_VASContractNumber__c,
														NE__CatalogItem__r.XC_ProductServiceType__c, NE__CatalogItem__r.XC_ProductLine__c, XC_Wbe__c, XC_ProductLine__c, XC_ProductServiceType__c, XC_CMProfitCenter__c, XC_CMCostCenter__c, XC_CountryFormula__c, XC_Select_Tax_Completed__c, XC_Exemptions__c,
														XC_BillingProfileLineItem__r.XC_BillingProfile__r.XC_LastEventDate__c, XC_BillingProfileLineItem__r.XC_BillingProfile__r.NE__Payment__c, NE__OrderId__r.XC_Country__c, NE__OrderId__r.NE__OptyId__r.Account.XC_AccountTaxType__c,
														XC_Tax_Type__c, XC_Tax_Subtype__c, XC_TaxRatePlan__c, XC_ApplyNormalTaxByDefault__c, XC_Not_Subject__c, XC_Sujeto_Pasivo_ISP__c, XC_Segment__c,
														NE__OrderId__r.XC_LegalEntity__c, NE__OrderId__r.NE__Type__c, NE__OrderId__r.XC_Subtype__c,
														(SELECT Id, Name, NE__Value__c, XC_DeveloperName__c, NE__FamPropId__r.NE__FamilyId__r.XC_LIC_Family_Name__c FROM NE__Order_Item_Attributes__r), 
														(SELECT CreatedDate FROM Assets__r),
                                               			(SELECT XC_DeliveryId__c, XC_EffectiveDeliveryDate__c FROM Work_Orders__r), NE__OrderId__r.NE__OptyId__r.XC_DataType__c,  NE__OrderId__r.NE__OptyId__r.XC_TextReference__c
												FROM NE__OrderItem__c 
												WHERE Id = :confItemId
												LIMIT 1]);//[2021-10-14 :: TP :: Third Party Billing :: adding VASContractNumber] [2021-12-16 :: FM :: adding XC_BillingProfileLineItem__r.XC_Status__c, NE__BillingProfId__r.NE__Payment__c, XC_BillingProfileLineItem__r.XC_CustomerAccount__c][//CR2249 - Gestione date contrattuali - federico.manni@accenture.com R1 2022 add NE__StartDate__c]
														  //2022-01-03 ALC ENELX - Adding VAT Management Fields: XC_Select_Tax_Completed__c, XC_Exemptions__c, XC_Tax_Type__c, XC_Tax_Subtype__c, XC_TaxRatePlan__c, XC_ApplyNormalTaxByDefault__c, XC_Not_Subject__c, XC_Sujeto_Pasivo_ISP__c
														  //[2022-02-11 :: NR2122 - Cumulative Invoice :: Retrieve XC_DeliveryId__c, XC_EffectiveDeliveryDate__c from WorkOrder :: ETsiolaki]
														  //[2022-05-17 :: NR1640 - LR :: Adding Fields: NE__OrderId__r.XC_LegalEntity__c, NE__OrderId__r.NE__Type__c, NE__OrderId__r.XC_Subtype__c]
			return item.values()[0];
	}
    

	/**
     * @author Nicola Mariniello - nmariniello@deloitte.it  / Luisana Rocco - lrocco@deloitte.it
     * @description retrieve the  bundle configuration items
     * @param bundleConfig the conf item id
     * @return the items
     */
    public static List<NE__OrderItem__c> retrieveBundleConfItems(String bundleConfig){

		Map<Id, NE__OrderItem__c> items = 
			new Map<Id, NE__OrderItem__c>([SELECT NE__Bundle_Configuration__c, XC_Product_Type__c, NE__CatalogItem__r.XC_Mixed_VAT__c, NE__OrderId__r.NE__AccountId__r.XC_RecordTypeDeveloperName__c,CurrencyIsoCode
											FROM NE__OrderItem__c 
											WHERE NE__Bundle_Configuration__c = :bundleConfig]);
		return items.values();
	}


	/**
     * @author Roberta Cossiga - rcossiga@deloitte.it
     * @description retrieve the  subsidy configuration items
     * @param confItem
     * @return the items
     */
    public static List<NE__OrderItem__c> retrieveRelatedProductConfItems(NE__OrderItem__c confItem){

		Map<Id, NE__OrderItem__c> items = 
			new Map<Id, NE__OrderItem__c>([SELECT Id
											FROM NE__OrderItem__c 
											WHERE XC_RelatedProduct__c = : confItem.NE__Item_Code__c
												AND NE__OrderId__c =: confItem.NE__OrderId__c
												AND XC_Product_Type__c = 'Billing'
												AND XC_Product_Subtype__c = 'Promotion']);
		return items.values();
	}


	/**
     * @author Nicola Mariniello - nmariniello@deloitte.it  / Luisana Rocco - lrocco@deloitte.it
     * @description retrieve the tecnical product configuration items
     * @param confItem
     * @return the items
     */
    public static List<NE__OrderItem__c> retrieveTecnicalProductConfItems(String orderId){

		Map<Id, NE__OrderItem__c> items = 
			new Map<Id, NE__OrderItem__c>([SELECT Id
											FROM NE__OrderItem__c 
											WHERE NE__OrderId__c =: orderId AND XC_Product_Type__c =: Label.XC_CL_Technical AND XC_Product_Subtype__c =: 'Product']);
		return items.values();
	}
	
	/**
     * @author Michelangelo Padalino - michelangelo.padalino@soft.it
     * @description retrieve the tecnical product configuration child item for complex product B2C
     * @param itemId
     * @return the items
     */
	public static List<NE__OrderItem__c> retrieveTecnicalProductConfItemsChildren(String itemId){

		Map<Id, NE__OrderItem__c> items = 
                new Map<Id, NE__OrderItem__c>([select id from NE__OrderItem__c where NE__Root_Order_Item__c =:itemId]);
				return items.values();
	}

	/**
     * @author Nicola Mariniello - nmariniello@deloitte.it  / Luisana Rocco - lrocco@deloitte.it
     * @description retrieve the tecnical product configuration items
     * @param confItem
	 * @param type
	 * @param subtype
     * @return the items
     */
    public static List<NE__OrderItem__c> retrieveConfItemsForSpareParts(String orderId, String type, String subtype){

		Map<Id, NE__OrderItem__c> items = 
			new Map<Id, NE__OrderItem__c>([SELECT Id,CurrencyIsoCode
											FROM NE__OrderItem__c 
											WHERE NE__OrderId__c =: orderId AND XC_Product_Type__c =: type AND XC_Product_Subtype__c =: subtype]);
		return items.values();
	}


    /**
	 * @author Francesco Imperioli - fimperioli@deloitte.it
	 * @description retrieves all configuration item discounts for the configuration item
	 * @param confItem
	 * @return the discountItem
	 */
	public static Map<String,List<NE__Order_Item_Discount__c>> retrieveDiscountItemsMap(List<String> confItemIds){
		
		List<NE__Order_Item_Discount__c> discounts = [SELECT Id,Name, NE__Order_Item__c, NE__Asset_update_key__c, 
		NE__Code__c, NE__Discount_Item__c, NE__End_Date__c, NE__One_Time_Percentage__c, 
		NE__One_Time_Price__c, NE__One_Time_Value__c, NE__Reason__c, NE__Recurring_Percentage__c, NE__Recurring_Price__c, 
		NE__Recurring_Value__c, NE__Sequence__c, NE__Start_Date__c, NE__Status__c, NE__Type__c, NE__Order_Item__r.NE__OrderId__r.CreatedDate  
		FROM NE__Order_Item_Discount__c WHERE NE__Order_Item__c IN : confItemIds];

		Map<String,List<NE__Order_Item_Discount__c>> result =  new Map<String,List<NE__Order_Item_Discount__c>>();

		for(NE__Order_Item_Discount__c disc : discounts){

			if(!result.containsKey(disc.NE__Order_Item__c)){
				result.put(disc.NE__Order_Item__c,new List<NE__Order_Item_Discount__c>{disc});
			}else{
				result.get(disc.NE__Order_Item__c).add(disc);
			}
		}
		return result; 
	}

		/**
     * @author Luisana Rocco - lrocco@deloitte.it
     * @description retrieve configuration items by licProductName
     * @param itemId 
	 * @param orderId 
	 * @param licProductName 
     * @return the items
     */
    public static List<NE__OrderItem__c> retrieveConfItemsbyProd(String itemId, String orderId, String licProductName){

		Map<Id, NE__OrderItem__c> items = 
			new Map<Id, NE__OrderItem__c>([SELECT id, createdDate, XC_Effective_Start_Date_Recurring__c,
										  (SELECT Id, CreatedDate FROM Assets__r)  
										  FROM NE__OrderItem__c 
										  WHERE NE__OrderId__c =: orderId AND NE__ProdId__r.XC_LIC_Product_Name__c =: licProductName
										  AND NE__Parent_Order_Item__c =: itemId
										  order by XC_Effective_Start_Date_Recurring__c DESC]);
		return items.values();
	}



	/**
	 * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
	 * @description retrieve zuora flags
	 * @param wr the ManageCreationWrapper
	 * @param item the conf item
	 */
	public static void retrieveZuoraFlags(XC_IN018_CreateZQuote.ManageCreationWrapper wr, NE__OrderItem__c item) {

		String legalEntity = String.isNotBlank(item.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c) ? item.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c : item.NE__OrderId__r.XC_LegalEntity__c;
		String billingModel = item.XC_BillingModel__c;
		String catalog = item.NE__CatalogItem__r.NE__Catalog_Id__r.XC_LIC_Name__c;
		
		Map<Id, XC_CM_ZuoraInvoiceGenConfiguration__mdt> zuoraFlags = new Map<Id, XC_CM_ZuoraInvoiceGenConfiguration__mdt>(
																		[SELECT Id, XC_GenerateInvoice__c, XC_SeparateInvoice__c, XC_InitialTerm__c, XC_AutoRenew__c, XC_GenerateSubscriptionEvergreen__c, XC_PaymentMethod__c 
																		FROM XC_CM_ZuoraInvoiceGenConfiguration__mdt
																		WHERE XC_LegalEntity__c =: legalEntity AND XC_BillingModel__c =: billingModel AND XC_Catalog__c =: catalog]);
		
		for(XC_CM_ZuoraInvoiceGenConfiguration__mdt cmdt : zuoraFlags.values()) {
			if(String.isBlank(cmdt.XC_PaymentMethod__c) || (item.XC_PaymentMethod__c == cmdt.XC_PaymentMethod__c)) {
				wr.generateInvoice = cmdt.XC_GenerateInvoice__c;
				wr.separateInvoice = cmdt.XC_SeparateInvoice__c;
				wr.generateEvergreen = cmdt.XC_GenerateSubscriptionEvergreen__c;
				if(item.XC_PaymentMethod__c == cmdt.XC_PaymentMethod__c) {
					break;
				}
			}
		}

	}
    
    /**
	 * @author Eleni Tsiolaki - etsiolaki@deloitte.gr
	 * @description retrieve WorkOrder Fields
	 * @param orderId string
	 * @return the workOrder
	 */
	public static List<WorkOrder> retrieveWOfields(String orderId){
		List<WorkOrder> wo = [SELECT ID, XC_DeliveryId__c , XC_EffectiveDeliveryDate__c FROM WorkOrder WHERE XC_Configuration__c =: orderId];
		return wo;
	}

}