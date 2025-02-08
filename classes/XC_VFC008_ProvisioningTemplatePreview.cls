/**
 * @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
 * @date Creation 29/11/2018
 * @date Modification  dd/mm/yyyy
 * @description Controller for XC_VFP008_ProvisioningTemplatePreview Visualforce Page
 */ 

public without sharing class XC_VFC008_ProvisioningTemplatePreview {
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
    }
    /** @description The JSO nlist steps. */
    public transient String jSONlistSteps {get;set;} 
    
    /**
     * @description Instantiates a new x C VFC 008 provisioning template preview.
     */
    public XC_VFC008_ProvisioningTemplatePreview(){ 
       //String  = ApexPages.currentPage().getParameters().get('templateName');
        //templateName = String.escapeSingleQuotes(templateName);
        String templateName = ApexPages.currentPage().getParameters().get('templateName').escapeHtml4();

        System.debug(LoggingLevel.FINEST,'templateName'+templateName);
        jSONlistSteps = JSON.serialize(getStepsByOrderItem(templateName)); 
        System.debug('templateName-->' + templateName); 
    }
	
    /**
     * @description Gets the steps by order item.
     *
     * @param templateName the template name
     * @return the steps by order item
     */
     @TestVisible
    private List<Step> getStepsByOrderItem(String templateName){
        List<Step> listSteps = new List<Step>();
            if (!String.isBlank(templateName)){
		Map<Id, XC_CM_Provisioning_Template_Config__mdt> listTStepsMap = 
            new Map<Id, XC_CM_Provisioning_Template_Config__mdt> ([SELECT Id, XC_CM_Template_Name__c, XC_CM_Step_Code__c, XC_CM_Step_Order__c, XC_CM_Mandatory_Steps__c, XC_CM_Step_Name__c
                     FROM XC_CM_Provisioning_Template_Config__mdt  
                     WHERE XC_CM_Template_Name__c  =: templateName]); 
         
        List<XC_CM_Provisioning_Template_Config__mdt> listTSteps = listTStepsMap.values();
        for(XC_CM_Provisioning_Template_Config__mdt s : listTSteps){
            Step step = new Step();
            step.name = s.XC_CM_Step_Name__c;
            step.seqOrder = Integer.valueOf(s.XC_CM_Step_Order__c);
            step.mandatoryPreviousSteps = s.XC_CM_Mandatory_Steps__c;
            step.code = s.XC_CM_Step_Code__c;
            listSteps.add(step);
        }
    }
        System.debug('The value of listSteps is: ' + listSteps);
        return listSteps;
    }    
}