/**
 * Created by snekkanti002 on 06/08/2021.
 */

public without sharing class GEDCheckAttachments {

    @InvocableMethod
    public static List<FlowOutput> gedCheckAttachments(List<FlowInput> flowInputs) {
        DebugService.printLimits('GEDCheckAttachments', 'gedCheckAttachments', 'start');
        List<FlowOutput> flowOutputs = new List<FlowOutput>();
        Map<String, String> caseIdOutputMap = new Map<String, String>();

        try {
            List<String> caseIds = new List<String>();
            Boolean updateError = false;
            List<String> contentVersionIds = new List<String>();

            for(FlowInput input : flowInputs) {
                caseIds.add(input.caseId);
                caseIdOutputMap.put(input.caseId, 'false');
            }

            List<Case> cases = CaseSelector.getCasesCreatedDateByCaseIds(caseIds);

            Map<Case, List<ContentVersion>> caseCVsMap = ContentVersionService.getCaseCvsAllGEDMap(cases);

            //Map<String, ContentVersion> contentVersionMap = ContentVersionSelector.getContentVersionMapByCaseIds(caseIds);

            System.debug('caseCVsMap ' + caseCVsMap);

            ContentVersionService.checkAttachmentsWithinLimitsAndUpdate(caseCVsMap, caseIdOutputMap, false);

            for(String cId : caseIdOutputMap.keySet()) {
                FlowOutput flowOutput = new FlowOutput();

                if(caseIdOutputMap.get(cId).equalsIgnoreCase('false&Error')) {
                    flowOutput.isError = true;
                }
                flowOutput.isAtleastOneAttachment = Boolean.valueOf(caseIdOutputMap.get(cId));
                flowOutput.isError = false;

                flowOutputs.add(flowOutput);
            }

            return flowOutputs;
        } catch(Exception e) {
            DebugService.printException('GEDCheckAttachment', 'gedCheckAttachment', e);
            ErrorLogEventHandler.standardExceptionLog(e);

            for(String cId : caseIdOutputMap.keySet()) {
                FlowOutput flowOutput = new FlowOutput();

                flowOutput.isAtleastOneAttachment = Boolean.valueOf(caseIdOutputMap.get(cId));
                flowOutput.isError = true;

                flowOutputs.add(flowOutput);
            }
        }

        DebugService.printLimits('GEDCheckAttachments', 'gedCheckAttachments', 'end');
        return flowOutputs;
    }

    public class FlowInput {
        @InvocableVariable
        public String caseId;
    }

    public class FlowOutput {
        @InvocableVariable
        public Boolean isError;

        @InvocableVariable
        public Boolean isAtleastOneAttachment;
    }
}