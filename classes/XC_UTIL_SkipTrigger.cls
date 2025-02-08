/**
* @author Nicola Arrigo
* @date Creation 21/11/2019
* @description This class ha all the rule to support the evaluation
*/
public without sharing class XC_UTIL_SkipTrigger {
  /**
    * @author Nicola Arrigo 
    * @createddate 21/11/2019
    * @description This method evaluate the user in context if have privilege to skip the rules
    * @return Boolean Return true if the user can the privilege to skip rules
    */
    private static Boolean checkUserPrivilege(){
        return (Constants.userInContext.XC_EnabledToSkip__c) ? true : false;
       //return true;
    }
 /**
    * @author Nicola Arrrigo
    * @createddate 21/11/2019
    * @description This method evaluate the user in context if have privilege to skip the rules
    * @param cmNameOfObject
    * @return Boolean Return true if the object can be skipper
    */
    public static Boolean checkObjToSKip (String cmNameOfObject) {
        return ( checkUserPrivilege() && Constants.coreSkipTrigger.containsKey(cmNameOfObject) && Constants.coreSkipTrigger.get(cmNameOfObject).XC_SkipTrigger__c ) ? true : false;
    }
  
  
}