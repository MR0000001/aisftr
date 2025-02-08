/**
*@author Riccardo Cossu riccardo.cossu@nttdata.com  & Roberta Porrega roberta.porrega@nttdata.com 
*@date Creation 19/02/2019
*@date Modification dd/mm/yyyy
*@description  Suspende / Resume Zuora 
*/
public without sharing class XC_LCC085_Suspende_Resume {

    /**
    *@description Wrapper with Asset List and zqu__Quote__c Listì
    */
    public without sharing class WrapperAssetAndQuote {
        public List<Asset> assetList;
        public List<zqu__Quote__c> zList;
    }
    
    /**
    *@description Check to change payment method.
    *@param recordId the record id
    *@return the x C UTI L result wrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper getSwitchUtil(String recordId){
        WrapperAssetAndQuote wrapper = returnAssetAndQuote(recordId);
        List<Asset> assetList = wrapper.assetList;
        List<zqu__Quote__c> zList = wrapper.zList;

        String zQuoteId;
        XC_UTIL_ResultWrapper wrW = new XC_UTIL_ResultWrapper ();
        wrW.success = false;
        wrW.resultMessage = 'Generic error';
        if(zList.isEmpty() || zList[0].zqu__ZuoraSubscriptionID__c == null) { 
            wrW.resultMessage = Label.XC_CL_Suspend_ZquoteIDNull;
            return wrW;
        }else{
            zQuoteId = zList[0].zqu__ZuoraSubscriptionID__c; 
            if(assetList[0].Status == Label.XC_CL_Asset_StatusActive && !String.isEmpty(zList[0].zqu__ZuoraSubscriptionID__c)){
                return getSuspend(recordId,zQuoteId);
            }else if(assetList[0].Status == Label.XC_CL_Asset_StatusSuspended && !String.isEmpty(zList[0].zqu__ZuoraSubscriptionID__c)){
                return getResume(recordId,zQuoteId);
            } else{
                return wrW;
            }
        }
    }
    
    /**
    *@description Gets the suspend.
    *@param recordId the record id
    *@param zQuoteId the z quote id
    *@return the suspend
    */
    public static XC_UTIL_ResultWrapper getSuspend(String recordId,String zQuoteId){
        XC_UTIL_ResultWrapper wrW = new XC_UTIL_ResultWrapper();
        WrapperAssetAndQuote wrapper = returnAssetAndQuote(recordId);
        List<Asset> assetList = wrapper.assetList;
        List<zqu__Quote__c> zQuoteList = wrapper.zList;
        Asset asset = assetList[0];
        zqu__Quote__c zQuote = zQuoteList[0];
        XC_REST_SuspendSubscription.WrapperRequest wr = new XC_REST_SuspendSubscription.WrapperRequest();
        if(asset.Status == Label.XC_CL_Asset_StatusSuspended){
            wrW.success = false;wrW.resultMessage = Label.XC_CL_Asset_AlreadySuspended;
            return wrW;
        }
        if(asset.Status == Label.XC_CL_Asset_StatusActive){
            System.debug(LoggingLevel.INFO,'@if active@');
            
            // ====> mapping hard-coded for TEST <==== 
            //wr.contractEffectiveDate = '2019-12-12';  
            //  wr.extendsTerm = false;
            wr.suspendPolicy = 'Today';
            //   wr.suspendSpecificDate = '2019-02-23';
            //========================================
            wr.legalEntity = asset.XC_LegalEntity__c;
            wr.stream = asset.XC_Segment__c;

            String subScriptionID = zQuoteId;			
            System.debug('subScriptionID  '+subScriptionID);
            //Call REST API - suspendSubscription
            XC_REST_SuspendSubscription.WrapperResponse resp = XC_REST_SuspendSubscription.suspendSubscription(subScriptionID, wr);  
            System.debug(LoggingLevel.FINEST,'-Response-'+resp.success);
            //Check Response REST API - suspendSubscription
            if(resp.success == true){
                wrW.resultMessage = Label.XC_CL_Suspended_Succes; 
                wrW.success = true;
                asset.Status = Label.XC_CL_Asset_StatusSuspended;  
                zQuote.zqu__ZuoraSubscriptionID__c = resp.subscriptionId;
                XC_UTIL_Sobject.updateRecord(asset);
                XC_UTIL_Sobject.updateRecord(zQuote);
            }else if(resp.success == false){
                wrW.success = false;
                wrW.resultMessage = resp.reasons[0].message;  
            }
        }
        return wrW;
    }   
    
    /**
    *@param recordId the record id
    *@param zQuoteId the z quote id
    *@return the resume
    *@description Gets the resume.
    */
    public static XC_UTIL_ResultWrapper getResume(String recordId, String zQuoteId){
        XC_UTIL_ResultWrapper wrW = new XC_UTIL_ResultWrapper ();
        WrapperAssetAndQuote wrapper = returnAssetAndQuote(recordId);
        List<Asset> assetList = wrapper.assetList;
        List<zqu__Quote__c> zQuoteList = wrapper.zList;
        Asset asset = assetList[0];
        zqu__Quote__c zQuote = zQuoteList[0];

        XC_REST_ResumeSubscription.WrapperRequest wr = new XC_REST_ResumeSubscription.WrapperRequest();
        if(asset.Status == Label.XC_CL_Asset_StatusSuspended){
            System.debug(LoggingLevel.INFO,'@if suspend@');
            //=======================================
            // wr.contractEffectiveDate = '2019-12-12';
            // wr.extendsTerm = false;
            wr.resumePolicy = 'SpecificDate';
            wr.resumeSpecificDate = string.valueOf(Date.today() + 1);
            // wr.runBilling = false;
            //==========================================
            
            wr.legalEntity = asset.XC_LegalEntity__c;
            wr.stream = asset.XC_Segment__c;
            String subScriptionID = zQuoteId;			
            System.debug('subScriptionID  '+subScriptionID);
            //Call REST API - suspendSubscription
            XC_REST_ResumeSubscription.WrapperResponse resp = XC_REST_ResumeSubscription.resumeSubscription(subScriptionID, wr);
            System.debug(LoggingLevel.FINEST,'-Response-'+resp.success);
            //Check Response REST API - suspendSubscription
            if(resp.success == true){
                wrW.resultMessage = Label.XC_CL_Resume_Success; 
                wrW.success = true;
                asset.Status = Label.XC_CL_Asset_StatusActive;   
                zQuote.zqu__ZuoraSubscriptionID__c = resp.subscriptionId;
                XC_UTIL_Sobject.updateRecord(asset);
                XC_UTIL_Sobject.updateRecord(zQuote);
            } else if(resp.success == false){
                wrW.success = false;
                wrW.resultMessage = resp.reasons[0].message;  
            }
        }
        return wrW;
    }
    /**
    *@description Method to return the Asset and quote
    *@param recordId the recordId
    *@return WrapperAssetAndQuote the wrapper with Asset and quote
    */
    public static WrapperAssetAndQuote returnAssetAndQuote(String recordId){
        WrapperAssetAndQuote wrapper = new WrapperAssetAndQuote();
        List<Asset> assetList = new List<Asset>();
        List<zqu__Quote__c> zList = new List<zqu__Quote__c>();
        if(Schema.sObjectType.Asset.fields.Id.isAccessible() && Schema.sObjectType.Asset.fields.Status.isAccessible() && Schema.sObjectType.Asset.fields.XC_ZQuoteId__c.isAccessible() && Schema.sObjectType.Asset.fields.XC_Configuration_Item__c.isAccessible() && Schema.sObjectType.zqu__Quote__c.fields.zqu__ZuoraSubscriptionID__c.isAccessible() && Schema.SObjectType.Asset.isAccessible() && Schema.SObjectType.zqu__Quote__c.isAccessible() ){
            
            Map<Id,Asset> assetListMap = new Map<Id,Asset>([SELECT id,Status,XC_ZQuoteId__c,XC_Configuration_Item__c, XC_LegalEntity__c, XC_Segment__c
                                    FROM Asset WHERE Id =: recordId LIMIT 1]);
            assetList = assetListMap.values();
           
            Map<Id,zqu__Quote__c> zListMap = new Map<Id,zqu__Quote__c>([SELECT zqu__ZuoraSubscriptionID__c FROM zqu__Quote__c WHERE ID =: assetList[0].XC_ZQuoteId__c LIMIT 1]);
            zList = zListMap.values();
        }

        wrapper.assetList = assetList;
        wrapper.zList = zList;

        return wrapper;
    }

}