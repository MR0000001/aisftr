/** 
* @author Greta Romei/De Blasio Valentina - greta.romei@accenture.com
* @date Creation 22/02/2022
* @description - XC_TR_Sla_Managment_Test – Test class for XC_TR_Sla_Managment
 */

@isTest
public class XC_TR_Sla_Managment_Test {
    
    @isTest 
     static void insertDefaultEntitlement(){
         insert XC_DF_OneOrg.createOneOrg('Spain');
             Account accountToInsert = new Account();
             accountToInsert.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2G').getRecordTypeId();
             accountToInsert.Name = 'Test Account n ' + (Math.random()*Math.random());
             accountToInsert.Company__c = 'Test Account Company n ' + (Math.random()*Math.random());            
             accountToInsert.XC_DocumentCountry__c = 'Argentina';           
             accountToInsert.PrimaryEmail__c = 'test_b2b' + (Math.random()*Math.random()) + '@email.com'; 
             accountToInsert.XC_DocumentCountry__c = 'Spain';
             accountToInsert.IdentityType__c = 'NIF';
             accountToInsert.IdentityNumber__c = '11400283B'; 
             accountToInsert.Country__c = 'Italy'; //DeAv add for fix CR760          
             Test.startTest();
             insert accountToInsert;
             SlaProcess spList=[Select id,Name from SlaProcess where Name='GU_SLAPROCESS_DEFAULT_24H']; 
             Entitlement etGU=new Entitlement ();
             etGU.AccountId=accountToInsert.Id;
             etGU.name='GU';
             etGU.SlaProcessId=spList.id;
             insert etGU; 
             SlaProcess spList2=[Select id,Name from SlaProcess where Name='IP_SLAPROCESS_DEFAULT_2H']; 
             Entitlement etIP=new Entitlement ();
             etIP.AccountId=accountToInsert.Id;
             etIP.name='IP';
             etIP.SlaProcessId=spList2.id;
             insert etIP;   
             SlaProcess spList4=[Select id,Name from SlaProcess where Name='IG_SLAPROCESS_DEFAULT_48H']; 
             Entitlement etIG=new Entitlement();
             etIG.AccountId=accountToInsert.Id;
             etIG.name='IG';
             etIG.SlaProcessId=spList2.id;
             insert etIG;   
             SlaProcess spList3=[Select id,Name from SlaProcess where Name='IS_SLAPROCESS_DEFAULT_2H']; 
             Entitlement etIS=new Entitlement ();
             etIS.AccountId=accountToInsert.Id;
             etIS.name='IS';
             etIS.SlaProcessId=spList3.id;
             insert etIS;   
             Test.stopTest();
        
     }
   
}