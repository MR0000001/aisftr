/**
  * @author Monica Cutillo - mcutillo@deloitte.it
  * @date Creation 04/12/2020
  * @date Modification dd/mm/yyyy
  * @description XC_AMP_LCC003_RedirectOrderCreation – Controller of XC_AMP_LCP003_RedirectOrderCreation
  */
public  without sharing class XC_AMP_LCC003_RedirectOrderCreation {

    /**
     * @description 
     * @param nameRT
     * @return the RT id
     */
    @AuraEnabled
    public static List<Map<String,Object>> retrieveRecordTypeId(String nameRTs){

      List<Map<String,Object>> resultList = new List<Map<String,Object>>();
      String[] rtsNameSplit = nameRTs.split(';');

      for(String rtDevName : rtsNameSplit){
        Map<String,Object> rtEntry = new Map<String,Object>{
          'label'=>Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get(rtDevName).getName(),'value'=> Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(rtDevName).getRecordTypeId()
        };
        resultList.add(rtEntry);
      }
      return resultList;
    }
}