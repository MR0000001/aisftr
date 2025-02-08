/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 24/04/2019
* @description XC_LCC014_CreateWorkOrder_U - Util class for XC_LCC014_CreateWorkOrder
*/

public without sharing class XC_LCC014_CreateWorkOrder_U {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC014_CreateWorkOrder_U');

    /** @description CheckLeadStatusWrapper */
	public class CheckLeadStatusWrapper {
		public XC_LCC014_CreateWorkOrder.CreateWOforLeadWrapper wrapper;
		public Boolean finish = false;
	}

	/** @description CheckLeadPendingSchedulingWrapper*/
	public class CheckLeadPendingSchedulingWrapper {
		public Boolean hasRequiredField;
		public Lead lead;
		public List<XC_ProductCategoryOfInterest__c> listProdCat = new List<XC_ProductCategoryOfInterest__c>();
		public Boolean isPendingScheduling;
		public CheckLeadStatusWrapper checkWrapper;
	}

    /**
	 * @param hasProductCategoryAddress - Map<String,Boolean>
	 * @param keyToSearch - String
	 * @description Search a key in a Map
	 * @return Boolean
	 */
    public static Boolean searchKeyInMap(Map<String,Boolean> hasProductCategoryAddress, String keyToSearch) {
		if(hasProductCategoryAddress.containsKey(keyToSearch) && !hasProductCategoryAddress.get(keyToSearch)) {
			return true;
		}
		return false;
	}

    /**
	 * @param checkPensingSchedulingWrapper - CheckLeadPendingSchedulingWrapper
	 * @description Check for Lead in PendingScheduling (FOR CYCLOMATIC COMPLEXITY)
	 */
    public static void checkLeadPendingScheduling(CheckLeadPendingSchedulingWrapper checkPensingSchedulingWrapper) {
		//System.debug('@@@checkPensingSchedulingWrapper.isPendingScheduling'+ checkPensingSchedulingWrapper.isPendingScheduling);
		//System.debug('@@@checkPensingSchedulingWrapper.listProdCat[0].XC_CommercialVisit__c' +checkPensingSchedulingWrapper.listProdCat[0].XC_CommercialVisit__c);
		if(checkPensingSchedulingWrapper.isPendingScheduling && !checkPensingSchedulingWrapper.listProdCat.isEmpty() && checkPensingSchedulingWrapper.listProdCat[0].XC_CommercialVisit__c) { 
			if(checkPensingSchedulingWrapper.lead.Email == null && checkPensingSchedulingWrapper.lead.MobilePhone == null && checkPensingSchedulingWrapper.lead.Phone == null){ 
				checkPensingSchedulingWrapper.checkWrapper.wrapper.check = false;
				checkPensingSchedulingWrapper.checkWrapper.wrapper.resultMessage = Label.XC_CL_Lead_MissingField;  
				checkPensingSchedulingWrapper.checkWrapper.finish = true;
			}else {
				checkPensingSchedulingWrapper.hasRequiredField = true;
			}
		} else {
			checkPensingSchedulingWrapper.checkWrapper.wrapper.check = false;
			checkPensingSchedulingWrapper.checkWrapper.wrapper.resultMessage = Label.XC_CL_WorkOrder_NoWoWithThisCategory;
			checkPensingSchedulingWrapper.checkWrapper.finish = true;
		}
	}

    /**
	 * @param lead - Lead
	 * @param checkWrapper - CheckLeadStatusWrapper 
	 * @description Check for Lead Status
	 * @return Boolean
	 */
    public static Boolean checkLeadStatus(Lead lead, CheckLeadStatusWrapper checkWrapper) {
		if(lead.Status == Label.XC_CL_WorkOrder_PendingScheduling) {
            return true;
        } else{
            checkWrapper.wrapper.check = false;
        	checkWrapper.wrapper.resultMessage = Label.XC_CL_WorkOrder_NotPendingScheduling; 
			checkWrapper.finish = true;
			return false;
        }  
	}

    /**
	 * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
	 * @param recordId the record id
	 * @return the boolean
	 * @date Creation 27/03/2019
	 * @description hasAddressForLead() - Check if a Lead has a address
	 */
    public static Boolean hasAddressForLead(String recordId) {
		Boolean result = false;
		//Add for PMD 
		Boolean b;
		if(!Schema.SObjectType.Lead.isAccessible()) {
            return b;
        }

		Map<Id,Lead> leadMap = new Map<Id,Lead> ([SELECT XC_LeadAddress__c 
												FROM Lead WHERE Id = :recordId LIMIT 1]);

		Lead lead = new Lead ();
		lead = leadMap.values();
		result = checkLeadField(lead);
		return result;
	}

	/**
	 * @description Check for field Lead
	 * @param lead - Lead
	 * @return Boolean
	 */
	public static Boolean checkLeadField(Lead lead) {
		if(!String.isBlank(lead.XC_LeadAddress__c)) {
			return true;
		}
		return false;
	}

    /**
	 * @description Check product category address.
	 * @param recordId the record id
	 * @param listProdCat the list prod cat
	 * @return the map
	 */
	public static Map<String,Boolean> checkProductCategoryAddress(String recordId, List<XC_ProductCategoryOfInterest__c> listProdCat) {
		if(!Schema.SObjectType.Lead.isAccessible()) {
            return new Map<String,Boolean>();
        }

		Map<Id,Lead> leadMap = new Map<Id,Lead>([SELECT XC_StreetType__c,
													 XC_StreetTypeText__c,
													 XC_Address__c,
													 XC_DeliveryAddress__c,
													 XC_InstallationAddress__c,
													 XC_StreetNumber__c,
													 XC_City__c,
													 XC_ZipCode__c, 
													 XC_Municipality__c, 
													XC_Country__c, XC_Province__c FROM Lead WHERE Id = :recordId LIMIT 1]);
		
		Lead lead = new Lead ();
		lead = leadMap.values();
		Map<String,Boolean> mapProdTypeAddress = new Map<String,Boolean>();
		for(XC_ProductCategoryOfInterest__c prodCat : listProdCat){
			if(prodCat.XC_AddressesRequired__c == 'D') {
				mapProdTypeAddress.put(prodCat.XC_AddressesRequired__c,lead.XC_DeliveryAddress__c);
			}else if(prodCat.XC_AddressesRequired__c == 'I' ){
				mapProdTypeAddress.put(prodCat.XC_AddressesRequired__c,lead.XC_InstallationAddress__c);
			}
		}
		return mapProdTypeAddress;
	}
}