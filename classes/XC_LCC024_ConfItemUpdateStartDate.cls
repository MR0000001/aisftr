/**
 * The Class XC_LCC024_ConfItemUpdateStartDate.
 *
 * @author Federico Amici, Monicaa Cutillo
 * @date Creation 04/10/2018
 * @date Modification 10_10_2018 by Riccardo Cossu - riccardo.cossu@nttdata.com
 * @description XC_LCC024_ConfItemUpdateStartDate - Integration stub to update Configuration Item Delivery Date
 */
public without sharing class XC_LCC024_ConfItemUpdateStartDate {

	/**
	 * @description The Class ResultWrapper.
	 */
	public class ResultWrapper{
		/**
		* @description success
		*/
		@AuraEnabled
		public Boolean success {get; set;} 

		/**
		* @description recordFields
		*/
		@AuraEnabled
        public List<FieldWrapper> recordFields {get; set;} 

	}


	/**
	 *  @description The Class JSONWrapper.
	 */
	public class JSONWrapper{
		/**
		* @description timeT
		*/
		@AuraEnabled
        public String timeT {get; set;} 
		/**
		* @description millisecondsSinceEpoch
		*/
		@AuraEnabled 
        public String millisecondsSinceEpoch {get; set;} 
		/**
		* @description dateT
		*/
        @AuraEnabled 
        public String dateT {get; set;} 
	}

	/**
	 *  @description The Class FieldWrapper.
	 */
	public class FieldWrapper{

		/**
		* @description fieldLabel
		*/
		@AuraEnabled
        public String fieldLabel {get; set;} 

		/**
		* @description fieldValue
		*/
		@AuraEnabled 
        public String fieldValue {get; set;} 
	}

    /**
     * @description Update fields order items.
     * @param recordId the record id
     * @return the list
     */
    @AuraEnabled
    public static List<NE__OrderItem__c> updateFieldsOrderItems(String recordId){

		if(!Schema.SObjectType.NE__OrderItem__c.isAccessible()) {
            return new List<NE__OrderItem__c>();
        }

        Map<Id,NE__OrderItem__c> listOrderItemMap = new Map<Id,NE__OrderItem__c>([SELECT Id, Name, NE__Description__c, NE__Delivery_Date__c, NE__ProdName__c
                                                 FROM NE__OrderItem__c WHERE NE__OrderId__c=:recordId]);
		

        List<NE__OrderItem__c> listOrderItem = listOrderItemMap.values();

		List<NE__OrderItem__c> listRealOrderItem = new List<NE__OrderItem__c>();

		Date newDeliveryDate = retrieveOrderItemDateFake();
		for(NE__OrderItem__c orderItem : listOrderItem) {
			if(XC_UTIL_ConfigurationItem.isThisARealProduct(orderItem.NE__ProdName__c)){
				orderItem.NE__Delivery_Date__c = newDeliveryDate;
				listRealOrderItem.add(orderItem);
			}
		}

        System.debug('OUTFOR');
		System.debug('listOrderItem.size='+listOrderItem.size());
		System.debug('listRealOrderItem.size='+listRealOrderItem.size());
		//update listOrderItem;
		return listRealOrderItem;
    }

    /**
     * @description Retrieve order item date fake.
     * 
     * @return the date
     */
    @AuraEnabled
    public static Date retrieveOrderItemDateFake(){
    	System.debug('@@@@ retrieveOrderItemDateFake @@@@');
    	HttpRequest req = XC_UTIL_RESTCallout.createRequest('http://time.jsontest.com/', '');
    	System.debug('@@@@'+req);
		try{
            HttpResponse resp = XC_UTIL_RESTCallout.sendRequest(req,'XC_LCC024_ConfItemUpdateStartDate');
			//System.debug('@@@@ resp.getBody()'+resp.getBody());
			JSONWrapper wrap = (JSONWrapper)JSON.deserialize(resp.getBody(), JSONWrapper.class);
			system.debug('@@@@' +wrap);
			return ((DateTime.newInstance(Long.valueOf(wrap.millisecondsSinceEpoch))).date()).addDays(2);
        } catch(Exception e){
			System.debug('@@@@ Error colling http://time.jsontest.com/');
            System.debug('@@@@ Error in : '+e.getMessage()+ ' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
			return (System.today()).addDays(2);
        }
    }


	/**
	 * @description Call commodity.
	 * @param recordId the record id
	 * @return the result wrapper
	 */
	@AuraEnabled
	public static ResultWrapper callCommodity(Id recordId){
		ResultWrapper result = new ResultWrapper();
		Account a = retrieveAccount(recordId);
		//NEW
		Boolean activeInterface = XC_UTIL_RESTCallout.checkActiveInterface('ConfItemUpdateStartDate');
		if(activeInterface){
			String url = '';
			String requestString = '';
	  		HttpRequest request = XC_UTIL_RESTCallout.createRequest(url, requestString);
	  		HttpResponse response = XC_UTIL_RESTCallout.sendRequest(request,'XC_LCC024_ConfItemUpdateStartDate');
			result = manageResponse(response);
		} else {
			String fakeResponse = '{"Blacklist result":"The account isn\'t in the blacklist."}';
			result = manageResponseFake(fakeResponse);
		}
		return result; 
	}



	/**
	 * @description  Manage response fake.
	 * @param fakeResponse the fake response
	 * @return the result wrapper
	 */
	private static ResultWrapper manageResponseFake(String fakeResponse){
		ResultWrapper result = new ResultWrapper();
		result.recordFields = new List<FieldWrapper>();
		Map<String,Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(fakeResponse); 
		for(String key : responseMap.keySet()){
        	FieldWrapper wr = new FieldWrapper();
        	wr.fieldLabel = key;
        	wr.fieldValue = (String)responseMap.get(key);
        	result.recordFields.add(wr);
        	System.debug(wr);
        }
        System.debug(result.recordFields);
        result.success = true;

		return result;
	}

	/**
	 * @description Manage response.
	 * @param response the response
	 * @return the result wrapper
	 */
	private static ResultWrapper manageResponse(HttpResponse response){
		ResultWrapper result = new ResultWrapper();
		return result;
	}

	/**
	 * @description Retrieve account.
	 * @param recordId the record id
	 * @return the account
	 */
	private static Account retrieveAccount(Id recordId){
		Account a = new Account();
		return a;
	}



    /**
     * @description Update record.
     * @param recordId the record id
     * @param newID the new ID
     */
    @AuraEnabled
	public static void updateRecord(Id recordId, String newID){

		  if(!Schema.sObjectType.Account.isAccessible()){
                    return;
                } 	

		Map<Id,Account> accountchecklistMap = new Map<Id,Account>([SELECT Id, XC_Employee_Id__C 
			from Account WHERE ID =:recordId Limit 1]);

		list<Account> accountchecklist = accountchecklistMap.values();

        if(accountchecklist.get(0) != null) {
        	accountchecklist.get(0).XC_Employee_Id__c = newID;
        }
        update accountchecklist.get(0);
	}
    
    /**
     * @description Checklist value.
     * @param recordId the record id
     * @return the list
     */
    // Get the value on the checkList field of the account and fill it with the external call.
    public static list<Account> checklistValue(Id recordId){

		  if(!Schema.sObjectType.Account.isAccessible()){
                    return new list<Account>();
                } 	

		Map<Id,Account> accountchecklistMap = new Map<Id,Account> ([SELECT Id, XC_Notes__c 
		from Account WHERE ID =:recordId Limit 1]);
        
        list<Account> accountchecklist = accountchecklistMap.values();
        if(accountchecklist.size() > 0) {
           	return accountchecklist; 
        }
        else {
			return null;
		}
	}
}