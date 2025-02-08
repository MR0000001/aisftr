/**
 * Created by FMARCHEGIA00 on 08/06/2021.
 */

public with sharing class GetThreadId {

        @InvocableMethod
        public static List<FlowOutput> getCaseThreadIdByCaseId(List<FlowInput> flowInputs) {
            List<FlowOutput> result = new List<FlowOutput>();
            FlowOutput singleResult = new FlowOutput();
            for ( FlowInput singleval : flowInputs ) {
                List<Messaging.RenderEmailTemplateBodyResult> renderResults = Messaging.renderEmailTemplate(null, singleval.caseId, new List<String>{'{!Case.Thread_Id}'});
                singleResult.Thread_Id = renderResults[0].getMergedBody();
                result.add(singleResult);
            }
            return result;
        }

        public class FlowInput {
            @InvocableVariable
            public String caseId;
        }

        public class FlowOutput {
            @InvocableVariable
            public String Thread_Id;
        }

    }