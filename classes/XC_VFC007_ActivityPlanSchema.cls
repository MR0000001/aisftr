/**
 * @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
 * @date Creation 29/11/2018
 * @date Modification  dd/mm/yyyy
 * @description Controller for XC_VFP007_ActivityPlanSchema Visualforce Page
 */ 
public without sharing class XC_VFC007_ActivityPlanSchema {
    
    /**
     * @description The Class Step.
     */
    public class Step {        
        
        /** @description The name. */
        public String name {get; set;}  
        /** @description The seq order. */
        public Decimal seqOrder {get; set;}
        /** @description The mandatory previous steps. */
        public String mandatoryPreviousSteps {get; set;} 
        /** @description The code. */
        public String code {get; set;}
        /** @description The status. */
        public String status {get; set;} 
        
    }
    /** @description  The JSO nlist steps. */
    public transient String jSONlistSteps {get;set;}
  	/** @description  The myobj. */
	WorkOrder myobj {get;set;} 

	/**
	 * @description  Instantiates a new x C VFC 007 activity plan schema.
	 *
	 * @param controller the controller
	 */
	public XC_VFC007_ActivityPlanSchema(ApexPages.StandardController controller){
        myobj = (WorkOrder)controller.getRecord(); 
        jSONlistSteps = JSON.serialize(getStepsByOrderItem(myobj.Id)); 
    }
    
    /**
     * @description Gets the steps by order item.
     *
     * @param recordId the record id
     * @return the steps by order item
     */
     @TestVisible
    private List<Step> getStepsByOrderItem(Id recordId){
        
        List<Step> listSteps = new List<Step>();
        
		Map<Id, WorkOrderLineItem> listTStepsMap = new Map<Id, WorkOrderLineItem>
            ([SELECT Id, XC_ActivityName__c,XC_OrderOfActivity__c,Status 
                     FROM WorkOrderLineItem  
                     WHERE WorkOrderId  =: recordId order by XC_OrderOfActivity__c]);
        List<WorkOrderLineItem> listTSteps = listTStepsMap.values();              
        System.debug('The value of listTSteps is: ' + listTSteps);
        String activityName; 
        String code;
        
        for(WorkOrderLineItem s : listTSteps){
            if (s.XC_OrderOfActivity__c > 1) {
                integer numberOfActivity =integer.ValueOf(s.XC_OrderOfActivity__c-1);
                code = listTSteps[numberOfActivity].XC_ActivityName__c;
                activityName= listTSteps[numberOfActivity-1].XC_ActivityName__c;
                System.debug('The value IN IF of TYF is : ' + numberOfActivity);
                System.debug('The value IN IF of TYF is : ' + activityName);
            }        
            else{
                activityName='';
                System.debug('The value IN ELSE of  TYF is: ' + activityName);
            }
            Step step = new Step();
            step.name = s.XC_ActivityName__c;
            step.seqOrder = s.XC_OrderOfActivity__c;
            step.mandatoryPreviousSteps = activityName;
            step.code = s.XC_ActivityName__c;
            step.status = s.Status;
            listSteps.add(step);
        } 
       

        System.debug('The value of listSteps is: ' + listSteps);
        return listSteps;
       
    }    
    
}