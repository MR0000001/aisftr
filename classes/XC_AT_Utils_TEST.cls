/**
* @author Riccardo Cossu - riccardo.cossu@nttdata.com 
* @Creation 16/05/2019
* @description Test Class for XC_AT_Utils
*/
@isTest
private class XC_AT_Utils_TEST {
    @TestSetup
    static void setup(){
        String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_ESP_Management_Case').getRecordTypeId(); //VDB 14-04-22 CR 760																																						
        List<Case> caseList = XC_DF_CASE.createCases(1);        
		caseList[0].Recordtypeid=recordTypeId;//VDB 14-04-22 CR 760														   
        caseList[0].Status = 'ESTA001';
		caseList[0].XC_LegalEntity__c='EndesaX';//VDB 14-04-22 CR 760	
        insert caseList;
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        insert assetList;
    }
    static testMethod void getRelatedParentCasesByCaseIdsTest(){
       	Test.startTest();
        insert XC_DF_OneOrg.createOneOrg('Spain');   
        List<Case> c = [SELECT ID FROM CASE LIMIT 1];
        Set<Id> caseParentIds = new Set<Id>();
        caseParentIds.add(c[0].Id);
 		
        List<Asset> aL = [SELECT ID FROM ASSET LIMIT 1];
        Set<Id> assetIds = new Set<Id>();
        assetIds.add(aL[0].Id);
       
        List<Case> a =XC_AT_Utils.getRelatedParentCasesByCaseIds(caseParentIds);
        String addC = XC_AT_Utils.addChangedValue('1','2','3');
        Map<Id,String> caT = XC_AT_Utils.getCatalogCategoryNamesMap(assetIds);
        Map<String, Entitlement> getSLA = XC_AT_Utils.getSLAEntitlement('Case');
        String addC2 =  XC_AT_Utils.addChangedValueHelper('TEST','TEST2');
        List<String> apData = new List<String>{'{"templateId":null,"refType":"test","refId":"test"}'};
        XC_AT_Utils.ActionPlanCreationWrapper apc = new XC_AT_Utils.ActionPlanCreationWrapper(null, 'test', 'test');
        XC_AT_Utils.futureActionPlanCreation(apData);
       	Schema.DescribeFieldResult dfr = Account.Description.getDescribe();
        XC_AT_Utils.RemarkMessageWrapper remarker = new XC_AT_Utils.RemarkMessageWrapper();
        remarker.fieldDescribe = dfr;
        
        XC_AT_Utils.addRemarkMessage(remarker);
        
        System.assert(!a.isEmpty());
        System.assert(!String.isBlank(addC));
        System.assert(!String.isBlank(addC2));
        System.assert(!aL.isEmpty());
        System.assert(getSLA.isEmpty());
        
        Test.stopTest();
        
    }
    static testMethod void getRelatedParentCasesByCaseIdsTest2(){
       	Test.startTest();
        insert XC_DF_OneOrg.createOneOrg('Spain');   
		XC_AT_Utils.ActionPlanCreationWrapper  actionP = new  XC_AT_Utils.ActionPlanCreationWrapper();
	    XC_AT_Utils.RemarkMessageWrapper rWr = new  XC_AT_Utils.RemarkMessageWrapper();
        rWr.lastMessage = 'lastMessage';
        rWr.newValue    = 'newValue';
		       
        Test.stopTest();
        
    }
}