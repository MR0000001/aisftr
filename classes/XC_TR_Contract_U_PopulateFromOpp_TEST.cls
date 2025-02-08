@isTest
public class XC_TR_Contract_U_PopulateFromOpp_TEST {
    
    static testMethod void test1(){
        List<Contract> contractList = XC_DF_Contract.createContracts(1);
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1,false);
        
        List<XC_Address__c> addList = [Select id,XC_PricinRegion__c,XC_AddressCountry__c from XC_Address__c limit 10];
        for(XC_Address__c add : addList){
            add.XC_AddressCountry__c = 'Italy';           
        }
		update addList;
        
        for(Opportunity opp : oppList){
            //opp.XC_Segment__c ='B2B';
            //opp.XC_LegalEntity__c ='EnelXItalia';
            opp.XC_ProductCategoryOfInterest__c = null;
            opp.XC_PipelineStatus__c = null;
            //opp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2B_Opportunity_Italy').getRecordTypeId(); 
            opp.Name = 'TEST';            
        }
        insert oppList;
        for(Contract c : contractList){
            c.XC_Segment__c = 'B2B';
            c.Opportunity__c = oppList.get(0).id;  
            c.RecordTypeId=Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_Contract').getRecordTypeId(); 
            c.XC_LegalEntity__c ='EnelXItalia';
        }
        insert contractList;
        
        List<Opportunity> oppL = [Select id from Opportunity limit 10];
        for(Opportunity opp : oppL){
            opp.XC_Segment__c ='B2B';
            opp.XC_LegalEntity__c ='EnelXItalia';
            opp.XC_ProductCategoryOfInterest__c = null;
            opp.XC_PipelineStatus__c = null;
            opp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2B_Opportunity_Italy').getRecordTypeId(); 
            opp.Name = 'TEST';                   
        }
		update oppL;
        
        Test.startTest();
        XC_TR_Contract_U_PopulateFromOpp.populatefields(contractList);
        Test.stopTest();
        
    }
}