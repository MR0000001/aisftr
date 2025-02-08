/**
 * The Class XC_LCC109_TakeChargeLead.
 *
 * @author: Monica Cutillo monica.cutillo@nttdata.com
 * @date Creation: 19/04/2019
 * @description XC_LCC109_TakeChargeLead – Controller of XC_LCP109_TakeChargeLead
 */
public with sharing class XC_LCC109_TakeChargeLead {
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC109_TakeChargeLead');

    /**
     * @description implements the Thake Charge logic
     * @param leadId Lead Id 
     * @return the result wrapper
     */
    @AuraEnabled
	public static XC_UTIL_ResultWrapper takeLeadChargeProcess(String leadId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ init takeLeadChargeProcess');
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        
        Lead lead = retrieveLead(leadId);
        if(lead==null){
            rw.success = false;
            rw.resultMessage = String.format(Label.XC_CL_ErrorRetrieveLead, new List<String>{leadId});
            return rw;
        }
        if(lead.OwnerId == Userinfo.getUserId()){
            return manageChangeStatus(lead);
        }
        return takeCharge(lead, Userinfo.getUserId());
    }
    
    /**
     * @description retrieve a Lead from its Id
     * @param leadId Lead Id
     * @return the retreaved Lead
     */
    private static Lead retrieveLead(String leadId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ retrieveLead with id '+leadId);
        Map<Id, Lead> leads = new Map<Id, Lead>([SELECT Id, Status, OwnerId,XC_CTI_Interaction__c, XC_CTICallRecording__c FROM Lead WHERE Id =: leadId LIMIT 1 ]);
        if(!(leads.values().isEmpty())){
            return leads.values()[0];
        }
        return null;
    }

    /**
     * @description retrieve a Lead from its Id
     * @param lead Lead object
     * @return the operation result wrapper
     */
    public static XC_UTIL_ResultWrapper manageChangeStatus(Lead lead){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ manageChangeStatus');
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        if(lead.Status != Label.XC_CL_Lead_TakeCharge){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ manageChangeStatus - TODO: update Lead status');
            lead.Status = Label.XC_CL_Lead_TakeCharge;
            List<XC_UTIL_Sobject.WrapperResult> updWR = XC_UTIL_DML.updateRecords(new List<Lead>{lead});
            if(updWR[0].success){
                rw.success = true;
                rw.resultMessage = Label.XC_CL_LeadUpdated;
            }else{
                rw.success = false;
                rw.resultMessage = updWR[0].errorMessage;
            }
        }else{
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ manageChangeStatus - TODO: nothing');
            rw.success = true;
            rw.resultMessage = Label.XC_CL_LeadAlreadiInStatus;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ takeCharge - result = '+ rw);
        return rw;
    }

    /**
     * @description manage operations to take charge to the new owner
     * @param lead 
     * @param newOwner
     * @return the take charge result
     */
    private static XC_UTIL_ResultWrapper takeCharge(Lead lead, String newOwner){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ takeCharge - old owner = '+ lead.OwnerId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ takeCharge - new owner = '+ newOwner);
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = true;

        lead.OwnerId = newOwner;
        lead.Status = Label.XC_CL_Lead_TakeCharge;
        try{
            checkCallRecordingMandatoriety(lead,rw);
            if(!rw.success){
                    return rw;
            }else{
                List<XC_UTIL_Sobject.WrapperResult> updWR = XC_UTIL_DML.updateRecords(new List<Lead>{lead});
                if(updWR[0].success){
                    rw.success = true;
                    rw.resultMessage = Label.XC_CL_LeadUpdated;
                }else{
                    rw.success = false;
                    rw.resultMessage = updWR[0].errorMessage;
                }
            }
        }catch(Exception ex){
            rw.success = false;
            rw.resultMessage = ex.getMessage();
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ takeCharge - result = '+ rw);
        return rw;
    }

    /**
    * @description check if CTI call recording is mandatory for the particular lead in order to be taken in charge
    * @author Francesco Imperioli - fimperioli@deloitte.it | 25/5/2020 
    * @param lead 
    * @param rw 
    * @return void 
    **/
    private static void checkCallRecordingMandatoriety(Lead lead,XC_UTIL_ResultWrapper rw){

        String userLe = XC_UTIL_User.getLegalEntityFromUser();
        List<XC_CM_CallRecordingConfiguration__mdt> callRecsConf = [SELECT XC_LegalEntity__c,XC_CheckOnLead__c FROM XC_CM_CallRecordingConfiguration__mdt WHERE XC_LegalEntity__c =:userLe LIMIT 1];

        if(callRecsConf.isEmpty() || !callRecsConf[0].XC_CheckOnLead__c || String.isBlank(lead.XC_CTI_Interaction__c)){
            rw.success = true;
        }else if (callRecsConf[0].XC_CheckOnLead__c && String.isNotBlank(lead.XC_CTI_Interaction__c) && String.isBlank(lead.XC_CTICallRecording__c)){
            rw.success = false;
            rw.resultMessage = Label.XC_CL_LCP109_CTIRecordingMandatory;
        }
    }

}