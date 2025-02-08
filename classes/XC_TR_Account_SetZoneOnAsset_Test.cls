/*
 * @author              : Sajan Sooraj sooraji.sajan@accenture.com - Raffaele Sojka raffaele.sojka@accenture.com
 * @group               : ACN Team
 * @created date        : 24-03-2022
 * @last modified date  : 24-03-2022
*/
@isTest
public class XC_TR_Account_SetZoneOnAsset_Test {
    
   static testMethod void test(){
       
        NE__Order__c ord = XC_DF_Order.createOrder('test');
        List<Asset> asstValues = XC_DF_Asset.createAssets(1);
        List<Account> accPartList = XC_DF_Account.insertPartnerAccounts(1);
        List<Account> accountList = new List<Account>();
        List<Asset> assetList = new List<Asset>();
       
        Account accountToInsert = new Account();
        accountToInsert.Id = accPartList[0].id;
        accountToInsert.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
        accountToInsert.XC_DocumentCountry__c = 'Italy';
        accountToInsert.XC_Zone__c='B2G-B2G';
        accountToInsert.XC_Segment__c = 'B2B';
        update accountToInsert;
 
        Asset asst = new Asset();
        asst.Name = 'TestAsset';
        asst.AccountId = accPartList[0].id;
        asst.XC_LegalEntity__c = 'EndesaX';
		asst.XC_Segment__c = 'B2C';
        asst.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('TAM_Network').getRecordTypeId();
        insert asst;
        System.debug('Recordtype ='+ asst.RecordType.DeveloperName );
       
        
      
        accountToInsert.XC_Zone__c='e-Mobility - Sud - Sicilia';
        update accountToInsert;
        accountList.add( accPartList[0]);
       
        User u = XC_DF_User.createUserAdmin();
         
        Map<id,Account> mapNew= new Map <id,Account>();
   		mapNew.put(accountList[0].id,accountList[0]);
        
        Map<id,Account> mapOld= new Map <id,Account>();
   		mapOld.put(accountList[0].id,accountList[0]); 
        
        insert u;
        
        Test.startTest();
        System.runAs(u)
        
        {
           XC_TR_Account_SetZoneOnAsset.setZoneOnAsset(accountList,mapOld,mapNew);
           List<String> fieldList = new List<String>{'XC_Zone__c'};
           List<Account> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
           
            if(!listChanged.isEmpty()){
              System.assertEquals('B2G-B2G', asst.XC_AccountZone__c);
                
                
            }
            
        }
        Test.stopTest(); 
        
    }
}