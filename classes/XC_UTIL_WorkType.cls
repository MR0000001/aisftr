/**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 28/02/2019
* @date Modification 19/11/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_UTIL_WorkType - Util class for Work Type
*/ 

public without sharing class XC_UTIL_WorkType {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_WorkType');

    /** @description Wrapper for splitWorkOrders return */
    public class WorkOrderWrapper{ 
        public List<WorkOrder> listWorkOrderCommercialVisit = new List<WorkOrder>();
        public List<WorkOrder> listWorkOrderDeliveryInstallation = new List<WorkOrder>();
        public List<WorkOrder> listWorkOrderMaintenance = new List<WorkOrder>();
        public List<WorkOrder> listWorkOrderRepair = new List<WorkOrder>();
        public List<WorkOrder> listWorkOrderReturn = new List<WorkOrder>();
        public List<WorkOrder> listWorkOrderSubstitution = new List<WorkOrder>();
    } 

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 19/11/2019
     * @description Method to get a List of Work Order filtered by a Work Type Category
     * @param listWorkOrder - List<WorkOrder>
     * @param workTypeCategory - String
     * @return List<WorkOrder>
     */
    public static List<WorkOrder> filterWOByWorkTypeCategory(List<WorkOrder> listWorkOrder, String workTypeCategory){
        return filterWOByWorkTypeCategory(listWorkOrder, new List<String>{workTypeCategory});
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 19/11/2019
     * @description Method to get a List of Service Appointment filtered by a Work Type Category
     * @param listServiceAppointment - List<ServiceAppointment>
     * @param workTypeCategory - String
     * @return List<ServiceAppointment>
     */
    public static List<ServiceAppointment> filterWOByWorkTypeCategory(List<ServiceAppointment> listServiceAppointment, String workTypeCategory){
        return filterSAByWorkTypeCategory(listServiceAppointment, new List<String>{workTypeCategory});
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 19/11/2019
     * @description Method to get a List of Work Order filtered by a list of Work Type Category
     * @param listWorkOrder - List<WorkOrder>
     * @param workTypeCategoryList - List<String>
     * @return List<WorkOrder>
     */
    public static List<WorkOrder> filterWOByWorkTypeCategory(List<WorkOrder> listWorkOrder, List<String> workTypeCategoryList){
        List<WorkOrder> listFilteredWorkOrder = new List<WorkOrder>();
        for(WorkOrder wo : listWorkOrder) {
            if(workTypeCategoryList.contains(wo.XC_WorkTypeCategory__c)) {
                listFilteredWorkOrder.add(wo);
            }
        }
        return listFilteredWorkOrder;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 19/11/2019
     * @description Method to get a List of Service Appointment filtered by a list of Work Type Category
     * @param listServiceAppointment - List<ServiceAppointment>
     * @param workTypeCategoryList - List<String>
     * @return List<ServiceAppointment>
     */
    public static List<ServiceAppointment> filterSAByWorkTypeCategory(List<ServiceAppointment> listServiceAppointment, List<String> workTypeCategoryList){
        List<ServiceAppointment> listFilteredServiceAppointment = new List<ServiceAppointment>();
        for(ServiceAppointment sa : listServiceAppointment) {
            if(workTypeCategoryList.contains(sa.XC_WorkTypeCategory__c)) {
                listFilteredServiceAppointment.add(sa);
            }
        }
        return listFilteredServiceAppointment;
    }
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @param listWorkOrder - List<WorkOrder>
     * @return WorkOrderWrapper
     * @description Splits Work Order according to Work Type
     */
    public static WorkOrderWrapper splitWorkOrders(List<WorkOrder> listWorkOrder){
        WorkOrderWrapper wrapper = new WorkOrderWrapper();
        List<WorkOrder> listWorkOrderCommercialVisit = new List<WorkOrder>();
        List<WorkOrder> listWorkOrderDeliveryInstallation = new List<WorkOrder>();
        List<WorkOrder> listWorkOrderMaintenance = new List<WorkOrder>();
        List<WorkOrder> listWorkOrderRepair = new List<WorkOrder>();
        List<WorkOrder> listWorkOrderReturn = new List<WorkOrder>();
        List<WorkOrder> listWorkOrderSubstitution = new List<WorkOrder>();
        for(WorkOrder wo : listWorkOrder){
            if(wo.XC_WorkTypeCategory__c == Label.XC_CL_CommercialVisit){
                listWorkOrderCommercialVisit.add(wo);
            } else if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation 
                    || wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Installation){
                listWorkOrderDeliveryInstallation.add(wo);
            } else if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_PlannedMaintenance){
                listWorkOrderMaintenance.add(wo);
            } else if(XC_UTIL_WorkType.isRepair( wo.XC_WorkTypeCategory__c )){
                listWorkOrderRepair.add(wo);
            } else if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Return){
                listWorkOrderReturn.add(wo);
            } else if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Substitution){
                listWorkOrderSubstitution.add(wo);
            }
        }
        wrapper.listWorkOrderCommercialVisit = listWorkOrderCommercialVisit;
        wrapper.listWorkOrderDeliveryInstallation = listWorkOrderDeliveryInstallation;
        wrapper.listWorkOrderMaintenance = listWorkOrderMaintenance;
        wrapper.listWorkOrderRepair = listWorkOrderRepair;
        wrapper.listWorkOrderReturn = listWorkOrderReturn;
        wrapper.listWorkOrderSubstitution = listWorkOrderSubstitution;
        return wrapper; 
    } 

    /**
     * @description Return a Map: WorkTypeName -> AssignToPartner
     * @param workTypeName - String
     * @return Boolean
     */
    public static Boolean isRepair(String workTypeName){
        Boolean repair = false;
        if (workTypeName == Label.XC_CL_WorkType_Repair){
            repair = true;
        }
        return repair;
    }

    /**
     * @description Return a Map: WorkTypeName -> AssignToPartner
     * @param listNameWorkType - List<String>
     * @return Map<String,Boolean>
     */
	public static Map<String,Boolean> getMapAssignToPartnerByWorkTypeName(List<String> listNameWorkType){
        if(!Schema.sObjectType.WorkType.isAccessible()){
            return new Map<String,Boolean>();
        }
        List<WorkType> listWorkType = [SELECT Name, XC_AssignToPartner__c FROM WorkType WHERE Name IN :listNameWorkType];

        Map<String,Boolean> mapWT = new Map<String,Boolean>();
        for(WorkType wt: listWorkType) {
            mapWT.put(wt.Name, wt.XC_AssignToPartner__c);
        }
		XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapWT ---> ' + mapWT);
		return mapWT;
    }
    
    /**
     * @description Return a Map: WorkTypeName -> AssignToPartner
     * @param listNameWorkType - List<String>
     * @return Map<String,Boolean>
     */
	public static Map<String,Boolean> getMapAssignToPartnerByWorkTypeId(List<String> listNameWorkTypeId){
        if(!Schema.sObjectType.WorkType.isAccessible()){
            return new Map<String,Boolean>();
        }
        List<WorkType> listWorkType = [SELECT Name, XC_AssignToPartner__c FROM WorkType WHERE Id IN :listNameWorkTypeId];

        Map<String,Boolean> mapWT = new Map<String,Boolean>();
        for(WorkType wt: listWorkType) {
            mapWT.put(wt.Name, wt.XC_AssignToPartner__c);
        }
		XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapWT ---> ' + mapWT);
		return mapWT;
	}

    /**
     * @description Return a Map: WorkTypeName -> WorkTypeId
     * @param listWorkTypeName - List<String>
     * @return Map<String, Id>
     */
    public static Map<String,Id> getMapWorkTypeNameId(List<String> listWorkTypeName){
        Map<String,Id> mapWorkType = new Map<String,Id>();
        if(!Schema.sObjectType.WorkType.isAccessible()){
            return new Map<String,Id>();
        }
        List<WorkType> listWorkType = [SELECT Id, Name FROM WorkType WHERE Name IN : listWorkTypeName ];
        for(WorkType wt : listWorkType){
            mapWorkType.put(wt.Name, wt.Id);
        }
        return mapWorkType;
    }
    
     /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @param listWorkTypeName - List<String>
     * @param listWorkTypeLE - List<String>
     * @description Method to get Work Type Id By Name and LE
     * @return Map<String,Id>
     */
    public static Map<String,Id> getMapWorkTypeNameLEToId(List<String> listWorkTypeName, List<String> listWorkTypeLE){
        Map<String,Id> mapWorkType = new Map<String,Id>(); 
        List<WorkType> listWorkType = new List<WorkType>([
            SELECT Id, Name, XC_LegalEntity__c 
            FROM WorkType 
            WHERE Name IN : listWorkTypeName
            AND XC_LegalEntity__c IN : listWorkTypeLE]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listWorkType in util -> ' + listWorkType);
        for(WorkType wt : listWorkType){
            mapWorkType.put(wt.Name + '_' + wt.XC_LegalEntity__c, wt.Id);
        }
        return mapWorkType;
    }

    
    /**
     * @author Roberta Cossiga - rcossiga@deloitte.it
     * @param typeName String
     * @description Method to get Work Type Id By Name
     * @return String
     */
	public static String getWorkTypeByNameAndLE(String typeName, String legalEntity){
		String wtId = '';
		List<WorkType> wtList = [SELECT Id 
                                 FROM WorkType 
                                 WHERE Name =:typeName 
                                 AND XC_LegalEntity__c =: legalEntity LIMIT 1];
		if(!wtList.isEmpty()){
			wtId = wtList[0].Id; 
		}
		return wtId;
	}
    
     /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @param typeName String
     * @description Method to get Work Type Id By Name
     * @return String
     */
	public static String getWorkTypeByName(String typeName){
		String wtId = '';
        if(!Schema.sObjectType.WorkType.isAccessible()){
            return wtId;
        }
		List<WorkType> wtList = [SELECT Id FROM WorkType WHERE Name =:typeName LIMIT 1];
		if(!wtList.isEmpty()){
			wtId = wtList[0].Id; 
		}
		return wtId;
	}

    /**
     * @description Return a Map: WorkTypeName -> WorkTypeId
     * @param listWorkTypeName - List<String>
     * @param listWorkTypeId - List<String>
     * @return Map<String,Id>
     */
    public static Map<Id,WorkType> retrieveWorkTypeByNameOrId(List<String> listWorkTypeName, List<String> listWorkTypeId){
        if(!Schema.sObjectType.WorkType.isAccessible()){
            return new Map<Id,WorkType>();
        }
        Map<Id,WorkType> mapWorkTypeIdName = new Map<Id,WorkType>([
            SELECT Id, Name, EstimatedDuration, XC_WorkTypeCategory__c
            FROM WorkType 
            WHERE Name IN : listWorkTypeName OR Id IN: listWorkTypeId
        ]);
        /*List<WorkType> listWorkType = [SELECT Id, Name 
                                       FROM WorkType 
                                       WHERE Name IN : listWorkTypeName OR Id IN: listWorkTypeId];
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@listWorkType-->'+listWorkType); 
        for(WorkType wt: listWorkType){
           mapWorkTypeIdName.put(wt.Id, wt.Name);  
        }    */
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@mapWorkTypeIdName-->'+mapWorkTypeIdName);
        return mapWorkTypeIdName;
    }

}