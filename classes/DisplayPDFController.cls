/**
 * Created by FMARCHEGIA00 on 06/07/2021.
 */

public without sharing class DisplayPDFController {

    private static final String SPACE = ' ';
    public enum CfPiva {CF, PIVA, BOTH}
    public CfPiva cfPivaEnum {get; set;}
    public String caseId {get; set;}
    public String accountId {get; set;}
    public String caseNumber {get; set;}
    public String caseNumberLabel {get; set;}
    public String caseType {get; set;}
    public String caseTypeLabel {get; set;}
    public String caseOrigin {get; set;}
    public String caseOriginLabel {get; set;}
    public String caseSubject {get; set;}
    public String caseSubjectLabel {get; set;}
    public String caseCreatedDate {get; set;}
    public String caseCreatedDateLabel {get; set;}
    public String caseOwner {get; set;}
    public String ownerLabel {get; set;}
    public String protocolStructure {get; set;}
    public String protocolStructureLabel {get; set;}
    public String caseAddress {get; set;}
    public String addressLabel {get; set;}
    public String caseName {get; set;}
    public String nameLabel {get; set;}
    public String caseEmail {get; set;}
    public String emailLabel {get; set;}
    public String fiscalCode {get; set;}
    public String fiscalCodeLabel {get; set;}
    public String caseDescription {get; set;}
    public String caseDescriptionLabel {get; set;}

    public DisplayPDFController() {
        DebugService.printLimits('DisplayPDFController', 'constructor', 'start');

        this.caseId = ApexPages.currentPage().getParameters().get('caseId');
        this.accountId = ApexPages.currentPage().getParameters().get('accountId');
        this.protocolStructure = ApexPages.currentPage().getParameters().get('structure');
        this.caseOwner = ApexPages.currentPage().getParameters().get('owner');
        this.caseType = ApexPages.currentPage().getParameters().get('type');
        this.caseOrigin = ApexPages.currentPage().getParameters().get('origin');
        this.caseSubject = ApexPages.currentPage().getParameters().get('subject');
        this.caseAddress = ApexPages.currentPage().getParameters().get('address');
        this.caseDescription = ApexPages.currentPage().getParameters().get('description');
        setPageForRender();

        DebugService.printLimits('DisplayPDFController', 'constructor', 'end');
    }
    
    public void setPageForRender() {
        DebugService.printLimits('DisplayPDFController', 'setPageForRender', 'start');

        Map<String, String> caseIdAccountId = new Map<String, String>();

        List<Case> cases = CaseSelector.getCasesForPDFById(new List<String>{this.caseId});
        DebugService.printList('DisplayPDFController', 'setPageForRender', 'cases', cases);

        caseIdAccountId.put(this.caseId, this.accountId);
        DebugService.printMap('DisplayPDFController', 'setPageForRender', 'caseIdAccountId', new List<String>(caseIdAccountId.keySet()), caseIdAccountId.values(), true);

        Map<String, Account> caseIdAccountDetailMap = AccountService.getAccountsForGEDPdfByIds(caseIdAccountId);
        DebugService.printMap('DisplayPDFController', 'setPageForRender', 'caseIdAccountDetailMap', new List<String>(caseIdAccountDetailMap.keySet()), caseIdAccountDetailMap.values(), true);

        if(!cases.isEmpty()) {
            for(Case singleCase : cases) {
                Account acc = caseIdAccountDetailMap.get(this.caseId);
                System.debug('Account ' + acc);
                System.debug('Case Case_Business_Account__c ' + singleCase.Case_Business_Account__c);

                this.populateCommonFieldsFromAccount(acc);
                this.populateCommonFieldsFromCase(singleCase);
                if(singleCase.Case_Business_Account__c) {
                    System.debug('Entered PG');
                    this.populateFieldsForPgFromAccount(acc);
                } else {
                    System.debug('Entered PA');
                    this.populateFieldsForPaFromAccount(acc);
                }
                this.populateLabels();
            }
        }
        DebugService.printLimits('DisplayPDFController', 'setPageForRender', 'end');
    }

    private void populateCommonFieldsFromAccount(Account acc) {
        DebugService.printLimits('DisplayPDFController', 'populateCommonFieldsFromAccount', 'start');
        this.caseName = acc?.Name;
        DebugService.printLimits('DisplayPDFController', 'populateCommonFieldsFromAccount', 'end');
    }

    private void populateCommonFieldsFromCase(Case singleCase) {
        DebugService.printLimits('DisplayPDFController', 'populateCommonFieldsFromCase', 'start');
        this.caseType = String.isNotBlank(this.caseType) ? this.caseType:'';
        this.caseOwner = String.isNotBlank(this.caseOwner) ? this.caseOwner:'';
        this.protocolStructure = String.isNotBlank(this.protocolStructure) ? this.protocolStructure:'';
        this.caseNumber = singleCase.CaseNumber;
        this.caseOrigin = String.isNotBlank(this.caseOrigin) ? this.caseOrigin : '';
        this.caseCreatedDate = singleCase.CreatedDate.date().format();
        this.caseSubject = String.isNotBlank(this.caseSubject) ? this.caseSubject : '';
        DebugService.printLimits('DisplayPDFController', 'populateCommonFieldsFromCase', 'end');
    }

    private void populateFieldsForPgFromAccount(Account acc) {
        DebugService.printLimits('DisplayPDFController', 'populateFieldsForPgFromAccount', 'start');
        this.processFiscalCodeForPG(acc);
        this.caseEmail = String.isNotBlank(acc ?.Email_Account__c) ? acc.Email_Account__c : '';
        this.caseAddress = String.isNotBlank(String.valueOf(acc ?.BillingAddress)) ? String.valueOf(acc.BillingAddress) : '';
        if (acc ?.BillingAddress != null) {
            this.caseAddress = (String.isNotBlank(acc.BillingAddress.getStreet()) ? acc.BillingAddress.getStreet() + ' ' : '') + (String.isNotBlank(acc.BillingAddress.getCity()) ? acc.BillingAddress.getCity() + ' ' : '') + (String.isNotBlank(acc.BillingAddress.getPostalCode()) ? acc.BillingAddress.getPostalCode() + ' ' : '') + (String.isNotBlank(acc.BillingAddress.getState()) ? acc.BillingAddress.getState() + ' ' : '');
        }
        DebugService.printLimits('DisplayPDFController', 'populateFieldsForPgFromAccount', 'end');
    }

    private void populateFieldsForPaFromAccount(Account acc) {
        DebugService.printLimits('DisplayPDFController', 'populateFieldsForPaFromAccount', 'start');
        this.fiscalCode = String.isNotBlank(acc?.Fiscal_Code__pc) ? acc.Fiscal_Code__pc : '';
        this.caseEmail = String.isNotBlank(acc?.PersonEmail) ? acc.PersonEmail : '';
        this.caseAddress = String.isNotBlank(this.caseAddress) ? this.caseAddress : '';
        DebugService.printLimits('DisplayPDFController', 'populateFieldsForPaFromAccount', 'end');
    }

    private void processFiscalCodeForPG(Account acc) {
        DebugService.printLimits('DisplayPDFController', 'populateCommonFields', 'start');
        if(String.isNotBlank(acc?.Account_Fiscal_Code__c) && String.isNotBlank(acc?.Partita_IVA__c)) {
            this.fiscalCode = acc.Account_Fiscal_Code__c + ' / ' + acc.Partita_IVA__c;
            this.cfPivaEnum = CfPiva.BOTH;
        } else if(String.isNotBlank(acc?.Account_Fiscal_Code__c)) {
            this.fiscalCode = acc.Account_Fiscal_Code__c;
            this.cfPivaEnum = CfPiva.CF;
        } else if(String.isNotBlank(acc?.Partita_IVA__c)) {
            this.fiscalCode = acc.Partita_IVA__c;
            this.cfPivaEnum = CfPiva.PIVA;
        } else {
            this.fiscalCode = '';
        }
        DebugService.printLimits('DisplayPDFController', 'processFiscalCodeForPG', 'end');
    }

    public void populateLabels() {
        DebugService.printLimits('DisplayPDFController', 'populateLabels', 'start');
        this.populateFiscalCodeLabel();
        this.caseSubjectLabel = Label.renderAsPDF_SubjectLabel + SPACE;
        this.addressLabel = Label.renderAsPDF_Address + SPACE;
        this.caseOriginLabel = Label.renderAsPDF_OriginLabel + SPACE;
        this.caseNumberLabel = Label.renderAsPDF_CaseNumber + SPACE;
        this.nameLabel = Label.renderAsPDF_FullName + SPACE;
        this.emailLabel = Label.renderAsPDF_Email + SPACE;
        if(String.isNotBlank(this.caseType) && this.caseType.equalsIgnoreCase(Label.reclamo)) {
            System.debug('Entered reclamo');
            this.caseTypeLabel = Label.renderAsPDF_TypeLabel + SPACE + 'del' + SPACE;
        } else if(String.isNotBlank(this.caseType) && this.caseType.equalsIgnoreCase(Label.segnalazione)) {
            System.debug('Entered segnalazion');
            this.caseTypeLabel = Label.renderAsPDF_TypeLabel + SPACE + 'della' + SPACE;
        }
        this.protocolStructureLabel = Label.renderAsPDF_ProtocolStructureLabel + SPACE;
        this.ownerLabel = Label.renderAsPDF_OwnerName + SPACE;
        this.caseCreatedDateLabel = Label.renderAsPDF_CreatedDate + SPACE;
        this.caseDescriptionLabel = Label.renderAsPDF_CaseDescription + SPACE;
        DebugService.printLimits('DisplayPDFController', 'populateLabels', 'end');
    }

    private void populateFiscalCodeLabel() {
        DebugService.printLimits('DisplayPDFController', 'processFiscalCodeLabelForPG', 'start');
        if(this.cfPivaEnum == CfPiva.BOTH) {
            this.fiscalCodeLabel = Label.renderAsPDF_CodiceFiscalePIVA + SPACE;
        } else if(this.cfPivaEnum == CfPiva.CF) {
            this.fiscalCodeLabel = Label.renderAsPDF_CodiceFiscale + SPACE;
        } else if(this.cfPivaEnum == CfPiva.PIVA) {
            this.fiscalCodeLabel = Label.renderAsPDF_PIVA + SPACE;
        } else {
            this.fiscalCodeLabel = Label.renderAsPDF_CodiceFiscale + SPACE;
        }
        DebugService.printLimits('DisplayPDFController', 'processFiscalCodeLabelForPG', 'end');
    }
}