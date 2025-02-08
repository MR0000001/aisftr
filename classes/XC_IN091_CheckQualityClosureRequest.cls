/**
 * @description       : This ckass is called from the XC_FL_CheckQualityClosure flow
 * @author            : Erlinda & Francisca
 * @group             : 
 * @last modified on  : 23-06-2022
 * @date Modification : dd/mm/yyyy
**/


public without sharing class XC_IN091_CheckQualityClosureRequest {
    
    public class FlowInputs{
        
        @InvocableVariable
        public String requestId;
        
    }

    @InvocableMethod
    public static void computeQualityCheckClosure(List<FlowInputs> flowInputs){
        
        if(!flowInputs.isEmpty()){ 
            
            FlowInputs flowInput=flowInputs[0]; 
        
            XC_KPI_Quality_Check_Request__c qualityCheckClosure = [SELECT Id,XC_Country__c, XC_Request_Status__c,XC_Safety_Points__c, XC_Quality_Check__c, 
                                                                  XC_High_Priority_Malus__c, XC_Low_Priority_Malus__c, XC_Medium_Priority_Malus__c
                                                           		  FROM  XC_KPI_Quality_Check_Request__c 
                                                                  WHERE Id = :flowInput.requestId];
          XC_UTIL_QualityCheckKPI.BonusMalus result = XC_UTIL_QualityCheckKPI.getBonusMalus(qualityCheckClosure.XC_Quality_Check__c,qualityCheckClosure.XC_Country__c);
          qualityCheckClosure.XC_Safety_Points__c = result.totalpriority;
          qualityCheckClosure.XC_High_Priority_Malus__c = result.highpriority; 
          qualityCheckClosure.XC_Medium_Priority_Malus__c = result.mediumpriority;  
          qualityCheckClosure.XC_Low_Priority_Malus__c = result.lowpriority;  
                
            qualityCheckClosure.XC_Request_Status__c='In Progress';
            
            Database.update(qualityCheckClosure);
            
        }
         
           
    }
}