/**
* @author FirstName : Patrizia Arcidiacono - patrizia.arcidiacono@nttdata.com
* @date Creation 28/01/2020
* @date Modification dd/mm/yyyy
* @description giic_UTIL_TransferOrderSharing_TEST
*/

@isTest
public with sharing class giic_UTIL_TransferOrderSharing_TEST {
	@TestSetup
    static void  setupData() {
     
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        Giic_UtilityClass_Test.accountCreation();
        Account accModRT = [Select Recordtype.Id, RecordType.DeveloperName from Account where Id=: Giic_UtilityClass_Test.objAccountCentral.Id];
        system.debug('@@@@ accModRt:' + accModRT.RecordType.DeveloperName);
        recordType idRT =[Select developername from Recordtype where name ='Partner' and developerName ='XC_Account_Partner'];
		accModRT.recordTypeId = idRT.id;
        update accModRT;
		       
        system.debug('@@@@ accModRt:' + idRT.developername);
        List<account> acc = [Select id From Account where id=:accModRT.Id];
      
        List<Contact> cont = XC_DF_Contact.createPartnerContacts(acc);
        system.debug('@@@@ cont:' + cont);

        insert cont;
        system.debug('@@@@ cont:' + cont);

    
        Giic_UtilityClass_Test.wareHouseGroupCreation();
       
        Giic_UtilityClass_Test.warehouseCreation();
                     
        Giic_UtilityClass_Test.productCreation();
  		gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c IN: Giic_UtilityClass_Test.lstProd Limit 1];
        objProdRef.gii__SerialControlled__c=true;
        objProdRef.giic_ProcurementType__c = 'Transfer';
        objProdRef.gii__PrimarySupplier__c = Giic_UtilityClass_Test.objAccountSupplier.Id;
        
        update objProdRef;
        
        system.debug('@@@@ insert obj ProductReference'); 
        Giic_UtilityClass_Test.SalesOrderCreation();
        Giic_UtilityClass_Test.salesOrderLineCreation(objProdRef);
		//Giic_UtilityClass_Test.transferOrderCreation();
    
    }
    
    static testMethod void test1(){
           
            Contact cont= [SELECT Id, accountId,account.Name, FirstName, LastName, Email
                                FROM Contact where FirstName ='Test contact'];
      		system.debug('@@@er test1 contct: a' + cont.FirstName);
            Profile profile = [SELECT Id FROM Profile WHERE Name = 'XC_ESP_PartnerAdmin']; 
            system.debug('@@@er profile: ' + Profile);
        	
           	Integer i = 0;
        	User user1 = new User();
            user1.Username = cont.FirstName.deleteWhitespace()+'_number_' + i +'@test.com';  
            user1.FirstName = cont.FirstName;
            user1.LastName = cont.LastName;
            user1.ContactId = cont.Id;
            user1.Email = cont.Email; 
            user1.CommunityNickname = cont.FirstName + '_number_' + i;
            user1.Alias = cont.FirstName.substring(0,4); 
            user1.ProfileId = profile.Id;
            user1.LocaleSidKey = 'it_IT';
            user1.TimeZoneSidKey = 'GMT';
            user1.LanguageLocaleKey = 'en_US';
            user1.EmailEncodingKey = 'ISO-8859-1'; 
            user1.IsActive = true; 
            user1.Country__c = 'SPAIN';
            insert user1;
           	
        	
            Test.StartTest();
        	
        	myFunc2();
			Test.stopTest();
        	
     }
     
     @future
	private static void myFunc2()

    {
       	account acc = [Select id from account where name ='Enel-X Central'];
        system.debug('@@@er acc: ' + acc);
        gii__warehouse__c CW= [select id from gii__warehouse__c where name ='Central Warehouse'];
        system.debug('@@@er CW: ' + CW);
        gii__warehouse__c LW = [select id from gii__warehouse__c where name ='Local Warehouse'];
        system.debug('@@@er LW: ' + LW);
        Giic_UtilityClass_Test.transferOrderCreationParam(LW.Id, CW.Id, acc.Id);	
       ///2nd DML operation
    
    }
       
}