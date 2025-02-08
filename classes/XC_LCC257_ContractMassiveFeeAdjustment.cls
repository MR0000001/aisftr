/**
 * @author: Eleni Tsiolaki - etsiolaki@deloitte.gr
 * @date Creation 09/10/2021
 * @date Modification 
 * @description XC_LCC257_ContractMassiveFeeAdjustment – Controller of XC_LCP257_ContractMassiveFeeAdjustment (to manage the Contract Management: Fee Adjustment – Massive Adjustment)
 */


public with sharing class XC_LCC257_ContractMassiveFeeAdjustment {
    

    /**
     * @author Eleni Tsiolaki - etsiolaki@deloitte.gr
     * @date Creation 09/10/2021
     * @date Modification dd/mm/yyyy
     * @description 
     * @return XC_UTIL_ResultWrapper
     */ 
    @AuraEnabled 
    public static XC_UTIL_ResultWrapper initComponent() {

        XC_UTIL_ResultWrapper resWrapper = new XC_UTIL_ResultWrapper(); 
        resWrapper.success = false;
        
        List<String> zones = XC_UTIL_Sobject.getPicklistValues('Contract', 'XC_Zone__c');
        List<String> businessLines = XC_UTIL_Sobject.getPicklistValues('Opportunity', 'XC_BusinessLine__c');
        List<String> legalEntities = XC_UTIL_Sobject.getPicklistValues('Contract', 'XC_LegalEntity__c');
        List<String> priceBand = XC_UTIL_Sobject.getPicklistValues('Contract', 'XC_Adjustment_Band__c');

        if(!businessLines.isEmpty() && !legalEntities.isEmpty()){
            resWrapper.success = true;
            resWrapper.resultMessage ='';
            resWrapper.fieldName = JSON.serialize(businessLines);
            resWrapper.fieldName2 = JSON.serialize(legalEntities);
            resWrapper.fieldName3 = JSON.serialize(zones);
            resWrapper.fieldName4 = JSON.serialize(priceBand);
        }

        return resWrapper;
    }


    /**
     * @description Search the contract based on the input fields in the component
     * @param paramsMap - Map<String,Object> 
     * @return XC_UTIL_ResultWrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper searchContracts(Map<String,Object> paramsMap) {

        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();

        String priceBand = String.valueOf(paramsMap.get('priceBand'));
        String contractZone = String.escapeSingleQuotes(String.valueOf(paramsMap.get('contractZone')));
        String businessLine = String.valueOf(paramsMap.get('businessLine'));
        String legalEntity = String.valueOf(paramsMap.get('legalEntity'));

        String query = XC_UTIL_Sobject.selectAllFieldsGetSelect('Contract');
        query += ' , Account.Name,  Opportunity__r.XC_BusinessLine__c, (SELECT XC_Status__c, XC_Contract__c, XC_EndDateBeforeExtension__c, XC_EndDateAfterLastExtension__c, XC_RevaluationEffectiveDate__c  FROM Contract_Amendments__r order by XC_EndDateAfterLastExtension__c ASC), ' ;
        query += ' (SELECT Id, NE__Order_Config__r.Name FROM assets1__r WHERE NE__Order_Config__r.NE__Type__c =\'' +  Label.XC_CL_Configuration_TypeDisconnection +'\' OR ';
        query += ' (NE__Order_Config__r.NE__Type__c =\'' +  Label.XC_CL_Configuration_TypeChangeOrder + '\' AND ';
        query += ' ((NE__Order_Config__r.XC_Status__c =\'' + Label.XC_CL_Order_StatusCancelled +'\' AND NE__Order_Config__r.XC_NumberOfConfigurationItem__c > 0) OR (NE__Order_Config__r.XC_Status__c !=\'' + Label.XC_CL_Order_StatusCancelled + '\' AND  NE__Order_Config__r.XC_Status__c != \'' +  Label.XC_CL_Configuration_Closed + '\' )))) ';
        query += ' FROM Contract';
        query += ' WHERE XC_Adjustment_Band__c = \'' + priceBand + '\'';
        query += ' AND XC_Zone__c = \'' + contractZone + '\'';
        if (businessLine != null) {
            query += ' AND  Opportunity__r.XC_BusinessLine__c =:businessLine';
        }
        if (legalEntity != null) {
            query += ' AND XC_LegalEntity__c =:legalEntity';
        }
        query += ' AND (Contract_Type__c = \'B2G Standard Contracts\' OR Contract_Type__c = \'Commodity, construction and service contracts\') ';
        query += ' AND EndDate >= TODAY ';
        
        //[Begin - Gestione Cruscotto - excludes a contract that has an error or a scheduled amendment  - 24/03/2022]
        //List<Contract> contracts = Database.query(query);
        List<Contract> allContracts = Database.query(query);
        Map<Id, String> contrIdErrorMessage = new Map<Id, String>();
        List<Contract> contracts = XC_LCC258_ContractRenewal.filterContract(allContracts, contrIdErrorMessage);
        //[End - Gestione Cruscotto - excludes a contract that has an error or a scheduled amendment  - 24/03/2022]
        
        if(contracts.size() > 0) {
            XC_ContractManagement_D.DataWrapper dataReturned = XC_ContractManagement_D.getRecurringContracts(contracts, true);
            rw.success = true;
            rw.resultMessage ='';
            rw.fieldName = JSON.serialize(dataReturned.contracts);
            rw.fieldName2 = JSON.serialize(dataReturned.assetIds);
            rw.fieldName3 = JSON.serialize(dataReturned.orderItemIds);
            rw.fieldName4 = JSON.serialize(dataReturned.orderItemContractMap);
        } else {
            rw.resultMessage = Label.XC_NoRecordsFound;
        }

        return rw; 
    }


    /**
     * @description Make the fee Adjustment on the Configuration Items related to the Contracts selected
     * @param paramsMap input Map<String,Object>
     * @param selectedContracts input List<String>
     * @return XC_UTIL_ResultWrapper
     **/
    @AuraEnabled
    public static XC_UTIL_ResultWrapper adjustFee(Map<String,Object> paramsMap){

        String symbol = String.valueOf(paramsMap.get('symbol'));
        Decimal percentage = Decimal.valueOf(String.valueOf(paramsMap.get('percentage')));

        List<Object> orderObject = (List<Object>) paramsMap.get('orderItemIds');
        List<string> orderItemIds= new List<string> ();
        for(Object o: orderObject){
            orderItemIds.add(String.valueOf(o));
        }

        List<Object> contractsObject = (List<Object>) paramsMap.get('selectedContracts');
        List<string> selectedContracts= new List<string> ();
        for(Object a: contractsObject){
            selectedContracts.add(String.valueOf(a));
        }

        Map<Object, Object> mapObject = (Map<Object, Object>) paramsMap.get('orderItemContractMap');
        Map<string, string> orderItemContractMap= new Map<string, string> ();
        for(Object a: mapObject.keySet()){
            orderItemContractMap.put(String.valueOf(a), String.valueOf(mapObject.get(a)));
        }

        System.debug('selected contracts ' + selectedContracts);
        System.debug('orderItems ' + orderItemIds);
        System.debug('map ' + orderItemContractMap);

        List<Contract> contracts = [SELECT Id, ContractNumber, EndDate, XC_Configurations__c FROM Contract WHERE Id IN :selectedContracts];
        XC_ContractManagement_D.DataWrapper dataReturned = XC_ContractManagement_D.getRecurringContracts(contracts, true);
        List<NE__OrderItem__c> orderItems = dataReturned.orderItems;
        List<Asset> assetsToUpdate = dataReturned.assets;

        Map<string, string> contractsMap= new Map<string, string> ();
        for(Contract c: contracts) {
            c.XC_LastAdjustmentDate__c = System.TODAY();
            contractsMap.put(c.Id, c.ContractNumber);
        }
        XC_UTIL_ResultWrapper resultContract =  new XC_UTIL_ResultWrapper();
        List<XC_UTIL_Sobject.WrapperResult> dmlResContract = XC_UTIL_DML.updateRecords(contracts);
        XC_UTIL_Sobject.WrapperResult globalResContract = XC_UTIL_Sobject.getGlobalDMLResults(dmlResContract);
        resultContract.success = globalResContract.success;
        
        if(!resultContract.success) {
            resultContract.resultMessage = globalResContract.errorMessage;
            return resultContract;
        } 
        //List<NE__OrderItem__c> orderItems = [SELECT Id, NE__RecurringChargeOv__c, NE__Parent_Order_Item__c FROM NE__OrderItem__c WHERE Id IN :orderItemIds];
        
        System.debug('selected contracts are ' + selectedContracts);

        Map<String, XC_ContractAmendment__c> orderItemToCustomContAmMap = new Map<String, XC_ContractAmendment__c>();

        for(NE__OrderItem__c orderItem : orderItems) {
            XC_ContractAmendment__c contrAmendement = new XC_ContractAmendment__c();
            contrAmendement.XC_CostBeforeLastRevaluation__c = orderItem.NE__RecurringChargeOv__c;

            if(symbol == '+') {
                orderItem.NE__RecurringChargeOv__c = orderItem.NE__RecurringChargeOv__c + orderItem.NE__RecurringChargeOv__c * percentage/100;
            } else if (symbol == '-') {
                orderItem.NE__RecurringChargeOv__c = orderItem.NE__RecurringChargeOv__c - orderItem.NE__RecurringChargeOv__c * percentage/100;
            }
            orderItem.XC_CA_UpdatePrice__c = true;
            orderItem.XC_CA_UpdateDate__c = false;
            orderItem.NE__Action__c = 'Change';
            
            contrAmendement.XC_Status__c = 'New';
            contrAmendement.XC_CostAfterLastRevaluation__c = orderItem.NE__RecurringChargeOv__c;
            contrAmendement.XC_LastRevaluationDate__c = System.TODAY();
            contrAmendement.XC_Contract__c = (orderItemContractMap != null && orderItemContractMap.containsKey(orderItem.Id)) ? orderItemContractMap.get(orderItem.Id) : null;
            contrAmendement.Name = (orderItemContractMap != null && orderItemContractMap.containsKey(orderItem.Id) && contractsMap != null && contractsMap.containsKey(orderItemContractMap.get(orderItem.Id))) ? contractsMap.get(orderItemContractMap.get(orderItem.Id)) : null;
            orderItemToCustomContAmMap.put(orderItem.Id, contrAmendement);
        }
        
        XC_UTIL_ResultWrapper result =  new XC_UTIL_ResultWrapper();
        List<XC_UTIL_Sobject.WrapperResult> dmlRes = XC_UTIL_DML.updateRecords(orderItems);
        XC_UTIL_Sobject.WrapperResult globalRes = XC_UTIL_Sobject.getGlobalDMLResults(dmlRes);
        result.success = globalRes.success;
        if(!result.success) {
            result.resultMessage = globalRes.errorMessage;
        } else {
            //List<Asset> assetsToUpdate = [SELECT Id, Name, XC_ContractEndDate__c, XC_Contract__c, NE__RecurringChargeOv__c, XC_Configuration_Item__c FROM Asset WHERE XC_Contract__c IN : selectedContracts AND Id IN: assetIds];
            //System.debug('assetsToUpdate ' + assetsToUpdate);
            List<string> assetIds= new List<string> ();
            for(Asset a : assetsToUpdate) {
                if(symbol == '+') {
                    a.NE__RecurringChargeOv__c = a.NE__RecurringChargeOv__c + a.NE__RecurringChargeOv__c * percentage/100;
                } else if (symbol == '-') {
                    a.NE__RecurringChargeOv__c = a.NE__RecurringChargeOv__c - a.NE__RecurringChargeOv__c * percentage/100;
                }
                assetIds.add(a.Id);
                a.NE__Action__c = 'Change';
                XC_ContractAmendment__c customObject = orderItemToCustomContAmMap.get(a.XC_Configuration_Item__c);
                customObject.XC_Asset__c = a.Id;
                customObject.Name = customObject.Name + ' - ' + a.Name;
                orderItemToCustomContAmMap.put(a.XC_Configuration_Item__c,customObject);
            }

            for(String key : orderItemToCustomContAmMap.keySet()) {
                if(orderItemToCustomContAmMap.get(key).XC_Asset__c == null) {
                    orderItemToCustomContAmMap.remove(key);
                }
            }

            XC_UTIL_ResultWrapper resultCustomObject =  new XC_UTIL_ResultWrapper();
            List<XC_UTIL_Sobject.WrapperResult> dmlResult = XC_UTIL_DML.insertRecords(orderItemToCustomContAmMap.values());
            XC_UTIL_Sobject.WrapperResult cADmlResult = XC_UTIL_Sobject.getGlobalDMLResults(dmlResult);
            resultCustomObject.success = cADmlResult.success;
            if (!cADmlResult.success){
                resultCustomObject.resultMessage = cADmlResult.errorMessage;
                return resultCustomObject;
            }
                
            Map<String,String> contractAmendementsMap = new Map<String,String>();
            for(XC_ContractAmendment__c c: orderItemToCustomContAmMap.values()) {
                contractAmendementsMap.put(c.XC_Asset__c, c.Id);
            }
            for(Asset a : assetsToUpdate) {
                if(contractAmendementsMap.get(a.Id) != null) {
                    a.XC_Contract_Amendment__c = contractAmendementsMap.get(a.Id);
                }
            }
            XC_UTIL_ResultWrapper resultAsset =  new XC_UTIL_ResultWrapper();
            List<XC_UTIL_Sobject.WrapperResult> dmlResAsset = XC_UTIL_DML.updateRecords(assetsToUpdate);
            XC_UTIL_Sobject.WrapperResult globalResAsset = XC_UTIL_Sobject.getGlobalDMLResults(dmlResAsset);
            resultAsset.success = globalResAsset.success;

            if(!resultAsset.success) {
                resultAsset.resultMessage = globalResAsset.errorMessage;
                return resultAsset;
            } else {
                for(NE__OrderItem__c orderItem : orderItems) {
                    if(orderItem.NE__Parent_Order_Item__c != null) {
                        if(orderItemToCustomContAmMap.get(orderItem.Id) != null) {
                            XC_ContractAmendment__c customObject = orderItemToCustomContAmMap.get(orderItem.Id);
                            if(orderItemToCustomContAmMap.get(orderItem.NE__Parent_Order_Item__c) != null ) {
                                customObject.Contract_Amendment_Parent__c = orderItemToCustomContAmMap.get(orderItem.NE__Parent_Order_Item__c).Id;
                                orderItemToCustomContAmMap.put(orderItem.Id,customObject);
                            }
                        }
                    }   
                }
                XC_UTIL_ResultWrapper resultUpdateCustom =  new XC_UTIL_ResultWrapper();
                List<XC_UTIL_Sobject.WrapperResult> dmlResCustom = XC_UTIL_DML.updateRecords(orderItemToCustomContAmMap.values());
                XC_UTIL_Sobject.WrapperResult globalResCustom = XC_UTIL_Sobject.getGlobalDMLResults(dmlResCustom);
                resultUpdateCustom.success = globalResCustom.success;
                if(!resultUpdateCustom.success) {
                    resultUpdateCustom.resultMessage = globalResCustom.errorMessage;
                    return resultUpdateCustom;
                }
            }

        }

        return result;
    }
}