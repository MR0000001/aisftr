/**
 * The Class XC_TR_Case_U_CheckAppCancellation.
 *
 * @author Monica Cutillo - monica.cutillo@nttdata.com , Chiara Turco - cturco@deloitte.it
 * @date Creation 12/03/2019
 * @date Modification
 * @description XC_TR_Case_U_CheckAppCancellation – Class to manage Appointment Cancellation
 */
public without sharing class XC_TR_Case_U_CheckAppCancellation {

	/**
	 * @description Manage appointment cancellation.
	 *
	 * @param listNew the list new
	 */
	public static void manageAppointmentCancellation(List<Case> listNew){
		//Set<WorkOrder> woToUpdate = new Set<WorkOrder>();
		Set<ServiceAppointment> saToUpdate = new Set<ServiceAppointment>();

		List<Case> appCancelCases = checkCaseSettings(listNew);
		if(appCancelCases.isEmpty()){
			return;
		}
		System.debug('@@@@@ XC_TR_Case_U_CheckAppCancellation - appCancelCases='+appCancelCases);

		Map<Id,ServiceAppointment> woSaRelations = retriveWOSARelations(appCancelCases);
		System.debug('@@@@@ XC_TR_Case_U_CheckAppCancellation - woSaRelations='+woSaRelations);

		ServiceAppointment sa;
		for(Case newCase: appCancelCases){
			sa = woSaRelations.get(newCase.XC_WorkOrder__c);
			if(sa == null){
				return;
			}
			if(sa.Status == Label.XC_CL_ServiceAppointment_Canceled || sa.Status == Label.XC_CL_ServiceAppointment_StatusCannotComplete){
                continue;
            }

			if(sa.Status == Label.XC_CL_ServiceAppointment_Scheduled || sa.Status == Label.XC_CL_ServiceAppointment_Dispatched ){
				System.debug('@@@@@ Case Appointment Cancellation OK');
				//close SA
				sa.Status = Label.XC_CL_ServiceAppointment_StatusCannotComplete;
				sa.XC_Reason_Cannot_Complete__c = Label.XC_CL_CustomerRefuseWorkReason; // Label.XC_CL_CannotCompleteReason;
				System.debug('@@@@@ sa to update='+sa);
				saToUpdate.add(sa);
				//close WO
				/*WorkOrder wo = new WorkOrder(Id=newCase.XC_WorkOrder__c);
				wo.Status = Label.XC_CL_WorkOrder_CannotComplete;
				wo.XC_Refusing_Reason__c = Label.XC_CL_CannotCompleteReason;
				System.debug('@@@@@ wo to update='+wo);
				woToUpdate.add(wo);*/

			} else {
				System.debug('@@@@@ Case Appointment Cancellation KO');
				newCase.addError(Label.XC_CL_ServiceAppointmentWrongStatus);
			}
		}

		/*if(!woToUpdate.isEmpty()){
			List<XC_Util_Sobject.WrapperResult> rw = XC_Util_Sobject.updateListRecords(new List<WorkOrder>(woToUpdate));
			System.debug('@@@@@ WorkOrder update result='+rw);
		}*/
		if(!saToUpdate.isEmpty()){
			List<XC_Util_Sobject.WrapperResult> rw = XC_Util_Sobject.updateListRecords(new List<ServiceAppointment>(saToUpdate));
			System.debug('@@@@@ ServiceAppointment update result='+rw);
		}
	}

	/**
	 * @description Filter Case of Appointment Cancellation type ad with WO relation.
	 *
	 * @param listNew the list new
	 * @return the list
	 */
	private static List<Case> checkCaseSettings(List<Case> listNew){
		List<Case> result = new  List<Case>();
		Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_AppointmentCancellation});
		System.debug('@@@@@ caseSettingsMap='+caseSettingsMap);
		XC_CM_Case_Type_Setting__mdt caseSettings = caseSettingsMap.get(Label.XC_CL_AppointmentCancellation);
       	if(caseSettings==null){
            System.debug( String.format(Label.XC_CL_NoMatchOnMetadata, new List<String>{'XC_CM_Case_Type_Setting__mdt', Label.XC_CL_AppointmentCancellation}));
            System.debug('@@@@@ XC_TR_Case_Care_Handler - CAN NOT create Case!');
            return result;
        }

        for(Case newCase: listNew){
        	result = checkCaseParameter(newCase, caseSettings);
        }
		return result;
	}

	/**
	 * @description check Case Reason, Subcause and SubType
	 *
	 * @param newCase
	 * @param caseSettings
	 * @return List<Case>
	 */
	private static List<Case> checkCaseParameter (Case newCase, XC_CM_Case_Type_Setting__mdt caseSettings){
		List<Case> result = new  List<Case>();
		if( (newCase.Reason!=null && newCase.Reason.equals(caseSettings.XC_Case_Reason__c)) &&
			(newCase.Subcause__c!=null && newCase.Subcause__c.equals(caseSettings.XC_Sub_Cause__c)) &&
			(caseSettings.XC_Sub_Type__c == null || (newCase.XC_Subtype__c != null && newCase.XC_Subtype__c.equals(caseSettings.XC_Sub_Type__c)))){

			if(newCase.XC_WorkOrder__c != null){
				result.add(newCase);
			}
		}
		return result;
	}

	/**
	 * @description retrive ServiceAppointment from WO related with cases in input.
	 *
	 * @param cases the cases
	 * @return the map
	 */
	private static Map<Id,ServiceAppointment> retriveWOSARelations(List<Case> cases){
		Map<Id,ServiceAppointment> result = new Map<Id,ServiceAppointment>();
		Set<Id> woIds = XC_UTIL_Sobject.getSetIdsOnField(cases, 'XC_WorkOrder__c');
		System.debug('@@@@@ woIds='+woIds);
		Map<Id,ServiceAppointment> soListMap = new Map<Id,ServiceAppointment>(
			[SELECT Id, Status, ParentRecordId 
			FROM ServiceAppointment WHERE ParentRecordId IN: woIds]);
		List<ServiceAppointment> soList = soListMap.values();

		for(ServiceAppointment so : soList){
			result.put(so.ParentRecordId, so);
		}
		return result;
	}
}