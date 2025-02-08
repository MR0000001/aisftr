public class XC_LCC269_LOACreation {
	@AuraEnabled
    public static Map<String, Object> getInitData(String accountid) {
   		Id loaRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('XC_LOA').getRecordTypeId();
        Map<String, Object> toReturn = new Map<String, Object>{'recordTypeId' => loaRecordTypeId};
        List<Contact> contacts = [SELECT Id FROM Contact WHERE AccountId = :accountid and XC_PrimaryContact__c=true];
        if(!contacts.isEmpty())
        {
            toReturn.put('contactId', contacts.get(0).Id);
        }
        return toReturn;
    }
    @AuraEnabled
    public static Map<String, Object> getServAccounts(String accountId, String utilityId) {
        List<Map<String, Object>> options = new List<Map<String, Object>>();
        for(Service_Account__c sa: [SELECT id, Name, XC_Address__c FROM Service_Account__c WHERE XC_Customer_Account__c=:accountId AND XC_Utility_Account__c =:utilityId])
        {
            String label = sa.Name + (String.isNotBlank(sa.XC_Address__c )? (' ( ' + sa.XC_Address__c + ' )'):'');
        	options.add(new Map<String, Object>{'label' => label, 'value' => sa.Id});
        }
        String templateName ='';
        List<XC_CongaTemplateMapping__c> templateMappings = [select Id, XC_CongaIdTemplate__c from XC_CongaTemplateMapping__c WHERE XC_Utility__c=:utilityId AND XC_AccountType__c='B2B'];
        if(!templateMappings.isEmpty())
        {
            List<APXTConga4__Conga_Template__c> templates = [SELECT Id, APXTConga4__Name__c FROM APXTConga4__Conga_Template__c WHERE Id = :templateMappings.get(0).XC_CongaIdTemplate__c];
            if(!templates.isEmpty())
            {
                templateName = templates.get(0).APXTConga4__Name__c;
            }
        }
        return new Map<String, Object>{
            'options' => options,
            'templateName' => templateName
        };
    }
    
    @AuraEnabled
    public static String insertServiceAccounts(String contractId, List<String> serviceAccounts) {
        String message = '';
        if(serviceAccounts != null && !serviceAccounts.isEmpty() && String.isNotBlank(contractId))
        {
            List<XC_Service_Account_LOA__c> servAccLoas = new List<XC_Service_Account_LOA__c>();
            for(String said : serviceAccounts)
            {
                servAccLoas.add(new XC_Service_Account_LOA__c(XC_Service_Account__c=said, XC_Contract__c =contractId));
            }
            List<XC_UTIL_Sobject.WrapperResult> results = XC_UTIL_Sobject.insertListRecords(servAccLoas);
            for(XC_UTIL_Sobject.WrapperResult wr : results)
            {
                message += (!wr.success?(wr.errorMessage + ', '):'');
            }
        }
        else
        {
            message = 'Error in inputs';
        }
        return message;
    }
}