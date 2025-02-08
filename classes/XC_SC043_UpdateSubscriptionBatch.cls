global class XC_SC043_UpdateSubscriptionBatch  implements Database.Batchable<sObject>, Database.AllowsCallouts {
 		String query;
        Set<Id> contracts;
    
        global XC_SC043_UpdateSubscriptionBatch(Set<Id> contracts) {
            this.contracts = contracts;
            this.query = 'SELECT Id,XC_AdditionalDescription__c, XC_ContractHeader__c,XC_Determina__c, XC_CUP__c, XC_CIG__c, XC_Segment__c, XC_LegalEntity__c, XC_Configurations__c FROM Contract WHERE Id IN :contracts';
        }
    
        global Database.QueryLocator start(Database.BatchableContext BC) {
            return Database.getQueryLocator(query);
        }
    
        global void execute(Database.BatchableContext BC, List<Contract> scope) {
            system.debug('scope '+scope);
            callZuoraFromContract(scope);
        }
    
        global void finish(Database.BatchableContext BC) {
      
        }
     
     
      //@future(callout=true)
    public static void callZuoraFromContract(List<Contract> contrList/*String contracts*/) {
        //List<Contract> contrList = (List<Contract>) JSON.deserialize(contracts, List<Contract>.class);
        if(contrList == null || contrList.isEmpty()){
            return;
        }
        
        List<XC_Integration_Log__c> integrationLogsToInsert = new List<XC_Integration_Log__c>();
        Map<String,Contract> contractMap = new Map<String,Contract>();
        for(Contract con : contrList){
            contractMap.put(con.XC_Configurations__c,con);
        }
        
        List<NE__OrderItem__c> itemsWithStepsAndTasks = [select Id,NE__OrderId__c,(select id,XC_Configuration_Item__r.NE__ORderId__c from Provisioning_Steps__r),(select id, XC_Configuration__c  from ProjectTasks__r),
                                                         		(Select id, XC_Subscription__c, XC_Subscription__r.Zuora__External_Id__c from Assets__r where NE__Root_Order_Item__c = null)
                                                         from NE__OrderItem__c 
                                     	 		  		  where  NE__OrderId__c in (select XC_Configurations__c from contract where id in :XC_UTIL_SObject.getIds(contrList))];
        
		
        
        
        
        for(NE__OrderItem__c oi : itemsWithStepsAndTasks){
            Contract contr = contractMap.get(oi.NE__OrderId__c);
            for(Asset a : oi.Assets__r){                         
                if(contr == null){
                    continue;
                }
                String cig = contr.XC_CIG__c;
                String cup = contr.XC_CUP__c;
                String contrHeader = contr.XC_ContractHeader__c;
                String additionalDescr = contr.XC_AdditionalDescription__c;
                String determina = contr.XC_Determina__c;
                String segment = contr.XC_Segment__c;
                String legalEntity = contr.XC_LegalEntity__c;
                
                Map<String,String> parametersMap = new Map<String,String>();
                if(a.XC_Subscription__r.Zuora__External_Id__c!=null || Test.isRunningTest()){
                    parametersMap.put('subscriptionId',a.XC_Subscription__r.Zuora__External_Id__c);        
                    parametersMap.put('XC_CigCup__c',(cig != null ? cig : '') + (cup != null ? ';' + cup : ''));                   
                    parametersMap.put('XC_Observaciones__c',contrHeader);                    
                    parametersMap.put('XC_AdditionalDescription__c',additionalDescr);
                    parametersMap.put('XC_Determina__c',determina);
                    
                    ZuoraWebService zws = new ZuoraWebService(XC_UTIL_Integration_U.getEntityNameWithStream(legalEntity, segment));
                    XC_Integration_Log__c integrationLog = zws.updateZuoraSubscription(parametersMap);
                    
                    if(integrationLog != null) {
                        integrationLog.XC_Log_ClientSystem__c = 'XCustomer';
                        integrationLog.XC_Log_ServerSystem__c = 'Zuora';
                        integrationLogsToInsert.add(integrationLog);
                    } 
                }
            }
        }        
        /*
        for(NE__OrderItem__c oi : itemsWithStepsAndTasks){
            for(XC_Provisioning_Step__c  step : oi.Provisioning_Steps__r){
				stepIds.add(step.Id);            
        	}
            for(project_cloud__Project_Task__c task : oi.ProjectTasks__r){
            	taskIds.add(task.Id); 
        	}
        }
        List<zqu__quote__c> quotes = [select Id, XC_LastSubscriptionId__c, zqu__ZuoraSubscriptionID__c, CRMConfiguration__c
                                        from zqu__Quote__c
                                        where XC_ProvisioningStep__c in :stepIds or XC_Project_Task__c in :taskIds];
        
    	Set<Id> stepIds = new Set<Id>();
        Set<Id> taskIds = new Set<Id>();
        for(NE__OrderItem__c oi : itemsWithStepsAndTasks){
            for(XC_Provisioning_Step__c  step : oi.Provisioning_Steps__r){
				stepIds.add(step.Id);            
        	}
            for(project_cloud__Project_Task__c task : oi.ProjectTasks__r){
            	taskIds.add(task.Id); 
        	}
        }
        
        List<zqu__quote__c> quotes = [select Id, XC_LastSubscriptionId__c, zqu__ZuoraSubscriptionID__c, CRMConfiguration__c
                                        from zqu__Quote__c
                                        where XC_ProvisioningStep__c in :stepIds or XC_Project_Task__c in :taskIds];
        
        
        for(zqu__quote__c q : quotes){
			Contract contr = contractMap.get(q.CRMConfiguration__c);            
            if(contr == null){
                continue;
            }
            String cig = contr.XC_CIG__c;
            String cup = contr.XC_CUP__c;
            String contrHeader = contr.XC_ContractHeader__c;
            String additionalDescr = contr.XC_AdditionalDescription__c;
            String determina = contr.XC_Determina__c;
            String segment = contr.XC_Segment__c;
            String legalEntity = contr.XC_LegalEntity__c;
            
            Map<String,String> parametersMap = new Map<String,String>();

            parametersMap.put('subscriptionId',q.XC_LastSubscriptionId__c != null ? q.XC_LastSubscriptionId__c : q.zqu__ZuoraSubscriptionID__c);        
            parametersMap.put('XC_CigCup__c',(cig != null ? cig : '') + (cup != null ? ';' + cup : ''));                   
            parametersMap.put('XC_Observaciones__c',contrHeader);                    
            parametersMap.put('XC_AdditionalDescription__c',additionalDescr);
            parametersMap.put('XC_Determina__c',determina);
            
            ZuoraWebService zws = new ZuoraWebService(XC_UTIL_Integration_U.getEntityNameWithStream(legalEntity, segment));
            XC_Integration_Log__c integrationLog = zws.updateZuoraSubscription(parametersMap);
            
            if(integrationLog != null) {
                integrationLog.XC_Log_ClientSystem__c = 'XCustomer';
                integrationLog.XC_Log_ServerSystem__c = 'Zuora';
                integrationLogsToInsert.add(integrationLog);
            }            
        }*/
        
        if(!integrationLogsToInsert.isEmpty()) {
			XC_UTIL_Sobject.insertListRecords(integrationLogsToInsert);
		}
    	
    }

}