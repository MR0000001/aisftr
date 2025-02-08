/**
 * @description       : 
 * @author            : benjamin.geronimo
 * @group             : WebResults
 * @last modified on  : 19-08-2021
 * @last modified by  : benjamin.geronimo
**/
public class TA_LCC261_WorkOrderChildView {

    public class ObjectWrapper {
        @AuraEnabled
        public String objectName {get; set;}

        @AuraEnabled
        public String whereCondition {get; set;}

        @AuraEnabled
        public Boolean showSecondaryChild {get; set;}

        @AuraEnabled
        public Boolean readOnly {get; set;}

        @AuraEnabled
        public String errorMessage {get; set;}

        @AuraEnabled
        public List<WorkOrderWrapper> workOrderChilds {get; set;}        

        public ObjectWrapper() {}

        public ObjectWrapper(String objectName, String whereCondition, Boolean showSecondaryChild, Boolean readOnly, String errorMessage) {
            this.objectName = objectName;
            this.whereCondition = whereCondition;
            this.showSecondaryChild = showSecondaryChild;
            this.readOnly = readOnly;
            this.errorMessage = errorMessage;
            this.workOrderChilds = new List<WorkOrderWrapper>();
        }
    }

    public class WorkOrderWrapper{

        @AuraEnabled
        public String workOrderID;

        @AuraEnabled
        public String workOrderNumber;

        @AuraEnabled
        public String assetName;

        @AuraEnabled
        public String status;

        @AuraEnabled
        public Boolean editEnabled;
		
        @AuraEnabled
        public Boolean showSecondary;

        @AuraEnabled
        public List<WorkOrderWrapper> workOrderSecondary {get; set;}

        public WorkOrderWrapper() {}

        public WorkOrderWrapper(String workOrderID, String workOrderNumber, String assetName, String status, Boolean editEnabled, Boolean showSecondary) {
            this.workOrderID = workOrderID;
            this.workOrderNumber = workOrderNumber;
            this.assetName = assetName;
            this.status = status;
            this.editEnabled = editEnabled;
            this.showSecondary = showSecondary;
            this.workOrderSecondary = new List<WorkOrderWrapper>();
        }
    }
    
    /**
    * @description 
    * @author benjamin.geronimo | 18-08-2021 
    * @param workOrderId 
    * @param customFieldSet 
    * @return ObjectWrapper 
    **/
    @AuraEnabled
    public static ObjectWrapper getObjWrapper(String workOrderId, String customFieldSet) {
        system.debug('>_> workOrderId : ' + workOrderId);
        system.debug('>_> customFieldSet : ' + customFieldSet);

        ObjectWrapper objWrapper = new ObjectWrapper();

        try {

            if(customFieldSet == null || workOrderId == null) {
                CalloutException e = new CalloutException();
                e.setMessage('workOrderId and/or customFieldSet is null!');
                throw e;
            }

            Map<String, Object> deserializedJson = (Map<String,Object>) JSON.deserializeUntyped(customFieldSet);

            if(deserializedJson != null) {
                Map<String, Object> mapDetails = (Map<String, Object>) deserializedJson.get('details');

                if(mapDetails != null) {
                    objWrapper = new ObjectWrapper(String.valueOf(mapDetails.get('objectName')),
                            String.valueOf(mapDetails.get('whereCondition')),
                            Boolean.valueOf(mapDetails.get('showSecondaryChild')),
                            Boolean.valueOf(mapDetails.get('readOnly')),
                            '');
                }

                WorkOrder woParent = [SELECT TA_Phase__c FROM WorkOrder WHERE Id =: workOrderId LIMIT 1];

                String woChildQuery = 'SELECT Id, TA_Phase__c, WorkOrderNumber, Asset.NE__Bundle_element__c, Asset.NE__Bundle_element__r.Name, Asset.NE__Bundle_element__r.XC_MacroCategory__c, XC_Address__r.Name, Status, Asset.Name, XC_ProductSubType__c, XC_Conga_AssetProductName__c, Asset.NE__ProdId__r.NE__Part__c, XC_Configuration_Item__r.NE__Bundle_Configuration__c ';
                woChildQuery += ', (SELECT Id FROM WorkOrderLineItems) ';
                woChildQuery += 'FROM WorkOrder ';
                woChildQuery += 'WHERE ' +  objWrapper.whereCondition;

                system.debug('>_> woChildQuery : ' + woChildQuery);

                List<WorkOrder> wocMain = new List<WorkOrder>();
                List<WorkOrder> wocSecondary = new List<WorkOrder>();
                List<WorkOrder> wocToUpdate = new List<WorkOrder>();

                for(WorkOrder woc : Database.query(woChildQuery)){

                    // START FIX [ADC01/09/2021] ENXCRM-200
                    //If wo father is on Action phase -> put the child on Action_Child phase
                    /*if(woParent.TA_Phase__c == 'Action' && (woc.TA_Phase__c.contains('Action') || woc.TA_Phase__c.contains('PreService') || woc.TA_Phase__c == null)){
                        woc.TA_Phase__c = 'Action_Child';

                        //Logica di “completamento automatico” dei wo figli che non hanno woli
                        if(woc.WorkOrderLineItems.isEmpty()) {
                            woc.Status = 'Completed';
                            woc.TA_Phase__c = 'CheckOut_Complete';
                        }

                        wocToUpdate.add(woc);
                    }


                    if('Main'.equals(woc.Asset.NE__Bundle_element__r.XC_MacroCategory__c)){
                        wocMain.add(woc);
                    } else {
                        wocSecondary.add(woc);
                    }   */

                    // Se il WO padre è in Action imposto la fase dei figli Main in Action_Child, i secondary in Action_ChildSecondary
                    if('Main'.equals(woc.Asset.NE__Bundle_element__r.XC_MacroCategory__c)){
                        wocMain.add(woc);
                        if(woParent.TA_Phase__c == 'Action' && (woc.TA_Phase__c.contains('Action') || woc.TA_Phase__c.contains('PreService') || woc.TA_Phase__c == null)){
                            woc.TA_Phase__c = 'Action_Child';                            
                        }
                    } else {
                        wocSecondary.add(woc);
                        if(woParent.TA_Phase__c == 'Action' && (woc.TA_Phase__c.contains('Action') || woc.TA_Phase__c.contains('PreService') || woc.TA_Phase__c == null)){
                            woc.TA_Phase__c = 'Action_ChildSecondary';                            
                        }
                    }

                    //Logica di “completamento automatico” dei wo figli che non hanno woli
                    if(woc.WorkOrderLineItems.isEmpty() && woParent.TA_Phase__c == 'Action') {
                        woc.Status = 'Completed';
                        woc.TA_Phase__c = 'CheckOut_Complete';

                        //START FIX [20220221AL] - align status on wo child
                        woc.TA_UpdatedByApp__c = true;
                        woc.TA_CompletedByApp__c = true;
                        //END FIX [20220221AL] - align status on wo child
                    }

                    wocToUpdate.add(woc);
                    // END FIX [ADC01/09/2021] ENXCRM-200
                }

                List<WorkOrderWrapper> workOrderChilds = new List<WorkOrderWrapper>(); 

                if(!wocMain.isEmpty()){

                    for(WorkOrder wom : wocMain){

                        WorkOrderWrapper woc = new WorkOrderWrapper(
                            wom.Id, wom.WorkOrderNumber, wom.Asset.Name, wom.Status,  !'Completed'.equals(wom.Status), objWrapper.showSecondaryChild
                        );
                
                        //Relationship between wo principal and secondary
                        for(WorkOrder wos : wocSecondary){
                            /*if( (wos.Asset.NE__Bundle_element__c != null && wom.XC_Conga_AssetProductName__c == wos.XC_Conga_AssetProductName__c) 
                                || (wos.Asset.NE__Bundle_element__c == null && wom.Asset.NE__Bundle_element__r.Name	 == wos.Asset.NE__ProdId__r.NE__Part__c) )*/
                            if( (wos.XC_Configuration_Item__r.NE__Bundle_Configuration__c != null && wom.XC_Configuration_Item__r.NE__Bundle_Configuration__c == wos.XC_Configuration_Item__r.NE__Bundle_Configuration__c) 
                                || (wos.Asset.NE__Bundle_element__c == null && wom.Asset.NE__Bundle_element__r.Name	 == wos.Asset.NE__ProdId__r.NE__Part__c) )    
                            {
                                woc.workOrderSecondary.add(new WorkOrderWrapper(
                                    wos.Id, wos.WorkOrderNumber, wos.Asset.Name, wos.Status, !'Completed'.equals(wos.Status), objWrapper.showSecondaryChild
                                ));
                            }
                        }
            
                        workOrderChilds.add(woc);
                    }

                } else {

                    for(WorkOrder wo : wocSecondary){
                        WorkOrderWrapper woc = new WorkOrderWrapper(
                            wo.Id, wo.WorkOrderNumber, wo.Asset.Name, wo.Status,  !'Completed'.equals(wo.Status), objWrapper.showSecondaryChild
                        );
                        workOrderChilds.add(woc);
                    }
                }

                objWrapper.workOrderChilds = workOrderChilds;

                if(!wocToUpdate.isEmpty()){
                    update wocToUpdate;
                }

            }

        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC261_WorkOrderChildView] getObjWrapper - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC261_WorkOrderChildView', 'getObjWrapper', errorMessage, 0, errorMessage, null);
            objWrapper.errorMessage = errorMessage;
        }
            
        return objWrapper;
    }

}