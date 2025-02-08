/*
Action Plans v3
Force.com Labs
http://appexchange.salesforce.com/listingDetail?listingId=a0N30000003HcINEA0

Copyright (c) 2011, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, 
    this list of conditions and the following disclaimer in the documentation 
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors 
    may be used to endorse or promote products derived from this software 
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
OF THE POSSIBILITY OF SUCH DAMAGE.

*/

@isTest
public class ActionPlansBatchBuilder_Test { 

  @isTest
  private static void runBatchAccount(){
    
    ActionPlansTestUtil_Test ge = new ActionPlansTestUtil_Test();
    
    Test.startTest();
    
      ActionPlan__c ap = ge.createNewActionPlan( 'accounts' ,2);
      ap.Name= 'check_undelete';
      List<APTaskTemplate__c> apTasks = new List<APTaskTemplate__c>();
      User u = ge.createTestUser();
      
      APTaskTemplate__c at = new APTaskTemplate__c();
         at.Action_Plan__c    = ap.Id;
         at.Dependent__c     = 'None';
         at.DaysFromStart__c  = 2.0;
         at.User__c       = u.Id;
         at.SendEmail__c     = false;
         at.Subject__c     = 'Test ';
         at.Type__c       = 'Email';
         at.Priority__c     = 'Low';
         at.Comments__c     = 'Test';
         at.Reminder__c     = true;
         at.Minutes_Reminder__c = '510';
         insert at;
         apTasks.add(at);
         
         at = new APTaskTemplate__c();
         at.Action_Plan__c    = ap.Id;
         at.Dependent__c     = 'None';
         at.DaysFromStart__c  = 2.0;
         at.User__c       = u.Id;
         at.SendEmail__c     = true;
         at.Subject__c     = 'Test ';
         at.Type__c       = 'Email';
         at.Priority__c     = 'Low';
         at.Comments__c     = 'Test';
         at.Reminder__c     = true;
         at.Minutes_Reminder__c = '510';
         insert at;
         apTasks.add(at);
    
      List<Account> ac = XC_DF_Account.createResidentialAccounts(2);
      XC_UTIL_Sobject.insertListRecords( ac);
      
      List<string> oIdsList = new List<String>();
      oIdsList.add(ac[0].Id);
      oIdsList.add(ac[1].Id);
      
         ActionPlansBatchBuilder testBatch = new ActionPlansBatchBuilder( ap,apTasks,'Account', oIdsList );
          ID batchID = Database.executeBatch(testBatch, 20);
    Test.stopTest();
    
    AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :batchId];
    System.AssertEquals('Completed', a.status);
    System.AssertEquals(0, a.NumberOfErrors);  
    /*
    List<ActionPlan__c> l_ap = [Select Id from ActionPlan__c where name ='check_undelete'];
    
    if (l_ap.size()>0){
      delete l_ap;
      List <String> ids = new List <String>();
      ids.add(l_ap[0].Id);
      try{
        database.undelete (ids);
      }catch(Dmlexception e){
        //System.assert( e.getMessage().contains('Undelete failed.'),e.getMessage() );
      }
    }*/
  }
  
  @isTest
  private static void runBatchContact(){
    
    ActionPlansTestUtil_Test ge = new ActionPlansTestUtil_Test();
    
    Test.startTest();
    
      ActionPlan__c ap = ge.createNewActionPlan( 'contacts' ,2);
      List<APTaskTemplate__c> apTasks = new List<APTaskTemplate__c>();
      User u = ge.createTestUser();
      
      APTaskTemplate__c at = new APTaskTemplate__c();
         at.Action_Plan__c    = ap.Id;
         at.Dependent__c     = 'None';
         at.DaysFromStart__c  = 2.0;
         at.User__c       = u.Id;
         at.SendEmail__c     = false;
         at.Subject__c     = 'Test ';
         at.Type__c       = 'Email';
         at.Priority__c     = 'Low';
         at.Comments__c     = 'Test';
         at.Reminder__c     = true;
         at.Minutes_Reminder__c = '510';
         insert at;
         apTasks.add(at);
         
         at = new APTaskTemplate__c();
         at.Action_Plan__c    = ap.Id;
         at.Dependent__c     = 'None';
         at.DaysFromStart__c  = 2.0;
         at.User__c       = u.Id;
         at.SendEmail__c     = true;
         at.Subject__c     = 'Test ';
         at.Type__c       = 'Email';
         at.Priority__c     = 'Low';
         at.Comments__c     = 'Test';
         at.Reminder__c     = true;
         at.Minutes_Reminder__c = '510';
         insert at;
         apTasks.add(at);
    
      //Contact op = new Contact();
      //op.LastName ='Doe';
      Account accountToInsert = new Account();
      accountToInsert.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Condominium').getRecordTypeId();
      accountToInsert.Name = 'Test Account n.';
      accountToInsert.PrimaryEmail__c = 'test_con@email.com'; 
      accountToInsert.XC_DocumentCountry__c = 'Spain';
      accountToInsert.IdentityType__c = 'NIF';
      accountToInsert.IdentityNumber__c = '84715536G';
          insert accountToInsert;
      Contact op = new Contact();
      op.RecordTypeID = Schema.SObjectType.contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_Contact_Condominium').getRecordTypeId();
      op.FirstName = 'Test contact';
      op.LastName = 'Doe';
      op.Email = 'test_condominium@email.com';  
      op.AccountId = accountToInsert.Id;
      op.XC_GiveDataToNew__c = 'Yes';
      op.XC_SkipTriggerIndividual__c = true; 
      op.XC_CountryLegalEntity__c = 'Spain';
      op.XC_MainLegalEntity__c = 'EndesaX';
      insert op;
      
      //Contact op2 = new Contact();
      //op2.LastName ='Doe';
      Contact op2 = new Contact();
      op2.RecordTypeID = Schema.SObjectType.contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_Contact_Condominium').getRecordTypeId();
      op2.FirstName = 'Test contact';
      op2.LastName = 'Doe';
      op2.Email = 'test_condominium2@email.com';  
      op2.AccountId = accountToInsert.Id;
      op2.XC_GiveDataToNew__c = 'Yes';
      op2.XC_SkipTriggerIndividual__c = true; 
      op2.XC_CountryLegalEntity__c = 'Spain';
      op2.XC_MainLegalEntity__c = 'EndesaX';
      insert op2;
      
      List<string> oIdsList = new List<String>();
      oIdsList.add(op.Id);
      oIdsList.add(op2.Id);
      
         ActionPlansBatchBuilder testBatch = new ActionPlansBatchBuilder( ap,apTasks,'Contact',oIdsList);
          ID batchID = Database.executeBatch(testBatch, 20);
    Test.stopTest();
    
    AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :batchId];
    System.AssertEquals('Completed', a.status);
    System.AssertEquals(0, a.NumberOfErrors);
    
  }
  
  @isTest
  private static void runBatchOpportunity(){
    
    ActionPlansTestUtil_Test ge = new ActionPlansTestUtil_Test();
    
    Test.startTest();
    
    
      ActionPlan__c ap = ge.createNewActionPlan( 'opportunitys' ,2);
      List<APTaskTemplate__c> apTasks = new List<APTaskTemplate__c>();
    
      APTaskTemplate__c at = new APTaskTemplate__c();
         at.Action_Plan__c    = ap.Id;
         at.Dependent__c     = 'None';
         at.DaysFromStart__c  = 2.0;
         at.User__c       = ge.createTestUser().Id;
         at.SendEmail__c     = false;
         at.Subject__c     = 'Test ';
         at.Type__c       = 'Email';
         at.Priority__c     = 'Low';
         at.Comments__c     = 'Test';
         at.Reminder__c     = true;
         at.Minutes_Reminder__c = '510';
         insert at;
         apTasks.add(at);
         
         at = new APTaskTemplate__c();
         at.Action_Plan__c    = ap.Id;
         at.Dependent__c     = 'None';
         at.DaysFromStart__c  = 2.0;
         at.User__c       = ge.createTestUser().Id;
         at.SendEmail__c     = true;
         at.Subject__c     = 'Test ';
         at.Type__c       = 'Email';
         at.Priority__c     = 'Low';
         at.Comments__c     = 'Test';
         at.Reminder__c     = true;
         at.Minutes_Reminder__c = '510';
         insert at;
         apTasks.add(at);
    
      //Opportunity op = new Opportunity();
      //op.Name ='Op1';
      //op.StageName = 'Won';
      //op.CloseDate = Date.today();
      Account accountToInsert = new Account();
      accountToInsert.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Condominium').getRecordTypeId();
      accountToInsert.Name = 'Test Account n.1';
      accountToInsert.PrimaryEmail__c = 'test_con@email.com'; 
      accountToInsert.XC_DocumentCountry__c = 'Spain';
      accountToInsert.IdentityType__c = 'NIF';
      accountToInsert.IdentityNumber__c = '84715536G';
      insert accountToInsert;
      Contact newContact = new Contact();
      newContact.RecordTypeID = Schema.SObjectType.contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_Contact_Condominium').getRecordTypeId();
      newContact.FirstName = 'Test contact';
      newContact.LastName = 'Test contact';
      newContact.Email = 'test_condominium@email.com';  
      newContact.AccountId = accountToInsert.Id;
      newContact.XC_GiveDataToNew__c = 'Yes';
      newContact.XC_SkipTriggerIndividual__c = true; 
      newContact.XC_CountryLegalEntity__c = 'Spain';
      newContact.XC_MainLegalEntity__c = 'EndesaX';
      insert newContact;
      XC_Address__c addressToInsert = new XC_Address__c();
      addressToInsert.XC_Account__c = accountToInsert.Id;
      addressToInsert.XC_Address__c = 'Ba ba ba ba ba';
      addressToInsert.XC_City__c = 'Madrid';
      addressToInsert.XC_AddressCountry__c = 'Spain';
      addressToInsert.XC_PostalCode__c = '28080';
      addressToInsert.XC_AddressProvince__c = 'Madrid';
      addressToInsert.XC_StreetNumber__c = '1';
      addressToInsert.XC_StreetType__c = 'Street'; 
      addressToInsert.XC_Municipality__c   = 'Test';
      addressToInsert.XC_Stair__c = '7';
      addressToInsert.XC_Floor__c = 'B';
      insert addressToInsert;
      List<String> lstPickvals = new List<String>();
    List<Schema.PicklistEntry> listActiveValues = new List<Schema.PicklistEntry>();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('Lead');
        Schema.DescribeSObjectResult describeObjResult = objType.getDescribe();
        Schema.DescribeFieldResult describeResult = describeObjResult.fields.getMap().get('XC_ProductCategoryOfInterest__c').getDescribe();
        List<Schema.PicklistEntry> allPicklistValues = describeResult.getPicklistValues();
        for(Schema.PicklistEntry f : allPicklistValues){
            if(f.isActive()){
                listActiveValues.add(f);
            }
        }
    List<Schema.PicklistEntry> picklistValues = listActiveValues; 
        for(Schema.PicklistEntry a : picklistValues) { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        } 
    String prodName = lstPickvals[1];
      XC_ProductCategoryOfInterest__c prodCat = new XC_ProductCategoryOfInterest__c();
      prodCat.Name = prodName;
      prodCat.XC_CommercialVisit__c = false;
      insert prodCat;
      Opportunity op = new Opportunity();
      op.Name = 'Op1';
      op.XC_Contact__c = newContact.Id;
      op.AccountId = accountToInsert.Id;
      op.XC_ProductCategoryOfInterest__c = prodCat.Name;
      op.CloseDate = Date.today();
      op.StageName = 'Draft';
      op.XC_Source__c = 'BLOG';
      op.XC_ReceivingChannel__c = 'Web';
      op.XC_Address__c = addressToInsert.Id;
      insert op;

      
      //Opportunity op2 = new Opportunity();
      //op2.Name ='Op2';
      //op2.StageName = 'Won';
      //op2.CloseDate = Date.today();
      Opportunity op2 = new Opportunity();
      op2.Name = 'Op2';
      op2.XC_Contact__c = newContact.Id;
      op2.AccountId = accountToInsert.Id;
      op2.XC_ProductCategoryOfInterest__c = prodCat.Name;
      op2.CloseDate = Date.today();
      op2.StageName = 'Draft';
      op2.XC_Source__c = 'BLOG';
      op2.XC_ReceivingChannel__c = 'Web';
      op2.XC_Address__c = addressToInsert.Id;
      insert op2;
      
      List<string> oIdsList = new List<String>();
      oIdsList.add(op.Id);
      oIdsList.add(op2.Id);
      
         ActionPlansBatchBuilder testBatch = new ActionPlansBatchBuilder( ap,apTasks,'Opportunity',oIdsList);
          ID batchID = Database.executeBatch(testBatch, 20);
    Test.stopTest();
    
    AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :batchId];
    System.AssertEquals('Completed', a.status);
    System.AssertEquals(0, a.NumberOfErrors);
    
    
  }
  
  @isTest
  private static void runBatchException(){
    ActionPlansBatchBuilder.throwExceptionInTest = true;
/*    ActionPlansTestUtil_Test ge = new ActionPlansTestUtil_Test();
    
    ActionPlan__c ap = ge.createNewActionPlan( 'leads' ,2);
    List<APTaskTemplate__c> apTasks = new List<APTaskTemplate__c>();
    List<string> oIdsList = new List<String>();
    
    Test.startTest();
         ActionPlansBatchBuilder testBatch = new ActionPlansBatchBuilder( ap,apTasks,'Opportunity',oIdsList);
          ID batchID = Database.executeBatch(testBatch, 20);
    Test.stopTest();
    
    AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :batchId];
    System.AssertEquals('Completed', a.status);*/
    ActionPlansTestUtil_Test ge = new ActionPlansTestUtil_Test();
    
    Test.startTest();
    
    
      ActionPlan__c ap = ge.createNewActionPlan( 'opportunitys' ,2);
      List<APTaskTemplate__c> apTasks = new List<APTaskTemplate__c>();
    
      APTaskTemplate__c at = new APTaskTemplate__c();
         at.Action_Plan__c    = ap.Id;
         at.Dependent__c     = 'None';
         at.DaysFromStart__c  = 2.0;
         at.User__c       = ge.createTestUser().Id;
         at.SendEmail__c     = false;
         at.Subject__c     = 'Test ';
         at.Type__c       = 'Email';
         at.Priority__c     = 'Low';
         at.Comments__c     = 'Test';
         at.Reminder__c     = true;
         at.Minutes_Reminder__c = '510';
         insert at;
         apTasks.add(at);
         
         at = new APTaskTemplate__c();
         at.Action_Plan__c    = ap.Id;
         at.Dependent__c     = 'None';
         at.DaysFromStart__c  = 2.0;
         at.User__c       = ge.createTestUser().Id;
         at.SendEmail__c     = true;
         at.Subject__c     = 'Test ';
         at.Type__c       = 'Email';
         at.Priority__c     = 'Low';
         at.Comments__c     = 'Test';
         at.Reminder__c     = true;
         at.Minutes_Reminder__c = '510';
         insert at;
         apTasks.add(at);
    
      //Opportunity op = new Opportunity();
      //op.Name ='Op1';
      //op.StageName = 'Won';
      //op.CloseDate = Date.today();
      Account accountToInsert = new Account();
      accountToInsert.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Condominium').getRecordTypeId();
      accountToInsert.Name = 'Test Account n.1';
      accountToInsert.PrimaryEmail__c = 'test_con@email.com'; 
      accountToInsert.XC_DocumentCountry__c = 'Spain';
      accountToInsert.IdentityType__c = 'NIF';
      accountToInsert.IdentityNumber__c = '84715536G';
      insert accountToInsert;
      Contact newContact = new Contact();
      newContact.RecordTypeID = Schema.SObjectType.contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_Contact_Condominium').getRecordTypeId();
      newContact.FirstName = 'Test contact';
      newContact.LastName = 'Test contact';
      newContact.Email = 'test_condominium@email.com';  
      newContact.AccountId = accountToInsert.Id;
      newContact.XC_GiveDataToNew__c = 'Yes';
      newContact.XC_SkipTriggerIndividual__c = true; 
      newContact.XC_CountryLegalEntity__c = 'Spain';
      newContact.XC_MainLegalEntity__c = 'EndesaX';
      insert newContact;
      XC_Address__c addressToInsert = new XC_Address__c();
      addressToInsert.XC_Account__c = accountToInsert.Id;
      addressToInsert.XC_Address__c = 'Address Name fgardefgh';
      addressToInsert.XC_City__c = 'Madrid';
      addressToInsert.XC_AddressCountry__c = 'Spain';
      addressToInsert.XC_PostalCode__c = '28080';
      addressToInsert.XC_AddressProvince__c = 'Madrid';
      addressToInsert.XC_StreetNumber__c = '1';
      addressToInsert.XC_StreetType__c = 'Street'; 
      addressToInsert.XC_Municipality__c   = 'Test';
      addressToInsert.XC_Stair__c = '7';
      addressToInsert.XC_Floor__c = 'B';
      insert addressToInsert;
      List<String> lstPickvals = new List<String>();
    List<Schema.PicklistEntry> listActiveValues = new List<Schema.PicklistEntry>();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('Lead');
        Schema.DescribeSObjectResult describeObjResult = objType.getDescribe();
        Schema.DescribeFieldResult describeResult = describeObjResult.fields.getMap().get('XC_ProductCategoryOfInterest__c').getDescribe();
        List<Schema.PicklistEntry> allPicklistValues = describeResult.getPicklistValues();
        for(Schema.PicklistEntry f : allPicklistValues){
            if(f.isActive()){
                listActiveValues.add(f);
            }
        }
    List<Schema.PicklistEntry> picklistValues = listActiveValues; 
        for(Schema.PicklistEntry a : picklistValues) { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        } 
    String prodName = lstPickvals[1];
      XC_ProductCategoryOfInterest__c prodCat = new XC_ProductCategoryOfInterest__c();
      prodCat.Name = prodName;
      prodCat.XC_CommercialVisit__c = false;
      insert prodCat;
      Opportunity op = new Opportunity();
      op.Name = 'Op1';
      op.XC_Contact__c = newContact.Id;
      op.AccountId = accountToInsert.Id;
      op.XC_ProductCategoryOfInterest__c = prodCat.Name;
      op.CloseDate = Date.today();
      op.StageName = 'Draft';
      op.XC_Source__c = 'BLOG';
      op.XC_ReceivingChannel__c = 'Web';
      op.XC_Address__c = addressToInsert.Id;
      insert op;

      
      //Opportunity op2 = new Opportunity();
      //op2.Name ='Op2';
      //op2.StageName = 'Won';
      //op2.CloseDate = Date.today();
      Opportunity op2 = new Opportunity();
      op2.Name = 'Op2';
      op2.XC_Contact__c = newContact.Id;
      op2.AccountId = accountToInsert.Id;
      op2.XC_ProductCategoryOfInterest__c = prodCat.Name;
      op2.CloseDate = Date.today();
      op2.StageName = 'Draft';
      op2.XC_Source__c = 'BLOG';
      op2.XC_ReceivingChannel__c = 'Web';
      op2.XC_Address__c = addressToInsert.Id;
      insert op2;
      
      List<string> oIdsList = new List<String>();
      oIdsList.add(op.Id);
      oIdsList.add(op2.Id);
      
         ActionPlansBatchBuilder testBatch = new ActionPlansBatchBuilder( ap,apTasks,'Opportunity',oIdsList);
          ID batchID = Database.executeBatch(testBatch, 20);
    Test.stopTest();
    
    AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :batchId];
    System.AssertEquals('Completed', a.status);
    System.AssertEquals(0, a.NumberOfErrors);
    
  }

}