/**
 * The Class XC_LCC239_DoxeeMyOrderTab.
 *
 * @author Simone Trenta - strenta@deloitte.it
 * @date Creation  18/01/2020
 * @date Modification
 * @description XC_LCC239_DoxeeMyOrderTab
 */
public without sharing class XC_LCC239_DoxeeMyOrderTab {

    /**
     * @description Fetch user.
     *
     * @param recordId the record id
     * @return the x C UTI L result wrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper fetchUser(String recordId){
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
        wr.objectInfo  = getUserInformation();

        if(!String.isBlank(wr.resultMessage) && !String.isBlank(wr.objectinfo)){
            wr.success = true;
        }
        return wr;
    }
    
        /**
     * @description Gets the user information.
     *
     * @return the user information
     */
    @AuraEnabled
    public static String getUserInformation(){

        XC_LCC066_Doxee.WrapperUser wrUser = new XC_LCC066_Doxee.WrapperUser();
        
        wrUser.objectType = 'Account'; 

        Id userId = UserInfo.getUserId();
        Map<Id,User> usrLstMap = new Map<Id,User>([SELECT UserName, Country__c, Company__c, XC_LegalEntity__c, Account.ParentId FROM User WHERE Id = :userId]);
        Account userAccount = usrLstMap.values()[0].Account;
        User currentUser = usrLstMap.values()[0];

        String userLE = currentUser.XC_LegalEntity__c;
        String orgId = UserInfo.getOrganizationId();

        String segment;
        if(!Test.isRunningTest()){
            Map<Id,Account> accMap = new Map<Id,Account>([SELECT XC_Segment__c FROM Account WHERE Id = :currentUser.Account.ParentId]);
            segment = accMap.values()[0].XC_Segment__c;
        }else{
            segment = 'B2C';
        }
       
        String query = 'SELECT XC_DoxeeCountry__c , XC_DoxeeCompany__c FROM XC_CM_LegalEntity_Configuration__mdt WHERE XC_LegalEntity__c =: userLE AND XC_OrgId__c =: orgId';
        query += (String.isNotBlank(segment)) ? ' AND XC_Stream__c =: segment' : '';   
        query += ' LIMIT 1';
        
        List<XC_CM_LegalEntity_Configuration__mdt> cmLegalEntityConf = (List<XC_CM_LegalEntity_Configuration__mdt>) Database.query(String.escapeSingleQuotes(query));
   
        wrUser.userName = currentUser.Username;
        wrUser.country = CMLegalEntityConf[0].XC_DoxeeCountry__c;
        wrUser.company = CMLegalEntityConf[0].XC_DoxeeCompany__c;
 
        wrUser.objectId = (userAccount!=null) ? userAccount.ParentId : null;
                 
        String res = JSON.serialize(wrUser);
        
        return res;
    }
    
}