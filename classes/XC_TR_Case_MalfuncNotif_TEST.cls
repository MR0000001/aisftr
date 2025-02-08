@isTest
public class XC_TR_Case_MalfuncNotif_TEST {
@TestSetup
    static void setup(){        
        List<Case> listCases=XC_DF_Case.createCases(1);
        List<Account> accList = [SELECT Id, XC_Segment__c, RecordTypeId FROM Account LIMIT 1];
        List<Contact> contactList = [SELECT Id, XC_MainLegalEntity__c, XC_CountryLegalEntity__c, XC_Segment__c, RecordTypeId FROM Contact LIMIT 1];
        accList[0].XC_Segment__c = 'B2G';
        accList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2G').getRecordTypeId();
        contactList[0].RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2G').getRecordTypeId();
        contactList[0].XC_Segment__c = 'B2G';
        contactList[0].XC_CountryLegalEntity__c = 'Italy';
        update contactList;
        update accList;       

        Id recordTypeId =Schema.SObjectType.Case.getRecordTypeInfosByName().get('XC_B2G_EnelXItalia_Management_Case').getRecordTypeId();
        listCases[0].RecordtypeId=recordTypeId;
        listCases[0].Reason='XCMOT002';
        listCases[0].SubCause__c='ATCL003';
        listCases[0].XC_Subtype__c='XC199';
        listcases[0].Origin='CAN001';
        listcases[0].XC_CallerType__c = 'Cittadino';
        listcases[0].XC_DefectType__c='Rischio elettrico';
        listCases[0].XC_BusinessLine__c='eCity';
        listcases[0].XC_Email__c='testMalf@email.com';
        listcases[0].XC_LegalEntity__c='EnelSole';
        listcases[0].XC_automaticClosure__c=false;
        listcases[0].XC_Segment__c = 'B2G';
        insert listCases;          
    }    
        
    @isTest
    static void test_notification(){     
        List<Case> caselist=[SELECT Id, Status, CreatedDate, XC_automaticClosure__c, XC_Segment__c, XC_BusinessLine__c, XC_DefectType__c, Origin, XC_Subtype__c, SubCause__c, Reason, AssetId, ContactId, AccountId, Account.Name, XC_Resolution__c 
                            FROM Case LIMIT 1];
    
        Map<Id, Case> mapOld=new Map<Id, Case> ();
        mapOld.put(caselist[0].Id,caselist[0]);
        Test.startTest();
        caselist[0].XC_automaticClosure__c=true;
        caselist[0].Status = 'ESTA007';
        update caselist;
        Map<Id, Case> mapNew=new Map<Id, Case> ();
        mapNew.put(caselist[0].Id,caselist[0]);
        XC_TR_Case_MalfunctioningNotification.checkCaseAndUpdateCustomerInteraction(caselist,mapOld,mapnew);
        Test.stopTest();               
    }
}