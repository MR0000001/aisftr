/**
* @author Federico Amici - federico.amici@nttdata.com
* @date Creation 11/06/2019
* @date Modification dd/mm/yyyy
* @description XC_LCC117_OptyNumberOfCalls_D – DAO for the XC_LCC117_OptyNumberOfCalls class
*/
public without sharing class XC_LCC117_OptyNumberOfCalls_D {
   
   /**
    * @author Federico Amici - federico.amici@nttdata.com
    * @date Creation 11/06/2019
    * @date Modification dd/mm/yyyy
    * @description retrieves the custom metadata containing the opportunity default values
    * @param country the country of the custom metadata
    * @return the custom metadata retrieved or null if not found
    */
   public static XC_CM_Opportunity_Default_Values__mdt getOpportunityDefaultValues(String country) {

        Map<Id, XC_CM_Opportunity_Default_Values__mdt> optyMD = 
            new Map<Id, XC_CM_Opportunity_Default_Values__mdt>([SELECT Id, XC_MinutesToUpdateNumberOfCalls__c, XC_NumberOfCallsToCloseOpportunity__c
                                                                FROM XC_CM_Opportunity_Default_Values__mdt
                                                                WHERE DeveloperName = :country]);
        if(optyMD.values().isEmpty()) {
            return null;
        }

        return optyMD.values()[0];
    }

    /**
    * @author Federico Amici - federico.amici@nttdata.com
    * @date Creation 11/06/2019
    * @date Modification dd/mm/yyyy
    * @description retrieves the custom metadata containing the opportunity default values
    * @param opportunityId the opportunity Id
    * @return the opportunity retrieved, null if not found
    */
   public static Opportunity getOpportunityById(String opportunityId) {

        Map<Id, Opportunity> optyMap = 
            new Map<Id, Opportunity>([SELECT Id, XC_NumberOfCalls__c, XC_LastUpdateCallCounter__c, StageName 
                                                                FROM Opportunity
                                                                WHERE Id = :opportunityId]);
        if(optyMap.values().isEmpty()) {
            return null;
        }

        return optyMap.values()[0];
    }
}