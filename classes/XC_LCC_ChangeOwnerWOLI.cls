public class XC_LCC_ChangeOwnerWOLI {

	public class WrapperResult{
        @AuraEnabled
        public Boolean errorResult;
        @AuraEnabled
        public String errorMessage;

        public WrapperResult(){
            errorResult = false;
            errorMessage = '';
        }
    }
    
    /**
     * Description
     * @param recordId id
     * @returns WrapperResult
     */
    @AuraEnabled
    public static WrapperResult changeOwner(String recId, String userId){
        WrapperResult wr = new WrapperResult();
        
        try{                      
            Id recordId = (Id)recId;
            Id uId = (Id)userId;
            updateWOLI(recordId, uId);  
            wr.errorMessage = 'Ownership changed.';
        } catch(Exception e) {
            wr.errorMessage = 'Error: '+e+' for record Id: '+recId;
            wr.errorResult = true;
        }
        
        return wr;
    }
    
    /**
     * Description
     * @param recordId id, userId id
     * @returns void
     */
    private static void updateWOLI(Id woId, Id userId){
        
        List<SObject> sobjs = new List<SObject>();
        
        SObject sobj = woId.getSObjectType().newSObject(woId);
        
        if(sobj instanceof WorkOrder){
            WorkOrder wo = new WorkOrder(Id=woId);
            wo.OwnerId = userId;
            
            sobjs.add(wo);
            
            List<WorkOrderLineItem> wolis = [SELECT id, XC_OwnerWorkOrder__c FROM WorkOrderLineItem WHERE WorkOrderId = :woId];
            
            for(WorkOrderLineItem woli : wolis){
                woli.XC_OwnerWorkOrder__c = userId;
                sobjs.add(woli);
            }
            
            sobjs.sort();
            update sobjs;
            
            //TODO Query sui WOLI - XC_OwnerWorkOrder__c (campo tecnico) v
            //aggiornare WO sul campo ownerId v
            //mettere in una lista di sobj v
            //ordinare la lista
            //update
        }
    }
}