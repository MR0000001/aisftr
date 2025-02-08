/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/
public with sharing class XC_TR_Configuration_CreateAutoNumber {
    /**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to create autonumber object
     * @param listNew - List<NE__Order__c>
    **/
    public static void createNewRecord(List<NE__Order__c> listNew,Map<Id, NE__Order__c> mapOld){
        List<NE__Order__c> orderRecTypeOrder = new List<NE__Order__c>();
        System.debug('@@DL START ***');

        orderRecTypeOrder= getOrderB2bandRTOrders(listNew, mapOld);
        if(!orderRecTypeOrder.isEmpty() || orderRecTypeOrder != null){
            createAutoNumber(orderRecTypeOrder);
        }



    }
    private static List<NE__Order__c> getOrderB2bandRTOrders(List<NE__Order__c> listNew,Map<Id, NE__Order__c> mapOld){
        List<NE__Order__c> orderB2b = new List<NE__Order__c>();
        List<NE__Order__c> orderFilteredB2b = new List<NE__Order__c>();
        Id recordTypeOrder = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        Set<String> legalEntity = new Set<String>();
        for(NE__Order__c ord : listNew){
            System.debug('@@DL ord.RecordTypeId*** '+ord.RecordTypeId);
            System.debug('@@DL record type decribe'+ recordTypeOrder);
            System.debug('@@DL mapOld.get(ord.id).RecordTypeId*** '+ mapOld.get(ord.id).RecordTypeId);
            if(ord.RecordTypeId == recordTypeOrder && mapOld.get(ord.id).RecordTypeId != recordTypeOrder){
                orderB2b.add(ord);
                legalEntity.add(ord.XC_LegalEntity__c);
            }
        }
        if(orderB2b.isEmpty()){
            return orderB2b;
        }
        orderFilteredB2b = getCustomMetadataLE(legalEntity,orderB2b);
        return orderFilteredB2b;
    }

    private static List<NE__Order__c>getCustomMetadataLE(Set<String> legalEntity,List<NE__Order__c> orderB2b){
        List<NE__Order__c> orderFiltered = new List<NE__Order__c>();
        List<XC_CM_CountryLegalEntityAssociation__mdt> cmLegalEntityAss = new List<XC_CM_CountryLegalEntityAssociation__mdt>();
        if(Schema.SObjectType.XC_CM_CountryLegalEntityAssociation__mdt.isAccessible()){
            cmLegalEntityAss = [SELECT XC_Category__c, XC_Country__c, XC_EmailToAddress__c, XC_LegalEntity__c, XC_LegalEntityGroup__c from XC_CM_CountryLegalEntityAssociation__mdt where XC_LegalEntity__c IN :legalEntity AND XC_Category__c = 'B2B'];
        }
        System.debug('@@DL **CM** '+ cmLegalEntityAss);
        for(NE__Order__c ord :orderB2b ){
            for(XC_CM_CountryLegalEntityAssociation__mdt cm :cmLegalEntityAss){
                System.debug('@@DL ord.XC_LegalEntity__c** '+ord.XC_LegalEntity__c);
                System.debug('@@DL cm.XC_LegalEntity__c** '+cm.XC_LegalEntity__c);
                if(ord.XC_LegalEntity__c == cm.XC_LegalEntity__c){

                    orderFiltered.add(ord);
                }
            }
        }
        return orderFiltered;

    }
    private static void createAutoNumber(List<NE__Order__c> orderFilter){
        List<XC_WBE_Order_Number__c> listAutoNumbers = new List<XC_WBE_Order_Number__c>();
        for(NE__Order__c ne : orderFilter){
            XC_WBE_Order_Number__c au = new XC_WBE_Order_Number__c(name = ne.name);
            listAutoNumbers.add(au);
        }
        if(Schema.SObjectType.XC_WBE_Order_Number__c.isCreateable() && !listAutoNumbers.isEmpty()){
            insert(listAutoNumbers);
        }


    }

}