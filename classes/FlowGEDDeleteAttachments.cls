/**
 * Created by snekkanti002 on 16/09/2021.
 */

public without sharing class FlowGEDDeleteAttachments {

    @InvocableMethod
    public static List<FlowOutput> gedDeleteAttachments (List<FlowInput> flowInputs) {
        DebugService.printLimits('FlowGEDDeleteAttachments', 'gedDeleteAttachments', 'start');
        System.debug('flowInputs ' + flowInputs);
        FlowOutput flowOutput = new FlowOutput();
        try {
            List<String> caseIds = new List<String>();

            for(FlowInput input : flowInputs) {
                caseIds.add(input.caseId);
            }

            flowOutput.isError = CaseService.processGEDDeleteAttachments(caseIds);
        } catch(Exception e) {
            DebugService.printException('FlowGEDDeleteAttachments', 'gedDeleteAttachments', e);
            flowOutput.isError = true;
            ErrorLogEventHandler.standardExceptionLog(e);
        }
        DebugService.printLimits('FlowGEDDeleteAttachments', 'gedDeleteAttachments', 'end');
        return new List<FlowOutput>{flowOutput};
    }

    public class FlowInput {
        @InvocableVariable
        public String caseId;
    }

    public class FlowOutput {
        @InvocableVariable
        public Boolean isError;
    }
}