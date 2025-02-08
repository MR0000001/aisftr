/**
 * @description       : 
 * @author            : Eleni Tsiolaki - etsiolaki@deloitte.gr
 * @group             : 
 * @last modified on  : 12-10-2021
 * @last modified by  : Eleni Tsiolaki - etsiolaki@deloitte.gr
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   12-10-2021   Eleni Tsiolaki - etsiolaki@deloitte.gr   Initial Version
**/
public with sharing class XC_ContractManagement_D {

    public class DataWrapper {
        public Set<Contract> contracts;
        public List<Asset> assets;
        public List<NE__OrderItem__c> orderItems;
        public List<String> assetIds;
        public List<String> orderItemIds;
        public Map<String,String> orderItemContractMap;
    }
    
    /**
     * @description Filter Contracts and return only recurring ones
     * @param contracts - List<Contract>
     * @param forFeeAdjustment - Boolean
     * @return dataReturned - DataWrapper
     */
    public static DataWrapper getRecurringContracts(List<Contract> contracts, Boolean forFeeAdjustment){

        return getRecurringContractsFromAsset(contracts, forFeeAdjustment);

        /*DataWrapper dataReturned = new DataWrapper();

        List<String> ordersId  = new List<String>();
        Map<Id, Id> orderContractMap = new Map<Id, Id>();
        Map<Id, Contract> contractsMap = new Map<Id, Contract>();

        for(Contract c: contracts) {
            ordersId.add(c.XC_Configurations__c);
            orderContractMap.put(c.XC_Configurations__c, c.Id);
            contractsMap.put(c.Id, c);
        }

        Map<String,String> orderItemContractMap = new Map<String,String>();

        List<NE__OrderItem__c> ordItems = new List<NE__OrderItem__c>();
        if(forFeeAdjustment) {
            ordItems = [SELECT Id , NE__OrderId__c, XC_Particle__c, NE__RecurringChargeOv__c, NE__Parent_Order_Item__c, NE__EndDate__c, XC_RecurringDuration__c  FROM  NE__OrderItem__c WHERE XC_BillingModel__c = 'Recurring' AND XC_Particle__c = 'FALSE' AND NE__OrderId__c IN :ordersId];
        } else {
            ordItems = [SELECT Id , NE__OrderId__c, XC_Particle__c, NE__RecurringChargeOv__c, NE__Parent_Order_Item__c, NE__EndDate__c, XC_RecurringDuration__c  FROM  NE__OrderItem__c WHERE XC_BillingModel__c = 'Recurring' AND NE__OrderId__c IN :ordersId];
        }
        
        Set<Contract> contractsFinal = new Set<Contract>();
        List<String> orderItemIds = new List<String>();
        for(NE__OrderItem__c o: ordItems) {
            contractsFinal.add(contractsMap.get(orderContractMap.get(o.NE__OrderId__c)));
            orderItemIds.add(o.Id);
            orderItemContractMap.put(o.Id, orderContractMap.get(o.NE__OrderId__c));
        }

        //System.debug('My new map ' + orderItemContractMap);

        List<Asset> assets = new List<Asset>();
        if(forFeeAdjustment) {
            assets = [SELECT Id, XC_ContractEndDate__c,NE__RecurringChargeOv__c, Name, XC_Contract__c, NE__Action__c, XC_Configuration_Item__c, NE__StartDate__c, XC_Configuration_Item__r.XC_Effective_Start_Date_Recurring__c, NE__RecurringChargeFrequency__c, Status  FROM Asset WHERE XC_Configuration_Item__c IN : orderItemIds AND XC_Particle__c = 'FALSE' AND NE__EndDate__c >= TODAY];
        } else {
            assets = [SELECT Id, XC_ContractEndDate__c, NE__RecurringChargeOv__c, Name, XC_Contract__c, NE__Action__c, XC_Configuration_Item__c, NE__StartDate__c, XC_Configuration_Item__r.XC_Effective_Start_Date_Recurring__c, NE__RecurringChargeFrequency__c, Status  FROM Asset WHERE XC_Configuration_Item__c IN : orderItemIds AND NE__EndDate__c >= TODAY];
        }

        List<String> assetIds = new List<String>();
        for(Asset a: assets) {
            assetIds.add(a.Id);
        }
         
        dataReturned.contracts = contractsFinal;
        dataReturned.assetIds = assetIds;
        dataReturned.orderItemIds = orderItemIds;
        dataReturned.assets = assets;
        dataReturned.orderItems = ordItems;
        dataReturned.orderItemContractMap = orderItemContractMap;
        System.debug('filtered contracts ' + contractsFinal);

        return dataReturned;*/
    }


    /**
     * @description Filter Contracts and return only recurring ones
     * @param contracts - List<Contract>
     * @param forFeeAdjustment - Boolean
     * @return dataReturned - DataWrapper
     */
    public static DataWrapper getRecurringContractsFromAsset(List<Contract> contracts, Boolean forFeeAdjustment){

        DataWrapper dataReturned = new DataWrapper();

        Map<Id, Contract> contractsMap = new Map<Id, Contract>();
        Set<Id> contractsId = new Set<Id>();
        Map<Id, NE__OrderItem__c> ordItems = new  Map<Id, NE__OrderItem__c>();
        Map<String,String> orderItemContractMap = new Map<String,String>();
        Map<NE__OrderItem__c, Asset> oiAssetMap = new Map<NE__OrderItem__c, Asset>();
        List<String> assetIds = new List<String>();

        for(Contract c: contracts) {
            contractsId.add(c.id);
            contractsMap.put(c.Id, c);
        }
        
        if(!contractsId.isEmpty()){
            Map<Id,Asset> assetMapRecurring;
            if(forFeeAdjustment) {
                assetMapRecurring = new Map<Id,Asset>([SELECT Id, XC_ContractEndDate__c,NE__RecurringChargeOv__c, Name, XC_Contract__c, NE__Action__c, XC_Configuration_Item__c, NE__StartDate__c, 
                                                        XC_Configuration_Item__r.XC_Effective_Start_Date_Recurring__c, NE__RecurringChargeFrequency__c, Status, XC_Configuration_Item__r.NE__OrderId__c, 
                                                        XC_Configuration_Item__r.XC_Particle__c, XC_Configuration_Item__r.NE__RecurringChargeOv__c, XC_Configuration_Item__r.NE__Parent_Order_Item__c, 
                                                        XC_Configuration_Item__r.NE__EndDate__c, XC_Configuration_Item__r.XC_RecurringDuration__c
                                                        FROM Asset  
                                                        WHERE XC_Particle__c = 'FALSE' AND NE__EndDate__c >= TODAY AND XC_BillingModel__c = : Label.XC_CL_BillingModel_Recurring AND XC_Contract__c IN: contractsId
                                                        AND Status =: Label.XC_CL_Asset_StatusActive]);
            } else {
                assetMapRecurring = new Map<Id,Asset>([SELECT Id, XC_ContractEndDate__c,NE__RecurringChargeOv__c, Name, XC_Contract__c, NE__Action__c, XC_Configuration_Item__c, NE__StartDate__c,
                                                        XC_Configuration_Item__r.XC_Effective_Start_Date_Recurring__c, NE__RecurringChargeFrequency__c, Status, XC_Configuration_Item__r.NE__OrderId__c,
                                                        XC_Configuration_Item__r.XC_Particle__c, XC_Configuration_Item__r.NE__RecurringChargeOv__c, XC_Configuration_Item__r.NE__Parent_Order_Item__c, 
                                                        XC_Configuration_Item__r.NE__EndDate__c, XC_Configuration_Item__r.XC_RecurringDuration__c
                                                        FROM Asset  
                                                        WHERE NE__EndDate__c >= TODAY AND XC_BillingModel__c =: Label.XC_CL_BillingModel_Recurring AND XC_Contract__c IN: contractsId
                                                        AND Status =: Label.XC_CL_Asset_StatusActive]);
            }
            
            for(Asset ass : assetMapRecurring.values()){
                if(!String.isBlank(ass.XC_Configuration_Item__c)){
                    NE__OrderItem__c oi = new NE__OrderItem__c();
                    oi.Id = ass.XC_Configuration_Item__c;
                    oi.NE__OrderId__c = ass.XC_Configuration_Item__r.NE__OrderId__c;
                    oi.XC_Particle__c = ass.XC_Configuration_Item__r.XC_Particle__c;
                    oi.NE__RecurringChargeOv__c = ass.XC_Configuration_Item__r.NE__RecurringChargeOv__c;
                    oi.NE__Parent_Order_Item__c = ass.XC_Configuration_Item__r.NE__Parent_Order_Item__c;
                    oi.NE__EndDate__c = ass.XC_Configuration_Item__r.NE__EndDate__c;
                    oi.XC_RecurringDuration__c = ass.XC_Configuration_Item__r.XC_RecurringDuration__c;
                    ordItems.put(oi.Id, oi);
                    oiAssetMap.put(oi, ass);      
                }
                assetIds.add(ass.Id);
            }

            Set<Contract> contractsFinal = new Set<Contract>();
            List<String> orderItemIds = new List<String>();
            for(NE__OrderItem__c orderItem: ordItems.values()) {
                if(oiAssetMap.get(orderItem) != null){
                    contractsFinal.add(contractsMap.get(oiAssetMap.get(orderItem).XC_Contract__c));
                    orderItemContractMap.put(orderItem.Id, oiAssetMap.get(orderItem).XC_Contract__c);
                }
                orderItemIds.add(orderItem.Id);
            }

        
            
            dataReturned.contracts = contractsFinal;
            dataReturned.assetIds = assetIds;
            dataReturned.orderItemIds =  orderItemIds;
            dataReturned.assets = assetMapRecurring.values();
            dataReturned.orderItems = ordItems.values();
            dataReturned.orderItemContractMap = orderItemContractMap;
            System.debug('filtered contracts ' + contractsFinal);
        }else{
            dataReturned.contracts = new Set<Contract>();
            dataReturned.assetIds = new List<String>();
            dataReturned.orderItemIds =   new List<String>();
            dataReturned.assets = new List<Asset>();
            dataReturned.orderItems =new List<NE__OrderItem__c>();
            dataReturned.orderItemContractMap = new Map<String,String>();
        }

        return dataReturned;
    }
	
	//START-CR772-elisa.caldini@acenture.com-30.05.2022

    /**
     * @description filter contracts by asset in status Active , billing model recurring and  the range endDate min and endDate Max
     *
     * @param contracts list of Contract
     * @param endDateMin date min for intervall
     * @param endDateMax date max for intervall
     * @return DataWrapper
     */

    public static DataWrapper getRecurringContractsFromAssetByRangeDate(List<Contract> contracts,String endDateMin, String endDateMax){

        DataWrapper dataReturned = new DataWrapper();
        Date endDMin = Date.valueOf(endDateMin);
        Date endDMax= Date.valueOf(endDateMax);
        DateTime endMinDate=DateTime.newInstance(endDMin.year(),endDMin.month(),endDMin.day());
        DateTime endMaxDate=DateTime.newInstance(endDMax.year(),endDMax.month(),endDMax.day());
        Map<Id, Contract> contractsMap = new Map<Id, Contract>();
        Set<Id> contractsId = new Set<Id>();
        Map<Id, NE__OrderItem__c> ordItems = new  Map<Id, NE__OrderItem__c>();
        Map<String,String> orderItemContractMap = new Map<String,String>();
        Map<NE__OrderItem__c, Asset> oiAssetMap = new Map<NE__OrderItem__c, Asset>();
        List<String> assetIds = new List<String>();

        for(Contract c: contracts) {
            contractsId.add(c.id);
            contractsMap.put(c.Id, c);
        }
        
        if(!contractsId.isEmpty()){
            Map<Id,Asset> assetMapRecurring;
            
                assetMapRecurring = new Map<Id,Asset>([SELECT Id, XC_ContractEndDate__c,NE__RecurringChargeOv__c, Name, XC_Contract__c, NE__Action__c, XC_Configuration_Item__c, NE__StartDate__c,
                                                        XC_Configuration_Item__r.XC_Effective_Start_Date_Recurring__c, NE__RecurringChargeFrequency__c, Status, XC_Configuration_Item__r.NE__OrderId__c,
                                                        XC_Configuration_Item__r.XC_Particle__c, XC_Configuration_Item__r.NE__RecurringChargeOv__c, XC_Configuration_Item__r.NE__Parent_Order_Item__c, 
                                                        XC_Configuration_Item__r.NE__EndDate__c, XC_Configuration_Item__r.XC_RecurringDuration__c
                                                        FROM Asset  
                                                        WHERE NE__EndDate__c>=:endMinDate AND  NE__EndDate__c <= :endMaxDate AND XC_BillingModel__c =: Label.XC_CL_BillingModel_Recurring AND XC_Contract__c IN: contractsId
                                                        AND Status =: Label.XC_CL_Asset_StatusActive]);
           
            for(Asset ass : assetMapRecurring.values()){
                if(!String.isBlank(ass.XC_Configuration_Item__c)){
                    NE__OrderItem__c oi = new NE__OrderItem__c();
                    oi.Id = ass.XC_Configuration_Item__c;
                    oi.NE__OrderId__c = ass.XC_Configuration_Item__r.NE__OrderId__c;
                    oi.XC_Particle__c = ass.XC_Configuration_Item__r.XC_Particle__c;
                    oi.NE__RecurringChargeOv__c = ass.XC_Configuration_Item__r.NE__RecurringChargeOv__c;
                    oi.NE__Parent_Order_Item__c = ass.XC_Configuration_Item__r.NE__Parent_Order_Item__c;
                    oi.NE__EndDate__c = ass.XC_Configuration_Item__r.NE__EndDate__c;
                    oi.XC_RecurringDuration__c = ass.XC_Configuration_Item__r.XC_RecurringDuration__c;
                    ordItems.put(oi.Id, oi);
                    oiAssetMap.put(oi, ass);      
                }
                assetIds.add(ass.Id);
            }

            Set<Contract> contractsFinal = new Set<Contract>();
            List<String> orderItemIds = new List<String>();
            for(NE__OrderItem__c orderItem: ordItems.values()) {
                if(oiAssetMap.get(orderItem) != null){
                    contractsFinal.add(contractsMap.get(oiAssetMap.get(orderItem).XC_Contract__c));
                    orderItemContractMap.put(orderItem.Id, oiAssetMap.get(orderItem).XC_Contract__c);
                }
                orderItemIds.add(orderItem.Id);
            }

            dataReturned.contracts = contractsFinal;
            dataReturned.assetIds = assetIds;
            dataReturned.orderItemIds =  orderItemIds;
            dataReturned.assets = assetMapRecurring.values();
            dataReturned.orderItems = ordItems.values();
            dataReturned.orderItemContractMap = orderItemContractMap;
            System.debug('filtered contracts ' + contractsFinal);
        }else{
            dataReturned.contracts = new Set<Contract>();
            dataReturned.assetIds = new List<String>();
            dataReturned.orderItemIds =   new List<String>();
            dataReturned.assets = new List<Asset>();
            dataReturned.orderItems =new List<NE__OrderItem__c>();
            dataReturned.orderItemContractMap = new Map<String,String>();
        }

        return dataReturned;
    }

    //END-CR772-elisa.caldini@acenture.com-30.05.2022
    

}