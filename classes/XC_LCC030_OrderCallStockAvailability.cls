/**
 * The Class XC_LCC030_OrderCallStockAvailability.
 *
 * @author Monica Cutillo - monica.cutillo@nttdata.com
 * @date Creation 23/10/2018
 * @date Modification 24/10/2018 by Fabrizio Antonioli - Fabrizio.Antonioli@nttdata.com & Giovanni Schioppa - Giovanni.Schioppa@nttdata.com
 * @description XC_LCC030_OrderCallStockAvailability –
 */
public without sharing class XC_LCC030_OrderCallStockAvailability {

	/** The Constant CLASS_NAME. */
	private static final String CLASS_NAME = 'XC_LCC030_OrderCallStockAvailability';
	
	/** The Constant SUCCESS_CODE. */
	private static final String SUCCESS_CODE = '200';

	/**
	 * @description The Class ResultWrapper.
	 */
	public class ResultWrapper{

		/** @description The success. */ 
		@AuraEnabled
		public Boolean success {get; set;}
		
		/** @description The record fields map. */
		@AuraEnabled
        public Map<String,String> recordFieldsMap {get; set;}
		
		/** @description The sobject list. */
		@AuraEnabled
        public List<SObject> sobjectList {get; set;}

		/**
		 * Instantiates a new result wrapper.
		 * @description ResultWrapper
		 */
		public ResultWrapper(){
			this.recordFieldsMap = new Map<String,String>();
		}

		/**
		 * @description Put field.
		 * @param label the label
		 * @param value the value
		 */
		public void putField(String label, String value){
			this.recordFieldsMap.put(label, value);
		}

		
	}

	/**
	 * @description The Class FieldWrapper.
	 */
	public class FieldWrapper{

		/** @description The field label. */
		@AuraEnabled
        public String fieldLabel {get; set;} 
		
		/** @description The field value. */
		@AuraEnabled 
        public String fieldValue {get; set;} 

		/**
		 * @description Instantiates a new field wrapper.
		 *
		 * @param label the label
		 * @param value the value
		 */
		public FieldWrapper(String label, String value){
			this.fieldLabel = label;
        	this.fieldValue = value;
		}
	}

	/**
	 * @description The Class ResultReservationWrapper.
	 */
	public class ResultReservationWrapper{
		
		/** @description The success. */
		@AuraEnabled
		public Boolean success {get; set;}
		
		/** @description The message. */
		@AuraEnabled
		public String message {get; set;}
		
		/** @description The serial number. */
		@AuraEnabled
		public String serialNumber {get; set;}
		
		/**@description  The result. */
		@AuraEnabled
		public String result {get; set;}
		
		/** @description The delivery id. */
		@AuraEnabled
		public String deliveryId {get; set;}
		
		/** @description The delivery date. */
		@AuraEnabled
		public Date deliveryDate {get; set;}
		
		/** @description The external id. */
		@AuraEnabled
		public String externalId {get; set;}
		
		/** @description The courier partner name. */
		@AuraEnabled
		public String courierPartnerName {get; set;} 
 		/** @description The tracking URL. */
 		//ESCEP-502 ESCEP-504 MCutillo 07/12/2018
		@AuraEnabled
		public String trackingURL {get; set;} //ESCEP-502 ESCEP-504 MCutillo 07/12/2018

	}

	/**
	 * @description Call stock availability.
	 *
	 * @param recordId the record id
	 * @return the result wrapper
	 */
	@AuraEnabled
    public static ResultWrapper callStockAvailability(String recordId){
		
		ResultWrapper authResult = new ResultWrapper();
		ResultWrapper stockAvailabilityResult = new ResultWrapper();
		ResultWrapper result = new ResultWrapper();
		Boolean activeInterface = XC_UTIL_RESTCallout.checkActiveInterface(Label.XC_CL_Configuration_CallToStockAvailability);
		System.debug('@@@@ Interface='+Label.XC_CL_Configuration_CallToStockAvailability+' @@ isActive='+activeInterface);
		if(activeInterface){
			//authentication call
			String user = 'my_user';
			String password = 'my_password';
			authResult = executeAuthenticationCall(user, password);
			String token = 'result_token';
			
			//stock availability call
			//stockAvailabilityResult = executeStockAvailabilityCall(token);
		}
		else {
			result.sobjectList = XC_LCC024_ConfItemUpdateStartDate.updateFieldsOrderItems(recordId);
		}

		return result;
	}

	/**
	 * @description Execute authentication call.
	 *
	 * @param user the user
	 * @param password the password
	 * @return the result wrapper
	 */
	@AuraEnabled
	public static ResultWrapper executeAuthenticationCall(String user, String password){
		String bodyRequest = '{ "user" : "'+user+'", "pass" : "'+password+'" }';
		Map<String,String> headerDefinitions = new Map<String,String>();
		headerDefinitions.put('User-Agent','Sirkus_Api_V1');
		headerDefinitions.put('Content-Type','application/json');
		//TODO > Label XC_CL_Configuration_StockAvailabilityAuthURL
		HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST','https://si.sirkus.es/api/v1/loginapi', headerDefinitions, bodyRequest);
		HttpResponse response = XC_UTIL_RESTCallout.sendRequest(request, CLASS_NAME);
		return manageAuthenticationResponce(response);
	}

	/**
	 * @description Update delivery dates.
	 *
	 * @param selectedStock the selected stock
	 * @return the result wrapper
	 */
	@AuraEnabled
	public static ResultWrapper updateDeliveryDates(String selectedStock){
		System.debug('@@@@ updateSelectedStock -> '+selectedStock);
		ResultWrapper result = new ResultWrapper();
		List<Object> objList = (List<Object>) JSON.deserializeUntyped(selectedStock);
        System.debug('fieldMap selectedStock -> '+objList);
		List<NE__OrderItem__c> listOrderToUpd = new List<NE__OrderItem__c>();
		for(Object obj : objList){
			Map<String,Object> stock = (Map<String,Object>)obj;
			NE__OrderItem__c order = new NE__OrderItem__c();
			order.Id = (Id)(stock.get('Id'));
			order.NE__Delivery_Date__c = Date.valueOf((String)(stock.get('NE__Delivery_Date__c')));

			listOrderToUpd.add(order);
		}
		
		XC_UTIL_Sobject.updateListRecords(listOrderToUpd);
        System.debug('listOrderToUpd UPDATED '+listOrderToUpd);
		result.success = true;
		return result;
	}
	

	/**
	 * @description Call stock reservation.
	 *
	 * @param externalId the external id
	 * @return the result reservation wrapper
	 */
	@AuraEnabled
    public static ResultReservationWrapper callStockReservation(String externalId){
		System.debug('@@@@ callStockReservation -> '+externalId);
		Boolean check = false;
		ResultReservationWrapper result = new ResultReservationWrapper();
		if(!Schema.SObjectType.NE__OrderItem__c.isAccessible()) {
            return new ResultReservationWrapper();
        }


		Map<Id,NE__OrderItem__c> orderItemListMap = new Map<Id,NE__OrderItem__c>(
		[SELECT Id, NE__OrderId__r.XC_IsStockReservationKO__c
		 FROM NE__OrderItem__c  WHERE Id =: externalId ]);
		List<NE__OrderItem__c> orderItemList = orderItemListMap.values();


		if(!orderItemList.isEmpty()){
			check = orderItemList[0].NE__OrderId__r.XC_IsStockReservationKO__c;
		}
		Boolean activeInterface = XC_UTIL_RESTCallout.checkActiveInterface(Label.XC_CL_Configuration_CallToStockReservation);
		System.debug('@@@@ Interface='+Label.XC_CL_Configuration_CallToStockReservation+' @@ isActive='+activeInterface);
		if(activeInterface){
			result.success = true;
			return result;
		} else {
			return manageReservationFakeResponce('SPAIN', externalId, check);
		}
	}

	/**
	 * @description Check delivery date.
	 *
	 * @param country the country
	 * @param expectedDeliveryDate the expected delivery date
	 * @return the boolean
	 */
	private static Boolean checkDeliveryDate(String country, Date expectedDeliveryDate){
		
		boolean b;
		if(!Schema.SObjectType.XC_CM_Configuration_Item_Default_Value__mdt.isAccessible()) {
            return b;
        }
		Map<Id,XC_CM_Configuration_Item_Default_Value__mdt> confItemDefValueListMap = new Map<Id,XC_CM_Configuration_Item_Default_Value__mdt>(
		[SELECT Id, XC_Days_for_Availability_Date_Too_Long__c  FROM 
		XC_CM_Configuration_Item_Default_Value__mdt WHERE XC_Country__c =: country]);
		
		List<XC_CM_Configuration_Item_Default_Value__mdt> confItemDefValueList = confItemDefValueListMap.values();

			if(!confItemDefValueList.isEmpty()){
				Integer daysBetweenTodayAndDeliveryDate = (system.today()).daysBetween(expectedDeliveryDate);
				if(daysBetweenTodayAndDeliveryDate > confItemDefValueList[0].XC_Days_for_Availability_Date_Too_Long__c){
						return false;
				}
			}
		return true;
	}

	/**
	 * @description Manage reservation fake responce.
	 *
	 * @param country the country
	 * @param externalId the external id
	 * @param check the check
	 * @return the result reservation wrapper
	 */
	private static ResultReservationWrapper manageReservationFakeResponce(String country, String externalId, Boolean check){
		ResultReservationWrapper result = new ResultReservationWrapper();
		result.success = true;

		Integer randBoolean = 1; //Math.mod(Math.abs(Crypto.getRandomInteger()), 2);
		if(check == false){
			result.result = 'OK';
			result.deliveryDate = date.today().addDays(10);
			if(!checkDeliveryDate(country, result.deliveryDate)){
				result.result = 'KO';
				result.message = Label.XC_CL_Availability_Date_Too_Long;
			}else { 
				result.externalId = externalId;
				result.serialNumber = String.valueOf(Math.abs(Crypto.getRandomLong()));
				Integer flagTracking = Math.mod(Math.abs(Crypto.getRandomInteger()), 2);
				if(flagTracking == 0){
					result.deliveryId = 'S' + Math.abs(Crypto.getRandomInteger());
					result.courierPartnerName = 'Google'; //ESCEP-502 ESCEP-504 MCutillo 07/12/2018
					result.trackingURL = 'www.google.com/'+result.deliveryId; //ESCEP-502 ESCEP-504 MCutillo 07/12/2018
				}
			} 
		} else {
			result.result = 'KO';
			result.message = Label.XC_CL_Product_Not_Available;
		} 
		return result;
	}

	/**
	 * @description Manage authentication responce.
	 *
	 * @param response the response
	 * @return the result wrapper
	 */
	private static ResultWrapper manageAuthenticationResponce(HttpResponse response){
		ResultWrapper result = new ResultWrapper();
		if(response==null){
			return result;
		}
        
		System.debug('Sirkus authentication response: '+response.getBody());
		Map<String, Object> mapResults = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
		if(mapResults != null){
			String returnCode = (String)mapResults.get('code');
			if(returnCode == SUCCESS_CODE){
				result.success=true;
				result.putField('code', (String)mapResults.get('code'));
				result.putField('token', (String)mapResults.get('token'));
			} else {
				result.success=false;
				result.putField('code', (String)mapResults.get('code'));
				result.putField('message_error', (String)mapResults.get('message_error'));
			}
		}
		return result;
	}

	/*private static ResultWrapper executeStockAvailabilityCall(String token){
		ResultWrapper result = new ResultWrapper();
		String requestString = '{ "token" : "'+token+'" }';
		HttpRequest request = XC_UTIL_RESTCallout.createRequest(Label.XC_CL_Configuration_CallToStockAvailabilityURL, requestString);
		HttpResponse response = XC_UTIL_RESTCallout.sendRequest(request, CLASS_NAME);
		return result; //manageStockAvailabilityResponce(response); << TODO
		
	}*/
    
}