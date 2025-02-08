/**
* @author Roberta Cossiga - rcossiga@deloitte.it || Emanuela Cacace - ecacace@deloitte.it
* @date Creation 01/07/2019
* @date Modification dd/mm/yyyy
* @description XC_LCC123_QualityInspectionWo_TEST – Test Class for XC_LCC123_QualityInspectionWorkOrder
*/ 

@isTest
public with sharing class XC_LCC123_QualityInspectionWo_TEST {
    
          // Test for checkExistingQualityWo method 
     static testMethod void checkExistingQualityWo(){
            insert XC_DF_OneOrg.createOneOrg('Spain');
            Test.startTest();
                List<Case> c = XC_DF_Case.createCases(1); 
                c[0].Status = 'ESTA001';
         		insert c;
         		List<WorkOrder> listwo = XC_DF_WorkOrder.createWorkOrders (1, Label.XC_CL_WorkType_QualityCheckInspection);
         		listwo[0].CaseId = c[0].Id; 
         		insert listwo;
				XC_UTIL_ResultWrapper result = XC_LCC123_QualityInspectionWorkOrder.checkExistingQualityWo (c[0].Id);
         		System.assert(result!=null);
            Test.stopTest();
     }

              // Test for checkAddressAndCreateWo method 
     static testMethod void checkAddressAndCreateWo(){
            insert XC_DF_OneOrg.createOneOrg('Spain');
            
         		List<Asset> listasset = XC_DF_Asset.createAssets(1);
   				insert listasset; 
                List<Case> c = XC_DF_Case.createCases(1);
                c[0].Status = 'ESTA001';
         		insert c;
         		List<Contact> listContact = new List<Contact> ([SELECT Id FROM Contact]);
             	List<Account> listAccount = new List<Account>([SELECT Id FROM Account WHERE RecordType.DeveloperName = 'XC_GLO_Account_Residential']);
         		listContact[0].AccountId = listAccount[0].Id;
         		update listContact;
         
         		List<XC_Address__c> listAddress = XC_DF_Address.createAddress(listAccount);
         		insert listAddress; 
		        WorkType workType = new WorkType();
                workType.Name = Label.XC_CL_WorkType_QualityCheckInspection;
                workType.XC_WorkTypeCategory__c = Label.XC_CL_WorkType_QualityCheckInspection;
                workType.DurationType = Label.XC_CL_WorkType_Hours;
                workType.EstimatedDuration = 1;
         		insert workType;
                Test.startTest();
         		WorkOrder listwo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_QualityCheckInspection)[0];
                listwo.CaseId = c[0].Id;
         		listwo.XC_Address__c = listAddress[0].Id;
                listwo.AssetId = listasset[0].Id; 
                listwo.ContactId = listContact[0].Id;
                listwo.AccountId = listAccount[0].Id;
         		listwo.XC_forSATO__c = true;
         		insert listwo;
                c[0].AccountId = listAccount[0].Id;
         		c[0].ContactId = listContact[0].Id;
         		c[0].XC_WorkOrder__c = listwo.Id;
        		update c ; 
				XC_UTIL_ResultWrapper result = XC_LCC123_QualityInspectionWorkOrder.checkAddressAndCreateWo (c[0].Id);
         		System.assert(result!=null);
            Test.stopTest();
     }
     static testMethod void checkAddressAndCreateWo2(){
         insert XC_DF_OneOrg.createOneOrg('Spain');
         
         List<Asset> listasset = XC_DF_Asset.createAssets(1);
         insert listasset; 
         List<Case> c = XC_DF_Case.createCases(1);
         c[0].Status = 'ESTA001';
         insert c;
         List<Contact> listContact = new List<Contact> ([SELECT Id FROM Contact]);
         List<Account> listAccount = new List<Account>([SELECT Id FROM Account WHERE RecordType.DeveloperName = 'XC_GLO_Account_Residential']);
         listContact[0].AccountId = listAccount[0].Id;
         update listContact;
         
         List<XC_Address__c> listAddress = XC_DF_Address.createAddress(listAccount);
         insert listAddress; 
         WorkType workType = new WorkType();
         workType.Name = Label.XC_CL_WorkType_QualityCheckInspection;
         workType.XC_WorkTypeCategory__c = Label.XC_CL_WorkType_QualityCheckInspection;
         workType.DurationType = Label.XC_CL_WorkType_Hours;
         workType.EstimatedDuration = 1;
         insert workType;
         Test.startTest();
         WorkOrder listwo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_QualityCheckInspection)[0];
         listwo.CaseId = c[0].Id;
         listwo.XC_Address__c = listAddress[0].Id;
         listwo.AssetId = listasset[0].Id; 
         listwo.ContactId = listContact[0].Id;
         listwo.AccountId = listAccount[0].Id;
         listwo.XC_forSATO__c = true;
         listwo.Status = Label.XC_CL_WorkOrder_Completed;
         insert listwo;
         c[0].AccountId = listAccount[0].Id;
         c[0].ContactId = listContact[0].Id;
         c[0].XC_WorkOrder__c = listwo.Id;
         update c ; 
         XC_UTIL_ResultWrapper result = XC_LCC123_QualityInspectionWorkOrder.checkAddressAndCreateWo (c[0].Id);
         System.assert(result!=null);
            Test.stopTest();
     }
}