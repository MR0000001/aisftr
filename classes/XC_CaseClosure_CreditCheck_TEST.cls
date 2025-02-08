/**
 * The Class XC_CaseClosure_CreditCheck_TEST.
 *
 * @author            : Marco Ottaviano mottaviano@deloitte.it
 * @date Creation     : 09/07/2020
 * @date Modification : 
 * @description       : TEST class for XC_CaseClosure_CreditCheck 
 **/

@isTest
public without sharing class XC_CaseClosure_CreditCheck_TEST {


    @isTest
    static void caseClosure() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Opportunity> opty = XC_DF_Opportunity.createOpportunity(1, false);
        insert opty;
        List<Contact> contCreated=[SELECT Id,AccountId FROM Contact LIMIT 1];
        Case caso = new Case();
        caso.Status = 'ESTA001';
        caso.Reason = 'XCMOT007';
        caso.SubCause__c = 'ATCL157';
       // caso.XC_Subtype__c = 'XC192';
        caso.AccountId = contCreated[0].AccountId;
        caso.ContactId = contCreated[0].Id;
        caso.XC_Opportunity__c =opty[0].Id;
        insert caso;

        Test.startTest();
        	caso.RecordTypeid = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_B2B_COL_Management_Case').getRecordTypeId();
        	caso.XC_Subtype__c ='XC192';
        	caso.XC_LegalEntity__c ='Codensa';
        	caso.XC_Segment__c='B2B';
            //caso.Status='ESTA007';
            caso.XC_Resolution__c ='R135';
            caso.XC_Result__c ='RS003';
            caso.CaseRemarks__c ='test';
            update caso;
        Test.stopTest();
    }

    @isTest
    static void oppListIdOKconditioned() {
        
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1,false);
        insert oppList;

        oppList[0].XC_Segment__c = 'B2B';
        oppList[0].XC_IndustrialKPI__c = 'Work Contract';
        oppList[0].XC_LegalEntity__c = 'EnelXItalia';
        oppList[0].XC_Invited_Checkbox__c = false;
        oppList[0].StageName = 'Abandoned';    
        oppList[0].XC_BusinessLine__c = 'eCity';
        oppList[0].RecordTypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2B_Opportunity_Italy').getRecordTypeId();
        oppList[0].XC_ProductCategory__c = 'Optimize';
        oppList[0].XC_ProductCategoryOfInterest__c = 'Architectural Lighting';

        update oppList;

        List<Account> accList = [SELECT Id FROM Account];
        List<XC_Address__c> addr = [SELECT Id FROM XC_Address__c];
        List<Contact> cont = [SELECT Id FROM Contact];

        List <Contract> contr= XC_DF_Contract.createCondominiumContract(accList);
        insert contr; 

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
        listCases[0].RecordTypeid = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_Management_Case').getRecordTypeId();
        listCases[0].AccountId= accList[0].id;
        listCases[0].ContactId= cont[0].id;
        listCases[0].XC_Opportunity__c= oppList[0].id;
        listCases[0].AssetId=ass[0].id;
        listCases[0].Reason='XCMOT007';
        listCases[0].SubCause__c='ATCL157';
        listCases[0].XC_Subtype__c='XC192';
        listcases[0].Origin='CAN001';
        listcases[0].XC_Segment__c='B2B';
        //listcases[0].XC_CallerType__c = 'Cittadino';
        listCases[0].XC_BusinessLine__c='eCity';
        //listcases[0].XC_Asset_B2B__c=ass[0].id;
        //listcases[0].XC_Email__c='testMalf@email.com';
        insert listCases;

        Test.startTest();
            listcases[0].XC_Resolution__c = 'R163';
            listcases[0].XC_Result__c = 'RS003';
            listcases[0].CaseRemarks__c = 'test';
            update listCases;
        Test.stopTest();
    }

    @isTest
    static void oppListIdKo() {
        
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1,false);
        insert oppList;

        oppList[0].XC_Segment__c = 'B2B';
        oppList[0].XC_IndustrialKPI__c = 'Work Contract';
        oppList[0].XC_LegalEntity__c = 'EnelXItalia';
        oppList[0].XC_Invited_Checkbox__c = false;
        oppList[0].StageName = 'Abandoned';    
        oppList[0].XC_BusinessLine__c = 'eCity';
        oppList[0].RecordTypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2B_Opportunity_Italy').getRecordTypeId();
        oppList[0].XC_ProductCategory__c = 'Optimize';
        oppList[0].XC_ProductCategoryOfInterest__c = 'Architectural Lighting';

        update oppList;

        List<Account> accList = [SELECT Id FROM Account];
        List<XC_Address__c> addr = [SELECT Id FROM XC_Address__c];
        List<Contact> cont = [SELECT Id FROM Contact];

        List <Contract> contr= XC_DF_Contract.createCondominiumContract(accList);
        insert contr; 

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
        listCases[0].RecordTypeid = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_Management_Case').getRecordTypeId();
        listCases[0].AccountId= accList[0].id;
        listCases[0].ContactId= cont[0].id;
        listCases[0].XC_Opportunity__c= oppList[0].id;
        listCases[0].AssetId=ass[0].id;
        listCases[0].Reason='XCMOT007';
        listCases[0].SubCause__c='ATCL157';
        listCases[0].XC_Subtype__c='XC192';
        listcases[0].Origin='CAN001';
        listcases[0].XC_Segment__c='B2B';
        //listcases[0].XC_CallerType__c = 'Cittadino';
        listCases[0].XC_BusinessLine__c='eCity';
        //listcases[0].XC_Asset_B2B__c=ass[0].id;
        //listcases[0].XC_Email__c='testMalf@email.com';
        insert listCases;

        Test.startTest();
            listcases[0].XC_Resolution__c = 'R136';
            listcases[0].XC_Result__c = 'RS003';
            listcases[0].CaseRemarks__c = 'test';
            update listCases;
        Test.stopTest();
    }

}