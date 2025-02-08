public without sharing class XC_SC067_LoaContractStatusUpdate implements Schedulable, Database.Batchable<sObject> {
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC067_LoaContractStatusUpdate');
    Date todaydate = system.today();
    String developerName = 'XC_LOA';
    String authorized= 'Authorized';
    /**
* @description execute method
* @param sc - SchedulableContext 
*/
    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new XC_SC067_LoaContractStatusUpdate());
    }
    
    /**
* @description start method
* @param bc - BatchableContext 
* @return Database.QueryLocator  
*/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start batch XC_SC067_LoaContractStatusUpdate');
        String responseConsent = 'Yes';
        /*String query = 'SELECT Id FROM Contract' +
            'WHERE RecordType.DeveloperName = XC_LOA AND XC_LOA_Signed__c = true AND XC_LOA_End_Date__c < system.today()' +
            'AND XC_LOA_Status__c = Authorized';*/
        String query = 'Select Id FROM Contract WHERE RecordType.DeveloperName =: developerName AND XC_LOA_Signed__c = true AND XC_LOA_End_Date__c <: todaydate AND Status =: authorized ';
        System.debug('data'+ Database.query(query));
        return Database.getQueryLocator(query);
    }
    
    /** 
* @description execute method
* @param bc - BatchableContext 
* @param scope - List<Contract>
*/
    public void execute(Database.BatchableContext bc, List<Contract> scope){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Execute batch XC_SC067_LoaContractStatusUpdate');
        List<Contract> listLecToUpdate = new List<Contract>();
        for(Contract lec : scope) {
            Contract lecToUpdate = new Contract();
            lecToUpdate.Id = lec.Id;
            lecToUpdate.Status = 'Expired';       
            listLecToUpdate.add(lecToUpdate);
        }
        XC_UTIL_Sobject.updateListRecords(listLecToUpdate, false);
    }    
    
    /**
* @description finish method
* @param bc - BatchableContext 
*/
    public void finish(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ End batch XC_SC067_LoaContractStatusUpdate');
    } 
    
}