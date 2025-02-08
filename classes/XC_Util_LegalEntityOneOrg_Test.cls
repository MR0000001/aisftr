/**
* @author Nicola Arrigo - narrigo@deloitte.it
* @date Creation  05/02/2020 
* @description XC_Util_LegalEntityOneOrg_Test – Test class for XC_Util_LegalEntityOneOrg
*/ 
 
@isTest
private class XC_Util_LegalEntityOneOrg_Test {
  static testMethod void isRightLegalEntity(){
    XC_LegalEntityOneOrg__c  mc = XC_LegalEntityOneOrg__c.getInstance(UserInfo.getProfileId()); 
    Test.startTest(); 
    boolean outcame=XC_Util_LegalEntityOneOrg.isRightLegalEntity('Codensa');
    if(mc!=null){
    System.assert(true,outcame); 
    }else{
        System.assert(false,outcame);
    }
    test.stopTest();
  }
   static testMethod void isRightLegalEntityEnelX(){
    XC_LegalEntityOneOrg__c  mc = XC_LegalEntityOneOrg__c.getInstance(UserInfo.getProfileId()); 
    Test.startTest(); 
    boolean outcame=XC_Util_LegalEntityOneOrg.isRightLegalEntity('EnelX');
    if(mc!=null){
    System.assert(true,outcame); 
    }else{
        System.assert(false,outcame);
    }
    test.stopTest();
  } 
    
    
    
  static testMethod void noRightLegalEntity(){
    XC_LegalEntityOneOrg__c  mc = XC_LegalEntityOneOrg__c.getInstance(UserInfo.getProfileId()); 
    Test.startTest(); 
    boolean outcame=XC_Util_LegalEntityOneOrg.isRightLegalEntity('Colombia');
    if(mc!=null){
    System.assert(true,outcame); 
    }else{
        System.assert(false,outcame);
    }
    test.stopTest();
  }
    
    @isTest
    static void getOrgConfigLegalEntities(){
        Test.startTest();
        	//Map<String,Map<String,XC_CM_LegalEntity_Configuration__mdt>> result = XC_Util_LegalEntityOneOrg.getOrgConfigLegalEntities(new Set<String>{'EndesaX'}, new Set<String>{'B2C'});
        	Map<String,XC_CM_LegalEntity_Configuration__mdt> result = XC_Util_LegalEntityOneOrg.getOrgConfigLegalEntities(new Set<String>{'EndesaX'}, new Set<String>{'B2C'});
        	System.assert(!result.isEmpty());
        test.stopTest();
    }
    
    @isTest
    static void getOrgConfigLegalEntitiesEmpty(){
        Test.startTest();
        	//Map<String,Map<String,XC_CM_LegalEntity_Configuration__mdt>> result = XC_Util_LegalEntityOneOrg.getOrgConfigLegalEntities(new Set<String>(), new Set<String>());
        	Map<String,XC_CM_LegalEntity_Configuration__mdt> result = XC_Util_LegalEntityOneOrg.getOrgConfigLegalEntities(new Set<String>(), new Set<String>());
        	System.assert(result.isEmpty());
        test.stopTest();
    }
    
    @isTest
    static void getConfigLegalEntityCaringInfo(){
        Test.startTest();
        	Map<String,XC_CM_LegalEntity_Configuration__mdt> result = XC_Util_LegalEntityOneOrg.getConfigLegalEntityCaringInfo(new Set<String>{'EndesaX'}, new Set<String>{'B2C'});
        	System.assert(!result.isEmpty());
        test.stopTest();
    }
    
    @isTest
    static void getConfigLegalEntityCaringInfoEmpty(){
        Test.startTest();
        	Map<String,XC_CM_LegalEntity_Configuration__mdt> result = XC_Util_LegalEntityOneOrg.getConfigLegalEntityCaringInfo(new Set<String>(), new Set<String>());
        	System.assert(result.isEmpty());
        test.stopTest();
    }
    
    @isTest
    static void getDefaultCatalogId(){
        Test.startTest();
        	Map<String,String> result = XC_Util_LegalEntityOneOrg.getDefaultCatalogId(new Set<String>{'EnelXItalia'}, new Set<String>{'B2C'});
        	System.assert(result != null);
        test.stopTest();
    }
}