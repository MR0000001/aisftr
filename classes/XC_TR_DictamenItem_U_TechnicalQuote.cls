/**
 * @File Name          : XC_TR_DictamenItem_U_TechnicalQuote.cls
 * @description        : Util to handle the creation of the Technical Quote
 * @Author             : Roberta Cossiga - rcossiga@deloitte.it && Marco Rosa - marco.rosa@nttdata.com && Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @Group              : 
 * @Last Modified By   : Roberta Cossiga - rcossiga@deloitte.it && Marco Rosa - marco.rosa@nttdata.com && Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @Last Modified On   : 24/10/2019, 11:37:20
**/
public without sharing class XC_TR_DictamenItem_U_TechnicalQuote {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_DictamenItem_U_TechnicalQuote');

    /**
    * @description createRepairWo
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 9/10/2019 
    * @param listNew 
    * @param mapOld
    * @param mapNew
    **/
    public static void checkRepairStatusChanged(List<XC_DictamenItem__c> listNew, Map<Id, SObject> mapOld, Map<Id, SObject> mapNew){
        List<String> fieldsToCheck = new List<String>{'XC_ReparationStatus__c'};
		List<XC_DictamenItem__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldsToCheck,mapOld,mapNew);
		if(!listChanged.isEmpty()){
			handleParentWorkOrderStatus(listChanged);
		}
    }

    /**
    * @description createRepairWo
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 9/10/2019 
    * @param listNew 
    **/
    public static void handleParentWorkOrderStatus(List<XC_DictamenItem__c> listNew){
        List<String> workOrderIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_WorkOrder__c');
        Map<Id, WorkOrder> rootWoMap = new Map<Id, WorkOrder>([SELECT Id, 
                                                                    (SELECT Id, ParentRecordId, Status 
                                                                    FROM ServiceAppointments 
                                                                    WHERE Status !=: Label.XC_CL_ServiceAppointment_CannotComplete),
                                                               XC_AssignedResource__c,  XC_LegalEntity__c, Street, PostalCode, City, Country, XC_Address__c, ParentWorkOrderId, AssetId 
                                                               FROM WorkOrder 
                                                               WHERE Id IN :workOrderIds]);
        List<ServiceAppointment> saListToUpdate = new List<ServiceAppointment>();
        List<WorkOrder> woListToUpdate = new List<WorkOrder>();
        for(XC_DictamenItem__c dic : listNew){
            WorkOrder wo = new WorkOrder(Id = dic.XC_WorkOrder__c);  
            if(dic.XC_ReparationStatus__c == Label.XC_CL_PendingQuoteAcceptance){                      
                wo.XC_StatusReason__c = Label.XC_CL_PendingAcceptanceQuote;
                if(!rootWoMap.get(dic.XC_WorkOrder__c).ServiceAppointments.isEmpty()){
                    ServiceAppointment sa = new ServiceAppointment(Id = rootWoMap.get(dic.XC_WorkOrder__c).ServiceAppointments[0].Id);
                    sa.Status = Label.XC_CL_ServiceAppointment_CannotComplete;
                    sa.XC_StatusReason__c = Label.XC_CL_QuoteInviable;
                    sa.XC_Reason_Cannot_Complete__c = Label.XC_CL_CustomerNotPresence;
                    saListToUpdate.add(sa);
                }else{
                    wo.Status = Label.XC_CL_ServiceAppointment_OnHold;
                }
            }else if(dic.XC_ReparationStatus__c == Label.XC_CL_PendingSpareParts){
                wo.XC_StatusReason__c = Label.XC_CL_PendingParts;
                if(!rootWoMap.get(dic.XC_WorkOrder__c).ServiceAppointments.isEmpty()){
                    ServiceAppointment sa = new ServiceAppointment(Id = rootWoMap.get(dic.XC_WorkOrder__c).ServiceAppointments[0].Id);
                    sa.Status = Label.XC_CL_ServiceAppointment_CannotComplete;
                    sa.XC_StatusReason__c = Label.XC_CL_QuoteAndPendingParts;
                    sa.XC_Reason_Cannot_Complete__c = Label.XC_CL_CustomerNotPresence;
                    saListToUpdate.add(sa);
                }else{
                    wo.Status = Label.XC_CL_ServiceAppointment_OnHold;
                }                
            }
            woListToUpdate.add(wo);
        }
        if(!woListToUpdate.isEmpty()){
            XC_UTIL_Sobject.updateListRecords(woListToUpdate);
        }
        if(!saListToUpdate.isEmpty()){
            XC_UTIL_Sobject.updateListRecords(saListToUpdate);
        }
    }

}