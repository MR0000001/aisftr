/**
* @author Monica Cutillo - monica.cutillo@nttdata.com
* @date Creation 15/05/2019
* @description XC_DF_Case – Data Factory for Case
*/
@isTest
public class XC_DF_Case {
        
     /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com
     * @description Method to Cases
     * @param n - number of case
     * @return  List<Case> to insert
    */
    public static List<Case> createCases(Integer n){
        List<Account> accounts = XC_DF_Account.createResidentialAccounts(n);
        insert accounts;
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accounts);
        insert contacts;
        
        //Id recordTypeId = CaseDAO.newInstance().getActiveRecordtypeIdByDeveloperName(XC_AT_Constants.CASE_RECORD_TYPE_XC_ATTENTION_ESPANA);
        List<Case> cases = new List<Case>();
        for (Integer i=0; i<n; i++){
            Case caso = new Case();
            //caso.RecordTypeId = recordTypeId;
            caso.Status = 'ESTA001';
            caso.Reason = 'XCMOT010';
            caso.SubCause__c = 'ATCL058';
            caso.AccountId = accounts[i].Id;
            caso.ContactId = contacts[i].Id;
            caso.XC_Type_Intermediary__c = 'TI001';
            cases.add(caso);
        }
        return cases;
    }
        
     /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com
     * @description Method to Case
     * @return  Case to insert
    */
    public static Case createCaseFromType(String caseReason, String subCause, String subType){
        List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
        insert accounts;
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accounts);
        insert contacts;
        //Id recordTypeId = CaseDAO.newInstance().getActiveRecordtypeIdByDeveloperName(XC_AT_Constants.CASE_RECORD_TYPE_XC_ATTENTION_ESPANA);
        Case caso = new Case();
        //caso.RecordTypeId = recordTypeId;
        caso.Status = 'ESTA001';
        caso.Reason = caseReason;
        caso.SubCause__c = subCause;
        if(subType!=null){
            caso.XC_SubType__c = subType;
        }
        caso.AccountId = accounts[0].Id;
        caso.ContactId = contacts[0].Id;
        caso.XC_Type_Intermediary__c = 'TI001';
        return caso;
    }
    
    public static XC_CM_CaseMapping__mdt createCaseMappingMdtRecord(Case caso){
        XC_CM_CaseMapping__mdt row = new XC_CM_CaseMapping__mdt();
        row.DeveloperName = 'CaseMappingMdtRowTest';
        row.MasterLabel = 'CaseMappingMdtRowTest';
        row.Label = 'CaseMappingMdtRowTest';
        row.QualifiedApiName = 'CaseMappingMdtRowTest';
        row.XC_ActionPlanTemplate__c = 'ActionPlanTemplateTest';
        row.XC_CaseReason__c = caso.Reason;
        row.XC_SubCause__c = caso.SubCause__c;
        row.XC_SubType__c = caso.XC_Subtype__c;
        return row;
    }
      /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com
     * @description Method to Cases
     * @param n - number of case
     * @return  List<Case> to insert
    */
    public static List<Case> createCasesForWo(Integer n){
        List<Account> accounts = XC_DF_Account.createResidentialAccounts(n);
        insert accounts;
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accounts);
        insert contacts;
        
        //Id recordTypeId = CaseDAO.newInstance().getActiveRecordtypeIdByDeveloperName(XC_AT_Constants.CASE_RECORD_TYPE_XC_ATTENTION_ESPANA);
        List<Case> cases = new List<Case>();
        for (Integer i=0; i<n; i++){
            Case caso = new Case();
            
            caso.Status = 'ESTA003';
            caso.Reason = 'XCMOT002';
            caso.XC_Subtype__c = 'XC033';
            caso.SubCause__c = 'ATCL054';
            caso.AccountId = accounts[i].Id;
            caso.ContactId = contacts[i].Id;
            caso.XC_LegalEntity__c = 'EndesaX';
            caso.XC_Type_Intermediary__c = 'TI001';
            cases.add(caso);
        }
        return cases;
    }
}