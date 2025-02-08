public without sharing class TA_LCC235_DocumentSignature {

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
        'XC_Step__c'
    };

	private static final Map<String,String> objectTypeMap = new Map<String,String>{
        'NE__Order__c' => 'XC_Order__c',
        'Contract' => 'XC_Contract__c',
        'NE__Billing_Profile__c' => 'XC_BillingProfile__c'
	};

    @AuraEnabled
    public static XC_DocumentSignature__c[] getDocumentSignatures(String orderId) {
		String objectType = XC_UTIL_Sobject_U_Retrieve.getObjectType(orderId);
        
        if(String.isNotBlank(objectType)) {
            String query = 'SELECT '
            + String.join(fieldsToQuery, ',')
            + ' FROM XC_DocumentSignature__c'
            + ' WHERE ' + objectTypeMap.get(objectType) + ' = :orderId';
            return Database.query(query);
        }
        return null;
    }

    @AuraEnabled
    public static XC_UTIL_ResultWrapper getInitInformation(String workOrderId) 
    { 
        XC_UTIL_ResultWrapper result = new XC_UTIL_ResultWrapper();
        result.success = true;
        Map<String,Object> objData = new Map<String,Object>();
        Boolean isCommunity = false;
        String orderId = '';

        String idUser = UserInfo.getUserId();
        List<User> user = new List<User>([SELECT Id, Country__c FROM User WHERE Id = :idUser  AND Profile.UserLicense.Name = 'Partner Community']);
        if(!user.isEmpty()){
            isCommunity = true;
        }

        if(String.isNotBlank(workOrderId)) {
            List<WorkOrder> workOrders = [SELECT Id, XC_Configuration__c FROM WorkOrder WHERE Id =:workOrderId];
            if(!workOrders.isEmpty()) {
                orderId = workOrders[0].XC_Configuration__c;
            }
        }  

        objData.put('orderId', orderId);
        objData.put('isCommunity', isCommunity);
        objData.put('sessionId',UserInfo.getSessionId());
        result.objectInfo = JSON.serialize(objData);
        return result;
    }

}