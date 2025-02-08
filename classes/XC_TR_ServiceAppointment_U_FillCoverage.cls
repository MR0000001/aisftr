/**
* @author: Roberta Cossiga - rcossiga@deloitte.it & Marco Rosa - marco.rosa@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date: Creation: 10/09/2019
* @date Modification:
* @description XC_TR_ServiceAppointment_U_FillCoverage - Util class to populate the Coverage (Zip Code Work Type) on Service Appointment
*/

public without sharing class XC_TR_ServiceAppointment_U_FillCoverage {

    /**
     * @description Populate Zip Code Work Type Lookup on Service Appointment 
     * @param listNew the list new
     * @param mapOld
     * @param mapNew
     */
    public static void checkZipCodeChanged(List<ServiceAppointment> listNew, Map<Id,ServiceAppointment> mapOld, Map<Id,ServiceAppointment> mapNew){
        List<String> fieldList = new List<String>{'XC_FSLAssignmentKey__c'};//new List<String>{'PostalCode'};
        List<ServiceAppointment> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()){
            populateZipCodeWorkType(listChanged);
        }      
    }

    /**
     * @description Populate Zip Code Work Type Lookup on Service Appointment 
     * @date Mod 02/09/2020 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @param listNew - List<ServiceAppointment> 
     */
    public static void populateZipCodeWorkType(List<ServiceAppointment> listNew){
        //List<String> workTypeNames = XC_UTIL_SObject.getListFieldValues(listNew, 'XC_WorkTypeLabel__c');
        //List<String> legalEntities = XC_UTIL_SObject.getListFieldValues(listNew, 'XC_LegalEntity__c');
        //Map<String,Id> mapWorkType = XC_UTIL_WorkType.getMapWorkTypeNameLEToId(workTypeNames, legalEntities);
        for(ServiceAppointment sa : listNew){
            if(sa.XC_SkipCheckZipCodeWorkType__c){
                return;
            }
        }
        List<XC_UTIL_ZipCodeWorkType.ZipCodeWorkTypeWrapper> zipCodeWtWrapper = new List<XC_UTIL_ZipCodeWorkType.ZipCodeWorkTypeWrapper>(); 
        Map<Id, WorkOrder> mapWo = new Map<Id, WorkOrder>([
            SELECT Id, WorkTypeId
            FROM WorkOrder
            WHERE Id = :XC_UTIL_SObject.getListFieldValues(listNew, 'ParentRecordId')
        ]);
        system.debug('MapWO'+' '+mapWo);
        for(ServiceAppointment sa : listNew){
            XC_UTIL_ZipCodeWorkType.ZipCodeWorkTypeWrapper wrap = new XC_UTIL_ZipCodeWorkType.ZipCodeWorkTypeWrapper(); 
            // This map is important to get id of Work Type in this step! Don't change it!
            wrap.workType = mapWo.get(sa.ParentRecordId).WorkTypeId; //mapWorkType.get(sa.XC_WorkTypeLabel__c + '_' + sa.XC_LegalEntity__c);
            wrap.zipCode = sa.XC_FSLAssignmentKey__c; //sa.PostalCode;
            zipCodeWtWrapper.add(wrap); 
        }
        Map<String, String> mapZipCodeWorkType = XC_UTIL_ZipCodeWorkType.calculateAssociationZipCodeWorkType(zipCodeWtWrapper);
        for(ServiceAppointment sa : listNew){
            //String key = sa.PostalCode+'_'+mapWo.get(sa.ParentRecordId).WorkTypeId;//mapWorkType.get(sa.XC_WorkTypeLabel__c + '_' + sa.XC_LegalEntity__c);
            String key = sa.XC_FSLAssignmentKey__c + '_' + mapWo.get(sa.ParentRecordId).WorkTypeId;
            sa.XC_ZipCedeWorkType__c = mapZipCodeWorkType.get(key);
        }
    }

    /**
    * @author Dario Tramontin dtramontin@deloitte.it
    * @date Creation 04/12/2019
    * @description Encrypt Id
    * @param listNew - List ServiceAppointment
    */
    public static void encryptServiceAppointmentIds(List<ServiceAppointment> listNew) {
        System.debug('Debug IN XC_TR_ServiceAppointment_U_FillCoverage - encryptServiceAppointmentIds ');
        List<ServiceAppointment> saToUpdate = new List<ServiceAppointment>();
        for(ServiceAppointment sa: listNew){
            ServiceAppointment saUpdate= new ServiceAppointment(Id=sa.Id);
            saUpdate.XC_EncryptedId__c = XC_UTIL_CustomerInteractionGeneration_U.objectIdEncrypt(sa.Id);
            saToUpdate.add(saUpdate);
        }
        
        XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        XC_UTIL_Sobject.updateListRecords(saToUpdate); 
        XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
    }
}