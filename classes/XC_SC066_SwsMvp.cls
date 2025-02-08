public class XC_SC066_SwsMvp implements Database.Batchable<Sobject>,Schedulable {


    public void execute(SchedulableContext sc) {

        Id batchId = Database.executeBatch(new XC_SC066_SwsMvp(), 1); //DON'T MODIFY THE SCOPE
    }
    
    
    public Database.QueryLocator start(Database.BatchableContext BC) {

        Set<String> outcomes = new Set<String> {'OK','KO'};
        Set<String> status = new Set<String> {'In Progress','To be validated'};
        String recordTypeDevName = 'Order';
        String country = 'Brazil';

        String query = 'SELECT Id,NE__Description__c,(select id,NE__Root_Order_Item__c from NE__Order_Items__r) FROM NE__Order__c where RecordType.DeveloperName = :recordTypeDevName AND XC_Country__c = :country AND XC_Status__c IN :status AND NE__Description__c IN :outcomes AND XC_AssetsCreated__c = false';

        return Database.getQueryLocator(query);
    }
    
    
    public void execute(Database.BatchableContext BC, List<NE__Order__c> scope) {

        List<NE__Order__c> orderToUpdateList = new List<NE__Order__c>();
        List<NE__OrderItem__c> orderItemToUpdateList = new List<NE__OrderItem__c>();
        List<Id> orderToAsset = new List<Id>();

        for(NE__Order__c ord : scope){
            if('KO'.equalsIgnoreCase(ord.NE__Description__c)){

                //cancel order
                NE.OrderSummaryButtonExtension.cancelButton(ord.Id);

                ord.XC_Status__c = Label.XC_CL_Order_StatusCancelled;
                ord.XC_Cancellation_Date__c = Date.today();
                ord.XC_Mode_of_cancellation__c = 'Manual';
                ord.XC_Type_of_cancellation__c = 'Total';
                ord.XC_Reason_of_cancellation__c = 'Cancelled Quote';
                orderToUpdateList.add(ord);
            }
            else if('OK'.equalsIgnoreCase(ord.NE__Description__c)){

                if(!ord.NE__Order_Items__r.isEmpty()){
                    for(NE__OrderItem__c oi : ord.NE__Order_Items__r){
                        if(null != oi.NE__Root_Order_Item__c){
                            oi.NE__Generate_Asset_Item__c = false;
                            orderItemToUpdateList.add(oi);
                            orderToAsset.add(ord.Id);
                        }
                    }
                }
            }
        }

        if(!orderToUpdateList.isEmpty()){
            XC_UTIL_Sobject.updateListRecords(orderToUpdateList);
        }    
        if(!orderItemToUpdateList.isEmpty()){
            XC_UTIL_Sobject.updateListRecords(orderItemToUpdateList);
        } 
        if(!orderToAsset.isEmpty()){
            //order2asset
            XC_UTIL_Configuration.changeOrderStatusSent(orderToAsset.get(0), false);    
        }      
    }

    
    public void finish(Database.BatchableContext bc){

    }

}