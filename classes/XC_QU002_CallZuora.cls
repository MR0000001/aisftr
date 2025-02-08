/**
@author Neeraj Saini - neeraj.saini@accenture.com
@date Creation 23/06/2022
@description XC_QU002_CallZuora – Call Zuora Queueable Class
@testclass XC_QU002_CallZuora_Test
*/
public class XC_QU002_CallZuora implements Queueable, Database.AllowsCallouts {

    Map<String,String> zuoraMap;
    Boolean toSave;

    public XC_QU002_CallZuora(Map<String,String> zuoraMaps,Boolean tosave){
        this.zuoraMap = zuoraMaps;
        this.toSave = tosave;
    }

    public void execute(QueueableContext context) {
        try{
            if(this.zuoraMap!=null && !this.zuoraMap.isEmpty()){
                XC_BillingProfileLineItem__c bpliUpdateRec = new XC_BillingProfileLineItem__c();
                bpliUpdateRec.id = zuoraMap.get('billingProfLineItemId');
                if(tosave){
                    bpliUpdateRec = XC_REST_Account_B.saveTechParameter(zuoraMap,bpliUpdateRec);
                }
                
                try{
                    XC_REST_Account_B.callZuoraSync(zuoraMap);
                }
                catch(Exception e){
                    system.debug(e.getMessage());
                }
                XC_TR_BillingProfileLineItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
                XC_TR_BillingProfileLineItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
                XC_UTIL_SObject.updateRecord(bpliUpdateRec);
                XC_TR_BillingProfileLineItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
                XC_TR_BillingProfileLineItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
            }
        } catch(Exception e) {
            if(this.zuoraMap!=null && !this.zuoraMap.isEmpty()){
                XC_REST_Account_B.manageRetry(zuoraMap.get('billingProfLineItemId'),e.getMessage() +' : '+e.getStackTraceString(),'','ExceptionExecutingQueueZuora');
            }
        }
    }

 }