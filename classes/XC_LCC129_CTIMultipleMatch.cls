/**
*@Author: Francesco Imperioli fimperioli@deloitte.it
*@Date creation: 09-07-2019
*@Description: Component controller for XC_LCP129_CTIMultipleMatch
**/

public with sharing class XC_LCC129_CTIMultipleMatch {

	private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC129_CTIMultipleMatch');

	public class WrapperCTIRecordMatch{
		@AuraEnabled
		public List<Lead> leadFound;
		@AuraEnabled
		public List<Contact> contactFound;
	}


	/**
	*@Author: Francesco Imperioli fimperioli@deloitte.it
	*@Date creation: 09-07-2019
	*@Description: Execute SOSL Query to find SOBJECT matches on phone fields
	**/
	@AuraEnabled
	public static WrapperCTIRecordMatch lookUpByPhone(String phoneKey){

		WrapperCTIRecordMatch result = new WrapperCTIRecordMatch();

		List<List<Sobject>> searchContactsByPhone = [FIND :phoneKey IN PHONE FIELDS RETURNING  Contact(Id,FirstName,LastName,Email,AccountId,XC_ContactPhone__c,XC_PhonePrefix__c),Lead(Id,FirstName,LastName,XC_LeadPhone__c,XC_PhonePrefix__c)];
		List<Contact> contactsFound = (List<Contact>) searchContactsByPhone[0];
		List<Lead> leadsFound = (List<Lead>) searchContactsByPhone[1];

	  	result.leadFound=leadsFound;
		result.contactFound=contactsFound;

		return result;

	}


	/**
	@Author: Francesco Imperioli fimperioli@deloitte.it
	@Date creation: 09-07-2019
	@Description: Retrieve available recordtype for sobject
	 */
	@AuraEnabled
    public static List<RecordType> getVisibleRecordType(String objectType) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'getVisibleRecordType - objectType='+objectType);
        List<RecordType> visibleRecordType = XC_UTIL_SObject_CheckVisibility.getVisibleRecordType(objectType);
        return visibleRecordType;
	}

	/**
	 * @author : Francesco Imperioli fimperioli@deloitte.it
	 * @description : create event for lead insertion in order to pop-out the recording panel
	 * @createdDate : 2020/02/24
	 */

	@AuraEnabled
	public static Boolean popUpCTIRecordingEvent(Map<String,Object> params){
		Map<String,Object> genesysParams = new Map<String,Object>{'eventType'=>'CALLINIT','connId'=>String.valueOf(params.get('connectionId'))};
		Map<String,Object> eventResult = XC_UTIL_CTICallRecording.publishStartStopRecordingEventMessage(genesysParams);
		return Boolean.valueOf(eventResult.get('success'));
	}






}