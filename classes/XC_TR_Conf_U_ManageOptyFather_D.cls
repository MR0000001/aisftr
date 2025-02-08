/**
 * @author Federico Amici - federico.amici@nttdata.com
 * @date 07/06/2019
 * @description XC_TR_Conf_U_ManageOptyFather_D - DAO for the XC_TR_Conf_U_ManageOptyFather class
 */
public without sharing class XC_TR_Conf_U_ManageOptyFather_D {
      
    /**
    * @author Federico Amici - federico.amici@nttdata.com
    * @date 07/06/2019
    * @param listIds list of opportunity Ids to retrieve
    * @description retrieves the opportunity and the related quotes
    */
    public static List<Opportunity> retrieveOpportunities(List<Id> listOpportunityIds) {

        Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>([SELECT Id, XC_Substatus__c
                                                                     FROM Opportunity
                                                                     WHERE Id IN :listOpportunityIds]);
        return mapOpportunities.values();

    }
}