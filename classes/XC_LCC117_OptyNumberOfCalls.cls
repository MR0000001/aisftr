/**
* @author Federico Amici - federico.amici@nttdata.com
* @date Creation 11/06/2019
* @date Modification dd/mm/yyyy
* @description XC_LCC117_OptyNumberOfCalls – Handles the increment of the number of calls on opportunity
*/
public without sharing class XC_LCC117_OptyNumberOfCalls {
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC117_OptyNumberOfCalls');
    @AuraEnabled
    /**
    * @author Federico Amici - federico.amici@nttdata.com
    * @date Creation 11/06/2019
    * @date Modification dd/mm/yyyy
    * @description updateNumberOfCalls – Handles the increment of the number of calls on opportunity
    * @param opportunityId the record Id
    * @return the JSON result
    */
    public static String updateNumberOfCalls(String opportunityId) {

        XC_UTIL_ResultWrapper resultWr = new XC_UTIL_ResultWrapper();

        Opportunity o = XC_LCC117_OptyNumberOfCalls_D.getOpportunityById(opportunityId);
        if(o == null) {
            resultWr.success = false;
            resultWr.resultMessage = Label.XC_CL_Opportunity_CantUpdateNumCallsDraft;
            return JSON.serialize(resultWr, true);
        } else if(o.StageName != Label.XC_CL_Opportunity_Draft) {
            resultWr.success = false;
            resultWr.resultMessage = Label.XC_CL_Opportunity_CantUpdateNumCallsDraft;
            return JSON.serialize(resultWr, true);
        }

        String country = 'Spain';   /* Variable to configure the retrieve */

        XC_CM_Opportunity_Default_Values__mdt optyDefault = XC_LCC117_OptyNumberOfCalls_D.getOpportunityDefaultValues(country);
        if(optyDefault == null) {
            resultWr.success = false;
            resultWr.resultMessage = Label.XC_CL_CustomMetadata_NotFound;
            return JSON.serialize(resultWr, true);
        }

        Boolean canUpdateCallCounter = checkConditionUpdateCallCounter(o.XC_LastUpdateCallCounter__c, optyDefault.XC_MinutesToUpdateNumberOfCalls__c);

        if(!canUpdateCallCounter) {
            resultWr.success = false;
            resultWr.resultMessage = Label.XC_CL_Opportunity_CantUpdateNumCalls;
            return JSON.serialize(resultWr, true);
        }

        o.XC_NumberOfCalls__c = o.XC_NumberOfCalls__c + 1;
        o.XC_LastUpdateCallCounter__c = DateTime.now();
        Integer callsThreshold = Integer.valueOf(optyDefault.XC_NumberOfCallsToCloseOpportunity__c);
        if(o.XC_NumberOfCalls__c >= callsThreshold) {
            o.StageName = Label.XC_CL_Opportunity_ClosedLost;
            o.XC_LossReason__c = Label.XC_CL_Opportunity_DoesNotAnswer;
        }

        XC_UTIL_SObject.WrapperResult updateResult = XC_UTIL_Sobject.updateRecord(o);
        resultWr.success = updateResult.success;
        resultWr.resultMessage = updateResult.errorMessage;
        resultWr.isValid = o.StageName == Label.XC_CL_Opportunity_ClosedLost ? true : false;
        return JSON.serialize(resultWr, true);
    }

    private static Boolean checkConditionUpdateCallCounter(DateTime lastUpdateDT, Decimal minutesToWaitD) {

        if(lastUpdateDT == null) {
            return true;
        }

        Long deltaMilli = Datetime.now().getTime() - lastUpdateDT.getTime();
        
        Long minutesPastL = (deltaMilli/1000)/60;
        Integer minutesPast = Integer.valueOf(minutesPastL);
        Integer minutesToWait = Integer.valueOf(minutesToWaitD);

        if(minutesPast < minutesToWait) {
            return false;
        } else {
            return true;
        }
    }

}