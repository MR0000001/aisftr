/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 13/05/2019
* @description XC_DF_Asset – Data Factory for Asset
*/
@isTest
public class XC_DF_Asset { 

     /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Method to Assets
     * @param n - number of asset
     * @return  List<Asset> to insert
    */
    public static List<Asset> createAssets(Integer n){
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(n);
        insert accountList;
        Id recTypeAssetId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
        List<Asset> assetList = new List<Asset>();
        for (Integer i=0; i<n; i++){
			Asset asst = new Asset();
            asst.Name = 'Test ' + i;
            asst.AccountId = accountList[i].Id;
            asst.RecordTypeId = recTypeAssetId;
            asst.XC_LegalEntity__c = Label.XC_CL_EndesaX;
            asst.XC_Segment__c  = 'B2C';
            assetList.add(asst);
        }
 		return assetList;
    }

    /**
     * @author Simone Trenta - strenta@deloitte.it
     * @description Method to Assets
     * @param accountList - accounts to link to assets
     * @return  List<Asset> to insert
    */
    public static List<Asset> createAssets(List<Account> accountList){
        List<Asset> assetList = new List<Asset>();
        Id recTypeAssetId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
        for (Integer i=0; i<accountList.size(); i++){
			Asset asst = new Asset();
            asst.Name = 'Test ' + i;
            asst.AccountId = accountList[i].Id;
            asst.RecordTypeId = recTypeAssetId;
            asst.XC_LegalEntity__c = Label.XC_CL_EndesaX;
            asst.XC_Segment__c  = 'B2C';
            assetList.add(asst);
        }
 		return assetList;
    }

     /**
     * @author Marco Ottaviano - mottaviano@deloitte.it
     * @description Method to Assets
     * @param contractList - contract to link to assets
     * @return  List<Asset> to insert
    */
    public static List<Asset> createAssetsFromContract(List<Contract> contractList){
        List<Asset> assetList = new List<Asset>();
        Id recTypeAssetId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
        for (Integer i=0; i<contractList.size(); i++){
            Asset asst = new Asset();
            asst.Name = 'Test ' + i;
            asst.XC_Contract__c = contractList[i].Id;
            asst.AccountId=contractList[i].AccountId;
            asst.RecordTypeId = recTypeAssetId;
            asst.XC_LegalEntity__c = Label.XC_CL_EndesaX;
            asst.XC_Segment__c  = 'B2C';
            assetList.add(asst);
        }
        return assetList;
    }

    /**
    * @author Federico Amici - federico.amici@nttdata.com, Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @date Creation 29/05/2019
    * @date Modification dd/mm/yyyy
    * @description Creates asset item attributes
    */
    public static List<NE__AssetItemAttribute__c> createAssetItemAttributes(List<Asset> listAsset, List<String> listAttributes) {

        List<NE__AssetItemAttribute__c> listAtt = new List<NE__AssetItemAttribute__c>();
        NE__AssetItemAttribute__c assetAttribute;

        for(Asset a : listAsset) {
            for(String att : listAttributes) {
                assetAttribute = new NE__AssetItemAttribute__c();
                assetAttribute.Name = att;
                assetAttribute.NE__Value__c = '3 years renting';
                assetAttribute.NE__Asset__c = a.ID;
                listAtt.add(assetAttribute);
            }
        }

        return listAtt;

    }
    
    /**
    * @author Federico Amici - federico.amici@nttdata.com, Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @date Creation 29/05/2019
    * @date Modification dd/mm/yyyy
    * @description Creates the asset with bundle records
    */    
    public static List<Asset> createAssetWithBundleRecords(List<NE__Product__c> proList, NE__Bundle__c bundle, XC_Address__c address) {
        //create Asset list
        List<Asset> listAsset = new List<Asset>();
        Asset assetToInsert;
		Id recTypeAssetId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
        for(Integer i = 0; i < proList.size(); i++) {

            assetToInsert = new Asset();

            assetToInsert.Name = proList.get(i).Name;
            assetToInsert.IsCompetitorProduct = true;
            assetToInsert.InstallDate = Date.newInstance(2018, 04, 13);
            assetToInsert.NE__Activation_Date__c = Date.newInstance(2018, 04, 13);
            assetToInsert.XC_ActivationDate__c = Date.newInstance(2018, 04, 13);
            assetToInsert.IsInternal = false;
            assetToInsert.Price = 104;
            assetToInsert.NE__Bundle__c = bundle.Id;
            assetToInsert.PurchaseDate = Date.newInstance(2018, 04, 05);
            assetToInsert.Quantity = 3;
            assetToInsert.SerialNumber = '1ADG45R';
            assetToInsert.NE__Status__c = 'Active';
            assetToInsert.UsageEndDate = Date.newInstance(2020, 12, 30);
            assetToInsert.NE__Commitment__c = false;
            assetToInsert.Status = 'Active';
            assetToInsert.NE__ProdId__c = proList.get(i).Id;
            assetToInsert.XC_Address__c = address.Id;
            assetToInsert.RecordTypeId = recTypeAssetId;
            assetToInsert.XC_LegalEntity__c = Label.XC_CL_EndesaX;
            assetToInsert.XC_Segment__c = 'B2C';
            listAsset.add(assetToInsert);
        }
        
        return listAsset;
    } 

}