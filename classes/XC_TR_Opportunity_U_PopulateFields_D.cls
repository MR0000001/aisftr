/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 06/06/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_Opportunity_U_PopulateFields_D – DAO for the XC_TR_Opportunity_U_PopulateFields class 
*/

public without sharing class XC_TR_Opportunity_U_PopulateFields_D {  
    
    
    /**
     * @description Get address fields by opportunities
     *
     * @param ids the set of id
     * @return a list of address
     */
    public static List<XC_Address__c> getAddrFields(set<String> ids){

        Map<id, XC_Address__c> add = new Map<id, XC_Address__c>([select id, XC_PricinRegion__c from XC_Address__c where id in: ids]);

        return add.values();
    }
    

}