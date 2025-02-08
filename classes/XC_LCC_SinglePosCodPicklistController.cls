/**
* @author sooraji.sajan@accenture.com - raffaele.sojka@accenture.com 
* @date Creation 11/03/2022
* @description Returns a list of not duplicated XC_PositionCode__c - CR704
*/


public class XC_LCC_SinglePosCodPicklistController {
    @auraEnabled
    public static List<String> getSinglePositionCodeValues(String woli){
    List<String> singlePositionCodeValues = new List<String>();
    List<XC_RequiredPosition__c> reqpos= [SELECT id, XC_PositionCode__c FROM XC_RequiredPosition__c WHERE XC_WorkOrderLineItem__c=:woli];
       for(XC_RequiredPosition__c req : reqpos){
           if(!singlePositionCodeValues.contains(req.XC_PositionCode__c)){singlePositionCodeValues.add(req.XC_PositionCode__c);}
              
          }
       System.debug('picklist '+singlePositionCodeValues);
    return singlePositionCodeValues;
     
   }

}