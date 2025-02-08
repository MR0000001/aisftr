/**
* @author Fabrizio Antonioli - fabrizio.antonioli@nttdata.com, Giovanni Schioppa - giovanni.schioppa@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 20/11/2018
* @date Modification
* @description XC_LCC041_StartProvisioning - Controller for XC_LCP041_StartProvisioning Component 
*/
public without sharing  class XC_LCC041_StartProvisioning {
    
    /**
     * @description The Class resultWrapper.
     */
    public class resultWrapper{
        
        /** The success. */
        @AuraEnabled
        public Boolean success;
        
        /** The message. */
        @AuraEnabled
        public String  message; 
    }
    
    /**
     * Check condition.
     *
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com, Fabrizio Antonioli - fabrizio.antonioli@nttdata.com, Giovanni Schioppa - giovanni.schioppa@nttdata.com
     * @param recordId the record id
     * @return the result wrapper
     * @description Method to call the server to check that there are provisioning steps on the configuration item in status Not Started. If
     *                     not, an error is sent to the component.
     */
    @AuraEnabled
    public static resultWrapper checkCondition(Id recordId){
        
        resultWrapper rw = new resultWrapper();
        rw.success = true;
        rw.message = Label.XC_CL_Provisioning_Started; 

        if(!Schema.SObjectType.XC_Provisioning_Step__c.isAccessible()) {
            return new resultWrapper();
        }

        
        Map<Id,XC_Provisioning_Step__c> saListMap = new Map<Id,XC_Provisioning_Step__c>([SELECT Id, XC_Status__c 
        FROM XC_Provisioning_Step__c WHERE XC_Configuration_Item__c =: recordId 
        AND XC_Step_Order__c = 1 LIMIT 1]);
        
        List<XC_Provisioning_Step__c> saList = saListMap.values();



        if(!saList.isEmpty()){
            if(saList[0].XC_Status__c != Label.XC_CL_Provisioning_Step_NotStarted){
                rw.success = false;
                rw.message = Label.XC_CL_Provisioning_Already_Started; 
            }
        }
        else{
            rw.success = false;
            rw.message = Label.XC_CL_No_Provisioning_Steps; 
        }      
        return rw;
    }
   
   /**
    * Start steps aura.
    *
    * @author Marco Rosa - marco.rosa@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @param recordId the record id
    * @description Method to call the server to start the provisioning.
    */
    @AuraEnabled
    public static void startStepsAura(Id recordId){
        Map<Id,Id> oiPsMap = new Map<Id,Id>();
        Map<Id,List<XC_Provisioning_Step__c>> idListMap = new Map<Id,List<XC_Provisioning_Step__c>>();

          if(!Schema.sObjectType.NE__OrderItem__c.isAccessible()){
                    return;
                } 
              
        Map<Id,NE__OrderItem__c> oiMap = new Map<Id,NE__OrderItem__c>([
            SELECT Id, 
                (SELECT Id,XC_Step_Order__c,XC_Configuration_Item__c,XC_Status__c,XC_Step_Code__c,XC_Mandatory_Steps__c,XC_Synchronous__c,XC_Flow_API_Name__c,
                            XC_Country__c,XC_ConfigurationId__c
                FROM Provisioning_Steps__r  ) 
                FROM NE__OrderItem__c 
            WHERE Id =: recordId]
        ); 

        for(Id oi : oiMap.keySet()) {
            List<XC_Provisioning_Step__c> psList = oiMap.get(oi).Provisioning_Steps__r;
            idListMap.put(oi,psList);
        } 

        for(Id orderItemId : idListMap.keyset()){
            if(!idListMap.get(orderItemId).isEmpty()){ 
                NE__OrderItem__c orderItem = new NE__OrderItem__c(Id = orderItemId);
                System.debug('check on orderitem ---->' + orderItem);
                //XC_UTIL_ProvisioningStep.ResultWrapper resultWrapper =  XC_UTIL_ProvisioningStep.insertSteps(orderItem);
                List<XC_Provisioning_Step__c> stepList = oiMap.get(orderItemId).Provisioning_Steps__r;
                System.debug('@@stepList->' + stepList);
                XC_UTIL_ProvisioningStep.startInitialSteps(stepList);
            } 
        }
    }
}