public without sharing class XC_IN065_PPM_InsertFSLWO {
    
    public class InputWrapper {       
        @Invocablevariable
        public String taskId;
        
        @Invocablevariable
        public String AssetId;
        
        @Invocablevariable
        public String City;
        
        @Invocablevariable
        public String ContactId;
        
        @Invocablevariable
        public String Country;
        
        @Invocablevariable
        public String OwnerId;
        
        @Invocablevariable
        public String ParentWorkOrderId;
        
        @Invocablevariable
        public String PostalCode;
        
        @Invocablevariable
        public String RecordTypeId;
        
        @Invocablevariable
        public String Street;
        
        @Invocablevariable
        public String Address;
        
        @Invocablevariable
        public String Configuration;
        
        @Invocablevariable
        public Date DueDate;
        
        @Invocablevariable
        public String LegalEntity;
        
        @Invocablevariable
        public String Opportunity;
        
        @Invocablevariable
        public String PreferredPartner;
        
        @Invocablevariable
        public String ProjectTask;
        
        @Invocablevariable
        public Boolean ToProject;
        
        @Invocablevariable
        public String WorkTypeCategory;
    }
    
	@InvocableMethod
    public static List<String> createWO(List<InputWrapper> inputWrapperList) {
        if(inputWrapperList == null || inputWrapperList.isEmpty()){
            return null;
        }
    	List<WorkOrder> woList = new List<WorkOrder>();
        project_cloud__Project_Task__c pTask = [select id, XC_Message__c, XC_TaskStatus__c from project_cloud__Project_Task__c where id = :inputWrapperList[0].taskId]; 
        
        for(InputWrapper wr : inputWrapperList){
            WorkOrder wo = new WorkOrder();
            	wo.AssetId = wr.AssetId;
                wo.City = wr.City;
                wo.ContactId = wr.ContactId;
                wo.Country = wr.Country;
                wo.OwnerId = wr.OwnerId;
                wo.ParentWorkOrderId = wr.ParentWorkOrderId;
                wo.PostalCode = wr.PostalCode;
                wo.RecordTypeId = wr.RecordTypeId;
                wo.Street = wr.Street;
                wo.XC_Address__c = wr.Address.length() == 0 ? null : wr.Address;
                wo.XC_Configuration__c = wr.Configuration;
                wo.XC_DueDate__c = wr.DueDate;
                wo.XC_LegalEntity__c = wr.LegalEntity;
                wo.XC_Opportunity__c = wr.Opportunity;
                wo.XC_PreferredPartner__c = wr.PreferredPartner;
                wo.XC_Project_Task__c = wr.ProjectTask;
                wo.XC_ToProject__c = wr.ToProject;
                wo.XC_WorkTypeCategory__c = wr.WorkTypeCategory;
			woList.add(wo);            
        }
        
        List<XC_UTIL_Sobject.WrapperResult> wrList = XC_UTIL_Sobject.insertListRecords(woList);
        if(!wrList.isEmpty()){
            if(!wrList[0].success){
                pTask.XC_TaskStatus__c = 'Suspended';
                pTask.XC_Message__c = wrList[0].errorMessage;
                update pTask;
                return null;
            }
            else{
                List<WorkOrder> woQuery = [select id, XC_WorkTypeLabel__c, WorkTypeId from WorkOrder where id = :wrList[0].recordId];
                if(!woQuery.isEmpty()){
                    if(woQuery[0].XC_WorkTypeLabel__c == null){
                        pTask.XC_TaskStatus__c = 'Suspended';
                        pTask.XC_Message__c = Label.XC_CL_NoWorkTypeLabel;
                        update pTask;
                        delete woQuery;
                        return null;
                    }	 
                }             
            }
            pTask.XC_Message__c = null;
            update pTask;
            return  new List<String>{woList[0].Id};
        }
		pTask.XC_Message__c = null;
        update pTask;        
        return  new List<String>{woList[0].Id};
        
    }
}