/**
 * The Class XC_TR_Configuration_U_CloseConfiguration.
 *
 * @authorFederico Amici - federico.amici@nttdata.com
 * @date Creation 11/06/2019
 * @date Modification dd/mm/yyyy
 * @description XC_TR_Configuration_U_CloseConfiguration_D - DAO for the XC_TR_Configuration_U_CloseConfiguration class
 */
public without sharing class XC_TR_Conf_U_CloseConfiguration_D {
   
   /**
    * @author Federico Amici - federico.amici@nttdata.com
    * @date Creation 11/06/2019
    * @date Modification dd/mm/yyyy
    * @description XC_TR_Configuration_U_CloseConfiguration_D - DAO for the XC_TR_Configuration_U_CloseConfiguration class
    */
    public static Map<Id, Opportunity> getOpportunityAndQuotes(List<Id> orderIds, List<String> listOptyIds) {

        Map<Id, Opportunity> mapOpty = new Map<Id, Opportunity>([SELECT Id,
                                                                (SELECT ID, XC_Status__c FROM NE__Orders__r 
                                                                WHERE Id IN :orderIds AND RecordType.DeveloperName = 'Quote' AND
                                                                XC_Status__c != 'Rejected') 
                                                                FROM Opportunity
                                                                WHERE Id IN :listOptyIds]);
        return mapOpty;
    }

}