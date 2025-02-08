/**
 * ***************************************************************************************************.
 *
 * @author  Roberta Cossiga r.cossiga@deloitte.it && Roberta Porrega roberta.porrega@nttdata.com && Simone Trenta strenta@deloitte.it
 * @date Creation 05/03/2019
 * @date Modification dd/mm/yyyy
 * @description controller for create a new Document Skill Association
 * ****************************************************************************************************
 */

public class XC_LCC090_NewSkillDocumentAssociation {
    
    /**
     * @description Save skill document association.
     *
     * @param mapSkillDocument the map skill document
     * @param recordTypeId the record type id
     * @return the x C UTI L result wrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper saveSkillDocumentAssociation(String mapSkillDocument, String recordTypeId){
        Map<String,Object> skillDocumentRecord = (Map<String, Object>) JSON.deserializeUntyped(mapSkillDocument);
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        XC_SkillDocumentAssociation__c ska = new XC_SkillDocumentAssociation__c();
        
        ska.XC_ListOfDocumentAND__c = (String) skillDocumentRecord.get('listOfDocumentAND');
        ska.XC_ListOfDocumentOR__c = (String) skillDocumentRecord.get('listOfDocumentOR');
        ska.XC_SkillId__c = (String) skillDocumentRecord.get('skillId');
        ska.XC_SkillName__c = (String) skillDocumentRecord.get('skillName');
        ska.RecordTypeId = recordTypeId;
        
       	XC_UTIL_Sobject.WrapperResult sobjectResult = XC_UTIL_Sobject.insertRecord(ska);
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