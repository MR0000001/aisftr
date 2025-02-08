public with sharing class XC_TR_CloseLclCase {

	public static void closeWoli(List<Case> listNew, Map<Id, Case> mapOld, Map<Id, Case> mapNew){
		system.debug('DL*** closewoli' );

        List<String> fieldList = new List<String>{'Status'};
        List<Case> caseToConsider = new List<Case>();
        List<Case> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
		system.debug('DL*** listChanged' + listChanged);
		List<String> listWoli = XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_WorkOrderLineItem__c');
		         if(!listChanged.isEmpty()){
             for(Case c : listChanged){
                 if( c.Status == 'ESTA007' && !String.isEmpty(c.XC_WorkOrderLineItem__c)){
					 caseToConsider.add(c);
					 system.debug('DL*** caseToConsider' + caseToConsider );                  
                 }
             }
             
         }
		 List<WorkOrderLineItem> woliForWoList =[SELECT id, WorkOrderId FROM Workorderlineitem where id in: listWoli];
	//NA service appointment managemment
	  Map<Id,ServiceAppointment> mapServiceAppoitment=new  Map<Id,ServiceAppointment>(); 
	  mapServiceAppoitment=retrieveSAmap(woliForWoList);
    //WorkorderLineItem woToClose = new WorkorderLineItem();
    //woToClose = [SELECT Id,WorkOrderId FROM WorkorderLineItem where id in: c.XC_WorkOrderLineItem__c];
		 
	List<Workorderlineitem> woliToUpdate = new List<Workorderlineitem>();
	List<Workorder> woToUpdate = new List<Workorder>();
	List<ServiceAppointment> saToUpdate=new List<ServiceAppointment>(); 	 	 
	 for(Case c : caseToConsider){
		 Workorderlineitem woli = new Workorderlineitem(Id = c.XC_WorkOrderLineItem__c);
		 //id woId =  c.XC_WorkOrderLineItem__r.WorkOrderId;

		 //Workorder wo = new Workorder(id = woli.WorkOrderId);
		 Workorder wo = new Workorder();
		 ServiceAppointment sa=new ServiceAppointment(); 
		 //system.debug('DL***  wo' +  wo);
		 wo.id= woliForWoList[0].WorkOrderId;
		 system.debug('DL***  wo' +  wo);
		 if( c.Status == 'ESTA007' && c.SubCause__c == 'ATCL115'){
			 woli.XC_StatusReason__c='Suspended';
			 wo.status='On Hold';
			 wo.XC_ReasonforSuspension__c ='LCL Suspended';
			  wo.XC_Notesforsuspensionandresolution__c='LCL Suspended';
             woli.XC_SuspensionDate__c = c.XC_SuspensionDate__c;
			 			 if(mapServiceAppoitment.get(woliForWoList[0].WorkOrderId)!=null){
				sa=mapServiceAppoitment.get(woliForWoList[0].WorkOrderId);
				sa.XC_Notesforsuspensionandresolution__c='LCL Suspended';
				sa.XC_ReasonforSuspension__c='LCL Suspended';
				saToUpdate.add(sa);
				system.debug('NA****ServiceAppointment Note'+sa.XC_Notesforsuspensionandresolution__c);
			 }
			 system.debug('DL***  c.Status' +  c.Status +  woli.XC_StatusReason__c + wo.status);
		 }
		 else if( c.Status == 'ESTA007' && c.SubCause__c == 'ATCL116'){
			woli.XC_StatusReason__c='Reactivated';

			wo.status='On Hold';
			wo.XC_ReasonforSuspension__c ='LCL Reactivated';
			wo.XC_Notesforsuspensionandresolution__c='LCL Reactivated';

			c.XC_LcLsuspended__c=true;
            woli.XC_DataRipresaLavori__c= c.XC_DataRipresaLavori__c;
			system.debug('DL***  c.Status' +  c.Status +  woli.XC_StatusReason__c + wo.status);
		}
		else if( c.Status == 'ESTA007' && c.SubCause__c == 'ATCL117'){
			woli.XC_StatusReason__c='Extended';
		/*	wo.status='On Hold';
			wo.XC_ReasonforSuspension__c ='LCL Extended';
			wo.XC_Notesforsuspensionandresolution__c='LCL Extended';
            woli.enddate = c.XC_DataPropoga__c;
			if(mapServiceAppoitment.get(woliForWoList[0].WorkOrderId)!=null){
				sa=mapServiceAppoitment.get(woliForWoList[0].WorkOrderId);
				sa.XC_Notesforsuspensionandresolution__c='LCL Extended';
				sa.XC_ReasonforSuspension__c='LCL Extended';
				saToUpdate.add(sa);
				system.debug('NA****ServiceAppointment Note'+sa.XC_Notesforsuspensionandresolution__c);
			 }
			system.debug('DL***  c.Status' +  c.Status +  woli.XC_StatusReason__c + wo.status);*/
		}
		woliToUpdate.add(woli);
		woToUpdate.add(wo);
		system.debug('DL*** woliToUpdate' + woliToUpdate + woToUpdate );
	 }
	 
           if(!saToUpdate.isEmpty()){
		     update saToUpdate; 	 
		 }
		 XC_UTIL_Sobject.updateListRecords(woliToUpdate);
		 XC_UTIL_Sobject.updateListRecords(woToUpdate);
   }
       private static map<id,ServiceAppointment> retrieveSAmap(List<WorkOrderLineItem> woliForWoList){
		List<id> WorkOrderListId=new List<id>(); 
		system.debug('enter method retrieve map service appointment');
		Map<id,ServiceAppointment> mapServiceAppoitment=new Map<id,ServiceAppointment>();
		for(WorkOrderLineItem woli:woliForWoList){
			WorkOrderListId.add(woli.WorkOrderId);
			system.debug('id workorder');
		 }
		 List<ServiceAppointment> saList=[select id,ParentRecordId,XC_Notesforsuspensionandresolution__c,XC_NotesforResolution__c,XC_ReasonforSuspension__c
		                                     from ServiceAppointment
		                                    where (ParentRecordId IN:WorkOrderListId  and 
											         status!='Completed' and 
											         status!='Canceled'
											       )];
	      system.debug('sa List '+saList); 											   
		for(ServiceAppointment sa:saList){
			system.debug('service appointment');
			mapServiceAppoitment.put(sa.ParentRecordId,sa);
		}										   
         return mapServiceAppoitment;
	 }

}