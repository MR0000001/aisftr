/**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 29/04/2019
* @description XC_DF_Account – Data Factory for Account
*/
@isTest

public class XC_DF_Account {
    
      /** 
     * @author Roberta Porrega - roberta.porrega@nttdata.com / Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Method to create N Residential accounts
     * @param n - Number of accounts to be created
     * @return  List<Account> to insert
    */
    public static List<Account> createResidentialAccounts(Integer n){
        List<Account> listAccounts = new List<Account>();
        for (Integer i=0; i<n; i++){
            Account accountToInsert = new Account();
            accountToInsert.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Residential').getRecordTypeId();
            accountToInsert.XC_FirstName__c = 'TestAccountN' + (Math.random()*Math.random());
            accountToInsert.XC_LastName__c = 'TestAccountN' + (Math.random()*Math.random());
            accountToInsert.PrimaryEmail__c = 'test_res' + (Math.random()*Math.random()) + '@email.com';
            accountToInsert.XC_DocumentCountry__c = 'Spain';
            accountToInsert.IdentityType__c='Passport';
            accountToInsert.IdentityNumber__c='3526173'+ (Math.random()*Math.random());
            accountToInsert.XC_CommercialCode__c='AAA123';
            accountToInsert.XC_InternalCommercialCode__c='BBB123';
            accountToInsert.name = 'Test Account n ' + (Math.random()*Math.random());
            listAccounts.add(accountToInsert);
        }
        return listAccounts;
    }
    
    
     /** 
     * @author Roberta Porrega - roberta.porrega@nttdata.com / Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Method to create N Condominium accounts
     * @param n - Number of accounts to be created
     * @return  List<Account> to insert
    */
    public static List<Account> createCondominiumAccounts(Integer n){
        List<Account> listAccounts = new List<Account>();
        for (Integer i=0; i<n; i++){
            Account accountToInsert = new Account();
            accountToInsert.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Condominium').getRecordTypeId();
            accountToInsert.Name = 'Test Account n ' + (Math.random()*Math.random());
            accountToInsert.PrimaryEmail__c = 'test_con' + (Math.random()*Math.random()) + '@email.com'; 
            accountToInsert.XC_DocumentCountry__c = 'Spain';
            accountToInsert.IdentityType__c = 'NIF';
            accountToInsert.IdentityNumber__c = '84715536G';
            listAccounts.add(accountToInsert);
        }
        return listAccounts;
    }
    
    
     /** 
     * @author Roberta Porrega - roberta.porrega@nttdata.com / Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Method to create N Partner accounts
     * @param n - Number of accounts to be created
     * @return  List<Account> to insert
     */
    public static List<Account> createSohoAccounts(Integer n){
        List<Account> listAccounts = new List<Account>();
        for (Integer i=0; i<n; i++){
            Account accountToInsert = new Account();
            accountToInsert.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Soho').getRecordTypeId();
            accountToInsert.Name = 'Test Account n ' + (Math.random()*Math.random());
            accountToInsert.PrimaryEmail__c = 'test_soho' + (Math.random()*Math.random()) + '@email.com'; 
            accountToInsert.XC_DocumentCountry__c = 'Spain';
            accountToInsert.IdentityType__c = 'NIF';
            accountToInsert.IdentityNumber__c = '11400283B';
            listAccounts.add(accountToInsert);
        }
        return listAccounts;
    }
    
     /** 
     * @author Roberta Porrega - roberta.porrega@nttdata.com / Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Method to create N Soho accounts
     * @param n - Number of accounts to be created
     * @return  List<Account> to insert
     */
    public static List<Account> insertPartnerAccounts(Integer n){
        return insertPartnerAccounts(n, Label.XC_CL_Account_StatusActive);
    }
    
    
       /** 
     * @author Roberta Porrega - roberta.porrega@nttdata.com / Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Method to create N Soho accounts
     * @param n - Number of accounts to be created
     * @param status - status of Account
     * @return  List<Account> to insert
     */
    public static List<Account> insertPartnerAccounts(Integer n, String status){
        List<Account> listAccounts = new List<Account>();
        for (Integer i=0; i<n; i++){
            Account accountToInsert = new Account();
            accountToInsert.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_Account_Partner').getRecordTypeId();
            accountToInsert.Name = 'Test Account n ' + (Math.random()*Math.random());
            accountToInsert.PrimaryEmail__c = 'test_partner' + (Math.random()*Math.random()) + '@email.com';
            accountToInsert.XC_Status__c = status; 
            accountToInsert.IdentityType__c='Passport';
            accountToInsert.IdentityNumber__c='3526173'+ (Math.random()*Math.random());
            
            listAccounts.add(accountToInsert);
        }
        insert listAccounts;
        for(account acc : listAccounts){
            acc.isPartner = true;
        }
        update listAccounts;
        return listAccounts;
    }
}