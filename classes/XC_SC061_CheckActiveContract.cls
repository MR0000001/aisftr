/**
 * @author Marina Ciavarra - mciavarra@deloitte.it
 * @date Creation 11/10/2021
 * @description XC_SC061_CheckActiveContract - Check all contract related to partner accounts checking its status
 */

public without sharing class XC_SC061_CheckActiveContract implements Schedulable, Database.Batchable<sObject> {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC056_ActivateBillingProfile');
    /**
        * @author Marina Ciavarra - mciavarra@deloitte.it
        * @description start
        * @param bc - BatchableContext 
        * @return Database.getQueryLocator
       */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        if(!Schema.sObjectType.Contract.isAccessible()){
            return null;
        }
        String query =  'SELECT id, AccountId, StartDate, EndDate ' +
                        ' FROM Contract ' +
                        ' WHERE Account.IsPartner = true and Account.XC_Segment__c = \'B2C\'';
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'query' + query);              
        return Database.getQueryLocator(query);
    }

    /**
    * @description execute method
    * @param sc - SchedulableContext
    */
    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new XC_SC061_CheckActiveContract());
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'batch XC_SC061_CheckActiveContract in execution'); 
    }

    /** 
    * @description execute method
    * @param bc - BatchableContext 
    * @param scope - list to execute logic on
   */
    public void execute(Database.BatchableContext bc, List<Contract> scope) {
        List<XC_BatchErrorLog__c> errorLog = new List<XC_BatchErrorLog__c>();
        Map<Id, Account> toUpdateAccount = new  Map<Id, Account>();
        Map<Id, List<Contract>> mapAccountContract =  new Map<Id, List<Contract>>();
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'scope ' + scope); 

        for(Contract contract: scope){
            if (mapAccountContract.containsKey(contract.AccountId)){
                mapAccountContract.get(contract.AccountId).add(contract);
            }else
                mapAccountContract.put(contract.AccountId, new  List <Contract> { contract });
        }

        for(Id accountId : mapAccountContract.keySet()){
            //check if exists at least one active contract (StartDate < today < EndDate)
            for(Contract cnt : mapAccountContract.get(accountId)){
                if(cnt.EndDate > Date.today()){
                    if(cnt.StartDate < Date.today()){
                        Account acc = new Account (Id = accountId);
                        acc.XC_ContractStatus__c = Label.XC_CL_Account_StatusActive;
                        toUpdateAccount.put(accountId,acc);
                        break;
                    }
                }
            }
                
            //if there are no active contract, checks if all the contract are Expired (EndDate < today)
            Integer i = 0;
			for(Contract cnt : mapAccountContract.get(accountId)){
                if(cnt.EndDate < Date.today()){
					i++;
                }
            }
			if(mapAccountContract.get(accountId).size()  == i){
				Account acc = new Account (Id = accountId);
                acc.XC_ContractStatus__c = Label.XC_CL_Opportunity_Expired;
                toUpdateAccount.put(accountId,acc);
			}
        } 


        List<XC_UTIL_Sobject.WrapperResult> listWrapperResult = XC_UTIL_Sobject.updateListRecords(toUpdateAccount.values());
        for(XC_UTIL_Sobject.WrapperResult wr : listWrapperResult){
            if(!wr.success){
                XC_BatchErrorLog__c bel = new XC_BatchErrorLog__c();
                bel.Name = 'XC_SC061_CheckActiveContract';
                bel.XC_ErrorMessage__c = wr.errorMessage;
                bel.XC_TypeOfOperation__c = 'Check Active Contract';
                bel.XC_RecordId__c = wr.errorObjectId;
                errorLog.add(bel);
            }
        }
        XC_UTIL_Sobject.insertListRecords(errorLog);
    }

    /** 
    * @description execute method
    * @param bc - BatchableContext 
    */
    public void finish(Database.BatchableContext bc) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'FINISH batch XC_SC061_CheckActiveContract');
    }

}