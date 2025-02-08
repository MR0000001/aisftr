/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date 27/02/2019
* @description - The class cancel the Service Appointment (not dispatched) when the related Asset is Disactive
*/

public without sharing  class XC_TR_Asset_U_CancelOpenSA {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Asset_U_CancelOpenSA');

    /**
     * @param listNew - List<Asset>
     * @param mapOld - Map<Id,Asset>
     * @param mapNew - Map<Id,Asset>
     * @description Cancel open service appointments.  
     */
    public static void cancelOpenServiceAppointments(List<Asset> listNew, Map<Id,Asset> mapOld, Map<Id,Asset> mapNew){
        List<Asset> inactiveAssetList = new List<Asset>();
        List<String> fieldList = new List<String>{'Status'};
        List<Asset> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'listChanged--->' + listChanged); 
        for(Asset asset : listChanged){
            if(asset.Status == Label.XC_CL_Asset_StatusInactive){
                inactiveAssetList.add(asset);
            }
        }
        if(!inactiveAssetList.isEmpty()){
            List<ServiceAppointment> saToUpdateList = new List<ServiceAppointment>();
            List<String> listConfigurationItemIds = XC_UTIL_SObject.getListFieldValues(inactiveAssetList, 'XC_Configuration_Item__c');
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'listConfigurationItemIds--->' + listConfigurationItemIds);
            Map<Id,ServiceAppointment> serviceAppointmentListMap = new Map<Id,ServiceAppointment>([SELECT Id, Status
                                                                FROM ServiceAppointment 
                                                                WHERE XC_Configuration_Item__c IN: listConfigurationItemIds
                                                                AND Status !=: Label.XC_CL_ServiceAppointment_Dispatched
                                                                AND XC_Check_Final_Status__c = false
                                                                AND XC_WorkTypeCategory__c =: Label.XC_CL_WorkType_PlannedMaintenance]);
           
            List<ServiceAppointment> serviceAppointmentList =  serviceAppointmentListMap.values();

            XC_UTIL_Debug.debug(DEBUGACTIVE, 'serviceAppointmentList--->' +serviceAppointmentList );
            for(ServiceAppointment sa : serviceAppointmentList){
                sa.XC_StatusReason__c = Label.XC_CL_StatusReason_LowContract;
                if(sa.Status == Label.XC_CL_ServiceAppointment_None || sa.Status == Label.XC_CL_ServiceAppointment_Scheduled){
                    sa.status = Label.XC_CL_ServiceAppointment_Canceled;
                    saToUpdateList.add(sa);
                }
                else{
                    sa.Status = Label.XC_CL_ServiceAppointment_CannotComplete;
                    sa.XC_Reason_Cannot_Complete__c = 'Rethinking_FINAL';
                    saToUpdateList.add(sa);
                }
            }
            XC_UTIL_Sobject.updateListRecords(saToUpdateList);
        }
    }

}