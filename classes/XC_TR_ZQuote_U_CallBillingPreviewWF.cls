/**
* @author dpalamides
* @date 12/06/2020
* @description classes.XC_TR_ZQuote_U_CallBillingPreviewWF
*/


public with sharing class XC_TR_ZQuote_U_CallBillingPreviewWF {
//call zuora wf asynch
    public class CallZuoraWFQueueable implements Queueable,Database.AllowsCallouts{
        Zqu__Quote__c      theQuote;
        NE__Order__c       theOrder;
        Map<String,String> zuoraParams;

        public callZuoraWFQueueable (NE__Order__c theOrder, Zqu__Quote__c  theQuote,Map<String,String> zuoraParams){
            this.zuoraParams = zuoraParams;
            this.theQuote = theQuote;
            this.theOrder = theOrder;
        }

        public void execute(QueueableContext ctx){
            //building params to call Zuora
            Map<String,Object> zuoraResult = callZuoraWF(zuoraParams);
            Boolean success = Boolean.valueOf(zuoraResult.get('success'));
            if(success==false) {
                theOrder.XC_BillingPreviewStatus__c = 'Error';
                theOrder.XC_BillingPreviewMessage__c = String.valueOf(zuoraResult.get('errorMsg'));
                XC_UTIL_Sobject.updateRecord(theOrder);
            }else{
                XC_UTIL_Sobject.deleteRecord(theQuote);
            }
        }

    }



    /**
    * @description call zuora workflow to manage billing preview products billing strategy
    * @author dpalamides
    * @param step
    * @return Boolean
    **/
    private static Map<String,Object> callZuoraWF(Map<String,Object> params){

        Map<String,Object> result = new Map<String,Object>();
        result.put('success',true);

        XC_REST_BillingPreviewWF.WrapperRequest req = new XC_REST_BillingPreviewWF.WrapperRequest();
        req.accountId = String.valueOf(params.get('zuoraAccountId'));
        req.subscriptionId = String.valueOf(params.get('subscriptionId'));
        req.legalEntity = String.valueOf(params.get('legalEntity'));
        req.stream = String.valueOf(params.get('stream'));

        XC_REST_BillingPreviewWF.WrapperResponse resp =  XC_REST_BillingPreviewWF.callBillingPreviewWF(req);
        if(resp.errors!=null && !resp.errors.isEmpty()){
            result.put('success',false);
            String errorMsgs = '';
            for(XC_REST_BillingPreviewWF.WrapperErrors err : resp.errors){
                errorMsgs += ' Zuora Workflow Error : ' + err.title + ' ' + err.code + ' ' + err.status;
            }
            result.put('errorMsg',errorMsgs);
        }

        return result;
    }

    /**
     * @description call zuora workflow to manage billing preview products billing strategy
     * @author dpalamides
     * @param step
     * @return Boolean
     **/
    public static void callZuoraBillingPreview(List<Zqu__Quote__c> quoteList){
        Map<Id,NE__Order__c> quoteOrders = new Map<Id,NE__Order__c>([
                select id, XC_Country__c, XC_LegalEntity__c, XC_Segment__c from NE__Order__c where id in :XC_UTIL_Sobject.getListFieldValues(quoteList,'CRMConfiguration__c')
        ]);
        Set<NE__Order__c>  inError  = new Set<NE__Order__c>();
        for(Zqu__Quote__c q : quoteList) {
            NE__Order__c ord = quoteOrders.get(q.CRMConfiguration__c);
            if(q.XC_IsSuccess__c == false && q.zqu__Status__c != 'Sent to Z-Billing'){
                ord.XC_BillingPreviewStatus__c = 'Error';
                ord.XC_BillingPreviewMessage__c = q.XC_Message__c!=null ? q.XC_Message__c : 'Send to z-billing error' + ' ('+q.XC_ConfigurationItem__c+')';
                inError.add(ord);
                continue;
            }
            if (Limits.getCallouts() < Limits.getLimitCallouts() && quoteOrders.containsKey(q.CRMConfiguration__c)) {

                //building params to call Zuora
                Map<String, String> params = new Map<String, String>();
                params.put('subscriptionId', q.zqu__ZuoraSubscriptionID__c);
                params.put('zuoraAccountId', q.zqu__ZuoraAccountID__c);
                params.put('legalEntity', ord.XC_LegalEntity__c);
                params.put('stream', ord.XC_Segment__c);

                // Map<String,Object> zuoraResult = callZuoraWF(params);
                // Boolean success = Boolean.valueOf(zuoraResult.get('success'));
                // step.XC_Status__c = success ==true ? Label.XC_CL_Completed_Ok : Label.XC_CL_Step_CompletedKO;
                // step.XC_ErrorMessage__c = success == true  ? '' : String.valueOf(zuoraResult.get('errorMsg'));
                CallZuoraWFQueueable callZuora = new CallZuoraWFQueueable(ord,q,params);
                System.enqueueJob(callZuora);
            }
        }
        List<NE__Order__c> ordUpd = new List<NE__Order__c>();
        ordUpd.addAll(inError);
        XC_UTIL_Sobject.updateListRecords(ordUpd);

    }
}