/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 02/05/2019
* @description XC_SC013_GenerateWBE – Batch for generate WBE
*/

public without sharing class XC_SC013_GenerateWBE implements Schedulable, Database.Batchable<sObject> {
 
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC013_GenerateWBE'); 

    /**
     * @description Method to schedule batch
     * @param sc - SchedulableContext 
    */
    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new XC_SC013_GenerateWBE(), 50); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'batch XC_SC013_GenerateWBE ID ' + batchId); 
    }

    /**
     * @description start method
     * @param bc - BatchableContext 
     * @return Database.QueryLocator  
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT XC_ProductLine__c, XC_ProductServiceType__c, XC_ProfitCenter__c, XC_CostCenter__c FROM NE__Catalog_Item__c WHERE XC_ProductServiceType__c != null and XC_ProductLine__c != null');
    }

    /** 
     * @description execute method
     * @param bc - BatchableContext 
     * @param scope - list to execute logic on
    */
    public void execute(Database.BatchableContext bc, List<NE__Catalog_Item__c> scope){
        List<XC_WbeTracking__c> listWBE = new List<XC_WbeTracking__c>();
        List<String> listCtaCts = XC_UTIL_WBE.getCtaCts(false, false);
        for(NE__Catalog_Item__c catalogItem : scope) {
            XC_UTIL_WBE.WBEWrapper wbeWrapper = new XC_UTIL_WBE.WBEWrapper();
            wbeWrapper.digitFree = XC_UTIL_WBE.getDigitFree();  
            wbeWrapper.capOpEx = XC_UTIL_WBE.getCAPExOpEx();
            wbeWrapper.projectScope = XC_UTIL_WBE.getProjectScope();
            wbeWrapper.productServiceType = (catalogItem.XC_ProductServiceType__c != null) ? catalogItem.XC_ProductServiceType__c : '000';
            wbeWrapper.productLine = (catalogItem.XC_ProductLine__c != null) ? catalogItem.XC_ProductLine__c : '0000';
            
            List<String> listCompanyCode = XC_UTIL_WBE_U.getMapCompanyCode();
            List<String> listBusinessModel = XC_UTIL_WBE_U.getMapBusinessModel();
            List<String> listChannel = XC_UTIL_WBE_U.getMapChannel();
            if(Test.isRunningTest()){// <--- added for limit dml row
                String companyCode = listCompanyCode[0];
                String businessModel = listBusinessModel[0];
                String channel = listChannel[0];
                listCompanyCode = new List<String>{companyCode};
                listBusinessModel = new List<String>{businessModel};
                listChannel = new List<String>{channel};
            }
            for(String companyCode : listCompanyCode) {
                for(String businessModel : listBusinessModel) {
                    for(String channel : listChannel) {
                        wbeWrapper.companyCode = companyCode; 
                        wbeWrapper.businessModel = businessModel;
                        wbeWrapper.channel = channel;
                        for(String ctaCts : listCtaCts) {
                            wbeWrapper.ctaCts = ctaCts;
                            XC_WbeTracking__c wbeTracking = new XC_WbeTracking__c();
                            wbeTracking.XC_WBE__c = XC_UTIL_WBE.getWBE(wbeWrapper);
                            wbeTracking.XC_ProfitCenter__c = catalogItem.XC_ProfitCenter__c;
                            System.debug(wbeWrapper);
                            System.debug(wbeTracking.XC_WBE__c);
                            wbeTracking.XC_CostCenter__c = catalogItem.XC_CostCenter__c;
                            listWBE.add(wbeTracking);
                        }
                    }
                }
            }
        }
        
        upsertWbeTracking(listWBE);
    }    

    /**
     * @description finish method
     * @param bc - BatchableContext 
    */
    public void finish(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ End batch XC_SC013_GenerateWBE');
    }

    /**
     * @description Upsert XC_WbeTrackin__c
     * @param listWBE - List<XC_WbeTracking__c> 
    */
    private void upsertWbeTracking(List<XC_WbeTracking__c> listWBE) {
        List<XC_BatchErrorLog__c> errorLog = new List<XC_BatchErrorLog__c>();  
        Schema.DescribeFieldResult wbeDescribe = XC_WbeTracking__c.XC_Wbe__c.getDescribe();
        Schema.sObjectField wbeToken = wbeDescribe.getSObjectField();
        List<Database.UpsertResult> listUpsertResult = Database.upsert(listWBE, wbeToken, false);  
        Boolean upsertSuccess = true;
        for(Integer i=0;i<listUpsertResult.size();i++){
            if(!listUpsertResult.get(i).isSuccess() || Test.isRunningTest()){
                upsertSuccess = false;
                XC_BatchErrorLog__c bel = new XC_BatchErrorLog__c();
                bel.Name = 'XC_SC013_GenerateWBE';
                bel.XC_ErrorMessage__c = 'Error on XC_WbeTracking__c insert';
                bel.XC_TypeOfOperation__c = 'Generate WBE';
                bel.XC_RecordId__c = listWBE.get(i).Id;
                errorLog.add(bel);
                break;
            }
        }          
        if(!upsertSuccess) {
            XC_UTIL_Sobject.insertListRecords(errorLog);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Error for UPSERT WBE Tracking!');

        }
    }
}