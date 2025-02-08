/**
* @author Eleni Tsiolaki - etsiolaki@deloitte.gr 
* @Creation 19/10/2021
* @Modification
* @description Test Class for XC_LCC257_ContractMassiveFeeAdjustment
*/
@isTest
private class XC_LCC257_ContractMassiveFeeAdj_TEST {

    @TestSetup
    static void insertRecords() {

        List<Contract> contracts = XC_DF_Contract.createContracts(1);
        for(Contract c: contracts) {
            c.RecordTypeID = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_Contract').getRecordTypeId();
            c.EndDate = System.today().addyears(2);
            c.XC_LegalEntity__c = 'EnelXItalia';
            c.StartDate = System.today();
            c.XC_Zone__c = 'B2G-B2G';
            c.XC_Adjustment_Band__c = 'Fascia Z2';
            c.Contract_Type__c = 'Commodity, construction and service contracts';
        }
        insert contracts;

        List<NE__OrderItem__c> orderItems = XC_DF_OrderItem.createOrderItems(1);
        for(NE__OrderItem__c o: orderItems) {
            o.XC_BillingModel__c = 'Recurring';
            o.XC_Particle__c = 'FALSE';
        }
        insert orderItems;
        
        contracts[0].XC_Configurations__c = orderItems[0].NE__OrderId__c;
        update contracts;
        
        List<Asset> assets = XC_DF_Asset.createAssetsFromContract(contracts);
        for(Asset a: assets){
            a.NE__EndDate__c = System.today().addyears(2);
            a.XC_Configuration_Item__c = orderItems[0].Id;
            a.XC_Particle__c = 'FALSE';
            a.NE__RecurringChargeOv__c = 10;
            a.XC_Contract__c = contracts[0].id;
            a.Status = Label.XC_CL_Asset_StatusActive;
            a.XC_BillingModel__c = Label.XC_CL_BillingModel_Recurring;
        }
        insert assets;
    }

    @isTest
    static void initComponentTest(){
        Test.startTest();
        XC_UTIL_ResultWrapper resultOK = XC_LCC257_ContractMassiveFeeAdjustment.initComponent();
        Test.stopTest();
        System.assertEquals(true,resultOK.success);
    }

    @isTest
    static void searchContractTest(){
        List<Contract> contracts = [SELECT Id, EndDate, StartDate, XC_Zone__c, XC_LegalEntity__c, ContractNumber, XC_Adjustment_Band__c FROM Contract];
        Map<String,Object> paramsMap = new Map<String,Object> ();
        paramsMap.put('endDate',contracts[0].EndDate);
        paramsMap.put('contractNumber', contracts[0].ContractNumber);
        paramsMap.put('priceBand',contracts[0].XC_Adjustment_Band__c);
        paramsMap.put('contractZone', contracts[0].XC_Zone__c);
        paramsMap.put('legalEntity', contracts[0].XC_LegalEntity__c);
        Test.startTest();
        XC_UTIL_ResultWrapper resultOK = XC_LCC257_ContractMassiveFeeAdjustment.searchContracts(paramsMap);
        Test.stopTest();
        System.assertEquals(true,resultOK.success);
    }

    @isTest
    static void adjustFeeTest(){
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
        paramsMap.put('symbol','+');
        paramsMap.put('percentage', '10');
        paramsMap.put('contractNumber', contracts[0].ContractNumber);
        
        Test.startTest();
        XC_UTIL_ResultWrapper resultOK = XC_LCC257_ContractMassiveFeeAdjustment.adjustFee(paramsMap);
        Test.stopTest();
        System.assertEquals(true,resultOK.success);
    }

}