/**
* @author Anna Maria Rosanova - annamaria.rosanova@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 10/07/2019
* @description XC_TR_Lead_U_SetDateTimeFields – class to set date time fields on the change of the leads status
*/ 
public class XC_TR_Lead_U_SetDateTimeFields {
        
    /**
      * @author Anna Maria Rosanova - annamaria.rosanova@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
      * @param listLead the list lead
      * @description    
      */
    public static void onBeforeUpdate (List<Lead> listLead, Map<Id, Lead> mapOld, Map<Id, Lead> mapNew) {
        List<String> fieldList = new List<String>{'Status'};
        List<sObject> leadChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!leadChanged.isEmpty()) {
            setDateTime(leadChanged); 
        }
    }


    /**
      * @author Anna Maria Rosanova - annamaria.rosanova@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
      * @param listLead the list lead
      * @description Set Date Time
      */
    private static void setDateTime (List<Lead> listLead) {
        for(Lead currentLead : listLead){
            if(currentLead.Status == Label.XC_CL_Lead_Assigned){
                currentLead.XC_AssignedTime__c = Datetime.now();
            } else if (currentLead.Status == Label.XC_CL_Lead_TakeCharge){
                currentLead.XC_TakeChargeTime__c= Datetime.now();
            } else if (currentLead.Status == Label.XC_CL_Lead_PendingScheduling){
                currentLead.XC_PendingSchedulingTime__c = Datetime.now();
            } else if (currentLead.Status == Label.XC_CL_Lead_ClosedConverted){
                currentLead.XC_ClosedConvertedTime__c = Datetime.now();
            } else if (currentLead.Status == Label.XC_CL_Lead_ClosedNotConverted){
                currentLead.XC_ClosedNotConvertedTime__c = Datetime.now();
            }
        }

    }

}