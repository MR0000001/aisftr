/**
 * @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
 * @date Creation 29/11/2018
 * @date Modification  dd/mm/yyyy
 * @description Controller for XC_VFP006_ProvisioningTemplateSchema Visualforce Page
 */
public without sharing class XC_VFC006_ProvisioningTemplateSchema {
    
    /**
    * @description The Class Step.
    */
    public class Step {        
        
        /** @description The name. */
        public String name {get; set;}  
        /** @description The seq order. */
        public Integer seqOrder {get; set;}
        /** @description The mandatory previous steps. */
        public String mandatoryPreviousSteps {get; set;} 
        /** @description The code. */
        public String code {get; set;} 
        /** @description The status. */
        public String status {get; set;}  
    }
    /**
    * @description jSONlistSteps
    */
    public transient String jSONlistSteps {get;set;}
	NE__OrderItem__c myobj {get;set;} 

	/**
	 * @description Instantiates a new x C VFC 006 provisioning template schema.
	 *
	 * @param controller the controller
	 */
	public XC_VFC006_ProvisioningTemplateSchema(ApexPages.StandardController controller){
        myobj = (NE__OrderItem__c)controller.getRecord(); 
        jSONlistSteps = JSON.serialize(getStepsByOrderItem(myobj.Id)); 
        system.debug('######' + jSONlistSteps);
    }
    
    /**
     * @description Gets the steps by order item.
     *
     * @param recordId the record id
     * @return the steps by order item
     */
    private List<Step> getStepsByOrderItem(Id recordId){
        List<Step> listSteps = new List<Step>();
		Map<Id,XC_Provisioning_Step__c> listTStepsMap = 
            new Map<Id,XC_Provisioning_Step__c> ([select Id, Name, XC_Step_Code__c, XC_Step_Order__c, XC_Mandatory_Steps__c, XC_Status__c,toLabel(XC_StepLabel__c)
                     from XC_Provisioning_Step__c  
                     where XC_Configuration_Item__c  =: recordId]);
        List<XC_Provisioning_Step__c>  listTSteps = listTStepsMap.values();
        System.debug('The value of listTSteps is: ' + listTSteps);
        for(XC_Provisioning_Step__c s : listTSteps){
            Step step = new Step();
            step.name = s.XC_StepLabel__c;
            step.seqOrder = Integer.valueOf(s.XC_Step_Order__c);
            step.mandatoryPreviousSteps = s.XC_Mandatory_Steps__c;
            step.code = s.XC_Step_Code__c;
            step.status = s.XC_Status__c;
            listSteps.add(step); 
        } 
        System.debug('The value of listSteps is: ' + listSteps);
        return listSteps;
    }    
}