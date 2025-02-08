/**
 * @author Federico Amici - federico.amici@nttdata.com
 * @date 07/06/2019
 * @description XC_TR_Opportunity_U_ManageSubStatus_D - DAO for the XC_TR_Opportunity_U_ManageSubStatus class
 */
public without sharing class XC_TR_Opportunity_U_ManageSubStatus_D {
   
   /**
    * @author Federico Amici - federico.amici@nttdata.com
    * @date 07/06/2019
    * @param listIds list of opportunity Ids to retrieve
    * @description retrieves the opportunity and the related quotes
    */
    public static List<Opportunity> getOpportunityAndRelatedQuotes(List<Id> listIds) {

        Map<Id, Opportunity> mapOpportunity =
            new Map<Id, Opportunity>([SELECT Id, (SELECT Id FROM NE__Orders__r WHERE RecordType.DeveloperName = 'Quote')
                                       FROM Opportunity
                                       WHERE Id IN :listIds]);
        return mapOpportunity.values();
    }
    
}