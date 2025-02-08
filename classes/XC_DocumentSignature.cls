/**
 * @File Name          : XC_DocumentSignature.cls
 * @Description        : 
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 28/4/2020, 18:52:22
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    28/4/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
**/
public class XC_DocumentSignature {

    private static final String[] fieldsToQuery = new String[]{
        'XC_SignerId__c',
        'XC_UrlAgent__c',
        'XC_UrlCustomer__c',
        'XC_DocumentName__c',
        'XC_DocumentType__c',
        'XC_LegalEntity__c',
        'XC_Country__c',
        'XC_DossierId__c',
        'XC_CompanyId__c',
        'XC_TaskId__c',
        'XC_TaskName__c',
        'XC_Status__c',
        'XC_CreationDate__c',
        'XC_LastActivityDate__c',
        'XC_Step__c',
        'XC_StatusDescription__c',
        'XC_RefuseNotes__c'
    };

	private static final Map<String,String> objectTypeMap = new Map<String,String>{
        'NE__Order__c' => 'XC_Order__c',
        'Contract' => 'XC_Contract__c',
        'NE__Billing_Profile__c' => 'XC_BillingProfile__c',
        'WorkOrderLineItem' => 'XC_WorkOrderLineItem__c',
        'Case' => 'XC_Case__c'
	};

    @AuraEnabled
    public static XC_DocumentSignature__c[] getDocumentSignatures(String recordId) {
		String objectType = XC_UTIL_Sobject_U_Retrieve.getObjectType(recordId);
        String query = 'SELECT '
            + String.join(fieldsToQuery, ',')
            + ' FROM XC_DocumentSignature__c'
            + ' WHERE ' + objectTypeMap.get(objectType) + ' = :recordId';
        return Database.query(query);
    }

    

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
    * @description get init Informations.
    * @param recordId the record id
    * @return the WrapperDoInit
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper getInitInformation(String recordId) { 
        XC_UTIL_ResultWrapper result = new XC_UTIL_ResultWrapper();
        result.success = true;
        Map<String,Object> objData = new Map<String,Object>();
        Boolean isCommunity = false;
        //Check community user
        String idUser = UserInfo.getUserId();
        List<User> user = new List<User>([SELECT Id, Country__c FROM User WHERE Id = :idUser  AND Profile.UserLicense.Name = 'Partner Community']);
        if(!user.isEmpty()){
            isCommunity = true;
        }
        objData.put('isCommunity', isCommunity);
        objData.put('sessionId',UserInfo.getSessionId());
        result.objectInfo = JSON.serialize(objData);
        return result;
    }

}