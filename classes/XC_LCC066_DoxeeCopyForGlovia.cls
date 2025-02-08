/**
 * The Class XC_LCC066_Doxee.
 *
 * @author Roberta Cossiga - rcossiga@deloitte.it
 * @date Creation  10/10/2018
 * @date Modification 
 * @description XC_LCC066_Doxee
 */

public without sharing class XC_LCC066_DoxeeCopyForGlovia {

    /**
     * @description The Class WrapperUser.
     */
    public class WrapperUser{
        
        /** The user name. */
        @AuraEnabled
        public String userName;
        
        /** The country. */
        @AuraEnabled
        public String country;
        
        /** The company. */
        @AuraEnabled
        public String company;
        
        /** The Object Type. */
        @AuraEnabled
        public String objectType;
        
         /** The parentId Object Type. to retrieve Logistic document parent Object*/
        @AuraEnabled
        public String parentId;
    }
    
    /**
     * @description Fetch user.
     *
     * @param recordId the record id
     * @return the x C UTI L result wrapper
     */
    @AuraEnabled 
    public static XC_UTIL_ResultWrapper  fetchUser(String recordId){
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        wr.success = false;  
        
        // query current user information  
        Map<Id,User> oUserMap = new Map<Id,User>([SELECT Id, Name, TimeZoneSidKey, Username, Alias, Country, Country__c, Company__c,
                      Email, FirstName, LastName, IsActive, IsPortalEnabled 
                      FROM User 
                      WHERE Id =: userInfo.getUserId()]);

        User oUser = new User ();
        oUser = oUserMap.values();
        
        wr.resultMessage  = oUser.Username;
        wr.objectInfo  = getUserInformation(recordId);
       
        if(!String.isBlank(wr.resultMessage) && !String.isBlank(wr.objectinfo)){
            wr.success = true;
        }
        system.debug('@@@ fetchUser wr:' + wr.objectInfo);
        return wr;
    }
    
    /**
     * @description Gets the user information.
     *
     * @return the user information
     */
    @AuraEnabled
    public static String getUserInformation(String recordId){
        
        WrapperUser wrUser = new WrapperUser();
        wrUser.objectType = XC_UTIL_Sobject.getObjectType(recordId);

        Id userId = UserInfo.getUserId();
        Map<Id,User> usrLstMap = new Map<Id,User>([SELECT UserName, Country__c, Company__c,XC_LegalEntity__c  FROM User WHERE Id = :userId]);        
        String userLE = usrLstMap.values()[0].XC_LegalEntity__c;

        String orgId = UserInfo.getOrganizationId();

        String query = 'SELECT XC_DoxeeCountry__c , XC_DoxeeCompany__c FROM XC_CM_LegalEntity_Configuration__mdt WHERE XC_LegalEntity__c =: userLE AND XC_OrgId__c =: orgId';
        if(Schema.getGlobalDescribe().get(wrUser.objectType).newSObject().getSobjectType().getDescribe().fields.getMap().containsKey('XC_Segment__c')) {
            Map<Id, String> segmentMap = XC_SegmentUtilities.getSegmentFromObject(new Set<Id>{recordId}, wrUser.objectType);
            String segment = segmentMap.get(recordId);
            query += (String.isNotBlank(segment)) ? ' AND XC_Stream__c =: segment' : '';
        }
        query += ' LIMIT 1';
        List<XC_CM_LegalEntity_Configuration__mdt> cmLegalEntityConf = (List<XC_CM_LegalEntity_Configuration__mdt>) Database.query(String.escapeSingleQuotes(query));

        //List<XC_CM_LegalEntity_Configuration__mdt> CMLegalEntityConf = [SELECT XC_DoxeeCountry__c , XC_DoxeeCompany__c FROM XC_CM_LegalEntity_Configuration__mdt WHERE XC_LegalEntity__c =: userLE AND XC_OrgId__c =: orgId limit 1];
        
        System.debug('@@@ CMLegalEntityConf :' +CMLegalEntityConf);
         
        wrUser.userName = usrLstMap.values()[0].Username;
        wrUser.country = CMLegalEntityConf[0].XC_DoxeeCountry__c;
        wrUser.company = CMLegalEntityConf[0].XC_DoxeeCompany__c;  
        system.debug('@@@ getUserInformation:' + wrUser.objectType);
        wrUser.parentId =   getIdParentObject(recordId);
        //wrUser.country = usrLst[0].Country__c;
        //wrUser.company = usrLst[0].Company__c;
       
        return JSON.serialize(wrUser);
    } 
 
    private static String getIdParentObject(String recordId){
		string idParentObject='';
        string parentId='';
		string objName = XC_UTIL_Sobject.getObjectType(recordId);
		system.debug('@@@ getIdParentObject - objType:' + objName);
        DDT_RetrieveParObj__c fieldLookUp = DDT_RetrieveParObj__c.getValues(objName);
		if(fieldLookUp!=null) {
            parentId = fieldLookUp.parentId__c;
            string query = 'SELECT ' + parentId + ' from ' + objName + ' where id =:recordId';
            system.debug('@@@ getIdParentObject - query:' + query);
            List<sObject> lista =  Database.query(String.escapeSingleQuotes(query).replace('\\', ''));
            if(Lista.size()>0){
                for(sObject acc:lista)  {
                    idParentObject = (String)acc.get(parentId);
                    system.debug('@@@ getIdParentObject - idParentObject:' + idParentObject);
                    
                    }
                
                } 
        }    
		return idParentObject;
    } 
    
}