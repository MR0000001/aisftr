/**
* @author Eleni Tsiolaki - etsiolaki@deloitte.gr
* @date Creation  02/03/2022
* @description XC_REST_ContractAmendment_TEST – Test class for XC_REST_ContractAmendment
*/

@isTest
public class XC_REST_ContractAmendment_TEST {
    
    //Test Method retrieveSubscriptionByName
    //static testMethod void retrieveSubscriptionByNameTest(){
        //Test.setMock(HttpCalloutMock.class, new XC_REST_ZuoraToken_Mock());
    @TestSetup
	static void setup(){   
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = 'ContractAmendment';
        ic.XC_interfaceName__c = 'ContractAmendment';
        insert ic;
        
        Zuora_OAuth__c zws = new Zuora_OAuth__c();
        zws.EntityName__c ='Spain'; 
        zws.EntityId__c= '8adce421661fcddc01664460d73d41c2';
        zws.Client_Secret__c='qzeQayHZPUQFRsuSSprAFfP6mgRe4sviHtE5wAFa' ; 
        zws.Client_Id__c = 'aaf997e3-4edd-4008-a5ba-f778e6d83149	';
        zws.Host__c= 'rest.sandbox.eu.zuora.com';
        zws.apiToken__c ='headerDefinitions';
        insert zws; 
        
        
        List<NE__OrderItem__c> orderItems = XC_DF_OrderItem.createOrderItems(1);
        for(NE__OrderItem__c o: orderItems) {
            o.XC_BillingModel__c = 'Recurring';
            o.XC_Particle__c = 'FALSE';
            o.XC_CA_UpdatePrice__c = true;
        }
        insert orderItems;
        XC_ContractAmendment__c contractAmendment = new XC_ContractAmendment__c(XC_Status__c = 'New', XC_EndDateBeforeExtension__c = Date.today().addDays(-1), XC_EndDateAfterLastExtension__c= Date.today() );
        XC_ContractAmendment__c contractAmendmentChild = new XC_ContractAmendment__c(XC_Status__c = 'New', XC_EndDateBeforeExtension__c = Date.today().addDays(-1), XC_EndDateAfterLastExtension__c= Date.today());
        List<XC_ContractAmendment__c> listContAmend = new List<XC_ContractAmendment__c>{contractAmendment,contractAmendmentChild};
        insert listContAmend;
        List<Asset> listAssets = XC_DF_Asset.createAssets(1);
        listAssets[0].XC_Configuration_Item__c = orderItems[0].Id;
        listAssets[0].XC_Original_Configuration_Item__c = orderItems[0].Id;
        listAssets[0].XC_Original_Creation_OrderItem__c  = orderItems[0].Id;
        listAssets[0].XC_Contract_Amendment__c = contractAmendment.id;
        listAssets[0].XC_Particle__c = 'false';
        listAssets[0].XC_Segment__c = 'B2C';
        listAssets[0].XC_LegalEntity__c ='EndesaX';
        listAssets[0].XC_SubscriptionName__c = 'test?test';
        insert listAssets;
        contractAmendment.XC_Asset__c = listAssets[0].id;
        contractAmendmentChild.XC_Asset__c = listAssets[0].id;
        contractAmendmentChild.Contract_Amendment_Parent__c = contractAmendment.id;
        update contractAmendment;
        update contractAmendmentChild;
        
        XC_REST_GetSubscription.WrapperRequest wrReq = new XC_REST_GetSubscription.WrapperRequest();
        wrReq.legalEntity = 'EndesaX';
        wrReq.stream = 'B2C';
       
        /*List<XC_ContractAmendment__c> parents =  [SELECT Id, Contract_Amendment_Parent__c ,CreatedDate, XC_Contract__r.ContractNumber, XC_EndDateBeforeExtension__c, XC_EndDateAfterLastExtension__c, XC_Asset__r.Name, 
        XC_Asset__r.XC_Particle__c, XC_Asset__r.XC_Segment__c, XC_Status__c, XC_Asset__r.XC_LegalEntity__c, XC_Asset__r.XC_SubscriptionName__c, XC_Asset__r.XC_Configuration_Item__c, XC_CostAfterLastRevaluation__c, 
                         XC_Asset__r.XC_Configuration_Item__r.NE__RecurringChargeOv__c, XC_Asset__r.XC_Configuration_Item__r.XC_CA_UpdatePrice__c, XC_Asset__r.XC_Configuration_Item__r.NE__OrderId__c, XC_Percentage__c,  XC_Asset__r.NE__RecurringChargeFrequency__c,XC_Contract__r.EndDate, 
                         XC_Asset__r.XC_Original_Configuration_Item__r.XC_ZQuoteId__c, XC_Asset__r.XC_Configuration_Item__r.XC_ZQuoteId__c, 
                       (SELECT Id, XC_Asset__r.XC_Particle__c, Contract_Amendment_Parent__c, XC_Asset__r.XC_SubscriptionName__c, XC_Asset__r.XC_Configuration_Item__c, XC_CostAfterLastRevaluation__c, XC_EndDateAfterLastExtension__c ,XC_CostBeforeLastRevaluation__c, XC_EndDateBeforeExtension__c, 
                       XC_Asset__r.XC_Configuration_Item__r.XC_CA_UpdatePrice__c, XC_Percentage__c, XC_Asset__r.NE__RecurringChargeFrequency__c,XC_Contract__r.EndDate, XC_Asset__r.XC_Original_Configuration_Item__r.XC_ZQuoteId__c, XC_Asset__r.XC_Configuration_Item__r.XC_ZQuoteId__c  FROM XC_ContractAmendmentsChilds__r WHERE XC_Asset__r.XC_Particle__c = 'false') 
                      FROM XC_ContractAmendment__c 
                    WHERE XC_Status__c = 'New' AND XC_Asset__c != null AND Contract_Amendment_Parent__c = null AND XC_Asset__r.XC_Particle__c = 'false' order by CreatedDate desc];
        List<XC_ContractAmendment__c> child = new List<XC_ContractAmendment__c>();
        child.add(contractAmendmentChild);

        
        
		Test.startTest();        
        XC_REST_ContractAmendment.retrieveSubscription(parents, child);

        Test.stopTest();*/
    }
    
    @isTest
	static void UpdatePriceTest(){

        NE__OrderItem__c o = [SELECT id FROM NE__OrderItem__c LIMIT1];
        o.XC_CA_UpdatePrice__c = true;
        o.XC_CA_UpdateDate__c = false;
        update o;

        List<XC_ContractAmendment__c> parents =  [SELECT Id, Contract_Amendment_Parent__c ,CreatedDate, XC_Contract__r.ContractNumber, XC_EndDateBeforeExtension__c, XC_EndDateAfterLastExtension__c, XC_Asset__r.Name, 
        XC_Asset__r.XC_Particle__c, XC_Asset__r.XC_Segment__c, XC_Status__c, XC_Asset__r.XC_LegalEntity__c, XC_Asset__r.XC_SubscriptionName__c, XC_Asset__r.XC_Configuration_Item__c, XC_CostAfterLastRevaluation__c, 
                         XC_Asset__r.XC_Configuration_Item__r.NE__RecurringChargeOv__c, XC_Asset__r.XC_Configuration_Item__r.XC_CA_UpdatePrice__c, XC_Asset__r.XC_Configuration_Item__r.NE__OrderId__c, XC_Percentage__c,  XC_Asset__r.NE__RecurringChargeFrequency__c,XC_Contract__r.EndDate, 
                         XC_Asset__r.XC_Original_Configuration_Item__r.XC_ZQuoteId__c, XC_Asset__r.XC_Configuration_Item__r.XC_ZQuoteId__c, 
                       (SELECT Id, XC_Asset__r.XC_Particle__c, Contract_Amendment_Parent__c, XC_Asset__r.XC_SubscriptionName__c, XC_Asset__r.XC_Configuration_Item__c, XC_CostAfterLastRevaluation__c, XC_EndDateAfterLastExtension__c ,XC_CostBeforeLastRevaluation__c, XC_EndDateBeforeExtension__c, 
                       XC_Asset__r.XC_Configuration_Item__r.XC_CA_UpdatePrice__c, XC_Percentage__c, XC_Asset__r.NE__RecurringChargeFrequency__c,XC_Contract__r.EndDate, XC_Asset__r.XC_Original_Configuration_Item__r.XC_ZQuoteId__c, XC_Asset__r.XC_Configuration_Item__r.XC_ZQuoteId__c  FROM XC_ContractAmendmentsChilds__r WHERE XC_Asset__r.XC_Particle__c = 'false') 
                      FROM XC_ContractAmendment__c 
                    WHERE XC_Status__c = 'New' AND XC_Asset__c != null AND Contract_Amendment_Parent__c = null AND XC_Asset__r.XC_Particle__c = 'false' order by CreatedDate desc];
        List<XC_ContractAmendment__c> child = new List<XC_ContractAmendment__c>();
        child.addAll(parents[0].XC_ContractAmendmentsChilds__r);

        Test.setMock(HttpCalloutMock.class, new XC_REST_ZuoraToken_Mock());
 
		Test.startTest();        
        XC_REST_ContractAmendment.retrieveSubscription(parents, child);

        Test.stopTest();
        
    }

    @isTest
	static void UpdateDateTest(){

        NE__OrderItem__c o = [SELECT id FROM NE__OrderItem__c LIMIT1];
        o.XC_CA_UpdatePrice__c = false;
        o.XC_CA_UpdateDate__c  = true;
        update o;

        List<XC_ContractAmendment__c> parents =  [SELECT Id, Contract_Amendment_Parent__c ,CreatedDate, XC_Contract__r.ContractNumber, XC_EndDateBeforeExtension__c, XC_EndDateAfterLastExtension__c, XC_Asset__r.Name, 
        XC_Asset__r.XC_Particle__c, XC_Asset__r.XC_Segment__c, XC_Status__c, XC_Asset__r.XC_LegalEntity__c, XC_Asset__r.XC_SubscriptionName__c, XC_Asset__r.XC_Configuration_Item__c, XC_CostAfterLastRevaluation__c, 
                         XC_Asset__r.XC_Configuration_Item__r.NE__RecurringChargeOv__c, XC_Asset__r.XC_Configuration_Item__r.XC_CA_UpdatePrice__c, XC_Asset__r.XC_Configuration_Item__r.NE__OrderId__c, XC_Percentage__c,  XC_Asset__r.NE__RecurringChargeFrequency__c,XC_Contract__r.EndDate, 
                         XC_Asset__r.XC_Original_Configuration_Item__r.XC_ZQuoteId__c, XC_Asset__r.XC_Configuration_Item__r.XC_ZQuoteId__c, 
                       (SELECT Id, XC_Asset__r.XC_Particle__c, Contract_Amendment_Parent__c, XC_Asset__r.XC_SubscriptionName__c, XC_Asset__r.XC_Configuration_Item__c, XC_CostAfterLastRevaluation__c, XC_EndDateAfterLastExtension__c ,XC_CostBeforeLastRevaluation__c, XC_EndDateBeforeExtension__c, 
                       XC_Asset__r.XC_Configuration_Item__r.XC_CA_UpdatePrice__c, XC_Percentage__c, XC_Asset__r.NE__RecurringChargeFrequency__c,XC_Contract__r.EndDate, XC_Asset__r.XC_Original_Configuration_Item__r.XC_ZQuoteId__c, XC_Asset__r.XC_Configuration_Item__r.XC_ZQuoteId__c  FROM XC_ContractAmendmentsChilds__r WHERE XC_Asset__r.XC_Particle__c = 'false') 
                      FROM XC_ContractAmendment__c 
                    WHERE XC_Status__c = 'New' AND XC_Asset__c != null AND Contract_Amendment_Parent__c = null AND XC_Asset__r.XC_Particle__c = 'false' order by CreatedDate desc];
        List<XC_ContractAmendment__c> child = new List<XC_ContractAmendment__c>();
        child.addAll(parents[0].XC_ContractAmendmentsChilds__r);

        
        Test.setMock(HttpCalloutMock.class, new XC_REST_ZuoraToken_Mock());
        
		Test.startTest();        
        XC_REST_ContractAmendment.retrieveSubscription(parents, child);

        Test.stopTest();
        
    }

    @isTest
	static void UpdateDateterminationTest(){

        NE__OrderItem__c o = [SELECT id FROM NE__OrderItem__c LIMIT1];
        o.XC_CA_UpdatePrice__c = false;
        o.XC_CA_UpdateDate__c  = true;
        update o;

        List<XC_ContractAmendment__c> parents =  [SELECT Id, Contract_Amendment_Parent__c ,CreatedDate, XC_Contract__r.ContractNumber, XC_EndDateBeforeExtension__c, XC_EndDateAfterLastExtension__c, XC_Asset__r.Name, 
        XC_Asset__r.XC_Particle__c, XC_Asset__r.XC_Segment__c, XC_Status__c, XC_Asset__r.XC_LegalEntity__c, XC_Asset__r.XC_SubscriptionName__c, XC_Asset__r.XC_Configuration_Item__c, XC_CostAfterLastRevaluation__c, 
                         XC_Asset__r.XC_Configuration_Item__r.NE__RecurringChargeOv__c, XC_Asset__r.XC_Configuration_Item__r.XC_CA_UpdatePrice__c, XC_Asset__r.XC_Configuration_Item__r.NE__OrderId__c, XC_Percentage__c,  XC_Asset__r.NE__RecurringChargeFrequency__c,XC_Contract__r.EndDate, 
                         XC_Asset__r.XC_Original_Configuration_Item__r.XC_ZQuoteId__c, XC_Asset__r.XC_Configuration_Item__r.XC_ZQuoteId__c, 
                       (SELECT Id, XC_Asset__r.XC_Particle__c, Contract_Amendment_Parent__c, XC_Asset__r.XC_SubscriptionName__c, XC_Asset__r.XC_Configuration_Item__c, XC_CostAfterLastRevaluation__c, XC_EndDateAfterLastExtension__c ,XC_CostBeforeLastRevaluation__c, XC_EndDateBeforeExtension__c, 
                       XC_Asset__r.XC_Configuration_Item__r.XC_CA_UpdatePrice__c, XC_Percentage__c, XC_Asset__r.NE__RecurringChargeFrequency__c,XC_Contract__r.EndDate, XC_Asset__r.XC_Original_Configuration_Item__r.XC_ZQuoteId__c, XC_Asset__r.XC_Configuration_Item__r.XC_ZQuoteId__c  FROM XC_ContractAmendmentsChilds__r WHERE XC_Asset__r.XC_Particle__c = 'false') 
                      FROM XC_ContractAmendment__c 
                    WHERE XC_Status__c = 'New' AND XC_Asset__c != null AND Contract_Amendment_Parent__c = null AND XC_Asset__r.XC_Particle__c = 'false' order by CreatedDate desc];
        List<XC_ContractAmendment__c> child = new List<XC_ContractAmendment__c>();
        child.addAll(parents[0].XC_ContractAmendmentsChilds__r);

        parents[0].XC_EndDateBeforeExtension__c = Date.today().addDays(10);
        parents[0].XC_EndDateAfterLastExtension__c= Date.today();
        update parents[0];
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_ZuoraToken_Mock());
        
		Test.startTest();        
        XC_REST_ContractAmendment.retrieveSubscription(parents, child);

        Test.stopTest();
        
    }

    public with sharing class XC_REST_ZuoraToken_Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) { 
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String json = '{ "success": true, "id": "8adcddea7f6e81a3017f73024bb13e94", "accountId": "8adcc2417e763ea4017e76e1ac9619cf", "accountNumber": "A-IT 00217106", "accountName": "Account B2G Enel Sole_2022", "invoiceOwnerAccountId": "8adcc2417e763ea4017e76e1ac9619cf", "invoiceOwnerAccountNumber": "A-IT 00217106", "invoiceOwnerAccountName": "Account B2G Enel Sole_2022", "subscriptionNumber": "A-S-IT00512909", "version": 1, "revision": "1.0", "termType": "TERMED", "invoiceSeparately": true, "contractEffectiveDate": "2021-04-01", "serviceActivationDate": "2021-04-01", "customerAcceptanceDate": "2021-04-01", "subscriptionStartDate": "2021-04-01", "subscriptionEndDate": "2023-05-01", "termStartDate": "2021-04-01", "termEndDate": "2023-05-01", "initialTerm": 25, "initialTermPeriodType": "Month", "currentTerm": 25, "currentTermPeriodType": "Month", "autoRenew": false, "renewalSetting": "RENEW_WITH_SPECIFIC_TERM", "renewalTerm": 1, "renewalTermPeriodType": "Month", "contractedMrr": 1100, "totalContractedValue": 27500, "notes": null, "status": "Active", "QuoteNumber__QT": "Q037270", "XC_InteresesdeDemora__c": "No", "OpportunityName__QT": null, "XC_MixedVATDescr__c": null, "XC_ContractType__c": "Commodity, construction and service contracts", "XC_OrdendeCompra__c": null, "RevenueSharingPrice__c": null, "XC_ContractId__c": null, "XC_ProjectTaskId__c": "aC47a000000L01tCAC", "XC_DTTNumberAndDate__c": null, "XC_BlockType__c": null, "XC_TassaDeUsura__c": null, "QuoteType__QT": "New Subscription", "XC_Pod__c": null, "XC_Conformidad__c": null, "XC_InstallmentFrequency__c": null, "XC_MixedVat__c": "N", "XC_AdditionalDescription__c": null, "XC_Asset_ID__c": null, "XC_BankTransferCode__c": null, "BillingModel__c": "Recurring", "XC_PaymentTerm__c": "0", "XC_BillingBlockReason__c": null, "XC_Determina__c": "323232312", "XC_InstallmentPlanType__c": null, "InvoiceMigrationInfo2__c": null, "AutoPost__c": "Yes", "InstallmentDivisionTax__c": "yes", "XC_ConfigurationItem__c": "a1t7a000006BJBjAAO", "XC_CompanyCode__c": "OR-0010123202;OR-0010123202", "XC_CigCup__c": "2111111111;324534444444444", "XC_PossibleCompensation__c": "no", "XC_Gestor__c": null, "XC_ProjectId__c": "aC57a000000Kz0CCAS", "XC_InstallmentRate__c": null, "XC_BillingPlanTotalAmount__c": null, "XC_OrderCurrency__c": null, "productCategory__c": null, "XC_IncentiveAmount__c": null, "XC_PartnerRevenueSharingPercentage__c": null, "XC_Observaciones__c": null, "InvoiceMigrationInfo1__c": null, "XC_BillingBlockDates__c": null, "CpqBundleJsonId__QT": "8adc8ea17f6e6c58017f73023bb46cb6", "ProtocolNumber__c": null, "XC_ParentSubscriptionId__c": null, "Everest_Contract_Id__c": null, "QuoteBusinessType__QT": null, "InvoiceMigrationInfo3__c": null, "XC_InstallmentsNumber__c": null, "CRMConfiguration__c": "a1x7a000001H1ZUAA0", "XC_InvoiceType__c": "Single Invoice - Separated by Materials", "XC_Annex__c": "no", "OpportunityCloseDate__QT": null, "XC_Referencia__c": null, "CRMContractNumber__c": "OR-0010123202", "billToContact": null, "paymentTerm": null, "ratePlans": [ { "id": "8adcddea7f6e81a3017f73024d0e3e9b", "productId": "8adc9dee75e5b1da0175fefe33c94cda", "productName": "Public lighting efficient solutions esco model", "productSku": "SKU-A-00034578", "productRatePlanId": "8adce42175e5c6fa0175fefe35930dea", "ratePlanName": "Public lighting efficient solutions esco model recurring 42", "NotesRatePlan__c": null, "XC_CentrodeCosto__c": null, "RatePlanOptionId__QT": null, "XC_bollo__c": null, "RatePlanOptionOverrideId__QT": null, "RatePlanBundleId__QT": null, "RatePlanOptionExtendId__QT": null, "RatePlanOptionGroupId__QT": null, "RatePlanOptionType__QT": null, "XC_GoodAmount__c": null, "ratePlanCharges": [ { "id": "8adcddea7f6e81a3017f73024d253e9c", "originalChargeId": "8adcddea7f6e81a3017f73024d253e9c", "productRatePlanChargeId": "8adcd9eb75e5c7040175feff06b937e2", "number": "C-IT02040251", "name": "Public lighting efficient solutions esco model", "type": "Recurring", "model": "PerUnit", "uom": "Each", "version": 1, "pricingSummary": "EUR0/Each", "priceChangeOption": null, "priceIncreasePercentage": null, "currency": "EUR", "price": 0, "tiers": null, "chargeModelConfiguration": null, "inputArgumentId": null, "includedUnits": null, "overagePrice": null, "discountPercentage": null, "discountAmount": null, "applyDiscountTo": null, "discountLevel": null, "discountClass": null, "discountApplyDetails": [], "billingDay": "SpecificDayofMonth/1st of the month", "listPriceBase": "Per_Month", "billingPeriod": "Month", "specificBillingPeriod": null, "billingTiming": "IN_ARREARS", "ratingGroup": null, "billingPeriodAlignment": "AlignToCharge", "quantity": 1, "smoothingModel": null, "numberOfPeriods": null, "overageCalculationOption": null, "overageUnusedUnitsCreditOption": null, "unusedUnitsCreditRates": null, "usageRecordRatingOption": null, "segment": 1, "effectiveStartDate": "2021-04-01", "effectiveEndDate": "2023-05-01", "processedThroughDate": null, "chargedThroughDate": null, "done": false, "triggerDate": null, "triggerEvent": "ServiceActivation", "endDateCondition": "Subscription_End", "upToPeriodsType": null, "upToPeriods": null, "specificEndDate": null, "mrr": 0, "dmrc": 0, "tcv": 0, "dtcv": 0, "description": "Public lighting efficient solutions esco model", "XC_CumulativeInvoiceType__c": null, "CRMAssetID__c": "02i7a00000RJaZTAA1", "TariffType__c": null, "XC_SubsidySubtype__c": null, "XC_Discount__c": null, "XC_OvverideAccountingCode__c": null, "XC_DaneCode__c": null, "XC_InvoiceDescription__c": "Illuminazione Pubblica - esco model", "XC_ProjectDimension__c": null, "XC_LawDescriptionCode__c": null, "XC_ExchangeRate__c": null, "XC_SubsidyCode__c": null, "XC_PercentualeSAL__c": null, "XC_ProfitCenter__c": "IT1F4S5YAY", "XC_CostCenter__c": "IT1F4S05YA", "IncludedkWh__c": null, "XC_PriceBillingPlan__c": null, "XC_WBE__c": "IT1FE400YAYS00120031E2", "XC_RagioneSAL__c": null, "XC_NumeroSAL__c": null, "XC_TotalToPay__c": null, "XC_DynamicPropertyDefinition__c": null, "XC_Hierarchy__c": "Root", "XC_LawDescription__c": null, "XC_SubsidyForm__c": null, "XC_WBEStatus__c": "Approved", "XC_GoodAmount__c": null, "XC_SubsidyDuration__c": null, "XC_CumulativeInvoiceCode__c": null, "LastModifiedBy__c": null, "XC_VASCode__c": null, "XC_SubsidyAmount__c": null, "XC_DiscountReason__c": null, "XC_OriginalCurrencyPrice__c": null, "XC_SubsidyType__c": null, "XC_SubsidyCollectionType__c": null, "XC_RootName__c": null } ], "externallyManagedPlanId": null } ], "externallyManagedBy": null }';
            res.setBody(json);
            res.setStatusCode(200);
            
            return res;    
        }
    }

}