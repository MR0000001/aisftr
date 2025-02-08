/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/
    public with sharing class XC_LCC199_CreateContractFromOpportunity {
        @AuraEnabled
        public static Map<String,String> createContract(Id recordId){
            Map<String,String> mapStringId = new Map<String,String>();
    
            List<Opportunity> listOpportunities = new List<Opportunity>();
            listOpportunities = getOpportunity(recordId);
    
            if(!listOpportunities.isEmpty()){
                String segment = listOpportunities[0].XC_Segment__c;
                String legalntity = listOpportunities[0].XC_LegalEntity__c;
                String recordTypeId = getRecordTypeId(segment,legalntity);
                mapStringId.put('Status','OK');
                mapStringId.put('Opportunity',listOpportunities[0].id);
                mapStringId.put('Account',listOpportunities[0].AccountId);
                mapStringId.put('RecordTypeId',recordTypeId);
                mapStringId.put('legalntity',legalntity);
                mapStringId.put('segment',segment);
                return mapStringId;
            }
    
            String message =Label.XC_CL_Contract_Error_Creation;
            String error =Label.XC_CL_Error;
            mapStringId.put('Status','KO');
            mapStringId.put('Message',message);
            mapStringId.put('ErrorMessage',error);
            return mapStringId;
    
    
        }
    
        private static List<Opportunity> getOpportunity(Id recordId){
            set<String> segment = new set<String>{'B2B','B2G'};
            set<String> legalEntity =  new set<String>{'EnelXItalia','EnelXMobilityItalia','EnelSole','Cogenio'};
            List<Opportunity> listOppo = new List<Opportunity>();
            if(Schema.sObjectType.Opportunity.isAccessible()){
                listOppo = [select id, XC_SalesNoNeeded__c, XC_LegalEntity__c, XC_Segment__c,AccountId from Opportunity where id = :recordId AND XC_SalesNoNeeded__c = TRUE AND XC_Segment__c IN : segment AND XC_LegalEntity__c IN :legalEntity];
            }
            return listOppo;
    
        }
    
        private static String getRecordTypeId(String segment, String legalEntity){
            List<XC_CM_LegalEntity_Configuration__mdt> listCM = new List<XC_CM_LegalEntity_Configuration__mdt>();
            listCM = [select id,XC_RecordType_Contract__c, XC_Stream__c, XC_LegalEntity__c from XC_CM_LegalEntity_Configuration__mdt where XC_Stream__c = :segment AND XC_LegalEntity__c = :legalEntity];
            String developerNameRecordType = listCM[0].XC_RecordType_Contract__c;
            System.debug('ListCM '+ listCM[0]);
            System.debug('developerNameRecordType '+ developerNameRecordType);
    
            Id recordTypeId =
                    Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName()
                            .get(developerNameRecordType).getRecordTypeId();
    
            String recordType = recordTypeId;
            System.debug('DL-RecordType->'+ recordType);
            return recordType;
        }
    
    }