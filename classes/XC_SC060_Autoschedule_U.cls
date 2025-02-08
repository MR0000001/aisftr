/**
 * Created by sbarbera on 11/10/21.
 */

public with sharing class XC_SC060_Autoschedule_U {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC060_Autoschedule_U');

    
    /**
     * @description method to select partners that have saturation < 100%
	 * @return mapElegiblePartnerSaturation - map where key is account id and value is its saturation percentage.
     * This account will be elegible for saturation logic
     */
    public static Map<Id,Integer> getAccountsForSaturationCalculation(){
        Integer saturation = 0;
        Map<id,Integer> mapPartnerWOAssigned = new Map<Id, Integer>();
        Map<Id,Integer> mapElegiblePartnerSaturation = new Map<Id, Integer>();
        
		//get number of WO Assigned in the current month for each partner
        List<AggregateResult> workOrderPerAccount = [SELECT XC_AssignedPartner__c, count(id) numWO FROM WorkOrder WHERE StartDate=THIS_MONTH AND XC_Segment__c ='B2C' AND XC_AssignedPartner__c!=null AND XC_WorkTypeCategory__c IN('Site Inspection','Installation','Delivery & Installation') GROUP BY XC_AssignedPartner__c];
        //get max number of WO that a partner can receive per month 
		List<Account> accoutList = [SELECT id, XC_Max_Work_Order_Per_Month__c FROM Account WHERE isPartner=true AND XC_ContractStatus__c = 'Active' AND XC_Technical_Service__c = true AND XC_Segment__c ='B2C'];
        
		for(AggregateResult aggr : workOrderPerAccount){
            mapPartnerWOAssigned.put((id)aggr.get('XC_AssignedPartner__c'),(Integer) aggr.get('numWO'));
        }

        Map<Id,Integer> mapPartnerSaturation = getAccountsSaturationPercentage(accoutList, mapPartnerWOAssigned);
		//Select only partner that are not sature yet
        for(Id accId : mapPartnerSaturation.keySet()){
            saturation = mapPartnerSaturation.get(accId) ;
			System.debug('XC_SC060 saturation= ' + saturation + ' accountId ' + accId);
            if(saturation < 100){
                mapElegiblePartnerSaturation.put(accId, saturation); 
            }
        }

        return mapElegiblePartnerSaturation;
    }

	/**
     * @description method to calculate partners' saturation %
	 * @param listAccounts - List of partners' Account 
     * @param mapPartnerSaturation - Map of Account id and number of WO assigned this month
	 * @return result - map where key is account id and value is its saturation %
     */
    private static Map<Id,Integer> getAccountsSaturationPercentage(List<Account> listAccounts,  Map<Id, Integer> mapPartnerSaturation){
        Map<Id,Integer> result = new Map<Id,Integer>();
        Integer saturation = 0;
        Decimal percentage = 0;
		for(Account acc : listAccounts){
            if (acc.XC_Max_Work_Order_Per_Month__c == 0 || acc.XC_Max_Work_Order_Per_Month__c == null){
                saturation = 100;
            }else{
                if(mapPartnerSaturation.get(acc.id) == null){
                    saturation = 0;
                }else{
                    saturation =  (Integer) ((mapPartnerSaturation.get(acc.id) / acc.XC_Max_Work_Order_Per_Month__c) * 100);
                }
            }
			result.put(acc.id, saturation); 
		}
        return result;
    }
    
    /**
     * @description 
     * @param mapPartnerSaturation -  Map of Account id and percentage of saturation
     * @param srManagerMap -  Map of Account id and ServiceResource that is manager
     * @return srList - list of updated ServiceResource
     */
    public static List<ServiceResource> setSaturationOnServiceResource( Map<Id, Integer> mapPartnerSaturation,  Map<Id, ServiceResource> srManagerMap){
		List<ServiceResource> srList = new List<ServiceResource>();
        for(Id accPartnerId : mapPartnerSaturation.keySet()){
            if(mapPartnerSaturation !=null ){
                ServiceResource sr = srManagerMap.get(accPartnerId);
                System.debug('XC_SC060 srManager= ' + sr);
                if(sr != null){
                    sr.XC_Saturation__c = mapPartnerSaturation.get(accPartnerId);
                    srList.add(sr);
                }
            }
        }
        update srList;
        return srList;
    }
    
    /**
     * @description 
     * @param srList - list of updated ServiceResource
     */
    public static void clearSaturationOnServiceResource(List<ServiceResource> srList){
        List<ServiceResource> srListToClear = new List<ServiceResource>();
        for(ServiceResource sr : srList){
            sr.XC_Saturation__c = null;
            srListToClear.add(sr);
        }
        update srList;
    }

	/**
     * @description method to sort partners based on their saturation in ascending order
     * @param mapAccountSaturation - Map of Account id and number of WO assigned this month
	 * @return result - Ordered list of partners' Account
     */
    public static List<Account> getOrderedListSaturationFromMap(Map<Id,Integer> mapAccountSaturation){
        List<Account> result = new  List<Account>();
        Set<Integer> saturationSet = new Set<Integer>(mapAccountSaturation.values());
        List<Integer> saturationList = new List<Integer>(saturationSet);

        saturationList.sort();
        
        for(Integer saturation : saturationList){
            for(Id accId : mapAccountSaturation.keySet()){
                if(mapAccountSaturation.get(accId) == saturation){
                    Account acc = new Account(id=accId);
                    result.add(acc);
                }
            }
        }

        return result;
    }

	/**
     * @description method get assigned partner from WorkOrder
	 * @param workOrders - List of WorkOrder
	 * @return assignedPartner - map where key is WorkOrder id and value is the account of assigned partner
     */
    public static Map<Id,Account> getMapWorkOrderAssignedPartner(List<WorkOrder> workOrders){
        Map<Id,Account> assignedPartner = new Map<Id,Account>();
        for (WorkOrder wo : workOrders){
			assignedPartner.put(wo.id, new Account (id=wo.XC_AssignedPartner__c));
		}
        return assignedPartner;
    }

	/**
     * @description method to return an Account Directly Elegible for WorkOrder of Repair and D&I.
	 *				An Account is Directly Elegible if it has completed a previous WO on the same Order. 
	 * @param woList - List of WorkOrder
	 * @return result - map where key is WorkOrder id and value is the Account Directly Elegible or null.
     */
    public static Map<Id,Id> getMapWorkOrderWithAccountDirectlyElegible(List<WorkOrder> woList){
        Map<Id,Id> result = new Map<Id,Id>();
		Map<Id,WorkOrder> mapWORepair = new Map<Id,WorkOrder>();
		Map<Id,WorkOrder> mapWODI = new Map<Id,WorkOrder>();
        Map<Id, WorkOrder> mapWOSI = new Map<Id,WorkOrder>();
		List<Id> orderRepair = new List<Id>();
		List<Id> orderDI = new List<Id>();
		
		for(WorkOrder wo : woList){
			if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Repair){
				mapWORepair.put(wo.id, wo);
			}else if(wo.XC_WorkTypeCategory__c ==  Label.XC_CL_WorkType_DeliveryInstallation || wo.XC_WorkTypeCategory__c==Label.XC_CL_WorkType_Installation){
				mapWODI.put(wo.id, wo);
			}else if(wo.XC_WorkTypeCategory__c ==  Label.XC_CL_WorkType_SiteInspection){
                mapWOSI.put(wo.id, wo);
            }
		}
		
		//Logic for Repair 
		if(!mapWORepair.isEmpty()){
			for(Id idR : mapWORepair.keySet()){
				if(mapWORepair.get(idR).Asset.XC_Original_Configuration_Item__c != null)
					orderRepair.add(mapWORepair.get(idR).Asset.XC_Original_Configuration_Item__c);
			}
		}
		
		if(!orderRepair.isEmpty()){
			//get all the WO of type Delivery&Installation and Completed for each Order
			Map<Id,WorkOrder> mapOrderRepair = new Map<Id,WorkOrder>([SELECT XC_Configuration_Item__c, XC_AssignedPartner__c FROM WorkOrder WHERE XC_Configuration_Item__c in :orderRepair AND XC_WorkTypeCategory__c = :Label.XC_CL_WorkType_DeliveryInstallation AND Status = 'Completed']);
			System.debug('XC_SC060 mapOrderRepair= ' + mapOrderRepair);
            //Map orderItem id, assegned partnerId
            Map<Id, Id> mapOrderAssignedPartner = new Map<Id,Id>();
            for(WorkOrder previousWO : mapOrderRepair.values()){
                mapOrderAssignedPartner.put(previousWO.XC_Configuration_Item__c, previousWO.XC_AssignedPartner__c);
            }
            
			for(WorkOrder wo : mapWORepair.values()){
                //Esiste un WO di D&I
                if(mapWORepair.get(wo.id).Asset.XC_Original_Configuration_Item__c != null && mapOrderAssignedPartner.get(mapWORepair.get(wo.id).Asset.XC_Original_Configuration_Item__c) != null){
                    System.debug('XC_SC060 repair - Esiste  WO di D&I ' + mapWORepair.get(wo.id));
                    result.put(wo.id, mapOrderAssignedPartner.get(mapWORepair.get(wo.id).Asset.XC_Original_Configuration_Item__c));
                }
					
			
			}
		}
		
		//Logic for Delivery&Installation
		if(!mapWODI.isEmpty()){
			for(Id idDI : mapWODI.keySet()){
				if(mapWODI.get(idDI).ParentWorkOrder.Id != null) {
                    if (mapWODI.get(idDI).ParentWorkOrder.XC_Configuration__c != null) {
                        orderDI.add(mapWODI.get(idDI).ParentWorkOrder.XC_Configuration__c);
                    }
				}
				else{
					if(mapWODI.get(idDI).XC_Configuration__c != null) {
                        orderDI.add(mapWODI.get(idDI).XC_Configuration__c);
                    }
				}
				
			}
		}
		
		if(!orderDI.isEmpty()){
			//get all the WO of type Site Inspection and Completed for each Order
			Map<Id,WorkOrder> mapOrderDI = new Map<Id,WorkOrder>( [SELECT XC_Configuration__c, XC_AssignedPartner__c FROM WorkOrder WHERE XC_Configuration__c in :orderDI AND XC_WorkTypeCategory__c = :Label.XC_CL_WorkType_SiteInspection AND Status = 'Completed']);
            //Map order id, assegned partnerId
            Map<Id, Id> mapOrderAssignedPartner = new Map<Id,Id>();
            for(WorkOrder previousWO : mapOrderDI.values()){
                mapOrderAssignedPartner.put(previousWO.XC_Configuration__c, previousWO.XC_AssignedPartner__c);
            }
            
			for(WorkOrder wo : mapWODI.values()){
				if(mapWODI.get(wo.id).ParentWorkOrder.Id != null){
                    System.debug('XC_SC060 D&I - ParentWorkOrder popolato ' +  mapWODI.get(wo.id).ParentWorkOrder.Id);
                    //Esiste WO di SI?
                    if(mapWODI.get(wo.id).ParentWorkOrder.XC_Configuration__c != null && mapOrderAssignedPartner.get(mapWODI.get(wo.id).ParentWorkOrder.XC_Configuration__c) != null) {
                        System.debug('XC_SC060 D&I ParentWorkOrder - Esiste  WO di SI ' + mapWODI.get(wo.id));
                        result.put(wo.id, mapOrderAssignedPartner.get(mapWODI.get(wo.id).ParentWorkOrder.XC_Configuration__c));
                    }else if (mapWODI.get(wo.Id).ParentWorkOrder.XC_Configuration__r.NE__OptyId__r.CreatedBy.Account.XC_Technical_Service__c) {
                        //Account su opportunity ? Seller ed Installer?
                        System.debug('XC_SC060 D&I ParentWorkOrder - seller & installer ' + mapWODI.get(wo.id));
                        result.put(wo.Id, mapWODI.get(wo.Id).ParentWorkOrder.XC_Configuration__r.NE__OptyId__r.CreatedBy.AccountId);
                    }else {
                        //Account su opportunity ha partner Associato?
                        System.debug('XC_SC060 D&I ParentWorkOrder - partner associato ' + mapWODI.get(wo.id));
                        result.put(wo.Id, mapWODI.get(wo.Id).ParentWorkOrder.XC_Configuration__r.NE__OptyId__r.CreatedBy.Account.XC_Technical_Service_Partner__c);
                    }
				}
				else{
                    //Esiste WO di SI?
                    System.debug('XC_SC060 D&I - ParentWorkOrder null ');
                    if(mapWODI.get(wo.id).XC_Configuration__c != null && mapOrderAssignedPartner.get(mapWODI.get(wo.id).XC_Configuration__c) !=null) {
                        System.debug('XC_SC060 D&I ParentWorkOrder null - Esiste  WO di SI ' + mapWODI.get(wo.id));
                        result.put(wo.id, mapOrderAssignedPartner.get(mapWODI.get(wo.id).XC_Configuration__c));
                    }else if (mapWODI.get(wo.Id).XC_Configuration__r.NE__OptyId__r.CreatedBy.Account.XC_Technical_Service__c) {
                        //Account su opportunity ? Seller ed Installer?
                        System.debug('XC_SC060 D&I ParentWorkOrder null - seller & installer ' + mapWODI.get(wo.id));
                        result.put(wo.Id, mapWODI.get(wo.Id).XC_Configuration__r.NE__OptyId__r.CreatedBy.AccountId);
                    }else {
                        //Account su opportunity ha partner Associato?
                       	System.debug('XC_SC060 D&I ParentWorkOrder null - partner associato ' + mapWODI.get(wo.id));
                        result.put(wo.Id, mapWODI.get(wo.Id).XC_Configuration__r.NE__OptyId__r.CreatedBy.Account.XC_Technical_Service_Partner__c);
                    }
				}
			}
		}

        //Logic for site inspection
        if(!mapWOSI.isEmpty()){
            for(Id wo : mapWOSI.keySet()){
                if(mapWOSI.get(wo).ParentWorkOrder.Id != null){
                    System.debug('XC_SC060 SI - ParentWorkOrder popolato ' +  mapWOSI.get(wo).ParentWorkOrder.Id);
                    //Account su opportunity ? Seller ed Installer?
                    if (mapWOSI.get(wo).ParentWorkOrder.XC_Configuration__r.NE__OptyId__r.CreatedBy.Account.XC_Technical_Service__c) {
                        System.debug('XC_SC060 SI ParentWorkOrder popolato -  seller & installer ' + mapWOSI.get(wo));
                        result.put(wo, mapWOSI.get(wo).ParentWorkOrder.XC_Configuration__r.NE__OptyId__r.CreatedBy.AccountId);
                    }else {
                        //Account su opportunity ha partner Associato?
                        System.debug('XC_SC060 SI ParentWorkOrder popolato -  partner associato ' + mapWOSI.get(wo));
                        result.put(wo, mapWOSI.get(wo).ParentWorkOrder.XC_Configuration__r.NE__OptyId__r.CreatedBy.Account.XC_Technical_Service_Partner__c);
                    }
                }else{
                    System.debug('XC_SC060 SI - ParentWorkOrder null ');
                    //Account su opportunity ? Seller ed Installer?
                    if (mapWOSI.get(wo).XC_Configuration__r.NE__OptyId__r.CreatedBy.Account.XC_Technical_Service__c) {
                         System.debug('XC_SC060 SI ParentWorkOrder null -  seller & installer ' + mapWOSI.get(wo));
                        result.put(wo, mapWOSI.get(wo).XC_Configuration__r.NE__OptyId__r.CreatedBy.AccountId);
                    }else{
                        //Account su opportunity ha partner Associato?
                         System.debug('XC_SC060 SI ParentWorkOrder null - partner associato' + mapWOSI.get(wo));
                        result.put(wo, mapWOSI.get(wo).XC_Configuration__r.NE__OptyId__r.CreatedBy.Account.XC_Technical_Service_Partner__c);
                    }
                }
            }
        }
        return result;
    }

	/**
     * @description method to retrieve the manager Service Resource from each Partner Account
	 * @param listAccounts - List of partners' Account 
     * @return result - map where key is account id and value is its ServiceResource manager associated
     */
    public static Map<Id, ServiceResource> getManagerFromAccount(List<Account> accountSaturation, List<Id> accountDirectEle){
        Map<Id, ServiceResource> result = new Map<Id, ServiceResource>();
		
		List<Id> listAccIds = XC_UTIL_Sobject.getIds(accountSaturation);
        for(Id accId : accountDirectEle){
            if(accId != null){
                listAccIds.add(accId);
            }
        }
        System.debug('listAccIds ' +listAccIds);
		Map<Id,ServiceResource> mapServiceResource = new Map<Id,ServiceResource> ([SELECT id, XC_Account__c FROM ServiceResource WHERE XC_IsManager__c = true AND XC_Account__c IN : listAccIds AND ResourceType ='T' AND XC_AccountStatus__c ='Active' AND XC_Is_Contract_Active__c = true AND IsCapacityBased=true ]);
		System.debug('XC_SC060 mapServiceResource ' + mapServiceResource);
        
		for(Id srId : mapServiceResource.keySet()){
			result.put(mapServiceResource.get(srId).XC_Account__c, mapServiceResource.get(srId));
		}
        return result;
    }

    /**
     * @param woId Id of WorkOrder where set preferences
     * @param srManager Srvice Resource to set in preference
     * @return true if operation sucessfullu ended
     */
    public static Boolean setServiceResourcePreference(Id woId, ServiceResource srManager){
        Boolean isOk = true;

        ResourcePreference newPreference = new ResourcePreference();
        newPreference.RelatedRecordId = woId;
        newPreference.ServiceResourceId = srManager.Id;
        newPreference.PreferenceType  = 'Required';
        XC_UTIL_Sobject.WrapperResult insertRequiredWrapper = XC_UTIL_Sobject.insertRecord(newPreference);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Insert Resource Preference -> ' + insertRequiredWrapper);
        if(!insertRequiredWrapper.success) {
            isOk = false;
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Error Inserting Resource Preference -> ' + insertRequiredWrapper.errorMessage);
        }

        return isOk;
    }

    /**
     * @param accountSaturation
     * @param accountDirectEle
     *
     * @return map where key is accountId and value serviceResource list related
     */
    public static Map<Id, List<ServiceResource>> getServiceResourcesFromAccount(List<Account> accountSaturation, List<Id> accountDirectEle){

        List<Id> listAccIds = XC_UTIL_Sobject.getIds(accountSaturation);
        for(Id accId : accountDirectEle){
            if(accId != null){
                listAccIds.add(accId);
            }
        }

        List<ServiceResource> srList = [SELECT ID,XC_Account__c from ServiceResource WHERE XC_Account__c IN :listAccIds AND IsActive = true AND ResourceType != 'D'];

        Map<ID, List<ServiceResource>> mapSr = new Map<Id, List<ServiceResource>>();

        for(ServiceResource sr : srList){
            if(mapSr.get(sr.XC_Account__c) != null){
                mapSr.get(sr.XC_Account__c).add(sr);
            }else{
                List<ServiceResource> listSr = new List<ServiceResource>();
                listSr.add(sr);
                mapSr.put(sr.XC_Account__c, listSr);
            }
        }
        return mapSr;
    }


    /**
     * @param woList list of work order
     * @param mapSr Map where key is account partner id and value is List of ServiceResource associated
     *
     * @return
     */
    public static void setResourcePreferenceForScheduledWorkOrder(List<WorkOrder> woList, Map<Id, List<ServiceResource>> mapSr){
        List<WorkOrder> updatedWoList = [SELECT Id, XC_AssignedPartner__c FROM WorkOrder WHERE Id IN :woList];
        
        List<ResourcePreference> resPreList = new List<ResourcePreference>();
        for(WorkOrder wo : updatedWoList){
            System.debug('wo.XC_AssignedPartner__c: ' + wo.XC_AssignedPartner__c);
            if(wo.XC_AssignedPartner__c != null) {
                System.debug('XC_AssignedPartner__c not null: ' + wo.XC_AssignedPartner__c);
                List<ServiceResource> listSr = mapSr.get(wo.XC_AssignedPartner__c);
                if (!listSr.isEmpty()) {
                    System.debug('listSr not empty: ' + listSr);
                    for (ServiceResource sr : listSr) {
                        ResourcePreference newPreference = new ResourcePreference();
                        newPreference.RelatedRecordId = wo.Id;
                        newPreference.ServiceResourceId = sr.Id;
                        newPreference.PreferenceType = 'Required';
                        resPreList.add(newPreference);
                    }
                }
            }
        }
        System.debug('Inserting ResourcePreference: ' + resPreList);
        List<XC_UTIL_Sobject.WrapperResult> insertRequiredWrapper = XC_UTIL_Sobject.insertListRecords(resPreList);
    }


        /**
         * @param woIdList list Id of WorkOrder where clear preferences
         * @return true if operation sucessfullu ended
         */
    public static Boolean clearResourcePreference(List<Id> woIdList){
        Boolean isOk = true;
        List<ResourcePreference> listResourcePreference = new List<ResourcePreference>([
                SELECT Id
                FROM ResourcePreference
                WHERE RelatedRecordId IN :woIdList
        ]);
        System.debug('Deleting ResourcePreference: ' + listResourcePreference);
        if(!listResourcePreference.isEmpty()) {
            List<XC_UTIL_Sobject.WrapperResult> lisrResDeleteWrapper = XC_UTIL_Sobject.deleteListRecords(listResourcePreference);
            if(!XC_UTIL_Sobject.checkDMLResults(lisrResDeleteWrapper)) {
                isOk = false;
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Error Deleting Resource Preference -> ' + lisrResDeleteWrapper);

            }
        }

        return isOk;
    }

    /**
     * @param sa: ServiceAppointment to schedule appointment (is required from FLS api)
     * @param policy: policy for the country
     * @param operatingHours: OperatingHours associated to country
     * @return return the first slot available
     */
    private static XC_UTIL_Schedule.Slot getSlot(ServiceAppointment sa, FSL__Scheduling_Policy__c policy, OperatingHours operatingHours){
        TimeZone timeZone = UserInfo.getTimeZone();
        if(Test.isRunningTest()){            
            XC_UTIL_Schedule.Slot slot = new XC_UTIL_Schedule.Slot();
            XC_UTIL_Schedule.Interval interval = new XC_UTIL_Schedule.Interval(System.now(), System.now().addHours(1)); 
            slot.interval = interval; 
            return slot;
        }
        System.debug('XC_SC060 '+ sa.Id +' ' + policy +  ' ' +   operatingHours + ' ' + timezone);
        datetime qryStart = datetime.now(); 
        List<FSL.AppointmentBookingSlot> slotsFSL = FSL.AppointmentBookingService.GetSlots(
                sa.Id,
                policy.Id,
                operatingHours,
                timezone,
                false
        );
		datetime qryEnd = datetime.now(); 

        List<XC_UTIL_Schedule.Slot> slotList = new List<XC_UTIL_Schedule.Slot>();
        slotList = XC_UTIL_Schedule.manageSlotsFSL(slotsFSL);

        if(slotList.size() > 0){
            return slotList[0];
        }else{
            return null;
        }

    }

    /**
     * @param wo to check first date product available
     * @param accountPartnerIdList list of accountId
     * @return the first date available
     */
    public static Date getAvailableDate(WorkOrder wo, List<Id> accountPartnerIdList){
        XC_UTIL_EligibleServiceResource.EligibleWrapper eligibleWrapper = new XC_UTIL_EligibleServiceResource.EligibleWrapper();
        eligibleWrapper = XC_UTIL_EligibleServiceResource.checkAvailabilityOnAutoSchedule(wo.Id, wo.XC_FSLAssignmentKey__c, wo.WorkTypeId, accountPartnerIdList, true);
        return eligibleWrapper.availabilityDate;
    }

    /**
    *  @param wo WorkOrder to set as manual
     * @return WorkOrder modified but not persisted yet
    */
    public static WorkOrder setWordOrderAsManual(WorkOrder wo){
        wo.XC_To_Be_Manually_Assigned__c = true;
        wo.XC_StatusReason__c = Label.XC_CL_StatusReason_ToBeScheduled;
        return wo;
    }

    /**
     * @param sa ServiceAppointment previously created
     * @param policy policy related to the country
     * @param operatingHours OperatingHours for country of WorkOrder
     * @return true if scheduled is ok, false otherwise
     */
    public static Boolean scheduleServiceAppointment(ServiceAppointment sa, FSL__Scheduling_Policy__c policy, OperatingHours operatingHours) {
        // *** DO NOT SOQL IN THIS METHOD***
        Boolean isOk = false;
        XC_UTIL_Schedule.Slot slot = getSlot(sa, policy, operatingHours);

        if(slot != null) {
            System.debug('BeforeUpdate sa ' + sa);
        
            datetime qryStart = datetime.now();
			FSL.ScheduleResult scheduleResult = FSL.ScheduleService.Schedule(policy.Id, sa.Id);
            if(scheduleResult !=null){
                if( scheduleResult.Service != null){
                    isOk = true;
                }
            }
            datetime qryEnd = datetime.now(); 
			system.debug('EXECUTION TIME FSL SCHEDULE: ' + (qryEnd.getTime() - qryStart.getTime()));

        }

        return isOk;
    }

    /**
     * @param listWo list of WorkOrder to get relative ServiceAppointment for each Account involved
     * @param directElegibilityList map where key is WorkIrder Id and Value the Id of directly elegible account
     * @param metadataMap map of XC_CM_Scheduling_Default_Value__mdt for country
     * @param accountForSaturation Ordered list of all account involved in Saturation
     *
     * @return A map where key is WorkOrder ID and value is a map where key is Account Id and value is ServiceAppointment
     */
    /*public static Map<Id, Map<Id, ServiceAppointment>> getServiceAppointmentsFromWorkOrder_OLD(List<WorkOrder> listWo, Map<Id, Id> directElegibilityList,Map<String,XC_CM_Scheduling_Default_Value__mdt> metadataMap, List<Account> accountForSaturation ){
        //fare attenzione al caso elegibilit? ma anche al caso semplice, cio? quando un WO ha direttamente il partner
        Map<Id, Map<Id, ServiceAppointment>> mapServiceAppointment = new Map<Id, Map<Id, ServiceAppointment>>();
        List<ServiceAppointment> saList = new List<ServiceAppointment>();

        for (WorkOrder wo : listWo) {
            //caso di NON saturazione -> elegibilit? diretta
            if(directElegibilityList.get(wo.Id) != null) {
                ServiceAppointment sa = XC_UTIL_ServiceAppointment.populateServiceAppointmentFromWorkOrder(wo);
                sa.XC_AssignToPartner__c = true;

                Id idAccountPartner = directElegibilityList.get(wo.Id);

                Boolean doCheckAvailability = wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation || wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Repair;

                if (metadataMap.get(wo.XC_Country__c.toUpperCase()).XC_Use_Glovia__c && doCheckAvailability) {
                    Date firstAvailableDate = getAvailableDate(wo, idAccountPartner);
                    sa.EarliestStartTime = firstAvailableDate;
                }

                if (wo.XC_WorkTypeCategory__c != Label.XC_CL_WorkType_Repair) {
                    Integer n = Integer.valueOf(metadataMap.get(wo.XC_Country__c.toUpperCase()).XC_Days_for_Due_Date__c);
                    sa.DueDate = XC_UTIL_Schedule_D.getDueDate(Date.today(), n);
                }

                Map<Id, ServiceAppointment> m = new Map<Id, ServiceAppointment>();
                m.put(idAccountPartner, sa);
                mapServiceAppointment.put( wo.Id, m);
                saList.add(sa);
            }else{
                Map<Id, ServiceAppointment> m = new Map<Id, ServiceAppointment>();
                for(Account acc : accountForSaturation){
                    ServiceAppointment sa = XC_UTIL_ServiceAppointment.populateServiceAppointmentFromWorkOrder(wo);
                    sa.XC_AssignToPartner__c = true;

                    Id idAccountPartner = acc.Id;
                    if (metadataMap.get(wo.XC_Country__c.toUpperCase()).XC_Use_Glovia__c) {
                        Date firstAvailableDate = getAvailableDate(wo, idAccountPartner);
                        sa.EarliestStartTime = firstAvailableDate;
                    }

                    if (wo.XC_WorkTypeCategory__c != Label.XC_CL_WorkType_Repair) {
                        Integer n = Integer.valueOf(metadataMap.get(wo.XC_Country__c.toUpperCase()).XC_Days_for_Due_Date__c);
                        sa.DueDate = XC_UTIL_Schedule_D.getDueDate(Date.today(), n);
                    }

                    m.put(idAccountPartner, sa);
                    saList.add(sa);
                }
                mapServiceAppointment.put(wo.Id, m);
            }
        }
        XC_UTIL_Sobject.insertListRecords(saList);
        return mapServiceAppointment;
    }*/
    
    /**
     * @param listWo list of WorkOrder to get relative ServiceAppointment for each Account involved
     * @param directElegibilityList map where key is WorkIrder Id and Value the Id of directly elegible account
     * @param metadataMap map of XC_CM_Scheduling_Default_Value__mdt for country
     * @param accountForSaturation Ordered list of all account involved in Saturation
     *
     * @return A map where key is WorkOrder ID and value is ServiceAppointment
     */
    public static Map<Id, ServiceAppointment> getServiceAppointmentsFromWorkOrder(List<WorkOrder> listWo, Map<Id, Id> directElegibilityList,Map<String,XC_CM_Scheduling_Default_Value__mdt> metadataMap, List<Account> accountForSaturation ){
        //fare attenzione al caso elegibilit? ma anche al caso semplice, cio? quando un WO ha direttamente il partner
        Map<Id, ServiceAppointment> mapServiceAppointment = new  Map<Id, ServiceAppointment>();
         List<ServiceAppointment> saList = new List<ServiceAppointment>();

        for (WorkOrder wo : listWo) {
            ServiceAppointment sa = XC_UTIL_ServiceAppointment.populateServiceAppointmentFromWorkOrder(wo);
            sa.XC_AssignToPartner__c = true;
            sa.XC_StatusReason__c = Label.XC_CL_StatusReason_ToBeScheduled;
            //caso di NON saturazione -> elegibilit? diretta
            if(directElegibilityList.get(wo.Id) != null) {

                Id idAccountPartner = directElegibilityList.get(wo.Id);

                Boolean doCheckAvailability = wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation ;

                if (metadataMap.get(wo.Country.toUpperCase()).XC_Use_Glovia__c && doCheckAvailability) {
                    List<String> listAccountPartner = new List<String>();
                    listAccountPartner.add(idAccountPartner);
                    Date firstAvailableDate = getAvailableDate(wo, listAccountPartner);
                    sa.EarliestStartTime = firstAvailableDate;
                }
            }else{
                Boolean doCheckAvailability = wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation;

                if (metadataMap.get(wo.Country.toUpperCase()).XC_Use_Glovia__c && doCheckAvailability) {
                    Date firstAvailableDate = getAvailableDate(wo, XC_UTIL_Sobject.getIds(accountForSaturation));
                    sa.EarliestStartTime = firstAvailableDate;
                }
            }

            if (wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Repair) {
                Integer n = Integer.valueOf(metadataMap.get(wo.Country.toUpperCase()).XC_Days_for_Due_Date__c);
                sa.DueDate = XC_UTIL_Schedule_D.getDueDate(Date.today(), n);
            }

            mapServiceAppointment.put(wo.Id, sa);
            saList.add(sa);
        }
        System.debug('BeforeInsert sa ' + saList);
        XC_UTIL_Sobject.insertListRecords(saList);
        return mapServiceAppointment;
    }

    /**
     * @param listWo list od WorkOrder where delete ServiceAppointment previously created to avoid exceed Governor Limit
     * @param woServiceAppointmentMap A map where key is WorkOrder ID and value is a map where key is Account Id and value is ServiceAppointment
     */
    public static void deleteServiceAppointNotUsed(List<WorkOrder> listWo, Map<Id, ServiceAppointment> woServiceAppointmentMap){
        Map<Id, ServiceAppointment> untouchable = getServiceAppointmentsScheduledFromWo(listWo);
        List<ServiceAppointment> saToDelete = new List<ServiceAppointment>();
        List<ServiceAppointment> saToUpdate = new List<ServiceAppointment>();

        for(WorkOrder wo : listWo){
            ServiceAppointment sa = woServiceAppointmentMap.get(wo.Id);
			System.debug('To check ' + sa);
            if(untouchable.get(wo.Id) == null){
                System.debug('To delete ' + sa);
                saToDelete.add(sa); 
            }else{
                System.debug('SA untouchable '+ sa);
            }
        }
        List<Id> saId =  XC_UTIL_SObject.getIds(untouchable.values());
        List<ServiceAppointment> newAppointment = [SELECT Id, XC_StatusReason__c, EarliestStartTime FROM ServiceAppointment WHERE id IN: saId];
        for(ServiceAppointment serviceApp : newAppointment ){
            serviceApp.XC_StatusReason__c = Label.XC_CL_StatusReason_ToBeScheduled;
            saToUpdate.add(serviceApp);
        }

        if(!saToDelete.isEmpty()){
            XC_UTIL_Sobject.deleteListRecords(saToDelete);
        }
        //set XC_StatusReason__c to XC_CL_StatusReason_ToBeScheduled
        if(!saToUpdate.isEmpty()){
            XC_UTIL_Sobject.updateListRecords(saToUpdate);
        }
    }

    /**
     * @param listWo list of WorkOrder to get related (and already scheduled) Service Appointment
     *
     * @return a map where key is WorkOrder id, and value is ServiceAppointment
     */
    private static Map<Id, ServiceAppointment> getServiceAppointmentsScheduledFromWo(List<WorkOrder> listWo){
        Map<Id, ServiceAppointment> result = new Map<Id, ServiceAppointment>();
        List<ID> listIdWo = XC_UTIL_Sobject.getIds(listWo);

        List<ServiceAppointment> listSa = [SELECT ID,ParentRecordId FROM ServiceAppointment WHERE ParentRecordId IN :listIdWo and Status='Scheduled'];

        for(ServiceAppointment sa : listSa){
            result.put(sa.ParentRecordId, sa);
        }

        return result;
    }

    /**
     * @param listWo list of WorkOrder to get relative custom metadata based on country
     *
     * @return return a map where Id is country String and value is XC_CM_Scheduling_Default_Value__mdt
     */
    public static Map<String,XC_CM_Scheduling_Default_Value__mdt> getMetadataFromWorkOrder(List<WorkOrder> listWo){

        Map<String,XC_CM_Scheduling_Default_Value__mdt> mapMetadata = new Map<String,XC_CM_Scheduling_Default_Value__mdt>();
        Set<String> countrySet = new Set<String>();

        for(WorkOrder wo : listWo){
            String country= wo.Country;
            countrySet.add(country.toUpperCase());
        }

        List<XC_CM_Scheduling_Default_Value__mdt> listMetadata = new List<XC_CM_Scheduling_Default_Value__mdt>();
        listMetadata = [SELECT XC_Country__c,XC_Days_for_Due_Date__c, XC_Operating_Hours_Name__c, XC_Policy_Name__c,XC_Policy_Name_NoAvailability__c,XC_Use_Glovia__c,XC_Policy_Name_Autoschedule__c,XC_Allow_Assignment_By_Saturation__c
        FROM XC_CM_Scheduling_Default_Value__mdt
        WHERE XC_Country__c in :countrySet];

        for(XC_CM_Scheduling_Default_Value__mdt item : listMetadata){
            mapMetadata.put(item.XC_Country__c, item);
        }

        return mapMetadata;
    }

    /**
     * @param listMtd list of XC_CM_Scheduling_Default_Value__mdt
     *
     * @return a map where key is OperatingHours name and value is OperatingHours object
     */
    public static Map<String, OperatingHours> getOperatingHoursMapFromMetadataList(List<XC_CM_Scheduling_Default_Value__mdt> listMtd){
        Map<String, OperatingHours> operatingHoursMap = new Map<String, OperatingHours>();

        for(XC_CM_Scheduling_Default_Value__mdt mtd : listMtd){
            if(operatingHoursMap.get(mtd.XC_Operating_Hours_Name__c) == null) {
                OperatingHours operatingHours = XC_UTIL_Schedule_D.getOperatingHoursByName(mtd.XC_Operating_Hours_Name__c);
                operatingHoursMap.put(mtd.XC_Operating_Hours_Name__c, operatingHours);
            }
        }

        return operatingHoursMap;
    }
    
    /**
     * @param listMtd list of XC_CM_Scheduling_Default_Value__mdt
     *
     * @return a map where key is OperatingHours name and value is OperatingHours object
     */
    public static Map<String, FSL__Scheduling_Policy__c> getPolicyFromMetadataList(List<XC_CM_Scheduling_Default_Value__mdt> listMtd){
        Map<String, FSL__Scheduling_Policy__c> policyMap = new  Map<String, FSL__Scheduling_Policy__c>();

        for(XC_CM_Scheduling_Default_Value__mdt mtd : listMtd){
            if(policyMap.get(mtd.XC_Policy_Name_Autoschedule__c) == null) {
                FSL__Scheduling_Policy__c  policy = XC_UTIL_Schedule_D.getPolicy(mtd.XC_Policy_Name_Autoschedule__c);
                policyMap.put(mtd.XC_Policy_Name_Autoschedule__c, policy);
            }
        }

        return policyMap;
    }

    public static void setWorkOrderAsManuallyAssigned(List<WorkOrder> listWo){
        List<WorkOrder> woToUpdate = new List<WorkOrder>();
        for(WorkOrder wo : listWo){
            if(wo.XC_To_Be_Manually_Assigned__c){
                woToUpdate.add(wo);
            }
        }
        if(!woToUpdate.isEmpty()){
            XC_UTIL_Sobject.updateListRecords(woToUpdate);
        }
    }

}