/**
 * @author: Eleni Tsiolaki - etsiolaki@deloitte.gr
 * @date Creation 06/10/2021
 * @date Modification 
 * @description XC_LCC256_ContractPunctualFeeAdjustment – Controller of XC_LCP256_ContractPunctualFeeAdjustment (to manage the Contract Management: Fee Adjustment – Punctual Adjustment)
 */


public with sharing class XC_LCC256_ContractPunctualFeeAdjustment {
    

    /**
    * @author Eleni Tsiolaki - etsiolaki@deloitte.gr
    * @date Creation 08/10/2021
    * @date Modification dd/mm/yyyy
    * @description 
    * @return XC_UTIL_ResultWrapper
    */ 
    @AuraEnabled 
    public static XC_UTIL_ResultWrapper initComponent() {

        XC_UTIL_ResultWrapper resWrapper = new XC_UTIL_ResultWrapper(); 
        resWrapper.success = false;
        
        List<String> businessLines = XC_UTIL_Sobject.getPicklistValues('Opportunity',  'XC_BusinessLine__c');
        List<String> legalEntities = XC_UTIL_Sobject.getPicklistValues('Contract',  'XC_LegalEntity__c');
        if(!businessLines.isEmpty() && !legalEntities.isEmpty()){
            resWrapper.success = true;
            resWrapper.resultMessage ='';
            resWrapper.fieldName = JSON.serialize(businessLines);
            resWrapper.fieldName2 = JSON.serialize(legalEntities);
        }

        return resWrapper;
    }


    /**
     * @description Search the contract based on the input fields in the component
     * @param paramsMap - Map<String,Object> 
     * @return XC_UTIL_ResultWrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper searchContract(Map<String,Object> paramsMap) {

        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();

        String contractNumber = String.valueOf(paramsMap.get('contractNumber'));
        String businessLine = String.valueOf(paramsMap.get('businessLine'));
        String legalEntity = String.valueOf(paramsMap.get('legalEntity'));

        String query = XC_UTIL_Sobject.selectAllFieldsGetSelect('Contract');
        query += ' , Account.Name,  Opportunity__r.XC_BusinessLine__c, (SELECT XC_Status__c, XC_Contract__c, XC_EndDateBeforeExtension__c, XC_EndDateAfterLastExtension__c, XC_RevaluationEffectiveDate__c FROM Contract_Amendments__r order by XC_EndDateAfterLastExtension__c ASC), ';
        query += ' (SELECT Id, NE__Order_Config__r.Name FROM assets1__r WHERE NE__Order_Config__r.NE__Type__c =\'' +  Label.XC_CL_Configuration_TypeDisconnection +'\' OR ';
        query += ' (NE__Order_Config__r.NE__Type__c =\'' +  Label.XC_CL_Configuration_TypeChangeOrder + '\' AND ';
        query += ' ((NE__Order_Config__r.XC_Status__c =\'' + Label.XC_CL_Order_StatusCancelled +'\' AND NE__Order_Config__r.XC_NumberOfConfigurationItem__c > 0) OR (NE__Order_Config__r.XC_Status__c !=\'' + Label.XC_CL_Order_StatusCancelled + '\' AND  NE__Order_Config__r.XC_Status__c != \'' +  Label.XC_CL_Configuration_Closed + '\' )))) ' ;
        query += ' FROM Contract';
        query += ' WHERE ContractNumber = :contractNumber';
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
            rw.resultMessage = '';
            rw.fieldName = JSON.serialize(dataReturned.contracts);
            rw.fieldName2 = JSON.serialize(dataReturned.assetIds);
            rw.fieldName3 = JSON.serialize(dataReturned.orderItemIds);
        } else if(allContracts.size() == 1 && !String.isBlank(contractNumber)){
            //[Begin - Gestione Cruscotto -excludes a contract that has an error or a scheduled amendment   - 24/03/2022]
            // the contract found is unique and has at least one contract amendment in error\scheduled
            rw.resultMessage = contrIdErrorMessage.get(allContracts[0].id); 
            //[End - Gestione Cruscotto - excludes a contract that has an error or a scheduled amendment  - 24/03/2022]
        }else {
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
    public static XC_UTIL_ResultWrapper adjustFee(Map<String,Object> paramsMap) { 

        String symbol = String.valueOf(paramsMap.get('symbol'));
        Decimal percentage = Decimal.valueOf(String.valueOf(paramsMap.get('percentage')));
        String contractNumber = String.valueOf(paramsMap.get('contractNumber'));

        List<Object> orderObject = (List<Object>) paramsMap.get('orderItemIds');
        List<string> orderItemIds= new List<string> ();
        for(Object o : orderObject){
            orderItemIds.add(String.valueOf(o));
        }

        List<Object> assetObject = (List<Object>) paramsMap.get('assetIds');
        List<string> assetIds = new List<string> ();
        for(Object a: assetObject){
            assetIds.add(String.valueOf(a));
        }

        System.debug('Symbol ' + symbol);
        System.debug('fee ' + percentage);
        System.debug('contractNumber ' + contractNumber);
        System.debug('orderItems ' + orderItemIds);
        System.debug('assets ' + assetIds);

        List<Contract> contracts = [SELECT Id, ContractNumber, EndDate, XC_Configurations__c FROM Contract WHERE ContractNumber =:contractNumber];
        for(Contract c : contracts) {
            c.XC_LastAdjustmentDate__c = System.TODAY();
        }
        XC_UTIL_ResultWrapper resultContract =  new XC_UTIL_ResultWrapper();
        List<XC_UTIL_Sobject.WrapperResult> dmlResContract = XC_UTIL_DML.updateRecords(contracts);
        XC_UTIL_Sobject.WrapperResult globalResContract = XC_UTIL_Sobject.getGlobalDMLResults(dmlResContract);
        resultContract.success = globalResContract.success;
        
        if(!resultContract.success) {
            resultContract.resultMessage = globalResContract.errorMessage;
            return resultContract;
        } 
        List<NE__OrderItem__c> orderItems = [SELECT Id, NE__RecurringChargeOv__c, NE__Parent_Order_Item__c FROM NE__OrderItem__c WHERE Id IN :orderItemIds];

        Map<String, XC_ContractAmendment__c> contrToCustomContAmMap = new Map<String, XC_ContractAmendment__c>();
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
            contrAmendement.XC_Contract__c = (contracts != null) ? contracts[0].Id : null;
            contrAmendement.Name = (contracts != null) ? contracts[0].ContractNumber : null;
            orderItemToCustomContAmMap.put(orderItem.Id, contrAmendement);
        }
        
        XC_UTIL_ResultWrapper result =  new XC_UTIL_ResultWrapper();
        List<XC_UTIL_Sobject.WrapperResult> dmlRes = XC_UTIL_DML.updateRecords(orderItems);
        XC_UTIL_Sobject.WrapperResult globalRes = XC_UTIL_Sobject.getGlobalDMLResults(dmlRes);
        result.success = globalRes.success;
        if(!result.success) {
            result.resultMessage = globalRes.errorMessage;
        } else {
            List<Asset> assetsToUpdate = [SELECT Id, Name, XC_Contract__c, NE__Action__c, NE__RecurringChargeOv__c, XC_Configuration_Item__c FROM Asset WHERE Id IN : assetIds];
            System.debug('Assets to be updated ' + assetsToUpdate);
            for(Asset a :assetsToUpdate) {
                if(symbol == '+') {
                    a.NE__RecurringChargeOv__c = a.NE__RecurringChargeOv__c + a.NE__RecurringChargeOv__c * percentage/100;
                } else if (symbol == '-') {
                    a.NE__RecurringChargeOv__c = a.NE__RecurringChargeOv__c - a.NE__RecurringChargeOv__c * percentage/100;
                }
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