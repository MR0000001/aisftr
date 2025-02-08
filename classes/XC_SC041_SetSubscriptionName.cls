/**
* @description XC_SC041_SetSubscriptionName - Batch to set subscription name on zquote and asset
*/

public class XC_SC041_SetSubscriptionName implements Schedulable, Database.Batchable<sObject> {


	private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC041_SetSubscriptionName');


	/**
     * @description execute method
     * @param sc - SchedulableContext 
    */
	public void execute(SchedulableContext sc) { 
		Id batchId = Database.executeBatch(new XC_SC041_SetSubscriptionName());
	}     


	/**
     * @description start method
     * @param bc - BatchableContext 
     * @return Database.QueryLocator  
    */
    public Database.QueryLocator start(Database.BatchableContext bc) { 
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'START batch SC041');

        DateTime dateNow = DateTime.now().addMinutes(-3);
		String query = 'SELECT Id, zqu__Status__c, zqu__ZuoraSubscriptionID__c, XC_LastSubscriptionId__c, zqu__Account__c ' + 
        			   'FROM zqu__Quote__c ' +
        			   'WHERE zqu__ZuoraSubscriptionID__c != null AND XC_SubscriptionName__c = null';
        query += (!Test.isRunningTest()) ? ' AND LastModifiedDate < :dateNow' : '';
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'query ' +  Database.getQueryLocator(query));	

        return Database.getQueryLocator(query);
    }


	/** 
     * @description execute method
     * @param bc - BatchableContext 
     * @param scope - list to execute logic on
    */
    public void execute(Database.BatchableContext bc, List<zqu__Quote__c> scope) {
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'EXECUTE batch SC041');
     	
        Set<String> subIds = new Set<String>();
        Set<String> accountIds = new Set<String>();
     	for(zqu__Quote__c zquote : scope) { 
			XC_UTIL_Debug.debug(DEBUGACTIVE, 'For quote ---> ' + zquote);
			XC_UTIL_Debug.debug(DEBUGACTIVE, 'SubscriptionId ---> ' + zquote.zqu__ZuoraSubscriptionID__c);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'LastSubscriptionId ---> ' + zquote.XC_LastSubscriptionId__c);
            if(String.isNotBlank(zquote.zqu__ZuoraSubscriptionID__c)) {
                subIds.add(zquote.zqu__ZuoraSubscriptionID__c);
            }
            if(String.isNotBlank(zquote.XC_LastSubscriptionId__c)) {
                subIds.add(zquote.XC_LastSubscriptionId__c);
            }
            if(String.isNotBlank(zquote.zqu__Account__c)) {
                accountIds.add(zquote.zqu__Account__c);
            }
     	}

        if(subIds.isEmpty()) {
            return;
        }

        Map<Id, Zuora__Subscription__c> subscriptionsMap = new Map<Id, Zuora__Subscription__c>([SELECT Id, Name, Zuora__OriginalId__c, Zuora__PreviousSubscriptionId__c, Zuora__External_Id__c, Zuora__SubscriptionNumber__c
                                                                                                FROM Zuora__Subscription__c
                                                                                                WHERE Zuora__Account__c IN :accountIds
                                                                                                    AND (Zuora__OriginalId__c IN :subIds
                                                                                                    OR Zuora__PreviousSubscriptionId__c IN :subIds
                                                                                                    OR Zuora__External_Id__c IN :subIds)]);
        Map<String, Zuora__Subscription__c> subIdNameMap = new Map<String, Zuora__Subscription__c>();
        for(Zuora__Subscription__c sub : subscriptionsMap.values()) {
            subIdNameMap.put(sub.Zuora__OriginalId__c, sub);
            subIdNameMap.put(sub.Zuora__PreviousSubscriptionId__c, sub);
            subIdNameMap.put(sub.Zuora__External_Id__c, sub);
        }
        
        List<zqu__quote__c> quotesToUpdate = new List<zqu__quote__c>();
        Map<Id, Zuora__Subscription__c> zqIdSubMap  = new Map<Id, Zuora__Subscription__c>();
        for(zqu__Quote__c zquote : scope) { 
            if(String.isNotBlank(zquote.zqu__ZuoraSubscriptionID__c) && subIdNameMap.containsKey(zquote.zqu__ZuoraSubscriptionID__c)) {
                zquote.XC_SubscriptionName__c = subIdNameMap.get(zquote.zqu__ZuoraSubscriptionID__c).Zuora__SubscriptionNumber__c;
                zquote.XC_LastSubscriptionId__c = (subIdNameMap.get(zquote.zqu__ZuoraSubscriptionID__c).Zuora__External_Id__c != zquote.zqu__ZuoraSubscriptionID__c) ? subIdNameMap.get(zquote.zqu__ZuoraSubscriptionID__c).Zuora__External_Id__c : zquote.XC_LastSubscriptionId__c;
                quotesToUpdate.add(zquote);
                zqIdSubMap.put(zquote.Id, subIdNameMap.get(zquote.zqu__ZuoraSubscriptionID__c));
            } else if(String.isNotBlank(zquote.XC_LastSubscriptionId__c) && subIdNameMap.containsKey(zquote.XC_LastSubscriptionId__c)) {
                zquote.XC_SubscriptionName__c = subIdNameMap.get(zquote.XC_LastSubscriptionId__c).Zuora__SubscriptionNumber__c;
                zquote.XC_LastSubscriptionId__c = (subIdNameMap.get(zquote.XC_LastSubscriptionId__c).Zuora__External_Id__c != zquote.zqu__ZuoraSubscriptionID__c) ? subIdNameMap.get(zquote.XC_LastSubscriptionId__c).Zuora__External_Id__c : zquote.XC_LastSubscriptionId__c;
                quotesToUpdate.add(zquote);
                zqIdSubMap.put(zquote.Id, subIdNameMap.get(zquote.XC_LastSubscriptionId__c));
            }
     	}
        
        if(!quotesToUpdate.isEmpty()) {
            XC_UTIL_SObject.updateListRecords(quotesToUpdate);
        }

        // CALL Method to update Subscription Field on Asset
        if(!zqIdSubMap.isEmpty()) {
            XC_TR_ZuoraSubscription_U_ManageZquote.updateSubscriptionOnAsset(zqIdSubMap, new List<Zuora__Subscription__c>()); //20211111_DD_SO_14
        }
    }


	/**
     * @description finish method
     * @param bc - BatchableContext 
    */
	public void finish(Database.batchablecontext bc) {
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'FINISH batch SC041'); 
    }
}