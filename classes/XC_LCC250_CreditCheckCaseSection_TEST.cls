@isTest
public class XC_LCC250_CreditCheckCaseSection_TEST {
    @testSetup
    static void makeData(){
        List<Account> accList = XC_DF_Account.createCondominiumAccounts(1);

        List <Contact> cont = XC_DF_Contact.createCondominiumContacts(accList);
        cont[0].AccountId=accList.get(0).id;

        accList[0].XC_NDADocumentNeeded__c=true;
        accList[0].XC_ContactToNotify__c=cont[0].id;

        insert accList;

        List <Contract> contr= XC_DF_Contract.createCondominiumContract(accList);
        insert contr; 

        List<XC_Address__c> addr = XC_DF_Address.createAddress(accList);
        insert addr;

        List<Asset> assCom = XC_DF_Asset.createAssets(1);
        assCom[0].XC_Address__c= addr[0].id;
        assCom[0].serialnumber='1823747';
        assCom[0].TAM_PartnerContractId__c='ok';
        assCom[0].TAM_IsTechnical__c= true;
        assCom[0].TAM_IsLogical__c=true;
        assCom[0].AccountId= accList[0].id;
        assCom[0].XC_Segment__c='B2B';
        insert assCom;

        List<Asset> ass=XC_DF_Asset.createAssets(1);
        ass[0].serialnumber='1823747';
        ass[0].XC_Address__c= addr[0].id;
        ass[0].XC_Contract__c= contr[0].id;
        ass[0].AccountId = accList[0].Id;
        ass[0].XC_Segment__c='B2B';
        ass[0].TAM_IsLogical__c=true;
        ass[0].TAM_CommercialAsset__c=assCom[0].id;
        insert ass;       
                      
        List<Case> listCases=XC_DF_Case.createCases(1);
        listCases[0].AccountId= accList[0].id;
        listCases[0].ContactId= cont[0].id;
        listCases[0].AssetId=ass[0].id;
        listCases[0].Reason='XCMOT002';
        listCases[0].SubCause__c='ATCL003';
        listCases[0].XC_Subtype__c='XC199';
        listcases[0].Origin='CAN001';
        listcases[0].XC_CallerType__c = 'Cittadino';
        listCases[0].XC_BusinessLine__c='eCity';
        listcases[0].XC_Asset_B2B__c=ass[0].id;
        listcases[0].XC_Email__c='testMalf@email.com';
        listcases[0].XC_LegalEntity__c='EnelXItalia';
        insert listCases;
    }

    @isTest
    static void retrieveInformation(){
        List<Case> caseList = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        XC_LCC250_CreditCheckCaseSection.resultWrapper result = XC_LCC250_CreditCheckCaseSection.retrieveInformation(caseList[0].Id);
        Test.stopTest();

        system.assertEquals(true,result.success);
    }
}