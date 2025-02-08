/**
* @author Dimitris Karnavas 
* @date Creation  10/06/2021
* @description Test Class for XC_TR_Account_U_VATGroupManage 
*/ 
@isTest
private class XC_TR_Account_U_VATGroupManage_TEST {
    @isTest static void gruppoIvaEnel(){
        insert XC_DF_OneOrg.createOneOrg('Spain');

        XC_AccountVatGroup__c testcomp = new XC_AccountVatGroup__c(Name = 'testcomp', CompanyFiscalCode__c = '09876543211', IdentityNumber__c = '09876543212',VatGroupType__c = 'Gruppo IVA Enel');
        insert testcomp;

        List<Account> acc = XC_DF_Account.createSohoAccounts(1);
        acc[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDevelopername().get('XC_GLO_B2B').getRecordTypeId();
        acc[0].XC_VatGroupType__c = 'Gruppo IVA Enel';
        acc[0].XC_CompanyFiscalCode__c = '09876543211';
        acc[0].IdentityNumber__c = '09876543212';
        acc[0].IdentityType__c = 'CF';
        acc[0].XC_TradingPartner__c = 'G0ES14';
        acc[0].XC_Segment__c = 'B2B';
        acc[0].XC_Country__c = 'Italy';

        test.startTest();
        insert acc;
        test.stopTest();

        Account result = [SELECT Id,XC_VatGroupType__c FROM Account WHERE Id =: acc[0].Id];
        system.assertEquals('Gruppo IVA Enel',result.XC_VatGroupType__c);
    }

    @isTest static void gruppoIvaEnelError(){
        insert XC_DF_OneOrg.createOneOrg('Spain');

        XC_AccountVatGroup__c testcomp = new XC_AccountVatGroup__c(Name = 'testcomp', CompanyFiscalCode__c = '09876543211', IdentityNumber__c = '09876543212',VatGroupType__c = 'Gruppo IVA Enel');
        insert testcomp;

        List<Account> acc = XC_DF_Account.createSohoAccounts(9);
        //Error 1 empty fiscal code
        acc[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDevelopername().get('XC_GLO_B2B').getRecordTypeId();
        acc[0].XC_VatGroupType__c = 'Gruppo IVA Enel';
        //acc[0].XC_CompanyFiscalCode__c = '09876543211';
        acc[0].IdentityNumber__c = '09876543212';
        acc[0].IdentityType__c = 'CF';
        acc[0].XC_TradingPartner__c = 'G0ES14';
        acc[0].XC_Segment__c = 'B2B';
        acc[0].XC_Country__c = 'Italy';

        //Error 2 doc number length
        acc[1].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDevelopername().get('XC_GLO_B2B').getRecordTypeId();
        acc[1].XC_VatGroupType__c = 'Gruppo IVA Enel';
        acc[1].XC_CompanyFiscalCode__c = '098765432111'; //length is 12
        acc[1].IdentityNumber__c = '09876543212';
        acc[1].IdentityType__c = 'CF';
        acc[1].XC_TradingPartner__c = 'G0ES14';
        acc[1].XC_Segment__c = 'B2B';
        acc[1].XC_Country__c = 'Italy';

        //Error 3 comp fiscal code length
        acc[2].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDevelopername().get('XC_GLO_B2B').getRecordTypeId();
        acc[2].XC_VatGroupType__c = 'Gruppo IVA Enel';
        acc[2].XC_CompanyFiscalCode__c = '09876543211'; 
        acc[2].IdentityNumber__c = '098765432122'; //length is 12
        acc[2].IdentityType__c = 'CF';
        acc[2].XC_TradingPartner__c = 'G0ES14';
        acc[2].XC_Segment__c = 'B2B';
        acc[2].XC_Country__c = 'Italy';

        //Error 4 secondary doc length
        acc[3].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDevelopername().get('XC_GLO_B2B').getRecordTypeId();
        acc[3].XC_VatGroupType__c = 'Gruppo IVA Enel';
        acc[3].XC_CompanyFiscalCode__c = '09876543211'; 
        acc[3].IdentityNumber__c = '09876543212'; 
        acc[3].XC_IdentityNumber2__c = '09876543212222'; //length error
        acc[3].XC_DocumentType2__c = 'Other';
        acc[3].IdentityType__c = 'CF';
        acc[3].XC_TradingPartner__c = 'G0ES14';
        acc[3].XC_Segment__c = 'B2B';
        acc[3].XC_Country__c = 'Italy';

        //Error 5 Trading Partner missing
        acc[4].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDevelopername().get('XC_GLO_B2B').getRecordTypeId();
        acc[4].XC_VatGroupType__c = 'Gruppo IVA Enel';
        acc[4].XC_CompanyFiscalCode__c = '09876543211'; 
        acc[4].IdentityNumber__c = '09876543212'; 
        acc[4].IdentityType__c = 'CF';
        //acc[4].XC_TradingPartner__c = 'G0ES14';
        acc[4].XC_Segment__c = 'B2B';
        acc[4].XC_Country__c = 'Italy';

        //Error 6 Doc Type != CF 
        acc[5].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDevelopername().get('XC_GLO_B2B').getRecordTypeId();
        acc[5].XC_VatGroupType__c = 'Gruppo IVA Enel';
        acc[5].XC_CompanyFiscalCode__c = '09876543211'; 
        acc[5].IdentityNumber__c = '09876543212'; 
        acc[5].IdentityType__c = 'Other';
        acc[5].XC_TradingPartner__c = 'G0ES14';
        acc[5].XC_Segment__c = 'B2B';
        acc[5].XC_Country__c = 'Italy';

        //Error 7 Doc Number = Comp Fiscal Code
        acc[6].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDevelopername().get('XC_GLO_B2B').getRecordTypeId();
        acc[6].XC_VatGroupType__c = 'Gruppo IVA Enel';
        acc[6].XC_CompanyFiscalCode__c = '09876543211'; 
        acc[6].IdentityNumber__c = '09876543211'; 
        acc[6].IdentityType__c = 'CF';
        acc[6].XC_TradingPartner__c = 'G0ES14';
        acc[6].XC_Segment__c = 'B2B';
        acc[6].XC_Country__c = 'Italy';

        //Error 8 comp fiscal code not found in Gruppo IVA Enel table
        acc[7].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDevelopername().get('XC_GLO_B2B').getRecordTypeId();
        acc[7].XC_VatGroupType__c = 'Gruppo IVA Enel';
        acc[7].XC_CompanyFiscalCode__c = '09876543213'; //!
        acc[7].IdentityNumber__c = '09876543212'; 
        acc[7].IdentityType__c = 'CF';
        acc[7].XC_TradingPartner__c = 'G0ES14';
        acc[7].XC_Segment__c = 'B2B';
        acc[7].XC_Country__c = 'Italy';

        //Error 9 Account is Gruppo IVA Enel but must change to 
        acc[8].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDevelopername().get('XC_GLO_B2B').getRecordTypeId();
        acc[8].XC_VatGroupType__c = 'Gruppo IVA societario';
        acc[8].XC_CompanyFiscalCode__c = '09876543211'; 
        acc[8].IdentityNumber__c = '09876543212'; 
        acc[8].IdentityType__c = 'CF';
        acc[8].XC_TradingPartner__c = 'G0ES14';
        acc[8].XC_Segment__c = 'B2B';
        acc[8].XC_Country__c = 'Italy';

        test.startTest();

        Database.SaveResult[] results  = Database.insert(acc,false);
        
        test.stopTest();

        Boolean onlyErrors = true;
        for(Database.SaveResult sr : results){
            system.debug(sr.isSuccess());
            if(sr.isSuccess()){
                onlyErrors = false;
            }
        }
        system.assertEquals(true,onlyErrors);
    }
}