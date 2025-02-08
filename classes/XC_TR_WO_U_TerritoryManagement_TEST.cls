/**
* @author Roberta Porrega - roberta.porrega@nttdata.com  
* @date Creation 21/05/2019 
* @description XC_TR_WO_U_TerritoryManagement_TEST – Test class 
*/
@isTest 
private  class XC_TR_WO_U_TerritoryManagement_TEST {
    
     @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        org.XC_Spain_ValidationRules__c =  true;
        insert org;
    }
    
    static testMethod void manageTerritoriesOnInsert() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Account> accList = XC_DF_Account.insertPartnerAccounts(1);
        List<ServiceTerritory> servTerr = XC_DF_ServiceTerritory.createServiceTerritories(accList);
        insert servTerr;
        
        User u = XC_DF_User.createUserAdmin();
        insert u;
        
        ServiceResource servRes = new ServiceResource(Name = 'Test', 
                                                      XC_Account__c = accList[0].Id, 
                                                      isCapacityBased = true,
                                                      RelatedRecordId = u.Id, 
                                                      isActive = true );
        insert servRes;
        
        ServiceTerritoryMember servTerrMemb = new ServiceTerritoryMember(
            ServiceTerritoryId = servTerr[0].Id,
            ServiceResourceId = servRes.Id,
            EffectiveStartDate = Date.Today()
        );
        insert servTerrMemb;
        List<XC_Address__c> addressList =  XC_DF_Address.createAddress(1);
        insert addressList;
        XC_ZipCodeSkill_TerritoryAssociation__c zipTerr = new XC_ZipCodeSkill_TerritoryAssociation__c();
        zipTerr.XC_ZipCode__c = addressList[0].XC_PostalCode__c;
        zipTerr.XC_ListOfSkills__c = 'CommercialVisit';
        zipTerr.XC_ServiceTerritoryId__c = servTerr[0].id;
        zipTerr.XC_Province__c = 'Madrid';
        insert zipTerr;  
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(10,  Label.XC_CL_WorkType_Installation);
        for(WorkOrder wo : woList){
            wo.XC_Address__c	 = addressList[0].Id;
            wo.PostalCode	 = addressList[0].XC_PostalCode__c;
        }
        insert woList;
        
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(10, listInsertedWorkOrders.size());
        Test.stopTest();
    }
    static testMethod void manageTerritoriesOnInsert1() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();    
        List<Account> accList = XC_DF_Account.insertPartnerAccounts(1);
        List<ServiceTerritory> servTerr = XC_DF_ServiceTerritory.createServiceTerritories(accList);
        insert servTerr;
        
        User u = XC_DF_User.createUserAdmin();
        insert u;
        
        ServiceResource servRes = new ServiceResource(Name = 'Test', 
                                                      XC_Account__c = accList[0].Id, 
                                                      isCapacityBased = true,
                                                      RelatedRecordId = u.Id, 
                                                      isActive = true );
        insert servRes;
        
        ServiceTerritoryMember servTerrMemb = new ServiceTerritoryMember(
            ServiceTerritoryId = servTerr[0].Id,
            ServiceResourceId = servRes.Id,
            EffectiveStartDate = Date.Today()
        );
        insert servTerrMemb;

        List<XC_Address__c> addressList =  XC_DF_Address.createAddress(1);
        insert addressList;
        XC_ZipCodeSkill_TerritoryAssociation__c zipTerr = new XC_ZipCodeSkill_TerritoryAssociation__c();
        zipTerr.XC_ZipCode__c = addressList[0].XC_PostalCode__c;
        zipTerr.XC_ListOfSkills__c = '0C55E0000004DtoSAE';
        zipTerr.XC_ServiceTerritoryId__c = servTerr[0].id;
        insert zipTerr;  
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(10,  Label.XC_CL_WorkType_Installation);
        for(WorkOrder wo : woList){
            wo.XC_Address__c	 = addressList[0].Id; 
        }
        insert woList;
        
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(10, listInsertedWorkOrders.size());
        Test.stopTest();
    }
    static testMethod void manageTerritoriesOnUpdate() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        XC_DF_ServiceResource.createServiceResources(1);
        List<ServiceResource> servRes = [SELECT Id FROM ServiceResource];
        List<Account> accList = [SELECT Id, Name FROM Account];
        List<ServiceTerritory> servTerr = XC_DF_ServiceTerritory.createServiceTerritories(accList);
        insert servTerr;
       
        
        ServiceTerritoryMember servTerrMemb = new ServiceTerritoryMember(
            ServiceTerritoryId = servTerr[0].Id,
            ServiceResourceId = servRes[0].Id,
            EffectiveStartDate = Date.Today()
        );
        insert servTerrMemb;
        User u = XC_DF_User.createUserAdmin();
        insert u;
        
        ServiceResource servRes2 = new ServiceResource(Name = 'No Candidate Found', 
                                                      XC_Account__c = accList[0].Id, 
                                                      isCapacityBased = true,
                                                      RelatedRecordId = u.Id, 
                                                      isActive = true );
        insert servRes2;
        List<XC_Address__c> addressList =  XC_DF_Address.createAddress(1);
        insert addressList;
        XC_ZipCodeSkill_TerritoryAssociation__c zipTerr = new XC_ZipCodeSkill_TerritoryAssociation__c();
        zipTerr.XC_ZipCode__c = addressList[0].XC_PostalCode__c;
        zipTerr.XC_ListOfSkills__c = '0C55E0000004DtoSAE';
        zipTerr.XC_ServiceTerritoryId__c = servTerr[0].id;
        zipTerr.XC_Province__c = 'Madrid';
        insert zipTerr;     	
        XC_ZipCodeSkill_TerritoryAssociation__c zipTerr1 = new XC_ZipCodeSkill_TerritoryAssociation__c();
        zipTerr1.XC_ZipCode__c = '28001';
        zipTerr1.XC_ListOfSkills__c = '0C55E0000004DtoSAE';
        zipTerr1.XC_ServiceTerritoryId__c = servTerr[0].id;
        zipTerr1.XC_Province__c = 'Madrid';
        insert zipTerr1;   
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(10,  Label.XC_CL_WorkType_Installation );
        for(WorkOrder wo : woList){
            wo.XC_Address__c	 = addressList[0].Id;
        }
        insert woList;
        for(WorkOrder wo : woList){
            wo.PostalCode	 = '28001';
        }
        update woList;
        
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(10, listInsertedWorkOrders.size());
        Test.stopTest();
    }
}