/**
* @author Nicola Arrigo - narrigo@deloitte.it
* @description classes. XC_TR_Case_U_CaseRepair_B2BG
*/
public with sharing class XC_TR_Case_U_CaseRepair_B2BG {
            /**
    * @author Nicola Arrigo
    * @date Creation 13/10/2020
    * @description Method retrieveid  
    * @return Map<id,XC_CM_Case_Repair_Configuration__mdt>       
    */
  public static Map<string,XC_CM_Case_Repair_Configuration__mdt> mapCaseRepairConfiguration(){
    system.debug('enter method mapCaseRepairConfiguration');
    List<XC_CM_Case_Repair_Configuration__mdt> caseRepairList=[select id,XC_Reason__c, XC_Sub_Cause__c, XC_Sub_Type__c,XC_B2BWONeeded__c,XC_BusinessLine__c 
                                                                from XC_CM_Case_Repair_Configuration__mdt where XC_B2BWONeeded__c=true];
   Map<string,XC_CM_Case_Repair_Configuration__mdt> mapCaseRepairConfiguration=new Map<string,XC_CM_Case_Repair_Configuration__mdt>();
   if(caseRepairList.isEmpty()){
       return  mapCaseRepairConfiguration;
   }
   for(XC_CM_Case_Repair_Configuration__mdt cm:caseRepairList){
    string s;
    if(!string.isBlank(cm.XC_Sub_Type__c)){
         s=cm.XC_Reason__c+'_'+cm.XC_Sub_Cause__c+'_'+cm.XC_Sub_Type__c+'_'+cm.XC_BusinessLine__c;
        mapCaseRepairConfiguration.put(s,cm);
    }else if(string.isBlank(cm.XC_Sub_Type__c)){
         s=cm.XC_Reason__c+'_'+cm.XC_Sub_Cause__c+'_'+cm.XC_BusinessLine__c;
        mapCaseRepairConfiguration.put(s,cm);
    }
    system.debug('Key CM '+s);    
  }
return mapCaseRepairConfiguration;
 }
 
  /**
* @author Nicola Arrigo
* @date Creation 14/10/2020
* @description Method findCMRecord
* @param c
* @param mapCaseRepairConfiguration 
* @return boolean    
*/
 public static boolean findCMRecord(case c,Map<string,XC_CM_Case_Repair_Configuration__mdt> mapCaseRepairConfiguration){
  system.debug('enter method mapCaseRepairConfiguration');
  boolean trovato=false; 
  if(!string.isBlank(c.XC_Subtype__c)){
    string s=c.reason+'_'+c.SubCause__c+'_'+c.XC_Subtype__c+'_'+c.XC_BusinessLine__c;
   if(
        mapCaseRepairConfiguration.get(s)!=null   
       ){

        trovato=true;
       }
   }else if (string.isBlank(c.XC_Subtype__c)){
    string s=c.reason+'_'+c.SubCause__c+'_'+c.XC_BusinessLine__c;
    if(
          mapCaseRepairConfiguration.get(s)!=null   
     ){
      trovato=true;  
    }   
  }
  system.debug('trovato '+trovato);
  return trovato;
 }                                                        
}