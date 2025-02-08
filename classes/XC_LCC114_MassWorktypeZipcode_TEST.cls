/**
* @author Massimiliano Avallone - massimiliano.avallone@nttdata.com 
* @date Creation 17/09/2019 
* @description XC_LCC114_MassWorktypeZipcode_TEST – Test class for XC_LCC114_MassWorktypeZipcode
*/
@isTest
public class XC_LCC114_MassWorktypeZipcode_TEST {
  static testMethod void massWorkTypeZipCode(){
    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
      
    List<ServiceResource> listserRes = XC_DF_ServiceResource.createServiceResources(1);
    ServiceResource sr = [SELECT id, XC_Account__c FROM ServiceResource];

    List<WorkType> wtList = new List<WorkType>();
    WorkType wt = XC_DF_WorkType.createWorkType(Label.XC_CL_WorkType_Installation);
    wtList.add(wt);
	  insert wtList; 
    	
	  List<XC_PartnerCoverage__c> listPc = new List<XC_PartnerCoverage__c>();
    XC_PartnerCoverage__c pc = new XC_PartnerCoverage__c();
    pc.XC_WorkType__c = wtList[0].Id;
    pc.XC_Account__c = listserRes[0].XC_Account__c;
    listPc.add(pc);
    insert listPc;  
       
    List<string> listPartnerCov = new List<string>();
    listPartnerCov.add(listPc[0].Id);  
	
	  List<XC_ZipCodeWorkType__c> listZcwt = new List<XC_ZipCodeWorkType__c>();
    XC_ZipCodeWorkType__c zCwT = new  XC_ZipCodeWorkType__c();
    listZcwt.add(zCwT);
    insert listZcwt;  
      
    List<string> listZipCodeWt = new List<string>();
    listZipCodeWt.add(listZcwt[0].Id);
       
    XC_LCC114_MassAssWorktypeZipCode_W.ResultByPartnerWrapper getResult = XC_LCC114_MassWorktypeZipcode.getResultWrapperByPartner(sr.XC_Account__c);
    XC_LCC114_MassWorktypeZipcode.addOperation(sr.XC_Account__c, wtList, listZipCodeWt, listPc);
    XC_LCC114_MassWorktypeZipcode.removeOperation(listPartnerCov);
    XC_LCC114_MassAssWorktypeZipCode_W.OutputWrapper transfer = XC_LCC114_MassWorktypeZipcode.transferOperation(listPc, sr.XC_Account__c);
     
    Test.stopTest();
  } 

  static testMethod void massWorkType(){
    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
      
    List<ServiceResource> listserRes = XC_DF_ServiceResource.createServiceResources(1);
    ServiceResource sr = [SELECT id, XC_Account__c FROM ServiceResource];

    List<WorkType> wtList = new List<WorkType>();
    WorkType wt = XC_DF_WorkType.createWorkType(Label.XC_CL_WorkType_Installation);
    wtList.add(wt);
	  insert wtList; 
	
	  List<XC_PartnerCoverage__c> listPc = new List<XC_PartnerCoverage__c>();
    insert listPc;  
       
    List<string> listPartnerCov = new List<string>();
    
	  List<XC_ZipCodeWorkType__c> listZcwt = new List<XC_ZipCodeWorkType__c>();
    XC_ZipCodeWorkType__c zCwT = new  XC_ZipCodeWorkType__c();
    listZcwt.add(zCwT);
    insert listZcwt;  
      
    List<string> listZipCodeWt = new List<string>();
    listZipCodeWt.add(listZcwt[0].Id);
       
    XC_LCC114_MassAssWorktypeZipCode_W.ResultByPartnerWrapper getResult = XC_LCC114_MassWorktypeZipcode.getResultWrapperByPartner(sr.XC_Account__c);
    XC_LCC114_MassWorktypeZipcode.addOperation(sr.XC_Account__c, wtList, listZipCodeWt, listPc);
    XC_LCC114_MassWorktypeZipcode.removeOperation(listPartnerCov);
    XC_LCC114_MassAssWorktypeZipCode_W.OutputWrapper transfer = XC_LCC114_MassWorktypeZipcode.transferOperation(listPc, sr.XC_Account__c);
     
    Test.stopTest();
  } 
}