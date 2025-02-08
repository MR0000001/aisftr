/**
 * @File Name          : XC_LCC184_B2WNextStep.cls
 * @Description        : 
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 19/6/2020, 16:34:50
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    9/4/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
**/
public without sharing class XC_LCC184_B2WNextStep {



    /**
    * @description check the available record type for legal entity in order to show choice selection inside the component
    * @author Francesco Imperioli - fimperioli@deloitte.it | 8/6/2020 
    * @param recordId 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String,Object> checkLEBusinessProcess(String recordId){

        Map<String,Object> result = new Map<String,Object>();
        Set<String> b2wNextStepRts = new Set<String>{'Quote','Order'};

        //getting current order infos
        NE__Order__c currentOrd = [SELECT Id,XC_LegalEntity__c,XC_Segment__c FROM NE__Order__c WHERE Id = :recordId LIMIT 1];

        //getting user le, then checking the current legal entity configuration for quote/order management
        String userLE = XC_UTIL_User.getLegalEntityFromUser();
        List<XC_CM_LegalEntity_Configuration__mdt> leConfs = [SELECT DeveloperName,XC_ExcludeQuote__c FROM XC_CM_LegalEntity_Configuration__mdt WHERE 
        XC_LegalEntity__c = :userLe AND XC_OrgId__c = :UserInfo.getOrganizationId()
        AND XC_Stream__c = : currentOrd.XC_Segment__c LIMIT 1];

        //TODO: check quote exclusion
        if(!leConfs.isEmpty() && leConfs[0].XC_ExcludeQuote__c){
            b2wNextStepRts.remove('Quote');
        }
        
        result.put('autoConvert',b2wNextStepRts.size()==1);
        result.put('availableRTs',b2wNextStepRts);

        return result;


    }



    /**
    * @description convert the order using b2w datamaps
    * @author Francesco Imperioli - fimperioli@deloitte.it | 8/6/2020 
    * @param paramsMap 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String,Object> b2wOrderToOrder(Map<String,Object> paramsMap){

        Map<String,Object> result = new Map<String,Object>();

       
        Boolean hasExpiredContract = checkItemsForExpiredContracts(paramsMap);

        if(hasExpiredContract){
            result.put('success', false);
            result.put('errorMsg', Label.XC_CL_QuoteItemsExpiredContract);
            return result;
        }

        Boolean isAmountZero = checkNonCapexItemsAmount(paramsMap);

        if(isAmountZero){
            result.put('success', false);
            result.put('errorMsg', System.Label.XC_CL_Configuration_CapexBillingModelErrorOrder);
            return result;
        }

        List<User> userList = [SELECT id, XC_AsycTrigger__c FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];
        if(userList[0].XC_AsycTrigger__c){
            XC_TR_ConfigurationItem_Handler.asyncAggreateAfterUpdate = true;
        }


        NE.DataMap.DataMapRequest dReq = new NE.DataMap.DataMapRequest();
        dReq.mapName = 'Order2Order';
        dReq.sourceId = String.valueOf(paramsMap.get('recordId'));
        NE.DataMap mp = new NE.DataMap();
        NE.DataMap.DataMapResponse dResp = mp.callDataMap(dReq);

        if(dResp.ErrorCode != '0'){
            throw new AuraHandledException('EXCEPTION ON B2W DATAMAP GENRATION ' + dResp.ErrorMessage);
        }

        NE__Order__c newConfiguration = new NE__Order__c(Id = dResp.parentId);
        newConfiguration.recordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get(String.valueOf(paramsMap.get('rtName'))).getRecordTypeId();
        newConfiguration.NE__OrderStatus__c = 'Pending';
        newConfiguration.XC_Status__c = String.valueOf(paramsMap.get('rtName')) == 'Order' ? Label.XC_CL_Configuration_OrderInProgress : Label.XC_CL_Configuration_QuoteDraft;
        XC_UTIL_Sobject.WrapperResult updateResult = XC_UTIL_Sobject.updateRecord(newConfiguration);

        if(userList[0].XC_AsycTrigger__c){
            XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
            System.enqueueJob((new XC_TR_ConfigurationItem_Handler.OnAfterUpdateAsyncAggregate(null)));
        }

        result.put('success',updateResult.success);
        if(String.isNotBlank(updateResult.recordId)){
            result.put('resultRecordId',updateResult.recordId);
        }

        return result;
    }

    private static Boolean checkNonCapexItemsAmount(Map<String,Object> paramsMap){
        //true: all items with != Capex model have amount 0
        //false: there is at least 1 item of != Capex model with amount > 0 
        Boolean isAmountZero = false;
        Id techItemRT = Schema.SObjectType.NE__OrderItem__c.RecordTypeInfosByDeveloperName.get('Technical_Item').getRecordTypeId(); //elisa.caldini@accenture.com-23.06.2022-hotfix CR758

        if(String.valueOf(paramsMap.get('rtName')) != null && String.valueOf(paramsMap.get('rtName')).equalsIgnoreCase('Order')){

            Map<Id,NE__Order__c> optyWithItems = new Map<Id,NE__Order__c>([SELECT Id,XC_Segment__c,XC_LegalEntity__c,NE__OptyId__r.XC_BusinessLine__c,(SELECT XC_BillingModel__c,NE__OneTimeFeeOv__c,NE__RecurringChargeOv__c FROM NE__Order_Items__r WHERE RecordTypeId !=: techItemRT) FROM NE__Order__c WHERE Id = : String.valueOf(paramsMap.get('recordId')) LIMIT 1]); //elisa.caldini@accenture.com-23.06.2022-hotfix CR758-add condition inner query

            if(optyWithItems.size()>0 && 
                (optyWithItems.values()[0].NE__OptyId__r.XC_BusinessLine__c == 'eCity' && (optyWithItems.values()[0].XC_Segment__c == 'B2G' || optyWithItems.values()[0].XC_Segment__c == 'B2B'))){
                
                //the list with all chlidren config items for the current quote
                List<NE__OrderItem__c> configItems = optyWithItems.values()[0].NE__Order_Items__r;

                isAmountZero = true;
                //counter for configuration items with billing model != capex
                Integer nonCapexModelItems = 0;

                for(NE__OrderItem__c item: configItems){
                    if(item.XC_BillingModel__c != 'Capex'){
                        nonCapexModelItems += 1;
                        if(item.NE__OneTimeFeeOv__c > 0 || item.NE__RecurringChargeOv__c > 0){
                            isAmountZero = false;
                            break;
                        }
                    }    
                }

                //in case there are no items with billing model != capex, do not give error
                if(nonCapexModelItems == 0){
                    isAmountZero = false;
                }
            }    
        }

        return isAmountZero;
    }

    private static Boolean checkItemsForExpiredContracts(Map<String,Object> paramsMap){
        Boolean isExpired = false;

        if(String.valueOf(paramsMap.get('rtName')) != null && String.valueOf(paramsMap.get('rtName')).equalsIgnoreCase('Order')){

            Map<Id,NE__Order__c> optyWithItems = new Map<Id,NE__Order__c>([SELECT Id,XC_Segment__c,XC_LegalEntity__c,NE__OptyId__r.XC_BusinessLine__c,(SELECT XC_PartnerContract__r.XC_CheckExpirDate__c FROM NE__Order_Items__r) FROM NE__Order__c WHERE Id = : String.valueOf(paramsMap.get('recordId')) LIMIT 1]);

            if(optyWithItems.size()>0 && 
                ( optyWithItems.values()[0].XC_Segment__c == 'B2G' || optyWithItems.values()[0].XC_Segment__c == 'B2B')){
                
                //the list with all chlidren config items for the current quote
                List<NE__OrderItem__c> configItems = optyWithItems.values()[0].NE__Order_Items__r;

                for(NE__OrderItem__c item: configItems){
                    if(!String.isBlank(item.XC_PartnerContract__c)){
                        if(!item.XC_PartnerContract__r.XC_CheckExpirDate__c){
                            isExpired = true;
                            break;
                        }
                    }    
                }

            }    
        }

        return isExpired;
    }
 
}