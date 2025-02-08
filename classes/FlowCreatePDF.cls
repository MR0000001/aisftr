/**
 * Created by FMARCHEGIA00 on 06/07/2021.
 */

public without sharing class FlowCreatePDF {

    @InvocableMethod
    public static List<FlowOutput> checkCase(List<FlowInput> flowInputs) {
        DebugService.printLimits('FlowCreatePDF', 'checkCase', 'start');

        List<String> caseIds = new List<String>();
        List<FlowOutput> results = new List<FlowOutput>();
        Map<String, String> caseIdProtocolName = new Map<String, String>();
        Map<String, String> caseIdAccountId = new Map<String, String>();
        Map<String, String> caseIdUrpProtocol = new Map<String, String>();
        Map<String, String> caseIdType = new Map<String, String>();
        Map<String, String> caseIdOrigin = new Map<String, String>();
        Map<String, String> caseIdSubject = new Map<String, String>();
        Map<String, String> caseIdAddress = new Map<String, String>();
        Map<String, String> caseIdDescription = new Map<String, String>();
        List<ContentVersionWrapper> contentVersionWrappers = new List<ContentVersionWrapper>();

        try {
            for(FlowInput singleFlowInput: flowInputs) {
                caseIdProtocolName.put(singleFlowInput.theCase.Id, singleFlowInput.structureName);
                caseIdAccountId.put(singleFlowInput.theCase.Id, singleFlowInput.newAccountId);
                caseIdUrpProtocol.put(singleFlowInput.theCase.Id, singleFlowInput.urpProtocol);
                caseIdType.put(singleFlowInput.theCase.Id, singleFlowInput.caseType);
                caseIdOrigin.put(singleFlowInput.theCase.Id, singleFlowInput.caseOrigin);
                caseIdSubject.put(singleFlowInput.theCase.Id, singleFlowInput.caseSubject);
                caseIdDescription.put(singleFlowInput.theCase.Id, singleFlowInput.caseDescription);
                String caseAddress = (String.isNotBlank(singleFlowInput.streetAddress) ? singleFlowInput.streetAddress+ ' ':'') + (String.isNotBlank(String.valueOf(singleFlowInput.numberAddress)) ? String.valueOf(singleFlowInput.numberAddress) + ' ':'') + (String.isNotBlank(singleFlowInput.letterAddress) ? singleFlowInput.letterAddress : '');
                caseIdAddress.put(singleFlowInput.theCase.Id, caseAddress);
            }

            for(FlowInput singleFlowInput: flowInputs) {
                Case c = singleFlowInput.theCase;
                System.debug('singleFlowInput.theCase ' + singleFlowInput.theCase);
                Pagereference pg = Page.renderAsPdf;
                pg.getParameters().put('caseId', c.Id);
                pg.getParameters().put('accountId', caseIdAccountId.get(c.Id));
                pg.getParameters().put('structure', caseIdProtocolName.get(c.Id));
                pg.getParameters().put('owner', caseIdUrpProtocol.get(c.Id));
                pg.getParameters().put('type', caseIdType.get(c.Id));
                pg.getParameters().put('origin', caseIdOrigin.get(c.Id));
                pg.getParameters().put('subject', caseIdSubject.get(c.Id));
                pg.getParameters().put('address', caseIdAddress.get(c.Id));

                //System.debug('available length ' + (2048 - pg.getParameters().toString().length()));
                pg.getParameters().put('description', caseIdDescription.get(c.Id).abbreviate(Integer.valueOf(Label.renderAsPDF_DescCharLimit)));
                /*pg.getParameters().put('caseName', acc.Name);
                pg.getParameters().put('caseEmail', acc.PersonEmail);
                pg.getParameters().put('fiscalCode', acc.Fiscal_Code__pc);*/

                System.debug('pg length ' + pg.getParameters().toString().length());

                String pdfName = c.CaseNumber + '-' + c.Subject;
                pdfName = pdfName.length() > Integer.valueOf(Label.GED_PdfNameLengthLimit) ? pdfName.substring(0, Integer.valueOf(Label.GED_PdfNameLengthLimit)) : pdfName;

                System.debug('caseIds -> '+ c.Id);
                System.debug(pdfName);
                System.debug(pdfName.length());

                ContentVersionWrapper wrapper = new ContentVersionWrapper(pdfName, pdfName+'.pdf', pg.getContentAsPDF(), 'H', c.Id, true, true);
                contentVersionWrappers.add(wrapper);
            }

            ContentVersionService.createContentVersionsFromPDF(contentVersionWrappers, results);
        } catch (Exception e) {
            System.debug('Exception at FlowCreatePDF.checkCase ' + e.getStackTraceString());
            FlowOutput singleResult = new FlowOutput();
            singleResult.isSuccess = false;
            singleResult.errorMessage = e.getMessage();
            results.add(singleResult);
        }
        system.debug('result -> '+results);
        DebugService.printLimits('FlowCreatePDF', 'checkCase', 'end');
        return  results;
    }

    public class FlowInput {
        @InvocableVariable
        public Case theCase;

        @InvocableVariable
        public String structureName;

        @InvocableVariable
        public String newAccountId;

        @InvocableVariable
        public String urpProtocol;

        @InvocableVariable
        public String caseType;

        @InvocableVariable
        public String caseOrigin;

        @InvocableVariable
        public String caseSubject;

        @InvocableVariable
        public Integer numberAddress;

        @InvocableVariable
        public String streetAddress;

        @InvocableVariable
        public String letterAddress;

        @InvocableVariable
        public String caseDescription;
    }

    public class FlowOutput {
        @InvocableVariable
        public Boolean isSuccess;

        @InvocableVariable
        public String errorMessage;
    }
}