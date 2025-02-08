/**
 * The Class XC_TR_Configuration_U_FillAddress.
 *
 * @author  Salvatore Scarpato - salvatore.scarpato@nttdata.com
 * @date    28/03/2019
 * @description The class populates the address lookup on the configuration when is created blank
 */
public without sharing class XC_TR_Configuration_U_FillAddress {
    /**
     * @description Populate address from opportunity.
     * @param listNew the list new
     * @modification : 09/11/2020
     * @author Dario Tramontin dtramontin@deloitte.it - Marina Ciavarra mciavarra@deloitte.it
     */
    public static void populateAddressFromOpportunity(List<NE__Order__c> listNew, Map<Id,Opportunity> oppMap){

        List<NE__Order__c> orderWithoutAddressList = new List<NE__Order__c>();
        /*
        List<String> listOpportunityId = XC_UTIL_Sobject.getListFieldValues(listNew, 'NE__OptyId__c');
        Map<Id,Opportunity> oppMap = new Map<Id, Opportunity> ([
            SELECT Id, XC_Address__c, XC_LegalEntity__c, XC_Country__c, AccountId, XC_Segment__c,
                    XC_CampaignPlatform__c, XC_CampaignProduct__c, XC_CampaignCode__c, XC_ConventionCode__c, XC_ECID__c
            FROM Opportunity 
            WHERE Id IN: listOpportunityId
        ]);*/

        for(NE__Order__c configuration : listNew){
            if(oppMap.containsKey(configuration.NE__OptyId__c)){
                Opportunity opp = oppMap.get(configuration.NE__OptyId__c);
                configuration.XC_Country__c = opp.XC_Country__c;
                configuration.XC_LegalEntity__c = opp.XC_LegalEntity__c;
                configuration.XC_Segment__c = opp.XC_Segment__c;
                configuration.XC_CampaignPlatform__c = opp.XC_CampaignPlatform__c;
                configuration.XC_CampaignProduct__c = opp.XC_CampaignProduct__c; 
                configuration.XC_CampaignCode__c = opp.XC_CampaignCode__c;
                configuration.XC_ConventionCode__c = opp.XC_ConventionCode__c ;
                configuration.XC_ECID__c = opp.XC_ECID__c;
                   
                if(String.isBlank(configuration.NE__AccountId__c)){
                    configuration.NE__AccountId__c = opp.AccountId;
                }
                if(String.isBlank(configuration.XC_DeliveryAddress__c)){
                    configuration.XC_DeliveryAddress__c = opp.XC_Address__c;
                }
                if(String.isBlank(configuration.XC_InstallationAddress__c)){
                    configuration.XC_InstallationAddress__c = opp.XC_Address__c;
                }
                if(String.isBlank(configuration.XC_ResidentialAddress__c) && !String.isBlank(opp.XC_ResidentialAddress__c)  ){
                    configuration.XC_ResidentialAddress__c = opp.XC_ResidentialAddress__c;
                }
                
            }  
        } 
    }
}