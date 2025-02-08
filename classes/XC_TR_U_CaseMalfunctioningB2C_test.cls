@IsTest
public class XC_TR_U_CaseMalfunctioningB2C_test {
    testmethod static void onInsertCase(){
    test.startTest();
        User itAdmin = XC_DF_User.createUserAdmin();
        itAdmin.XC_LegalEntity__c = 'EnelXItalia';
        itAdmin.XC_LegalEntities__c = 'EnelXItalia';
        insert itAdmin;
     id rtId =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_ITA_Management_Case').getRecordTypeId();
    List<Account> accList = XC_DF_Account.createCondominiumAccounts(1);
    insert accList;
    List <Contact> cont = XC_DF_Contact.createCondominiumContacts(accList);
    cont[0].AccountId=accList.get(0).id;
    List<Asset> ass=XC_DF_Asset.createAssets(1);
    ass[0].AccountId = accList[0].Id;
    ass[0].TAM_IsLogical__c=true;
    ass[0].XC_Segment__c='B2B';
    ass[0].XC_Product_Subtype__c='Charging Station';
    ass[0].XC_LegalEntity__c='EndesaX';
    insert ass;
    List<Case> caseToCreateWo = XC_DF_Case.createCases(1);
    caseToCreateWo[0].XC_Subtype__c = 'XC199';
    caseToCreateWo[0].reason='XCMOT002';
    caseToCreateWo[0].SubCause__c='ATCL003';
    caseToCreateWo[0].AccountId=accList[0].id;
    caseToCreateWo[0].ContactId=cont[0].id;
    caseToCreateWo[0].XC_Segment__c='B2C';
    caseToCreateWo[0].XC_Asset_B2B__c=ass[0].id;
    caseToCreateWo[0].XC_BusinessLine__c='eHome';    
    caseToCreateWo[0].XC_Asset_B2B__c=ass[0].id;
    caseToCreateWo[0].Status='New';
    caseToCreateWO[0].RecordTypeId=rtId;
    caseToCreateWO[0].XC_LegalEntity__c='EndesaX';     
    insert caseToCreateWo;
     System.runAs(itAdmin) {
    XC_TR_U_CaseMalfunctioningB2C.onInsertCase(caseToCreateWo);
     }
    test.stopTest();
    }
    testmethod static void onUpdateCase(){
    test.startTest();
     id rtId =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_ITA_Management_Case').getRecordTypeId();
    List<Account> accList = XC_DF_Account.createCondominiumAccounts(1);
    insert accList;
    List <Contact> cont = XC_DF_Contact.createCondominiumContacts(accList);
    cont[0].AccountId=accList.get(0).id;
    List<Asset> ass=XC_DF_Asset.createAssets(2);
    ass[0].AccountId = accList[0].Id;
    ass[0].TAM_IsLogical__c=true;
    ass[0].XC_Segment__c='B2B';
    ass[0].XC_Product_Subtype__c='Charging Station';
    ass[0].XC_LegalEntity__c='EndesaX';
    ass[1].AccountId = accList[0].Id;
    ass[1].TAM_IsLogical__c=true;
    ass[1].XC_Segment__c='B2B';
    ass[1].XC_Product_Subtype__c='Charging Station';
    ass[1].XC_LegalEntity__c='EndesaX';
    insert ass;
    List<Case> caseToCreateWo = XC_DF_Case.createCases(1);
    caseToCreateWo[0].XC_Subtype__c = 'XC199';
    caseToCreateWo[0].reason='XCMOT002';
    caseToCreateWo[0].SubCause__c='ATCL003';
    caseToCreateWo[0].AccountId=accList[0].id;
    caseToCreateWo[0].ContactId=cont[0].id;
    caseToCreateWo[0].XC_Segment__c='B2C';
    caseToCreateWo[0].XC_Asset_B2B__c=ass[0].id;
    caseToCreateWo[0].XC_BusinessLine__c='eHome';    
    caseToCreateWo[0].XC_Asset_B2B__c=ass[0].id;
    caseToCreateWo[0].Status='New';
    caseToCreateWO[0].RecordTypeId=rtId;
    caseToCreateWO[0].XC_LegalEntity__c='EndesaX';     
    insert caseToCreateWo;  
    Case olditem =  caseToCreateWo[0].clone(true,false,false,false);
    caseToCreateWo[0].XC_Asset_B2B__c=ass[1].id;
    update caseToCreateWo;
    Map<id,Case> mapNew= new Map <id,Case>();
   	mapNew.put(olditem.id,olditem);
    XC_TR_U_CaseMalfunctioningB2C.onUpdateCase(caseToCreateWo,mapNew);
    test.stopTest();
    }
        testmethod static void assignParentId(){
    test.startTest();
              User itAdmin = XC_DF_User.createUserAdmin();
        itAdmin.XC_LegalEntity__c = 'EnelXItalia';
        itAdmin.XC_LegalEntities__c = 'EnelXItalia';
        insert itAdmin;
    List<Account> accList = XC_DF_Account.createCondominiumAccounts(1);
    insert accList;
    List <Contact> cont = XC_DF_Contact.createCondominiumContacts(accList);
    cont[0].AccountId=accList.get(0).id;
    List<Asset> ass=XC_DF_Asset.createAssets(2);
    ass[0].AccountId = accList[0].Id;
    ass[0].TAM_IsLogical__c=true;
    ass[0].XC_Segment__c='B2B';
    ass[0].XC_Product_Subtype__c='Charging Station';
    ass[0].XC_LegalEntity__c='EndesaX';
    ass[1].AccountId = accList[0].Id;
    ass[1].TAM_IsLogical__c=true;
    ass[1].XC_Segment__c='B2B';
    ass[1].XC_Product_Subtype__c='Charging Station';
    ass[1].XC_LegalEntity__c='EndesaX';
    insert ass;
     id rtId =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_ITA_Management_Case').getRecordTypeId();
    List<Case> caseToCreateWo = XC_DF_Case.createCases(1);
    caseToCreateWo[0].XC_Subtype__c = 'XC199';
    caseToCreateWo[0].reason='XCMOT002';
    caseToCreateWo[0].SubCause__c='ATCL003';
    caseToCreateWo[0].AccountId=accList[0].id;
    caseToCreateWo[0].ContactId=cont[0].id;
    caseToCreateWo[0].XC_Segment__c='B2C';
    //caseToCreateWo[0].XC_Asset_B2B__c=ass[0].id;
    caseToCreateWo[0].XC_BusinessLine__c='eHome';    
    caseToCreateWo[0].XC_Asset_B2B__c=ass[0].id;
    caseToCreateWo[0].Status='New';
    caseToCreateWO[0].RecordTypeId=rtId;
    caseToCreateWO[0].XC_LegalEntity__c='EndesaX';        
    insert caseToCreateWo;  
	List<Case> caseToCreateWo2 = XC_DF_Case.createCases(1);
    //id rtId =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_B2C_EnelXItalia_Management_Case').getRecordTypeId();
    caseToCreateWo2[0].XC_Subtype__c = 'XC199';
    caseToCreateWo2[0].reason='XCMOT002';
    caseToCreateWo2[0].SubCause__c='ATCL003';
    caseToCreateWo2[0].AccountId=accList[0].id;
    caseToCreateWo2[0].ContactId=cont[0].id;
    caseToCreateWo2[0].XC_Segment__c='B2C';
    caseToCreateWo2[0].XC_BusinessLine__c='eHome';
    caseToCreateWo2[0].XC_Asset_B2B__c=ass[0].id;
    caseToCreateWo2[0].XC_TechnicalAsset__c=ass[0].id;
    caseToCreateWo2[0].Status='New';
    caseToCreateWo2[0].ParentId=caseToCreateWo[0].id;
   caseToCreateWO2[0].RecordTypeId=rtId; 
   caseToCreateWO2[0].XC_LegalEntity__c='EndesaX';      
   insert caseToCreateWo2;  
	System.runAs(itAdmin) {
    XC_TR_U_CaseMalfunctioningB2C.assignParentId(caseToCreateWo,caseToCreateWo2);
    }
    test.stopTest();
    }
}