@istest
public class XC_TR_CheckParentMal_test {
static testmethod void onInsert()
{
    test.startTest();
    User u = XC_DF_User.createUserAdmin();
        u.Country__c = 'ITLY';
        u.CompanyP__c = 'ITALY';
        u.XC_LegalEntity__c='EnelXItalia';
  //    u.XC_EnabledToSkip__c=true;
        insert u; 
     System.runAs(u) {
    List<Account> accList = XC_DF_Account.createCondominiumAccounts(1);
    insert accList;
    List <Contact> cont = XC_DF_Contact.createCondominiumContacts(accList);
    cont[0].AccountId=accList.get(0).id;
    //List<Contract> contr=XC_DF_Contract.createCondominiumContract(accList);
    //insert contr;
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
    List<Asset> ass = XC_DF_Asset.createAssets(1);
    //ass[0].XC_Contract__c=contr[0].id;
    ass[0].AccountId=accList[0].id;
    ass[0].TAM_IsTechnical__c=true;
    ass[0].ContactId= cont[0].id;
    ass[0].XC_Segment__c='B2B';
    ass[0].XC_Address__c=addressToInsert.id; 
    ass[0].XC_Product_Subtype__c='Generic';
    ass[0].XC_LegalEntity__c='EnelXItalia';
    insert ass;  
    List<XC_CM_Case_Repair_Configuration__mdt> caseRepairList=[select id,XC_Reason__c, XC_Sub_Cause__c, XC_Sub_Type__c,XC_B2BWONeeded__c 
                                                               from XC_CM_Case_Repair_Configuration__mdt
                                                              limit 1];
    caseRepairList[0].XC_B2BWONeeded__c=true;   
    system.debug('caseRepairList'+''+caseRepairList);
    Map<id,XC_CM_Case_Repair_Configuration__mdt> mapNew= new Map <id,XC_CM_Case_Repair_Configuration__mdt>();
    mapNew.put(caseRepairList.get(0).id,caseRepairList.get(0));
    List<Case> caseToCreateWo = XC_DF_Case.createCases(1);
    id rtEndesaX =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_ITA_Management_Case').getRecordTypeId();
    caseToCreateWo[0].AccountId= ass[0].AccountId;
    caseToCreateWo[0].ContactId= cont[0].id;
    caseToCreateWo[0].XC_Force_Work_Order_creation__c=true;
    caseTocreateWO[0].RecordTypeId=rtEndesaX;
    caseTocreateWO[0].ParentId=null;
    caseTocreateWO[0].Status='ESTA003';
    insert caseToCreateWo;
    id rtId =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_B2G_EnelXItalia_Management_Case').getRecordTypeId();
    caseTocreateWo[0].XC_LegalEntity__c='EnelXItalia';
	caseToCreateWo[0].reason= 'XCMOT002';
    caseToCreateWo[0].XC_Subtype__c='XC199';
    caseToCreateWo[0].SubCause__c='ATCL003';
    caseToCreateWo[0].XC_Segment__c='B2G';    
    caseToCreateWo[0].XC_TechnicalAsset__c=ass[0].Id;
    caseTocreateWO[0].XC_Address__c=addressToInsert.id;
    caseTocreateWO[0].RecordTypeId=rtId;
    caseTocreateWO[0].XC_BusinessLine__c='eCity';
    
    //caseTocreateWO[0].AssetId=ass[0].Id;
    update caseToCreateWo; 
    //test.stopTest();
    //seconda case
   /* List<Case> caseToCreateWo2 = XC_DF_Case.createCases(1);
     caseToCreateWo2[0].AccountId= ass[0].AccountId;
    caseToCreateWo2[0].ContactId= cont[0].id;
    caseToCreateWo2[0].XC_Force_Work_Order_creation__c=true;
    caseTocreateWO2[0].RecordTypeId=rtEndesaX;
    caseTocreateWO2[0].Status='ESTA003';
    caseTocreateWO2[0].ParentId=null;
    insert caseToCreateWo2;
   // id rtIdB2C =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_B2C_EnelXItalia_Management_Case').getRecordTypeId();
	caseToCreateWo2[0].reason= 'XCMOT002';
    caseTocreateWo2[0].XC_LegalEntity__c='EnelXItalia';
    caseToCreateWo2[0].XC_Subtype__c='XC199';
    caseToCreateWo2[0].SubCause__c='ATCL003';
    caseToCreateWo2[0].XC_Segment__c='B2G';    
    caseToCreateWo2[0].XC_TechnicalAsset__c=ass[0].Id;
    caseTocreateWO2[0].XC_Address__c=addressToInsert.id;
    //caseTocreateWO2[0].AssetId=ass[0].Id;
    caseTocreateWO2[0].RecordTypeId=rtId;
    caseTocreateWO[0].XC_BusinessLine__c='eCity';
    caseTocreateWO2[0].RecordTypeId=rtId;
    update caseToCreateWo2;*/
    system.debug('il mio caseToCreateWo'+''+caseToCreateWo[0]);
   //  System.runAs(u) {
    XC_TR_CheckParentMalfunctioning.onInsert(caseToCreateWo);
   }
     test.stopTest();
    //XC_TR_CheckParentMalfunctioning.onUpdate(caseToCreateWo,mapOld);
 }
}
 /*   static testmethod void onInsert1()
{
    test.startTest();
    List<Account> accList = XC_DF_Account.createCondominiumAccounts(2);
    insert accList;
    List <Contact> cont = XC_DF_Contact.createCondominiumContacts(accList);
    cont[0].AccountId=accList.get(0).id;
    List<Asset> ass = XC_DF_Asset.createAssets(1);
    ass[0].AccountId=accList[0].id;
    ass[0].TAM_IsTechnical__c=true;
    ass[0].ContactId= cont[0].id;
    ass[0].XC_Segment__c='B2B';
    insert ass;  
    /*List<XC_CM_Case_Repair_Configuration__mdt> caseRepairList=[select id,XC_Reason__c, XC_Sub_Cause__c, XC_Sub_Type__c,XC_B2BWONeeded__c 
                                                               from XC_CM_Case_Repair_Configuration__mdt
                                                              limit 1];
	caseRepairList[0].XC_Reason__c=
    caseRepairList[0].XC_Sub_Cause__c=
    caseRepairList[0].XC_Sub_Type__c= 
    caseRepairList[0].XC_B2BWONeeded__c=true;
   
    system.debug('caseRepairList'+''+caseRepairList);*/
   // Map<id,XC_CM_Case_Repair_Configuration__mdt> mapNew= new Map <id,XC_CM_Case_Repair_Configuration__mdt>();
   // mapNew.put(caseRepairList.get(0).id,caseRepairList.get(0));
    /*List<Case> caseToCreateWo = XC_DF_Case.createCases(1);
    caseToCreateWo[0].AccountId= accList[0].id;
    caseToCreateWo[0].AssetId=ass[0].id;
    caseToCreateWo[0].ContactId= cont[0].id;
    caseToCreateWo[0].ParentId=null;
	caseToCreateWo[0].reason= 'XCMOT002';
    //caseToCreateWo[0].XC_Subtype__c='XC199';
    caseToCreateWo[0].SubCause__c='ATCL003';
    caseToCreateWo[0].XC_Segment__c='B2B';
    //caseToCreateWo[0].XC_TechnicalAsset__c=ass[0].id;
    caseToCreateWo[0].XC_Type_Intermediary__c='TI001';
    caseToCreateWo[0].XC_IsCloned__c=true;    
    insert caseToCreateWo;
    XC_TR_CheckParentMalfunctioning.onInsert(caseToCreateWo);
    //update caseToCreateWo;
    //XC_TR_CheckParentMalfunctioning.onUpdate(caseToCreateWo,mapOld);

    test.stopTest();
}
     static testmethod void onInsert2()
{
    test.startTest();
    List<Account> accList = XC_DF_Account.createCondominiumAccounts(2);
    insert accList;
    List <Contact> cont = XC_DF_Contact.createCondominiumContacts(accList);
    cont[0].AccountId=accList.get(0).id;
    List<Asset> ass = XC_DF_Asset.createAssets(1);
    ass[0].AccountId=accList[0].id;
    ass[0].TAM_IsTechnical__c=true;
    ass[0].ContactId= cont[0].id;
    ass[0].XC_Segment__c='B2B';
    insert ass;  
    List<XC_CM_Case_Repair_Configuration__mdt> caseRepairList=[select id,XC_Reason__c,XC_Sub_Type__c, XC_Sub_Cause__c,XC_B2BWONeeded__c 
                                                               from XC_CM_Case_Repair_Configuration__mdt
                                                              limit 1];
	caseRepairList[0].XC_Reason__c=
    caseRepairList[0].XC_Sub_Cause__c= 
    caseRepairList[0].XC_Sub_Type__c= null;
    caseRepairList[0].XC_B2BWONeeded__c=true;
   
    system.debug('caseRepairList'+''+caseRepairList);
    Map<id,XC_CM_Case_Repair_Configuration__mdt> mapNew= new Map <id,XC_CM_Case_Repair_Configuration__mdt>();
    mapNew.put(caseRepairList.get(0).id,caseRepairList.get(0));
    List<Case> caseToCreateWo = XC_DF_Case.createCases(1);
    caseToCreateWo[0].AccountId= accList[0].id;
    caseToCreateWo[0].AssetId=ass[0].id;
    caseToCreateWo[0].ContactId= cont[0].id;
    caseToCreateWo[0].ParentId=null;
	caseToCreateWo[0].reason= 'XCMOT002';
    //caseToCreateWo[0].XC_Subtype__c='XC199';
    caseToCreateWo[0].SubCause__c='ATCL003';
    caseToCreateWo[0].XC_Segment__c='B2B';
    //caseToCreateWo[0].XC_TechnicalAsset__c=ass[0].id;
    caseToCreateWo[0].XC_Type_Intermediary__c='TI001';
    caseToCreateWo[0].XC_IsCloned__c=true;    
    insert caseToCreateWo;
    //XC_TR_CheckParentMalfunctioning.mapCaseRepairConfiguration(caseRepairList);
    //update caseToCreateWo;
    //XC_TR_CheckParentMalfunctioning.onUpdate(caseToCreateWo,mapOld);

    test.stopTest();
}
}*/