/**
* @author Eleni Tsiolaki - etsiolaki@deloitte.gr 
* @Creation 18/10/2021
* @Modification
* @description Test Class for XC_LCC256_ContractPunctualFeeAdjustment
*/
@isTest
private class XC_LCC258_ContractRenewal_TEST {

    @TestSetup
    static void insertRecords() {

        List<Contract> contracts = XC_DF_Contract.createContracts(1);
        for(Contract c: contracts) {
            c.RecordTypeID = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_Contract').getRecordTypeId();
            c.EndDate = System.today().addyears(2);
            c.XC_LegalEntity__c = 'EnelXItalia';
            c.StartDate = System.today();
            c.XC_Zone__c = 'B2G-B2G';
        }
        insert contracts;

        List<NE__OrderItem__c> orderItems = XC_DF_OrderItem.createOrderItems(1);
        for(NE__OrderItem__c o: orderItems) {
            o.XC_BillingModel__c = 'Recurring';
            o.NE__EndDate__c = System.today().addyears(2);
            o.XC_RecurringDuration__c = 3;
        }
        insert orderItems;
        
        contracts[0].XC_Configurations__c = orderItems[0].NE__OrderId__c;
        update contracts;
        
        List<Asset> assets = XC_DF_Asset.createAssetsFromContract(contracts);
        for(Asset a: assets){
            a.NE__EndDate__c = System.today().addyears(2);
            a.XC_Configuration_Item__c = orderItems[0].Id;
            a.XC_Contract__c = contracts[0].id;
            a.Status = Label.XC_CL_Asset_StatusActive;
            a.XC_BillingModel__c = Label.XC_CL_BillingModel_Recurring;
        }
        insert assets;
    }

    @isTest
    static void initComponentTest(){
        Test.startTest();
        XC_UTIL_ResultWrapper resultOK = XC_LCC258_ContractRenewal.initComponent();
        Test.stopTest();
        System.assertEquals(true,resultOK.success);
    }

    @isTest
    static void searchContractsTest(){
        List<Contract> contracts = [SELECT Id, EndDate, StartDate, XC_Zone__c, ContractNumber, XC_LegalEntity__c FROM Contract];
        contracts[0].Status = 'Active';
        update contracts;
        Map<String,Object> paramsMap = new Map<String,Object> ();
        paramsMap.put('endDate',contracts[0].EndDate);
        paramsMap.put('startDate',contracts[0].StartDate);
        paramsMap.put('contractZone', contracts[0].XC_Zone__c);
        paramsMap.put('contractNumber', contracts[0].ContractNumber);
        paramsMap.put('legalEntity', contracts[0].XC_LegalEntity__c);
		paramsMap.put('endDateMin', contracts[0].EndDate.addDays(-5));																												   
		Test.startTest();
        XC_UTIL_ResultWrapper resultOK = XC_LCC258_ContractRenewal.searchContracts(paramsMap);
        Test.stopTest();
        System.assertEquals(true,resultOK.success);
    }
    
    @isTest
    static void saveDatesTest(){
        List<Contract> contracts = [SELECT Id, EndDate, StartDate, XC_Zone__c, ContractNumber, XC_LegalEntity__c FROM Contract];
        Map<String,Object> paramsMap = new Map<String,Object> ();
        
        List<NE__OrderItem__c> orderItems = [SELECT Id FROM NE__OrderItem__c];
        List<String> orderItemIds = new List<String>();
        for(NE__OrderItem__c o : orderItems) {
            orderItemIds.add(o.id);
        }
        
        List<Asset> assets = [SELECT Id FROM Asset];
        List<String> assetIds = new List<String>();
        for(Asset a : assets) {
            assetIds.add(a.id);
        }
        Map<Object, Object> orderItemContractMap = new Map<Object, Object>();
        orderItemContractMap.put(orderItems[0].Id,contracts[0].Id);
        paramsMap.put('orderItemIds', orderItemIds);
        paramsMap.put('assetIds',assetIds);
        paramsMap.put('selectedContracts', new List<String> {contracts[0].Id});
        paramsMap.put('orderItemContractMap', orderItemContractMap);
        
        Map<String,Object> draftValueMap = new Map<String,Object> ();
        draftValueMap.put(contracts[0].Id, System.today());
        Test.startTest();
        XC_UTIL_ResultWrapper resultOK = XC_LCC258_ContractRenewal.saveDates(draftValueMap,paramsMap);
        Test.stopTest();
        System.assertEquals(true,resultOK.success);
    }

	@isTest
    static void searchContractsByRangeDateTest(){
        List<Contract> contracts = [SELECT Id, EndDate, StartDate, XC_Zone__c, ContractNumber, XC_LegalEntity__c FROM Contract];
        contracts[0].Status = 'Active';
        update contracts;
		 DateTime dateMin=contracts[0].EndDate.addYears(-3);
        DateTime dateMax=contracts[0].EndDate.addYears(+3);
        Map<String,Object> paramsMap = new Map<String,Object> ();
		paramsMap.put('endDateMin',dateMin);
        paramsMap.put('endDate',dateMax);
        paramsMap.put('startDate',contracts[0].StartDate);
        paramsMap.put('contractZone', contracts[0].XC_Zone__c);
        paramsMap.put('contractNumber', contracts[0].ContractNumber);
        paramsMap.put('legalEntity', contracts[0].XC_LegalEntity__c);
        Test.startTest();
        XC_UTIL_ResultWrapper resultOK = XC_LCC258_ContractRenewal.searchContracts(paramsMap);
        Test.stopTest();
        System.assertEquals(true,resultOK.success);
    }	
    
}