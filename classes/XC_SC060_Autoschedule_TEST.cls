/**
* @author Salvatore Barbera - sbarbera@deloitte.it 
* @date Creation 03/10/2019
* @date 
* @description Test for XC_SC060_Autoschedule and classes used from it
*/

@isTest
public with sharing class XC_SC060_Autoschedule_TEST {
    @TestSetup
	static void setup(){
        XC_CS_UtilityGlobalValues__c csInsertDML = new XC_CS_UtilityGlobalValues__c();
        csInsertDML.Name = 'XC_SC060Autoschedule_batchSize';
        csInsertDML.Value__c = '200';
        insert csInsertDML;
        XC_CS_UtilityGlobalValues__c csInsertDML1 = new XC_CS_UtilityGlobalValues__c();
        csInsertDML1.Name = 'XC_SC060Autoschedule_parallelNumExec';
        csInsertDML1.Value__c = '1';
        insert csInsertDML1;
        XC_CS_Autoschedule__c settings = new XC_CS_Autoschedule__c();
        settings.XC_Country__c = 'Italy;ITALY';
        settings.XC_LegalEntity__c = 'EnelXItalia';
		settings.XC_ExcludedCountry__c = 'Chile';
        insert settings;

        List<Account> accLis = XC_DF_Account.createResidentialAccounts(1);
        insert accLis;

        List<Contact> conList = XC_DF_Contact.createResidentialContacts(accLis);
        for (Contact cnt: conList){
            cnt.XC_CountryLegalEntity__c = 'ITALY';
            cnt.XC_MainLegalEntity__c = 'EnelXItalia';
        }
        insert conList;

        List<XC_Address__c> addrList = XC_DF_Address.createItalianAddress(accLis);
        insert addrList;

        List<Account> partnerAccList = XC_DF_Account.insertPartnerAccounts(1);
        Account partnerAccount = [SELECT id, XC_Technical_Service_Partner__c,XC_Technical_Service__c, XC_Max_Work_Order_Per_Month__c, Name, XC_ContractStatus__c, XC_Status__c FROM Account WHERE id IN: partnerAccList LIMIT 1 ];
        partnerAccount.XC_Technical_Service__c = true;
        partnerAccount.XC_Max_Work_Order_Per_Month__c = 100;
        partnerAccount.XC_ContractStatus__c = 'Active';
        partnerAccount.XC_Status__c = 'Active';
        partnerAccount.XC_Segment__c ='B2C';
        update partnerAccount;
        List<Account> finalAccPart = new List<Account>();
        finalAccPart.add(partnerAccount);

        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunityWithoutVisit(conList, addrList[0]);
        for(Opportunity opp : oppList){
            opp.XC_ProductCategoryOfInterest__c = 'Smart Home';
            opp.XC_LegalEntity__c = 'EnelXItalia';
        }
        insert oppList;
        Opportunity opty = [SELECT id FROM Opportunity LIMIT 1];

        NE__Order__c order = new NE__Order__c();
        order.XC_DeliveryAddress__c = addrList[0].id;
        order.XC_InstallationAddress__c =  addrList[0].id;
        order.NE__AccountId__c = accLis[0].id;
        order.NE__OptyId__c = opty.id;
        Id quote = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        order.RecordTypeId = quote; 
        order.XC_Status__c = 'Accepted';
        order.NE__Type__c = 'In Order';
        order.XC_Country__c = 'Italy';
        insert order;
        NE__Order__c configuration = [SELECT id FROM NE__Order__c LIMIT 1];
        NE__OrderItem__c item = XC_DF_OrderItem.createOrderItem(order);
        item.NE__Account__c =  accLis[0].id;
        item.XC_Installation_Address__c =  addrList[0].id;
        insert item;
        NE__OrderItem__c confItem = [SELECT id FROM NE__OrderItem__c WHERE NE__OrderId__c = :configuration.id LIMIT 1];
        
        OperatingHours oh = new OperatingHours();
        oh.Name = 'Gold Appointments Calendar';
        insert oh;
        OperatingHours opH = [SELECT Id, Name FROM OperatingHours Limit 1];
        
        FSL__Scheduling_Policy__c policy  = new FSL__Scheduling_Policy__c();
		policy.Name = 'X-Customer Autoschedule';
        insert policy;

        String assetProductName = 'Enel X JuiceBox 22';
        List<NE__Product__c> productToInsert = XC_DF_Product.createProducts(3);
        for (Integer i=0; i<3; i++){
            productToInsert[i].Name = assetProductName;
            productToInsert[i].XC_LIC_Product_Name__c = assetProductName;
            productToInsert[i].XC_Product_Subtype__c = 'Wallbox';
            productToInsert[i].XC_Product_Type__c = 'Equipment';
        }
        insert productToInsert;
        
        List<Asset> assetToInsert = XC_DF_Asset.createAssets(3);  
        for (Integer i=0; i<3; i++){
            assetToInsert[i].Name = assetProductName;
            assetToInsert[i].NE__ProdId__c = productToInsert[i].id;
            assetToInsert[i].XC_LegalEntity__c = 'EnelXItalia';
            assetToInsert[i].XC_Original_Configuration_Item__c = confItem.id;
        }
        insert assetToInsert;
        List<Asset> assetList = [SELECT id, XC_Original_Configuration_Item__c FROM Asset WHERE XC_Original_Configuration_Item__c =: confItem.id ];

        WorkType workTypeDI = XC_DF_WorkType.createWorkType(Label.XC_CL_WorkType_DeliveryInstallation);
        insert workTypeDI;
 		
        
        List<ServiceResource> listServiceResource = XC_DF_ServiceResource.createServiceResourcesFromAccount(finalAccPart, false);
        for(Integer i=0; i<listServiceResource.size(); i++) {
            listServiceResource[i].XC_IsManager__c = true;
            listServiceResource[i].ResourceType ='T';
            listServiceResource[i].AccountId = finalAccPart[0].id;
        }
        update listServiceResource;
		
		List<ServiceResource> srM = [SELECT id, XC_Account__c, XC_IsManager__c, ResourceType, XC_AccountStatus__c, XC_Is_Contract_Active__c, AccountId, Account.XC_ContractStatus__c FROM ServiceResource WHERE XC_IsManager__c = true];
        System.debug('MC ' + srM);

        List<ServiceTerritory> listServiceTerritory = new List<ServiceTerritory>();
        for(Account account : finalAccPart) {
            ServiceTerritory st = new ServiceTerritory();
            st.Name = 'Test'+String.valueOf(Math.random());
            st.Street = 'Via Test';
            st.City = 'Latina';
            st.State = 'Spain';
            st.PostalCode = '04100';
            st.Country = 'Italy';
            st.IsActive = true;
            st.XC_AccountId__c = account.Id;
            st.XC_Country__c = 'ITALY';
            st.FSL__Hide_Emergency_Map__c = false;
            st.FSL__TerritoryLevel__c = 0;
            st.OperatingHoursId = oh.Id;
            listServiceTerritory.add(st);
        }
        insert listServiceTerritory;

        List<WorkOrder> woListDI = new List<WorkOrder>();
        for (Integer i=0; i<3; i++){
            WorkOrder workOrderToInsert = new WorkOrder();
            workOrderToInsert.XC_WorkTypeCategory__c = Label.XC_CL_WorkType_DeliveryInstallation;
            workOrderToInsert.WorkTypeId = workTypeDI.Id;
            workOrderToInsert.AssetId =assetList[i].id;
        	workOrderToInsert.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2C_EnelXItalia_WorkOrder').getRecordTypeId();
            workOrderToInsert.XC_Address__c = addrList[0].id;
            workOrderToInsert.XC_CreatedAutomaticallyBySystem__c = true;
            workOrderToInsert.XC_Country__c ='Italy';
            workOrderToInsert.XC_LegalEntity__c = 'EnelXItalia';
            workOrderToInsert.XC_Segment__c = 'B2C';
            workOrderToInsert.XC_To_Be_Manually_Assigned__c = false;
            workOrderToInsert.ServiceTerritoryId = listServiceTerritory[0].id;
            workOrderToInsert.XC_Configuration__c = configuration.id;
            woListDI.add(workOrderToInsert);
        }
        woListDI[1].AssetId = assetList[0].id;
        insert woListDI;
        

        List<ServiceTerritoryMember> listServiceTerritoryMember = new List<ServiceTerritoryMember>();
        for(Integer i=0; i<listServiceResource.size(); i++) {
            ServiceTerritoryMember stm = new ServiceTerritoryMember();
            stm.ServiceTerritoryId = listServiceTerritory[i].Id;
            stm.ServiceResourceId = listServiceResource[i].Id;
            stm.TerritoryType = 'P';
            stm.EffectiveStartDate = Datetime.Now().addDays(-15);
            stm.EffectiveEndDate = Datetime.Now().addDays(15);
            stm.OperatingHoursId = oh.Id;
            stm.XC_Country__c = 'ITALY';
            listServiceTerritoryMember.add(stm);
        }
        insert listServiceTerritoryMember;

        List<ServiceResourceSkill> listServiceResourceSkill = new List<ServiceResourceSkill>();
        Skill skillCommercialVisit = [SELECT Id FROM Skill WHERE DeveloperName = 'Delivery_Installation' LIMIT 1];
        for(Integer i=0; i<listServiceResource.size(); i++) {
            ServiceResourceSkill srs = new ServiceResourceSkill();
            srs.SkillLevel = 1;
            srs.SkillId = skillCommercialVisit.Id;
            srs.EffectiveStartDate = Datetime.Now().addDays(-10);
            srs.EffectiveEndDate = Datetime.Now().addDays(10);
            srs.ServiceResourceId = listServiceResource[i].Id;
            listServiceResourceSkill.add(srs);
        }
        insert listServiceResourceSkill;

        List<ServiceResourceSkill> listSr = new List<ServiceResourceSkill>([SELECT Id, EffectiveStartDate, EffectiveEndDate FROM ServiceResourceSkill WHERE Id =: listServiceResourceSkill]);
        System.debug('##### listSr----> ' +listSr);
        for(ServiceResourceSkill sr : listSr){
            sr.EffectiveEndDate = sr.EffectiveEndDate.addDays(11);    
        }
        update listSr;
        List<SkillRequirement> listSkillReq = new List<SkillRequirement>();
        for(WorkOrder wo : woListDI) {
            SkillRequirement skillReq = new SkillRequirement();
            skillReq.XC_Country__c = 'ITALY';
            skillReq.SkillLevel = 1;
            skillReq.SkillId = skillCommercialVisit.Id;
            skillReq.RelatedRecordId = wo.Id;
            listSkillReq.add(skillReq);
        } 
        insert listSkillReq;
        
    }

    static testMethod void testDeliveryInstallation(){
        
        Test.startTest();
        String chron = '0 0 23 * * ?';
        system.schedule('Test Sched060', chron,  new XC_SC060_AutoSchedule());
        Test.stopTest();
        
    }
    
    static testMethod void test2(){
        
        
        List<Account> accLis = XC_DF_Account.createResidentialAccounts(1);
        insert accLis;
         List<XC_Address__c> addrList = XC_DF_Address.createItalianAddress(accLis);
        insert addrList;
        

        List<Account> partnerAccList = XC_DF_Account.insertPartnerAccounts(1);
        Account partnerAccount = [SELECT id, XC_Technical_Service_Partner__c,XC_Technical_Service__c, XC_Max_Work_Order_Per_Month__c, Name, XC_ContractStatus__c, XC_Status__c FROM Account WHERE id IN: partnerAccList LIMIT 1 ];
        partnerAccount.XC_Technical_Service__c = true;
        partnerAccount.XC_Max_Work_Order_Per_Month__c = 100;
        partnerAccount.XC_ContractStatus__c = 'Active';
        partnerAccount.XC_Status__c = 'Active';
        partnerAccount.XC_Segment__c ='B2C';
        update partnerAccount;
        List<Account> finalAccPart = new List<Account>();
        finalAccPart.add(partnerAccount);
        update finalAccPart;
      Test.startTest();
        List<Contact> conList = XC_DF_Contact.createResidentialContacts(accLis);
        for (Contact cnt: conList){
            cnt.XC_CountryLegalEntity__c = 'ITALY';
            cnt.XC_MainLegalEntity__c = 'EnelXItalia';
        }
        
        insert conList;
        
        Opportunity opty = [SELECT id FROM Opportunity where XC_ProductCategoryOfInterest__c ='Smart Home' LIMIT 1];

        
        NE__Order__c order = new NE__Order__c();
        order.XC_DeliveryAddress__c = addrList[0].id;
        order.XC_InstallationAddress__c =  addrList[0].id;
        order.NE__AccountId__c = accLis[0].id;
        order.NE__OptyId__c = opty.id;
        Id quote = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        order.RecordTypeId = quote; 
        order.XC_Status__c = 'Accepted';
        order.NE__Type__c = 'In Order';
        order.XC_Country__c = 'Italy';
        insert order;
        NE__Order__c configuration = [SELECT id FROM NE__Order__c LIMIT 1];
        NE__OrderItem__c item = XC_DF_OrderItem.createOrderItem(order);
        item.NE__Account__c =  accLis[0].id;
        item.XC_Installation_Address__c =  addrList[0].id;
        insert item;
        NE__OrderItem__c confItem = [SELECT id FROM NE__OrderItem__c WHERE NE__OrderId__c = :configuration.id LIMIT 1];
        
        
        String assetProductName = 'Enel X JuiceBox 22';
        List<NE__Product__c> productToInsert = XC_DF_Product.createProducts(3);
        for (Integer i=0; i<3; i++){
            productToInsert[i].Name = assetProductName;
            productToInsert[i].XC_LIC_Product_Name__c = assetProductName;
            productToInsert[i].XC_Product_Subtype__c = 'Wallbox';
            productToInsert[i].XC_Product_Type__c = 'Equipment';
        }
        insert productToInsert;
        
        List<Asset> assetToInsert = XC_DF_Asset.createAssets(3);  
        for (Integer i=0; i<3; i++){
            assetToInsert[i].Name = assetProductName;
            assetToInsert[i].NE__ProdId__c = productToInsert[i].id;
            assetToInsert[i].XC_LegalEntity__c = 'EnelXItalia';
            assetToInsert[i].XC_Original_Configuration_Item__c = confItem.id;
        }
        insert assetToInsert;
        List<Asset> assetList = [SELECT id, XC_Original_Configuration_Item__c FROM Asset WHERE XC_Original_Configuration_Item__c =: confItem.id ];
        
        WorkType workTypeDI = XC_DF_WorkType.createWorkType(Label.XC_CL_WorkType_DeliveryInstallation);
        insert workTypeDI;
 		
        
        WorkOrder workOrderDI = new WorkOrder();
        workOrderDI.XC_WorkTypeCategory__c = Label.XC_CL_WorkType_DeliveryInstallation;
        workOrderDI.WorkTypeId = workTypeDI.Id;
        workOrderDI.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2C_EnelXItalia_WorkOrder').getRecordTypeId();
        workOrderDI.XC_Address__c = addrList[0].id;
        workOrderDI.XC_Country__c ='Italy';
        workOrderDI.XC_LegalEntity__c = 'EnelXItalia';
        workOrderDI.XC_Segment__c = 'B2C';
        workOrderDI.Status = 'Completed';
        workOrderDI.XC_AssignedPartner__c = partnerAccount.id;
        workOrderDI.XC_Configuration_Item__c = assetList[0].XC_Original_Configuration_Item__c;
        insert workOrderDI;


       
        
        WorkType workTypeSI = XC_DF_WorkType.createWorkType(Label.XC_CL_WorkType_SiteInspection);
        insert workTypeSI; 
        WorkType workTypeRepair = XC_DF_WorkType.createWorkType(Label.XC_CL_WorkType_Repair);
        insert workTypeRepair;
        
        List<WorkOrder> woListSI = new List<WorkOrder>();
        for (Integer i=0; i<1; i++){
            WorkOrder workOrderToInsert = new WorkOrder();
            workOrderToInsert.XC_WorkTypeCategory__c = Label.XC_CL_WorkType_SiteInspection;
            workOrderToInsert.WorkTypeId = workTypeSI.Id;
        	workOrderToInsert.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2C_EnelXItalia_WorkOrder').getRecordTypeId();
            workOrderToInsert.XC_Address__c = addrList[0].id;
            workOrderToInsert.XC_CreatedAutomaticallyBySystem__c = true;
            workOrderToInsert.XC_Country__c ='Italy';
            workOrderToInsert.XC_LegalEntity__c = 'EnelXItalia';
            workOrderToInsert.XC_Segment__c = 'B2C';
            workOrderToInsert.XC_To_Be_Manually_Assigned__c = false;
            workOrderToInsert.XC_Configuration__c = configuration.id;
            woListSI.add(workOrderToInsert);
        }
        insert woListSI;
        
        List<WorkOrder> woListRepair = new List<WorkOrder>();
        for (Integer i=0; i<3; i++){
            WorkOrder workOrderToInsert = new WorkOrder();
            workOrderToInsert.XC_WorkTypeCategory__c = Label.XC_CL_WorkType_Repair;
            workOrderToInsert.WorkTypeId = workTypeRepair.Id;
        	workOrderToInsert.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2C_EnelXItalia_WorkOrder').getRecordTypeId();
            workOrderToInsert.XC_Address__c = addrList[0].id;
            workOrderToInsert.XC_CreatedAutomaticallyBySystem__c = true;
            workOrderToInsert.XC_Country__c ='Italy';
            workOrderToInsert.XC_LegalEntity__c = 'EnelXItalia';
            workOrderToInsert.XC_Segment__c = 'B2C';
            workOrderToInsert.XC_To_Be_Manually_Assigned__c = false;
            workOrderToInsert.AssetId =assetList[0].id;
            woListRepair.add(workOrderToInsert);
        }
        insert woListRepair;
        
        User usersList = XC_DF_User.createUserAdmin();
        insert usersList;
         
        /*ServiceResource serviceRes = new ServiceResource();
        serviceRes.Name = finalAccPart[0].Name;
        serviceRes.XC_Account__c = finalAccPart[0].Id;
        serviceRes.IsActive = true;
        serviceRes.XC_IsManager__c = true;
        serviceRes.RelatedRecordId = usersList.Id;
        insert serviceRes;*/
        
        String chron = '0 0 23 * * ?';
        system.schedule('Test Sched060', chron,  new XC_SC060_AutoSchedule());
       Test.stopTest();
        
    }
}