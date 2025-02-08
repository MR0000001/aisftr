/**
 * @author  Roberta Cossiga r.cossiga@deloitte.it && Roberta Porrega roberta.porrega@nttdata.com && Simone Trenta strenta@deloitte.it
 * @date Creation 05/03/2019
 * @date Modification dd/mm/yyyy
 * @description controller for create a new Document Skill Association
 */

public without sharing class XC_LCC096_EditSkillDocumentAssociation {

    /**
     * @description Sets the fields values.
     * @param recordId the record id
     * @return the x C skill document association c
     */
    @AuraEnabled
    public static XC_SkillDocumentAssociation__c setFieldsValues (Id recordId){
        Map<Id,XC_SkillDocumentAssociation__c> sdaMap = new Map<Id,XC_SkillDocumentAssociation__c>([SELECT Id, XC_SkillId__c, 
                                                    XC_ListOfDocumentAND__c, 
                                                    XC_ListOfDocumentOR__c, 
                                                    RecordTypeId
                                                    FROM XC_SkillDocumentAssociation__c
                                                    WHERE Id=: recordId]);
        List<XC_SkillDocumentAssociation__c> sda = sdaMap.values();        
        return sda[0]; 
    }

    /**
     * @description Save skill document association
     * @param mapDocumentAssString - String
     * @return the x C UTI L result wrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper saveSkillDocumentAssociation(String mapDocumentAssString) {
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        // Modifica Salvatore Agrillo (06/05/2019)
        if(String.isBlank(mapDocumentAssString)){
            wr.resultMessage = Label.XC_CL_SkillDocumentAssociation_ErrorLoadData;
            wr.success = false; 
            return wr;
        } 
        Map<String,Object> mapDocumentAss = (Map<String, Object>) JSON.deserializeUntyped(mapDocumentAssString);
        String recordId = (String) mapDocumentAss.get('recordId');
        String listOfDocumentAND = (String) mapDocumentAss.get('listOfDocumentAND');
        String listOfDocumentOR = (String) mapDocumentAss.get('listOfDocumentOR');
        String skillId = (String) mapDocumentAss.get('skillId');
        String skillName = (String) mapDocumentAss.get('skillName');
        
        Map<Id,XC_SkillDocumentAssociation__c> skaMap = new Map<Id,XC_SkillDocumentAssociation__c>([select id, XC_ListOfDocumentAND__c,
                                 XC_ListOfDocumentOR__c, XC_SkillId__c, XC_SkillName__c 
                                              from XC_SkillDocumentAssociation__c 
                                              where id =: recordId]);

        XC_SkillDocumentAssociation__c ska = new XC_SkillDocumentAssociation__c();
        ska = skaMap.values();
            
        system.debug('saveSkillDocumentAssociation: '+listOfDocumentAND+' '+skillId+' '+skillName);
        
        ska.XC_ListOfDocumentAND__c = listOfDocumentAND;
        ska.XC_ListOfDocumentOR__c = listOfDocumentOR;
        ska.XC_SkillId__c = skillId;
        ska.XC_SkillName__c = skillName;
        
       	XC_UTIL_Sobject.WrapperResult sobjectResult = XC_UTIL_Sobject.updateRecord(ska);
        if(sobjectResult.success == true){
            wr.success = true;
            wr.resultMessage = 'Success';
            wr.recordId = sobjectResult.recordId;
        } else{
            wr.resultMessage = sobjectResult.errorMessage;
            wr.success = false;  
        }
        return wr;
    }  
    
}