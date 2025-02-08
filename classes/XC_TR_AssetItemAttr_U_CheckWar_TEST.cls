/**
* @author Sara Miozza sara.miozza@nttdata.com
* @date Creation 21/05/2019
* @date Modification gg/mm/yyyy
* @description XC_TR_AssetItemAttr_U_CheckWar_TEST test class for XC_TR_AssetItemAttribute_U_CheckWarranty - Manage the Warranty Asset
*/

@isTest
public class XC_TR_AssetItemAttr_U_CheckWar_TEST {
    
    	   
    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }

    
    static testMethod void afterAssetItemAttributeInsertTest(){
         List<Asset> assetList = XC_DF_Asset.createAssets(1); 
        insert assetList;
        List<NE__AssetItemAttribute__c> listAtt = new List<NE__AssetItemAttribute__c>();
        NE__AssetItemAttribute__c assetAttribute = new NE__AssetItemAttribute__c(Name = Label.XC_CL_AssetItemAttribute_Warranty,NE__Value__c = '3 years renting',
                                                                                 		NE__Old_Value__c = 'One Shot',
        		                                                                       NE__Asset__c = assetList[0].Id);
        listAtt.add(assetAttribute);
        Test.startTest();
        insert listAtt;
        Test.stopTest();
        System.assert(listAtt[0].Name == Label.XC_CL_AssetItemAttribute_Warranty);
        
    }     
   
    static testMethod void afterAssetItemAttributeUpdateTest(){
        List<Asset> assetList = XC_DF_Asset.createAssets(1); 
        insert assetList;
        List<NE__AssetItemAttribute__c> listAtt = new List<NE__AssetItemAttribute__c>();
        NE__AssetItemAttribute__c assetAttribute = new NE__AssetItemAttribute__c(Name = Label.XC_CL_AssetItemAttribute_Warranty,NE__Value__c = '3 years renting',
                                                                                 		
        		                                                                       NE__Asset__c = assetList[0].Id);
        listAtt.add(assetAttribute);
        test.startTest();
        insert listAtt;
        for(NE__AssetItemAttribute__c att : listAtt){
    		att.NE__Value__c = 'One Shot';
        }    
        update listAtt;
        delete listAtt;
		test.stopTest();
        System.assert(listAtt[0].Name == Label.XC_CL_AssetItemAttribute_Warranty);
        
    }     
               
}