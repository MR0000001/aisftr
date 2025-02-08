/**
* @description XC_SC005_AutoCloseVoucher - Batch to close voucher
*/

public class XC_SC005_AutoCloseVoucher implements Schedulable, Database.Batchable<sObject> {

	private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC005_AutoCloseVoucher');

	/**
     * @description execute method
     * @param sc - SchedulableContext 
    */
	public void execute(SchedulableContext sc) { 
		Id batchId = Database.executeBatch(new XC_SC005_AutoCloseVoucher());
	}     

	/**
     * @description start method
     * @param bc - BatchableContext 
     * @return Database.QueryLocator  
    */
    public Database.QueryLocator start(Database.BatchableContext bc) { 
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'Start batch SC005');
		String query = 'SELECT Id, XC_VoucherCode__c, XC_Status__c, XC_EndDate__c, XC_Uses__c, XC_Usage_Counter__c ' + 
        			   'FROM XC_Voucher__c ' +
        			   'WHERE XC_Status__c = \'Active\' AND XC_EndDate__c < ' + DateTime.now().format('yyyy-MM-dd');
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'query ' +  Database.getQueryLocator(query));	
        return Database.getQueryLocator(query);
    }

	/** 
     * @description execute method
     * @param bc - BatchableContext 
     * @param scope - list to execute logic on
    */
    public void execute(Database.BatchableContext bc, List<XC_Voucher__c> scope) {
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'Execute batch SC005');
     	List<XC_Voucher__c> listVoucherToProcess = new List<XC_Voucher__c>();
     	for(XC_Voucher__c voucher : scope) { 
			XC_UTIL_Debug.debug(DEBUGACTIVE, 'For voucher ---> ' + voucher);
			XC_UTIL_Debug.debug(DEBUGACTIVE, 'Voucher CODE ---> ' + voucher.XC_VoucherCode__c);
			if(voucher.XC_Uses__c > voucher.XC_Usage_Counter__c) {
				voucher.XC_Status__c = 'Expired';
				listVoucherToProcess.add(voucher);
				XC_UTIL_Debug.debug(DEBUGACTIVE, 'Voucher added to update status.');
			}
     	}

		XC_UTIL_Debug.debug(DEBUGACTIVE, 'List of processed' + listVoucherToProcess);
		XC_UTIL_Sobject.updateListRecords(listVoucherToProcess);
    }

	/**
     * @description finish method
     * @param bc - BatchableContext 
    */
	public void finish(Database.batchablecontext bc) {
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'FINISH batch IS_RefreshNewYear ID'); 
    }
}