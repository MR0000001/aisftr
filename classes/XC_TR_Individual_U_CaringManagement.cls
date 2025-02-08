/**
 * The Class XC_TR_Individual_U_CaringManagement.
 *
 * @author Monica Cutillo - monica.cutillo@nttdata.com
 * @date Creation 26/02/2019
 * @date Modification
 * @description XC_TR_Individual_U_CaringManagement – Class that manages case caring
 */

public class XC_TR_Individual_U_CaringManagement {
	public static Boolean SKIP_CASE_CREATION = false;
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Individual_U_CaringManagement');

	/**
	 * @description Manage case creation.
	 * @param indiList the indi list
	 * @param oldIndiMap the old indi map
	 * @param newIndiMap the new indi map
	 */
	public static void manageCaseCreation(List<Individual> indiList, Map<ID, Individual> oldIndiMap, Map<ID, Individual> newIndiMap){
		XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ START XC_TR_Individual_U_CaringManagement.manageCaseCreation');
		List<String> listFieldsChanged = new List<String>{'XC_GiveDataToThirdParties__c'};
        List<Individual> listIndiChanged = XC_UTIL_Sobject.getListChanged(listFieldsChanged, oldIndiMap, newIndiMap);
        
        String caseSettingsName = Label.XC_CL_PersonalInfoChangeWithoutAuth;
        Map<String, XC_CM_Case_Type_Setting__mdt> settingsMap = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{caseSettingsName});
        if(settingsMap.isEmpty()){
        	XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ No Match on XC_CM_Case_Type_Setting__mdt with settingName='+caseSettingsName);
        	return;
        }
        XC_CM_Case_Type_Setting__mdt caseSettings = settingsMap.get(caseSettingsName);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ caseSettings='+caseSettings);

        Map<Id,Contact> contactsMap = XC_UTIL_Contact.getContactsFromaIndividuals(newIndiMap.keySet());
        List<Case> listCaseToInsert = new List<Case>();
        Case caseIndividual;
        Individual oldIndividual;
        Contact contact;
        for(Individual newIndividual : listIndiChanged){
			oldIndividual = oldIndiMap.get(newIndividual.Id);
            if(newIndividual.XC_GiveDataToThirdParties__c != oldIndividual.XC_GiveDataToThirdParties__c && !SKIP_CASE_CREATION){
        		caseIndividual = XC_UTIL_Case.initCaseFromCaseSettings(caseSettings);
                caseIndividual.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(XC_AT_Constants.CASE_RECORD_TYPE_XC_ATTENTION_ESPANA).getRecordTypeId();
                //caseIndividual.Reason = caseSettings.XC_Case_Reason__c;
                //caseIndividual.Subcause__c = caseSettings.XC_Sub_Cause__c;
                //caseIndividual.XC_Subtype__c = caseSettings.XC_Sub_Type__c;
                //caseIndividual.Priority = caseSettings.XC_Priority__c;
                //caseIndividual.Status = caseSettings.XC_Status__c;
                //caseIndividual.Origin = caseSettings.XC_Origin__c;
                contact = contactsMap.get(newIndividual.Id);
                if(contact!=null){
                	caseIndividual.ContactId =  contact.Id;
                	caseIndividual.AccountId =  contact.AccountId;
                }

                String remarksContent = checkRemarkContent(newIndividual, oldIndividual);
                if(!String.isEmpty(remarksContent)){
                    caseIndividual.CaseRemarks__c = remarksContent;
                }

                listCaseToInsert.add(caseIndividual);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ XC_TR_Individual_U_CaringManagement New CaseIndividual = ' + caseIndividual);
        	}
        }

        if(!listCaseToInsert.isEmpty()) {
        	List<XC_UTIL_SObject.WrapperResult> results = XC_UTIL_Sobject.insertListRecords(listCaseToInsert);
			XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ CaseIndividual eseriti' + results);
        }
	}

    /**
	 * @description Check and Populate Remarks Content
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
	 * @param newIndividual - Individual
	 * @param oldIndividual - Individual
	 * @return String
	 */
	private static String checkRemarkContent(Individual newIndividual, Individual oldIndividual) {
        String remarksContent = '';
        if(newIndividual.XC_GiveDataToThirdParties__c != oldIndividual.XC_GiveDataToThirdParties__c) {
            XC_AT_Utils.RemarkMessageWrapper remarkWrapper = new XC_AT_Utils.RemarkMessageWrapper();
            remarkWrapper.lastMessage = remarksContent;
            remarkWrapper.fieldDescribe = Schema.Individual.fields.XC_GiveDataToThirdParties__c.getDescribe();
            remarkWrapper.newValue = String.valueOf(newIndividual.XC_GiveDataToThirdParties__c);
            remarkWrapper.oldValue = String.valueOf(oldIndividual.XC_GiveDataToThirdParties__c);
            remarksContent = XC_AT_Utils.addRemarkMessage(remarkWrapper);
        }
        return remarksContent;
    }
}