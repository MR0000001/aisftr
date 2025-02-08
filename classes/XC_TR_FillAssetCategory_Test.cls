@isTest
public class XC_TR_FillAssetCategory_Test {
    static testMethod void fillAssetCategoryonInsert(){
        User u = XC_DF_User.createUserAdmin();
         u.Country__c = 'ITLY';
        u.CompanyP__c = 'ITALY';
        u.XC_LegalEntity__c='EnelXItalia';
        insert u; 
        system.runAs(u){
         List<Account> accList = XC_DF_Account.createCondominiumAccounts(1);
         accList[0].RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2G').getRecordTypeId();
         accList[0].XC_Segment__c='B2G';
            insert accList;
            List <Contact> cont = XC_DF_Contact.createCondominiumContacts(accList);
    	  cont[0].RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2G').getRecordTypeId();
          cont[0].AccountId=accList.get(0).id;
    	 //cont[0].XC_MainLegalEntity__c='EnelXItalia';
            insert cont;
           List<XC_Address__c> addr = XC_DF_Address.createAddress(accList);
        addr[0].XC_AddressCountry__c='Italy';
        insert addr;
          List<Asset> ass = XC_DF_Asset.createAssets(1);
        //ass[0].XC_Contract__c= cont[0].id;
        //ass[0].AssetServicedById=accList[0].id;
        ass[0].XC_Address__c= addr[0].id;
        ass[0].serialnumber='1823747';
        ass[0].TAM_PartnerContractId__c='ok';
        ass[0].TAM_IsTechnical__c= true;
        ass[0].TAM_IsLogical__c=true;
        ass[0].AccountId= accList[0].id;
        ass[0].XC_Segment__c='B2B';
        ass[0].TAM_Category__c='VIP';
         ass[0].XC_LegalEntity__c='EnelXItalia'; 
        insert ass;
        id rtIdB2B =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_B2G_EnelXItalia_Management_Case').getRecordTypeId();
        List<Case> caseToCreateWo = XC_DF_Case.createCases(1);
        caseToCreateWO[0].RecordTypeId=rtIdB2B;
        caseToCreateWo[0].XC_Subtype__c = 'XC199';
        caseToCreateWo[0].reason='XCMOT002';
        caseToCreateWo[0].SubCause__c='ATCL003';
		caseToCreateWo[0].AccountId=accList[0].id;
       	caseToCreateWo[0].ContactId=cont[0].id;
        caseToCreateWO[0].XC_BusinessLine__c='eCity'; 
        caseToCreateWo[0].XC_TechnicalAsset__c=ass[0].id;
        caseTocreateWO[0].XC_Force_Work_Order_creation__c=TRUE;
        caseToCreateWo[0].XC_Segment__c='B2G';
        caseToCreateWo[0].XC_LegalEntity__c='EnelXItalia';    
        insert caseToCreateWO;
        }
    }
}