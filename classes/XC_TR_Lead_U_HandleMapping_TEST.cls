/**
* @author Marco Rosa - marco.rosa@nttdata.com & Roberta Cossiga - rcossiga@deloitte.it
* @date Creation  03/04/2019 
* @description XC_TR_Lead_U_HandleMapping_TEST – Test class for XC_TR_Lead_U_HandleMapping
*/ 

@isTest
private class XC_TR_Lead_U_HandleMapping_TEST {

    static testMethod void onInsert() {
        Test.startTest();
        insert XC_DF_Lead.createResidentialLeads(100);
        List<Lead> listInsertedLeads = [SELECT Id FROM Lead];
        System.assertEquals(100, listInsertedLeads.size());
        Test.stopTest();
    }
    
    static testMethod void handleCustomMapping() {
        insert XC_DF_Lead.createResidentialLeads(100);
        List<Lead> listInsertedLeads = [SELECT Id, Email FROM Lead];
        System.assertEquals(100, listInsertedLeads.size());
        
        Test.startTest();
        for(Lead ld : listInsertedLeads){
            ld.Email = 'test'+ld.Email;
        }
        update listInsertedLeads;
        System.assertEquals(100, listInsertedLeads.size());
        Test.stopTest();
    }
    
    static testMethod void getCommercialVisitRequired() {
        XC_ProductCategoryOfInterest__c prodCatM=XC_DF_ProductCategoryOfInterest.prodCatWithVisitRecord(); 
        prodCatM.Name='Caldera';
        prodCatM.XC_CommercialVisit__c =true;
        insert prodCatM;
        XC_ProductCategoryOfInterest__c prodCat = [SELECT Id, Name FROM XC_ProductCategoryOfInterest__c LIMIT 1];
        insert XC_DF_Lead.createResidentialLeads(100);
        List<Lead> listInsertedLeads = [SELECT Id FROM Lead];
        System.assertEquals(100, listInsertedLeads.size());
        
        Test.startTest();
        Integer i = 0;
        for(Lead ld : listInsertedLeads){
            ld.XC_DocumentType__c = 'Passport';
            ld.XC_DocumentNumber__c = '5168461'+ i;
            ld.XC_DocumentCountry__c = 'Spain';
            ld.XC_ProductCategoryOfInterest__c = prodCat.Name;
            i++;
        }
        update listInsertedLeads;
        System.assertEquals(100, listInsertedLeads.size());
        Test.stopTest();
    }
}