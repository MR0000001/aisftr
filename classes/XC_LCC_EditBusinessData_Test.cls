@IsTest
public class XC_LCC_EditBusinessData_Test {
    
    @TestSetup
    static void setup(){
    Account acc = new Account();
      acc.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Condominium').getRecordTypeId();
      acc.Name = 'Test Account n.';
      acc.PrimaryEmail__c = 'test_con@email.com'; 
      acc.XC_DocumentCountry__c = 'Spain';
      acc.IdentityType__c = 'NIF';
      acc.IdentityNumber__c = '84715536G';
      insert acc;
    Asset assetTest = new Asset();
        assetTest.XC_LegalEntity__c = 'EndesaX';
        assetTest.XC_Segment__c = 'B2B';
        assetTest.Name = 'BOMBILLA LED LG DICROICA 5_4W MR16';
        assetTest.AccountId = acc.Id;
        insert assetTest;  
    Contract cont = new Contract();
        cont.AccountId       = acc.Id;
        cont.XC_LegalEntity__c = null;
        cont.StartDate       = Date.today();
        cont.ContractTerm    = 1;
        cont.XC_ContractSAP__c='test';//CR762 11-07-22
        insert cont;
    }
     @isTest
     static void queryAssetTest(){
     String recordId = [SELECT Id FROM Asset LIMIT 1].Id;
     String contId = [SELECT Id FROM Contract LIMIT 1].Id;    
       Test.startTest();
            XC_LCC_EditBusinessData.queryAsset(recordId,contId);
        Test.stopTest();
    }
    @isTest
     static void checkContractTest(){
     String contId = [SELECT Id FROM Contract LIMIT 1].Id;
       Test.startTest();
         try{
             XC_LCC_EditBusinessData.checkContract(contId);
         }
          catch(exception e){
                 
             }
            
        Test.stopTest();
    }
    @isTest
     static void selectConfermaTest(){
         String recordId = [SELECT Id FROM Asset LIMIT 1].Id;
          String contId = [SELECT Id,XC_ContractSAP__c FROM Contract where XC_ContractSAP__c !=null  LIMIT 1].XC_ContractSAP__c;//CR762 11-07-22
       Test.startTest();   
         
         XC_LCC_EditBusinessData.Product2ContactLineItemWrapper SelectedRows = new XC_LCC_EditBusinessData.Product2ContactLineItemWrapper(); 
         SelectedRows.Id=recordId;
         List<XC_LCC_EditBusinessData.Product2ContactLineItemWrapper> SelectedRowsList = new List<XC_LCC_EditBusinessData.Product2ContactLineItemWrapper>{SelectedRows};
       
         
         XC_LCC_EditBusinessData.selectConferma(contId,'test2','test3',System.today()+5,SelectedRowsList,'Schedula');//CR762 11-07-22
         XC_LCC_EditBusinessData.selectConferma(contId,'test2','test3',System.today(),SelectedRowsList,'AnnullaSchedulazione');
         XC_LCC_EditBusinessData.selectConferma(contId,'test2','test3',System.today(),SelectedRowsList,'RimuoviContratto');
         XC_LCC_EditBusinessData.selectConferma(contId,'test2','test3',System.today(),SelectedRowsList,'test4');
        Test.stopTest();
    }
    //START CR762 11-07-22
    @isTest
     static void getSAPContract(){
     	String contId = [SELECT Id,XC_ContractSAP__c FROM Contract where XC_ContractSAP__c !=null  LIMIT 1].Id;
      	 Test.startTest();
         XC_LCC_EditBusinessData.getSAPContract(contId);
     	Test.stopTest();
   
     }
     @isTest
     static void getAccountContractsTest(){
     String recordId = [SELECT Id FROM Asset LIMIT 1].Id;
     String contId = [SELECT Id FROM Contract LIMIT 1].Id;
       Test.startTest();
             XC_LCC_EditBusinessData.getAccountContracts(recordId,contId);      
        Test.stopTest();
    }
    //END CR762 11-07-22
}