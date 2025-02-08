/*
 * @author              : Sajan Sooraj sooraji.sajan@accenture.com - Raffaele Sojka raffaele.sojka@accenture.com
 * @group               : ACN Team
 * @created date        : 24-03-2022
 * @last modified date  : 24-03-2022
*/
@isTest
public class XC_TR_Address_SetProvinceOnAsset_Test {
    
    static testMethod void test(){
       
        NE__Order__c ord = XC_DF_Order.createOrder('test');
        List<Asset> asstValues = XC_DF_Asset.createAssets(1);
        List<Account> accPartList = XC_DF_Account.insertPartnerAccounts(1);
        List<XC_Address__c> addrPartList = XC_DF_Address.createAddress(accPartList);
        List<XC_Address__c> addrList = new List<XC_Address__c>();
        List<Asset> assetList = new List<Asset>();
        
        Account accountToInsert = new Account();
        accountToInsert.Id = accPartList[0].id;
        accountToInsert.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
        accountToInsert.XC_DocumentCountry__c = 'Italy';
        accountToInsert.XC_Zone__c='B2G-B2G';
        accountToInsert.XC_Segment__c = 'B2B';
        update accountToInsert;
        
        XC_Address__c addrToInsert = new XC_Address__c();
        addrToInsert.Id = addrPartList[0].id;
        addrToInsert.RecordTypeId = Schema.SObjectType.XC_Address__c.getRecordTypeInfosByDeveloperName().get('XC_GLO_Address_Partner').getRecordTypeId();
        addrToInsert.XC_Account__c = accountToInsert.id;
        addrToInsert.XC_AddressProvince__c='Alba';
        
        insert addrToInsert;
        Asset asst = new Asset();
        asst.Id = asstValues[0].id;
        asst.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('TAM_Network').getRecordTypeId();
        asst.XC_Address__c = addrToInsert.id;
        asst.Name = 'TestAsset';
        asst.XC_LegalEntity__c = 'EndesaX';
		asst.XC_Segment__c = 'B2C';
        insert asst;
      
        addrToInsert.XC_AddressProvince__c='Allier';
        update addrToInsert;
        addrList.add(addrToInsert);
       
        User u = XC_DF_User.createUserAdmin();
         
        Map<id,XC_Address__c> mapNew= new Map <id,XC_Address__c>();
   		mapNew.put(addrList[0].id,addrList[0]);
       
        
        Map<id,XC_Address__c> mapOld= new Map <id,XC_Address__c>();
   		mapOld.put(addrList[0].id,addrList[0]); 
        
        insert u;
        
        Test.startTest();
        System.runAs(u)
        
        {
           XC_TR_Address_SetProvinceOnAsset.setProvinceOnAsset(addrList,mapOld,mapNew);
           List<String> fieldList = new List<String>{'XC_AddressProvince__c'};
           List<XC_Address__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
           
            if(!listChanged.isEmpty()){
              System.assertEquals('Alaska', asst.XC_AddressProvince__c);
                
                
            }
            
        }
        Test.stopTest(); 
        
    }

}