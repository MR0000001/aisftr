global class XC_SC036_EMSAssetManagement implements Schedulable, Database.Batchable<sObject>, Database.AllowsCallouts {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC036_EMSAssetManagement');

    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new XC_SC036_EMSAssetManagement(), 1);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_SC036_EMSAssetManagement ' + batchId); 
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
    
        String query = 'Select id,XC_Address__r.XC_ElectricCUPS__c,XC_ActivationDate__c, NE__Billing_Account__r.XC_PoD__c,  status,  XC_Subscription__r.Zuora__SubscriptionStartDate__c, NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c, NE__CatalogItem__r.NE__Product_Name__c, XC_DescCodeNEXT__c, XC_SubstatusNEXT__c,LastModifiedDate,LastModifiedBy.NAME from Asset where NE__CatalogItem__c != null and NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c = \'Monitoring And Verification Start\' and XC_SubstatusNEXT__c != \'OK\' and XC_Segment__c != \'B2C\'';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Asset> assetList) {
        //asset assetEMS=assetList[0];
        for(asset assetEMS:assetList){
            try{
                if(assetEMS.status == 'Active'){
                    XC_REST_Subscription_Outbound.RequestWrapper wrapper = new XC_REST_Subscription_Outbound.RequestWrapper();
                    wrapper.Subscription = new XC_REST_Subscription_Outbound.SubscriptionWrapper();
                    wrapper.Subscription.asset_id = assetEMS.id;
                    wrapper.Subscription.channel = 'N';
                    wrapper.Subscription.pod = assetEMS.XC_Address__r.XC_ElectricCUPS__c;
                    string month = String.ValueOf(assetEMS.XC_ActivationDate__c.month()); 
                    //Integer monthLength = month.length();
                     if(month.length()==1){
                         month='0'+month;
                     }
                    system.debug('MonthActivationDate '+month);
                     string year = String.ValueOf(assetEMS.XC_ActivationDate__c.year());
                     system.debug('YearActivationDate '+year); 
                    string day=String.ValueOf(assetEMS.XC_ActivationDate__c.day());
                     if(day.length()==1){
                         day='0'+day;
                     }
                     system.debug('DayActivationDate '+day);
                     string activationDate=day+month+year;
                    system.debug('ActivationDate1 '+activationDate);
                    wrapper.Subscription.activation_date=activationDate;
                   // wrapper.Subscription.activation_date = String.ValueOf(assetEMS.XC_ActivationDate__c);
                    wrapper.Subscription.result_type ='daily';
                    wrapper.Subscription.SubscriptionItem = new List<XC_REST_Subscription_Outbound.SubscriptionItemWrapper>();
                    XC_REST_Subscription_Outbound.SubscriptionItemWrapper subscriptionItem = new XC_REST_Subscription_Outbound.SubscriptionItemWrapper();
                    subscriptionItem.id = 'enelx96';
                    //subscriptionItem.validity_from;
                    subscriptionItem.rectification_subscr = 'Y';
                    subscriptionItem.delay_estimation = '2';
                    wrapper.Subscription.SubscriptionItem.add(subscriptionItem);

                    XC_REST_Subscription_Outbound.ResponseWrapper response = XC_REST_Subscription_Outbound.activateCall(wrapper);
                    System.debug('response : ' + response);
                   if(response.result.Message== null){
                        assetEMS.XC_SubstatusNEXT__c = 'OK';
                    }else{
                        assetEMS.XC_SubstatusNEXT__c = 'KO';
                        assetEMS.XC_DescCodeNEXT__c = response.result.Message;
                    }
                }else if(assetEMS.status == 'Inactive'){
                    XC_REST_Subscription_Outbound.RequestWrapper wrapper = new XC_REST_Subscription_Outbound.RequestWrapper();
                    wrapper.Subscription = new XC_REST_Subscription_Outbound.SubscriptionWrapper();
                    wrapper.Subscription.asset_id = assetEMS.id;
                    wrapper.Subscription.channel = 'N';
                    wrapper.Subscription.pod = assetEMS.XC_Address__r.XC_ElectricCUPS__c;

                    XC_REST_Subscription_Outbound.ResponseWrapper response = XC_REST_Subscription_Outbound.deactivateCall(wrapper);
                    if(response.result.Message== null){
                        assetEMS.XC_SubstatusNEXT__c = 'OK';
                    }else{
                        assetEMS.XC_SubstatusNEXT__c = 'KO';
                        assetEMS.XC_DescCodeNEXT__c = response.result.Message;
                    }
                }  
            }catch(Exception e){
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
            }
        }
        update assetList;
    }
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}