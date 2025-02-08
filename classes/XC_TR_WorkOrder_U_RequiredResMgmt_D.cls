/**
 * @author: Marco Rosa - marco.rosa@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it, 
 * @date  : 10/09/2019
 * @description DAO class for XC_TR_WorkOrder_U_RequiredResourcesMgmt.
**/

public without sharing class XC_TR_WorkOrder_U_RequiredResMgmt_D {
   
    /**
     * @description Retrieve map service resources.
     * @param listAccountIds the list of partner account ids
     * @return the map
     */
    public static Map<Id, List<ServiceResource>> retrieveMapAccountListServiceResources(List<Id> listAccountIds){
        Map<Id, List<ServiceResource>> mapAccountListServiceResources = new Map<Id, List<ServiceResource>>();
        List<Account> listAccounts = new List<Account>([
            SELECT Id, 
                (SELECT Id
                FROM Service_Resources__r
                WHERE IsActive = true AND (ResourceType = 'T' OR ResourceType = 'C'))
            FROM Account
            WHERE Id IN: listAccountIds
        ]);
        for(Account a : listAccounts){
            if(!a.Service_Resources__r.isEmpty()){
                mapAccountListServiceResources.put(a.Id, a.Service_Resources__r);
            }
        } 
        return mapAccountListServiceResources;
    }
}