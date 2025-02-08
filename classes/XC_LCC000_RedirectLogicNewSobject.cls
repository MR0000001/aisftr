/**
 * @author Marco Rosa - marco.rosa@nttdata.com & Nicolò Leonardi - nleonardi@deloitte.it
 * @date Creation  09/10/2018
 * @date Modification 25/10/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @description XC_LCP000_RedirectLogicNewSobject – Helper for component to redirect Login "New Sobject"
*/

public class XC_LCC000_RedirectLogicNewSobject {
    
    /**
     * @description Gets the default record type  
     * @param objectName - String
     * @return String
     */
    @AuraEnabled
    public static String getDefaultRecordType(String objectName) { 
        List<RecordType> recordTypeList = XC_UTIL_SObject_CheckVisibility.getVisibleRecordType(objectName);
        if(!recordTypeList.isEmpty()) {
            return JSON.serialize(recordTypeList[0].Id);
        }
        else{
            return JSON.serialize('ERROR');
        }
    }
    
    /**
     * @description Retrive receiving channel
     * @param userId - String
     * @return String
     */
    @AuraEnabled
    public static String retriveReceivingChannel(String userId) { 
       return XC_UTIL_User.getChannelFromUser(userId);
    }
    /**
    * @description Manage Opportunity Segment
    * @author Valentina De Blasio - valentina.de.blasio@accenture.com 16-03-2022 cr 758
    * @param recordType - Id
    *
    */
    @AuraEnabled
    public static String opportunitySegment(String recordTypeId){
        String segmentOp='';
        List<RecordType> rtype=[Select Name from Recordtype where id=:recordTypeId and sobjecttype='Opportunity'];
        for(RecordType rt:rtype){
            if(rt.name.contains('B2B')|| rt.name.contains('B2G') || rt.name.contains('B2C')){
                segmentOp=rt.name.substring(0,3);   
            }
        }
       return segmentOp;
    }
    /**
    * @description Manage Opportunity Segment
    * @author Valentina De Blasio - valentina.de.blasio@accenture.com 17-03-2022 cr 758
    * @param segmentOpportunity - string segment opportunity
    *
    */
    @AuraEnabled
    public static String opportunityLegalEntity(String segmentOp){
        String legalentityopp='';
        User u = [SELECT Id,XC_LegalEntity__c FROM User WHERE id = :UserInfo.getUserId()]; 
             if(segmentOp=='B2B'|| segmentOp=='B2G'){
                legalentityopp=u.XC_LegalEntity__c; 
        }
       return legalentityopp;
    }
}