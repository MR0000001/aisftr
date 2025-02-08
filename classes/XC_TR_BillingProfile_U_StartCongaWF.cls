/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 09/08/2019
* @date Modification dd/mm/yyyy
* @description  – XC_TR_BillingProfile_U_StartCongaWF  - Class that recover the info from Billing Profile and related records and pass the info to the Conga call
*                                                             that start with a workflow  
*/ 
public without sharing class XC_TR_BillingProfile_U_StartCongaWF {
    
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_BillingProfile_U_StartCongaWF');

    /**
    * @description
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 12/8/2019
    * @param mapOld Map<Id, NE__Billing_Profile__c> 
    * @param mapNew Map<Id, NE__Billing_Profile__c>
    */
    public static void populateCongaField(List<NE__Billing_Profile__c> listNew, Map<Id, NE__Billing_Profile__c> mapOld, Map<Id, NE__Billing_Profile__c> mapNew) {     
        
        // IN THIS CASE THE GETLISTCHANGED IS NOT USEFULL BECAUSE THE FIELD CREATE MANDATE IS UPDATE TO FALSE WITH A WORKFLOW
        //List<String> fieldList = new List<String>{'XC_CreateMandate__c'};
        //List<NE__Billing_Profile__c> billingProfileList = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        Map<String, NE__Billing_Profile__c> billingProfilesIdMap = new Map<String, NE__Billing_Profile__c>(); 
        for(NE__Billing_Profile__c billingProfile : listNew){
            if(billingProfile.NE__Payment__c == Label.XC_CL_DirectDebt &&
            billingProfile.XC_CreateMandate__c &&
            !String.isEmpty(billingProfile.XC_SepaAutoNumber__c) &&
            !String.isEmpty(billingProfile.XC_SepaMandate__c) &&
            !String.isEmpty(billingProfile.NE__Iban__c) 
            ){
                billingProfilesIdMap.put(billingProfile.Id, billingProfile);
            }
        }  
        if(billingProfilesIdMap.isEmpty()){
            return;
        }
        List<XC_UTIL_Conga.UtilWrapper> wrapperList = createCongaWrapper(billingProfilesIdMap, listNew);
        XC_UTIL_Conga.queryOnCongaTemplates(wrapperList, 'SEPA_SIGNATURE');
    
        if(!wrapperList.isEmpty()){
            startingCongaWorkflow(wrapperList);
        }
    }
    
    /**
    * @description 
    * @author salvatore.scarpato@nttdata.com | 25/3/2020 
    * @param billingProfilesIdMap 
    * @param listNew 
    * @return List<XC_UTIL_Conga.UtilWrapper> 
    **/
    private static List<XC_UTIL_Conga.UtilWrapper> createCongaWrapper(Map<String, NE__Billing_Profile__c> billingProfilesIdMap, List<NE__Billing_Profile__c> listNew){
        List<XC_UTIL_Conga.UtilWrapper> wrapperList = new List<XC_UTIL_Conga.UtilWrapper>();

        for(NE__Billing_Profile__c bp : listNew){
            XC_UTIL_Conga.UtilWrapper wrapper = new XC_UTIL_Conga.UtilWrapper();
            if(billingProfilesIdMap.containsKey(bp.Id)){
                wrapper.billingProfileToUpdate = bp;
                wrapper.legalEntity = bp.XC_LegalEntity__c;
                wrapperList.add(wrapper); 
            }
        }
        return wrapperList;
    }

    /**
    * @description 
    * @author salvatore.scarpato@nttdata.com | 25/3/2020 
    * @param wrapperList 
    * @return List<NE__Billing_Profile__c> 
    **/
    private static void startingCongaWorkflow(List<XC_UTIL_Conga.UtilWrapper> wrapperList){
        List<NE__Billing_Profile__c> billingProfileToUpdateList = new List<NE__Billing_Profile__c>();
        for(XC_UTIL_Conga.UtilWrapper wrapper : wrapperList){    
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ START CONGA ON BILLING PROFILE templateId--> ' + wrapper.templateId);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ START CONGA ON BILLING PROFILE congaquery--> ' + wrapper.congaQuery);
            if(!String.isBlank(wrapper.templateId) && !String.isBlank(wrapper.congaQuery) ){
                NE__Billing_Profile__c bpToUpdate = wrapper.billingProfileToUpdate;
                String dynamicApi = '&Id=' + bpToUpdate.Id + '&QueryId=' +  wrapper.congaQuery + '&TemplateId=' +  wrapper.templateId
                            + '&OFN=' +  bpToUpdate.Id + ' - SEPA_SIGNATURE'+
                            + '&DefaultPDF=1&qmode=SalesforceFile';
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ START CONGA ON BILLING PROFILE dynamicApi--> ' + dynamicApi);
                bpToUpdate.XC_CongaDynamicAPI__c = bpToUpdate.XC_CongaStaticAPI__c + dynamicApi;
            } 
        }
    }
}