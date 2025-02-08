/**
* Created by SNEKKANTI00 on 09/03/2021.
*/
public without sharing class MailUpService {

    @InvocableMethod
    public static void createMailRecords(List<FlowInput> flowInputs) {
        List<EmailMessage> emailsToInsert = new List<EmailMessage>();
        List<GetThreadId.FlowInput> listInputForThreadId = new List<GetThreadId.FlowInput>();
        GetThreadId.FlowInput singlelistInputForThreadId = new GetThreadId.FlowInput();
        for ( FlowInput singleFlowInput: flowInputs ) {
            singlelistInputForThreadId.caseId = singleFlowInput.caseId;
            listInputForThreadId.clear();
            listInputForThreadId.add(singlelistInputForThreadId);

            EmailMessage emailMessage = new EmailMessage();
            emailMessage.FromAddress = singleFlowInput.fromAddress;
            emailMessage.FromName = singleFlowInput.fromName;
            emailMessage.HtmlBody = singleFlowInput.htmlBody;
            emailMessage.RelatedToId = singleFlowInput.relatedToId;
            emailMessage.Status = singleFlowInput.status;
            emailMessage.Subject = GetThreadId.getCaseThreadIdByCaseId(listInputForThreadId)[0].Thread_Id + singleFlowInput.subject;
            emailMessage.ToAddress = singleFlowInput.toAddress;

            emailsToInsert.add(emailMessage);
        }

        if ( !emailsToInsert.isEmpty() ) {
            System.debug('emailsToInsert -> ' + emailsToInsert);
            List<Database.SaveResult> resInsert = Database.insert(emailsToInsert, true);
            System.debug('resInsert -> ' + resInsert);
        }
    }



    public class FlowInput {
        @InvocableVariable
        public String fromAddress;
        @InvocableVariable
        public String fromName;
        @InvocableVariable
        public String htmlBody;
        @InvocableVariable
        public String relatedToId;
        @InvocableVariable
        public String status;
        @InvocableVariable
        public String subject;
        @InvocableVariable
        public String toAddress;
        @InvocableVariable
        public String caseId;
    }

}