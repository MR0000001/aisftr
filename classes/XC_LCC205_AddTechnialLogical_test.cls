@Istest (SeeAllData = false)
public class XC_LCC205_AddTechnialLogical_test {
    static testmethod void retrieveListAsset(){
    //test.startTest(); //DeAv 08.07.2022 - Code coverage
    List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
    insert accList;
    List <Contact> cont = XC_DF_Contact.createCondominiumContacts(accList);
    cont[0].AccountId=accList.get(0).id;
    XC_Address__c addressToInsert = new XC_Address__c();
    addressToInsert.XC_Account__c = accList[0].Id;
    addressToInsert.XC_Address__c = 'Test';
    addressToInsert.XC_City__c = 'Roma';
    addressToInsert.XC_AddressCountry__c = 'Italy';
    addressToInsert.XC_PostalCode__c = '0198';
    addressToInsert.XC_AddressProvince__c = 'Roma';
    addressToInsert.XC_StreetNumber__c = '11' + Math.random();
    addressToInsert.XC_StreetType__c = 'Street'; 
    addressToInsert.XC_StreetTypeText__c='Street';
    addressToInsert.XC_Municipality__c   = 'Test' + Math.random();
    addressToInsert.XC_InstallationAddress__c = TRUE;
    addressToInsert.XC_DeliveryAddress__c = TRUE;
    addressToInsert.XC_BillingAddress__c = TRUE;
    addressToInsert.XC_PickUpPoint__c = TRUE;
    addressToInsert.XC_PointOfSales__c = TRUE;
    addressToInsert.XC_WareHouse__c = TRUE;
    insert addressToInsert;
    List<Asset> ass = XC_DF_Asset.createAssets(2);
    //ass[0].XC_AssetType__c='projector';
    ass[0].AccountId=accList[0].id;
    ass[0].XC_Address__c=addressToInsert.id;
    ass[0].TAM_IsTechnical__c=true;
    ass[0].ContactId= cont[0].id;
    ass[0].TAM_BusinessLine__c='ecity';
    ass[1].AccountId=accList[0].id;
    ass[1].XC_Address__c=addressToInsert.id;
    ass[1].TAM_IsTechnical__c=true;
    ass[1].ContactId= cont[0].id;
    ass[1].TAM_BusinessLine__c='ecity';
    insert ass; 
    Id rtCaseId = Schema.SObjectType.Case.RecordTypeInfosByDeveloperName.get('XC_B2B_EnelXItalia_Management_Case').getRecordTypeId(); //DeAv 08.07.2022 - Code coverage   
    List<Case> caseToCreateWo = XC_DF_Case.createCases(1);
    caseToCreateWo[0].RecordTypeId = rtCaseId; //DeAv 08.07.2022 - Code coverage
	caseToCreateWo[0].XC_Address__c= addressToInsert.id;
    caseToCreateWo[0].AccountId= accList[0].id;
    caseToCreateWo[0].XC_BusinessLine__c='eCity';
    caseToCreateWo[0].ContactId= cont[0].id;
    caseToCreateWo[0].XC_LegalEntity__c='EnelSole';
    caseToCreateWo[0].XC_Force_Work_Order_creation__c=true; 
    insert caseToCreateWo;
    String recordId = caseToCreateWo.get(0).id;
    XC_LCC205_AddTechnialLogicalAsset.retrieveListAsset(recordId);
    caseToCreateWo[0].XC_TechnicalAsset__c=ass[0].id;
         test.startTest();
      XC_LCC205_AddTechnialLogicalAsset.retrieveListAsset(recordId);
    XC_LCC205_AddTechnialLogicalAsset.retrieveLogicalAndTechnicalAsset(recordId);
    XC_LCC205_AddTechnialLogicalAsset.retrieveFilteredLogicalAndTechnicalAsset(recordId, '');
	XC_LCC205_AddTechnialLogicalAsset.showNewComponent(recordId);
  //      test.stopTest();
    id assetId=ass[0].id;
    XC_LCC205_AddTechnialLogicalAsset.caseUpdate(recordId, assetId, '', false);
   // XC_LCC205_AddTechnialLogicalAsset.caseUpdate(recordId, assetId);
    //caseToCreateWo[0].XC_TechnicalAsset__c=assetId;
    caseToCreateWo[0].XC_Force_Work_Order_creation__c=true;  
    update caseToCreateWo; 
 //   test.startTest(); //DeAv 08.07.2022 - Code coverage
    XC_LCC205_AddTechnialLogicalAsset.caseUpdate(recordId, assetId, '', false);
  //  caseToCreateWo[0].XC_Address__c=null;
  //  update caseToCreateWo; 
    //XC_LCC205_AddTechnialLogicalAsset.retrieveListAsset(recordId); 
    //XC_LCC205_AddTechnialLogicalAsset.caseUpdate(recordId,ass[1].id, '', false);    
    /*ass[0].TAM_PartnerContract__c=null;
    update ass;
    XC_LCC205_AddTechnialLogicalAsset.caseUpdate(recordId, assetId);*/
    test.stopTest();
    }
}