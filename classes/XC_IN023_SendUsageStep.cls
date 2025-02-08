/**
 * @author Federico Amici - federico.amici@nttdata.com / Salvatore Scarpato - salvatore.scarpato@nttdata.com
 * @date 02/05/2019
 * @description XC_IN023_SendUsageStep Step that calls uses Send Usage interface
 */
public with sharing class XC_IN023_SendUsageStep {
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN023_SendUsageStep');


    /** 
     * @author Federico Amici - federico.amici@nttdata.com
     * @date 18/03/2019
     * @description Wrapper used by flow
     */
    public class InputWrapper{ 
        @Invocablevariable
        public String stepId; 
    }    

    private class UtilWrapper{
        String subscriptionId;
        String accountId;
        Decimal amount;
        String legalEntity;
        String stream;
        XC_Provisioning_Step__c step = new XC_Provisioning_Step__c();
    }
    /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @description createZquote manages the creation of the zquote
     * @param inputWrapperList the input wrapper list
     */
    @InvocableMethod
    public static void stepSendUsage(List<InputWrapper> inputWrapperList) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering XC_IN023_SendUsageStep');
        UtilWrapper utilWr = getParentsInfo(inputWrapperList);
        XC_REST_PayAndBill.WrapperRequest wrapperPayAndBill = new XC_REST_PayAndBill.WrapperRequest();
        wrapperPayAndBill.SubscriptionId = utilWr.subscriptionId;
        wrapperPayAndBill.AccountId =  utilWr.accountId;
        wrapperPayAndBill.PrepaidAmount = utilWr.amount;
        wrapperPayAndBill.legalEntity = utilWr.legalEntity;
        wrapperPayAndBill.stream = utilWr.stream;
        //ACTIONS
        XC_UTIL_Debug.debug(DEBUGACTIVE, '###wrapperPayAndBill subscription Id  -->'+ utilWr.subscriptionId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '###wrapperPayAndBill accountId Id  -->'+ utilWr.accountId);
        //1) CALL THE REST CLASS
        if(wrapperPayAndBill.AccountId!='No value' && wrapperPayAndBill.SubscriptionId!= 'No value'){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '###wrapperPayAndBill SENT - Send Usage  -->'+ wrapperPayAndBill);
            XC_REST_PayAndBill.WrapperResponse wrResponse = XC_REST_PayAndBill.createPayAndBill(wrapperPayAndBill);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '###SEND USAGE WRAPPER - Send Usage -->'+ wrResponse);
            if(!(wrResponse.errors).isEmpty()){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '###SET KO');
                utilWr.step.XC_ErrorMessage__c = wrResponse.errors[0].title;
                completeStepKo(utilWr.step);
            }else {
                //2) Complete the step
                completeStep(utilWr.step);
            }
        } else {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '###SET KO');
            completeStepKo(utilWr.step);
        }
    }

    private static Boolean checkIfBlankFields(String costCenter, String companyCode){
        if(!String.isBlank(costCenter) && !String.isBlank(companyCode)){
            return true;
        }
        return false;
    }

    private static Boolean checkIfEmptyList(List<String> costCenterList, List<String> companyCodeList){
        if(!costCenterList.isEmpty() && !companyCodeList.isEmpty()){
            return true;
        }
        return false;
    }
    /**
    * @description Gets the info from step.
    * @param inputWrapperList the input wrapper list
    * @return 
    **/
    private static UtilWrapper getParentsInfo(List<InputWrapper> inputWrapperList){
        UtilWrapper wrapper = new UtilWrapper();
        NE__OrderItem__c orderItemFather = new NE__OrderItem__c();
        List<String> configurationItemIds = new List<String>(); 
        List<String> listStepIds = new List<String>(); 
        for(InputWrapper inputWr : inputWrapperList){                
            listStepIds.add(inputWr.stepId);
        } 

        Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id,XC_Provisioning_Step__c> ([
            SELECT XC_Configuration_Item__c, XC_ConfigurationId__c,XC_Status__c
            FROM XC_Provisioning_Step__c 
            WHERE Id IN: listStepIds
        ]);    
        List<XC_Provisioning_Step__c> listSteps = mapSteps.values();
        for(XC_Provisioning_Step__c step : listSteps){
            if(!String.isBlank(step.XC_Configuration_Item__c)){
                configurationItemIds.add(step.XC_Configuration_Item__c);
            }
        }
        Map<Id, NE__OrderItem__c> configurationItemMap  = new Map<Id, NE__OrderItem__c>([
            SELECT ID, NE__OrderId__c,  NE__OrderId__r.XC_Company_Code__c, NE__OneTimeFeeOv__c, NE__OrderId__r.XC_Segment__c,
            NE__OrderId__r.XC_Cost_Center__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c
            FROM NE__OrderItem__c 
            WHERE Id IN: configurationItemIds
        ]);              
        List<String> costCenterList = new List<String>();
        List<String> companyCodeList = new List<String>();
        for(NE__OrderItem__c orderItem : configurationItemMap.values()){
            if(checkIfBlankFields(orderItem.NE__OrderId__r.XC_Cost_Center__c, orderItem.NE__OrderId__r.XC_Company_Code__c)){
                costCenterList.add(orderItem.NE__OrderId__r.XC_Cost_Center__c);
                companyCodeList.add(orderItem.NE__OrderId__r.XC_Company_Code__c);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '###costCenterList Send Usage ---> ' + costCenterList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '###companyCodeList Send Usage ---> ' + companyCodeList);
        Map<Id, Asset> assetMap = new Map<Id, Asset>();
        Map<Id, zqu__Quote__c> mapZquote = new Map<Id, zqu__Quote__c>();
        
        if(checkIfEmptyList(costCenterList, companyCodeList)){
            assetMap = new Map<Id, Asset>([SELECT Id, XC_ZQuoteId__c
                                        FROM Asset
                                        WHERE XC_CostCenter__c IN:  costCenterList
                                        AND XC_CompanyCode__c IN: companyCodeList
                                        AND XC_ZQuoteId__c != null
            ]);
            List<String> zQuoteList = new List<String>();
            for(Asset asst : assetMap.values()){
                zQuoteList.add(asst.XC_ZQuoteId__c);
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '###zQuoteList Send Usage ---> ' + zQuoteList);
            mapZquote = new Map<Id, zqu__Quote__c>([SELECT Id, zqu__ZuoraSubscriptionID__c,zqu__ZuoraAccountID__c
                                    FROM zqu__Quote__c WHERE Id IN: zQuoteList]);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '###mapZquote Send Usage ---> ' + mapZquote);
        }

        if(!mapZquote.isEmpty()){
            wrapper.subscriptionId = mapZquote.values()[0].zqu__ZuoraSubscriptionID__c;
            wrapper.accountId = mapZquote.values()[0].zqu__ZuoraAccountID__c;
        } else {
            wrapper.subscriptionId = 'No value';
            wrapper.accountId = 'No value';
        }
        wrapper.amount = configurationItemMap.values()[0].NE__OneTimeFeeOv__c;
        wrapper.step = listSteps[0];
        wrapper.legalEntity = configurationItemMap.values()[0].NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c;
        wrapper.stream = configurationItemMap.values()[0].NE__OrderId__r.XC_Segment__c;

        XC_UTIL_Debug.debug(DEBUGACTIVE, '###Wrapper Send Usage ---> ' + wrapper);
        return wrapper; 
    }        

    private static void completeStep(XC_Provisioning_Step__c step){
        step.XC_Status__c = Label.XC_CL_Completed_OK;
        XC_UTIL_Sobject.updateRecord(step);
    }

    private static void completeStepKo(XC_Provisioning_Step__c step){
        step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
        XC_UTIL_Sobject.updateRecord(step);
    }
}