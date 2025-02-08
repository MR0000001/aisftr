/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description XC_IN055_Project_Task_U_ManageInvoice
     *
    **/
public without sharing class XC_IN055_Project_Task_U_ManageInvoice {
    /** The Constant DEBUGACTIVE. */
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN055_Project_Task_U_ManageInvoice');

    public class InputWrapper {

        /** The String. */
        @Invocablevariable
        public String taskId;

    }


    /**
     * @author dpalamides - dpalamides@deloitte.it
     * @param inputWrapperList the list coming from flow
     * @description Method to do the logic required for Pay And Bill.
     */
    @InvocableMethod
    public static void createInvoice(List<InputWrapper> inputWrapperList) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering XC_IN055_Project_Task_U_ManageInvoice');

        if (!inputWrapperList.isEmpty() && Schema.sObjectType.project_cloud__Project_Task__c.isAccessible() && Schema.sObjectType.NE__OrderItem__c.isAccessible()) {

            List<String> listStepIds = new List<String>();

            for (InputWrapper inputWr : inputWrapperList) {
                listStepIds.add(inputWr.taskId);
            }

            Map<Id, project_cloud__Project_Task__c> mapTasks = new Map<Id, project_cloud__Project_Task__c>([
                    SELECT ID, XC_AmountToBill__c, project_cloud__Project_Phase__r.project_cloud__Project__r.XC_LegalEntity__c,
                            project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Segment__c
                    FROM project_cloud__Project_Task__c
                    WHERE Id IN:listStepIds
            ]);

            /*if (checkIfItalyAndMixedVAT(mapSteps)) {
                return;
            }*/ //TODO mixed VAT??

            Map<Id, String> mapConfItemZQuoteId = new Map<Id, String>();

            Map<Id, zqu__Quote__c> mapZuoraQuote = new Map<Id, zqu__Quote__c>([
                    SELECT Id, zqu__ZuoraSubscriptionID__c, zqu__ZuoraAccountID__c,XC_Project_Task__c
                    FROM zqu__Quote__c
                    WHERE XC_Project_Task__c IN :mapTasks.keyset()
            ]);

            Map<Id, zqu__Quote__c> quoteByTask = new Map<Id, zqu__Quote__c>();
            for(zqu__Quote__c q : mapZuoraQuote.values()){
                quoteByTask.put(q.XC_Project_Task__c,q);
            }

            for (InputWrapper inputWr : inputWrapperList) {
                project_cloud__Project_Task__c theTask = mapTasks.get(inputWr.taskId);
                zqu__Quote__c theQuote = quoteByTask.get(inputWr.taskId);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'task -> ' + theTask);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'quote -> ' + theQuote);

                XC_REST_PayAndBill.WrapperRequest wrapperPayAndBill = new XC_REST_PayAndBill.WrapperRequest();
                wrapperPayAndBill.SubscriptionId = theQuote.zqu__ZuoraSubscriptionID__c;
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'SubscriptionId -> ' + wrapperPayAndBill.SubscriptionId);

                wrapperPayAndBill.PrepaidAmount = theTask.XC_AmountToBill__c;
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'PrepaidAmount -> ' + wrapperPayAndBill.PrepaidAmount);

                wrapperPayAndBill.accountId = theQuote.zqu__ZuoraAccountID__c;
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'accountId->' + wrapperPayAndBill.accountId);

                wrapperPayAndBill.legalEntity = theTask.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_LegalEntity__c;
                wrapperPayAndBill.stream = theTask.project_cloud__Project_Phase__r.project_cloud__Project__r.XC_Segment__c;
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'legalEntity-->' + wrapperPayAndBill.legalEntity);

                callZuoraAndSetStepStatus(JSON.serialize(wrapperPayAndBill), JSON.serialize(theTask));

            }

            //updateSteps(wrList,provisioningStepsToComplete);
        }
    }


    /**
     * @author dpalamides - dpalamides@deloitte.it
     * @param wrapperPayAndBillSerialize the wrapperPayAndBill serialized
     * @param taskSerialize the step serialized
     * @description Method to do the logic required for Pay And Bill.
     */
    @future(callout=true)
    public static void callZuoraAndSetStepStatus(String wrapperPayAndBillSerialize, String taskSerialize) {

        XC_REST_PayAndBill.WrapperRequest wrapperPayAndBill = (XC_REST_PayAndBill.WrapperRequest) JSON.deserialize(wrapperPayAndBillSerialize, XC_REST_PayAndBill.WrapperRequest.class);
        project_cloud__Project_Task__c theTask = (project_cloud__Project_Task__c) JSON.deserialize(taskSerialize, project_cloud__Project_Task__c.class);

        XC_REST_PayAndBill.WrapperResponse wrResponse = XC_REST_PayAndBill.createPayAndBill(wrapperPayAndBill);

        setTaskStatus(wrResponse, theTask);
        //XC_UTIL_Sobject.updateRecord(theTask);
        update theTask;
    }


    /**
    * Set step status.
    * @param wrResponse the PayAndBill wrapper response
    * @param step the provisioning step to update
    * @description Method to set step status
    */
    private static void setTaskStatus(XC_REST_PayAndBill.WrapperResponse wrResponse, project_cloud__Project_Task__c theTask) {
        if (wrResponse.errors != null && !(wrResponse.errors).isEmpty()) {
            theTask.XC_TaskStatus__c = 'Suspended';
            theTask.XC_Message__c = Label.XC_CL_BillingTaskInvoiceKO;
            //theTask.project_cloud__Health__c = 'Yellow';
        } else {
            theTask.XC_TaskStatus__c = 'Closed';
            theTask.project_cloud__Completed_Date__c = Date.today();
            theTask.XC_Message__c = Label.XC_CL_BillingTaskDone;
            //theTask.project_cloud__Health__c = 'Green';
            theTask.XC_StepInvoice__c = true;
        }
    }

}