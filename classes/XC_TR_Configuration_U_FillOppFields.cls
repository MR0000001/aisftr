/**
 * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Marco Rosa - marco.rosa@nttdata.com
 * @date Creation 10/05/2019
 * @description XC_TR_Configuration_U_FillOppFields – Class to fill Opportunity Fields for Configuration Object
 */

public without sharing class XC_TR_Configuration_U_FillOppFields {
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Configuration_U_FillOppFields');

    /**
     * @description Method to populate Opportunity
     * @param listOrder - List<NE__Order__c>
     * @param mapOld
     * @param mapNew
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @data 10/05/2019
     */
    public static void populateOpportunity(List<NE__Order__c> listOrder, Map<Id, NE__Order__c> mapOld, Map<Id, NE__Order__c> mapNew){
        system.debug('sono nel metodo populate opportunity');
        List<NE__Order__c> listChanged = XC_UTIL_Sobject.getListChanged(new List<String>{'RecordTypeAUX__c'}, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        List<Opportunity> listOppToUpdate = new List<Opportunity>();
        List<String> listIdOpp = XC_UTIL_Sobject.getListFieldValues(listChanged,'NE__OptyId__c');
        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>([SELECT Id, Name, XC_CompanyCode__c, XC_CostCenter__c
                                                                    FROM Opportunity
                                                                    WHERE Id IN :listIdOpp]);
        for(NE__Order__c order : listChanged) {
            system.debug('test: '+mapOpportunity.get(order.NE__OptyId__c));
            if(order.RecordTypeAUX__c == 'Order' && order.XC_Channel__c != 'EnelEnergiaItalia') {
                Opportunity opp = mapOpportunity.get(order.NE__OptyId__c);

                if(!String.isBlank(opp.XC_CompanyCode__c)){
                    order.XC_Company_Code__c = opp.XC_CompanyCode__c; 
                } else {
                    opp.XC_CompanyCode__c = order.Name;
                    order.XC_Company_Code__c = order.name;
                }

                if(!String.isBlank(opp.XC_CostCenter__c)) {
                    order.XC_Cost_Center__c = opp.XC_CostCenter__c;
                } else {
                    opp.XC_CostCenter__c = order.Name;
                    order.XC_Cost_Center__c = order.name;
                }
                
                listOppToUpdate.add(opp);
            }
        }
        XC_UTIL_Sobject.updateListRecords(listOppToUpdate);
    }

        /**
     * @description Method to populate skip contract on order 
     * @param listNew - List<NE__Order__c>
     * @author Domenico Del Prete - domenico.delprete@nttdata.com
     * @data 25/09/2020
     */
    public static void populateSkipContractOnOrder(List<NE__Order__c> listNew){
        Id recTypeOptyId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Order_RecordTypeOpty).getRecordTypeId();
        Map<String, NE__Order__c> mapOppIdOrder = new Map<String, NE__Order__c>();
        List<String> listOfLE = new List<String>();
        List<String> listOfSegment = new List<String>();
        for(NE__Order__c ord : listNew){
            if(recTypeOptyId.equals(ord.RecordTypeId)){
                if(!String.isBlank(ord.NE__OptyId__c)){
                    mapOppIdOrder.put(ord.NE__OptyId__c, ord);
                    listOfLE.add(ord.XC_LegalEntity__c);
                    listOfSegment.add(ord.XC_Segment__c);
                 }
            }
        }
        if(mapOppIdOrder.values().isEmpty()){
            return;
        }
        List<Opportunity> listOpp = new List<Opportunity>([SELECT Id, XC_ExternalPartner__c 
                                                            FROM Opportunity 
                                                            WHERE ID IN:mapOppIdOrder.keySet()
                                                                AND XC_ExternalPartner__c != null]);
        List<XC_CM_CountryLegalEntityAssociation__mdt > listOfCountryLE = new List<XC_CM_CountryLegalEntityAssociation__mdt >([
                SELECT Id, XC_LegalEntity__c, XC_Stream__c, XC_SkipContractGen__c
                FROM XC_CM_CountryLegalEntityAssociation__mdt  
                WHERE XC_LegalEntity__c IN: listOfLE AND XC_Stream__c IN: listOfSegment 
        ]);
        Map<String, List<String>> mapLegalEntityStreamPartner = new Map<String, List<String>>();
        for(XC_CM_CountryLegalEntityAssociation__mdt cmd : listOfCountryLE){
            if(!String.isBlank(cmd.XC_SkipContractGen__c)){
                if(!mapLegalEntityStreamPartner.containsKey(cmd.XC_LegalEntity__c +'_'+cmd.XC_Stream__c)){
                    mapLegalEntityStreamPartner.put(cmd.XC_LegalEntity__c +'_'+cmd.XC_Stream__c, new List<String>());
                }
                mapLegalEntityStreamPartner.get(cmd.XC_LegalEntity__c +'_'+cmd.XC_Stream__c).addAll(cmd.XC_SkipContractGen__c.split(';'));
            }
        }
        for(Opportunity opp : listOpp){
            for(NE__Order__c ord : listNew){
                if(mapOppIdOrder.get(opp.Id) == ord && mapLegalEntityStreamPartner.get(ord.XC_LegalEntity__c+'_'+ord.XC_Segment__c) != null){
                    for(String externalPartner : mapLegalEntityStreamPartner.get(ord.XC_LegalEntity__c+'_'+ord.XC_Segment__c)){
                        if(externalPartner.equals(opp.XC_ExternalPartner__c)){
                            ord.XC_SkipContractGeneration__c = true;
                        }
                    }
                }
            }
        }
    }

}