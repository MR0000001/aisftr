/**
 * @File Name          : XC_UTIL_PaymentMethodFilter.cls
 * @Description        : 
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 3/7/2020, 16:58:02
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    29/5/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
**/
public without sharing class XC_UTIL_PaymentMethodFilter {

    public class MopWrapper{
        @AuraEnabled
        public String mopLabel {get;set;}
        @AuraEnabled
        public String mopValue {get;set;}
    }

    public class MopMatchWrapper{
        @AuraEnabled
        public String billingModel {get;set;}
        @AuraEnabled
        public String productSubtype {get;set;}
        @AuraEnabled
        public String confItemId {get;set;}
        @AuraEnabled
        public List<XC_CM_Excluded_MOP_LE__mdt> mopConfigurations {get;set;}
        @AuraEnabled
        public List<MopWrapper> allMops {get;set;}
    }



    /**
    * @description returns a list of available payment methods for a particular LegalEntity
    * @author Francesco Imperioli - fimperioli@deloitte.it | 29/5/2020 
    * @param legalEntity 
    * @param stream 
    * @return List<MopWrapper> 
    **/
    public static List<MopWrapper> getAvailableMopsForLe (String legalEntity,String stream){
        List<MopWrapper> globalMops = getMopPickValues();
        List<MopWrapper> result = new List<MopWrapper>();
        List<XC_CM_Excluded_MOP_LE__mdt> mopConfs = getMOPFilterConfigurations(legalEntity,stream,'GLOBAL');

        if(!mopConfs.isEmpty()){
            List<String> excludedMopsValues = mopConfs[0].XC_Excluded_Payment_Methods__c.split(';');
            Set<String> excludedMopsSet = new Set<String>();
            excludedMopsSet.addAll(excludedMopsValues);
    
            for(MopWrapper mw : globalMops){
                if(!excludedMopsSet.contains(mw.mopValue)){
                    result.add(mw);
                }
            }
        }
        return !result.isEmpty() ? result : globalMops;
    }


    /**
    * @description returns the list of available payment methods for a list of orderItems
    * @author Francesco Imperioli - fimperioli@deloitte.it | 29/5/2020 
    * @param List<NE__OrderItem__c> 
    * @return Map<String, List<MopWrapper>> 
    **/
    public static Map<String,List<MopWrapper>> getAvailabeMopsForOrderItems(String legalEntity,String stream,List<NE__OrderItem__c> orderItems){
        if(orderItems[0].NE__Billing_Account__c != null && orderItems[0].NE__Account__c != null &&  orderItems[0].NE__Billing_Account__c != orderItems[0].NE__Account__c){
            stream = 'B2B';
        }
        Map<String,List<MopWrapper>> result = new Map<String,List<MopWrapper>>();
        List<XC_CM_Excluded_MOP_LE__mdt> mopConfs = getMOPFilterConfigurations(legalEntity,stream,'PRODUCT');
        List<XC_CM_Excluded_MOP_LE__mdt> mopGlobalConfs = getMOPFilterConfigurations(legalEntity,stream,'GLOBAL');
        
        XC_UTIL_DependentPicklist.PicklistWrapper pw = XC_UTIL_DependentPicklist.getDependentPicklist('NE__OrderItem__c', 'XC_BillingModel__c', 'XC_PaymentMethod__c');
        Map<String,String> pickListLabelValueMap = new Map<String,String>();
        Schema.DescribeFieldResult fr = NE__Billing_Profile__c.NE__Payment__c.getDescribe();

        List<Schema.PicklistEntry> entryList = fr.getPicklistValues();
        for(Schema.PickListEntry ple : entryList){
            pickListLabelValueMap.put(ple.getValue(),ple.getLabel());
        }

        if(!mopConfs.isEmpty()){

            //TOP DOWN APPROACH --> FIRST WILD CARDS, THEN CLEAN WITH SPECIFIC CASE


            //check a wild card match
            for(NE__OrderItem__c oi : orderItems){
                if(!result.containsKey(oi.Id)){
                        MopMatchWrapper mw = new MopMatchWrapper();
                        mw.confItemId = oi.Id;
                        mw.billingModel = oi.XC_BillingModel__c;
                        mw.mopConfigurations = mopConfs;
                        mw.productSubtype = oi.XC_Product_Subtype__c;
                        mw.allMops = getAvailableMopsForLEAndBillingModel(oi.XC_BillingModel__c,legalEntity,stream,pw,mopGlobalConfs,pickListLabelValueMap);
                        checkWildCardMatch(mw, result);
                }
            }

            //check if there's an exact match for the configuration
            for(NE__OrderItem__c oi : orderItems){
                MopMatchWrapper mw = new MopMatchWrapper();
                mw.confItemId = oi.Id;
                mw.billingModel = oi.XC_BillingModel__c;
                mw.mopConfigurations = mopConfs;
                mw.productSubtype = oi.XC_Product_Subtype__c;
                mw.allMops = getAvailableMopsForLEAndBillingModel(oi.XC_BillingModel__c,legalEntity,stream,pw,mopGlobalConfs,pickListLabelValueMap);
                checkExactMatch(mw,result);
            }
    

        }

        //global assign mops if no configuration found that matches
        for(NE__OrderItem__c oi : orderItems){
            if(!result.containsKey(oi.Id)){
                System.Debug('FINAL CHECK ENTERED ON FILTER MOPS');
                result.put(oi.Id,getAvailableMopsForLEAndBillingModel(oi.XC_BillingModel__c,legalEntity,stream,pw,mopGlobalConfs,pickListLabelValueMap));
            }
        }

        return result;
    } 


    /**
    * @description get the current MOP Picklist on the org
    * @author Francesco Imperioli - fimperioli@deloitte.it | 29/5/2020 
    * @return List<MopWrapper> 
    **/
    private static List<MopWrapper> getMopPickValues(){
        List<MopWrapper> result = new List<MopWrapper>();
        Schema.DescribeFieldResult fr = NE__Billing_Profile__c.NE__Payment__c.getDescribe();
        List<Schema.PicklistEntry> entryList = fr.getPicklistValues();
        for(Schema.PickListEntry ple : entryList){
            MopWrapper mw = new MopWrapper();
            mw.mopValue = ple.getValue();
            mw.mopLabel = ple.getLabel();
            result.add(mw);
        }
        return result;
    }

    /**
    * @description returns the configurations
    * @author Francesco Imperioli - fimperioli@deloitte.it | 29/5/2020 
    * @param legalEntity 
    * @param stream 
    * @param option 
    * @return List<XC_CM_Excluded_MOP_LE__mdt> 
    **/
    private static List<XC_CM_Excluded_MOP_LE__mdt> getMOPFilterConfigurations(String legalEntity,String stream,String option){
        if(option.equalsIgnoreCase('GLOBAL')){
            return [SELECT Id,XC_Excluded_Payment_Methods__c,XC_Stream__c,XC_BillingModel__c,XC_ProductSubtype__c FROM XC_CM_Excluded_MOP_LE__mdt WHERE XC_LegalEntity__c = :legalEntity AND XC_Stream__c = :stream AND XC_BillingModel__c = null LIMIT 1 ]; /*Add wildcards check on new fields*/
        }else if(option.equalsIgnoreCase('PRODUCT')){
            return [SELECT Id,XC_Excluded_Payment_Methods__c,XC_Stream__c,XC_BillingModel__c,XC_ProductSubtype__c FROM XC_CM_Excluded_MOP_LE__mdt WHERE XC_LegalEntity__c = :legalEntity AND XC_Stream__c = :stream AND XC_BillingModel__c!=null]; /*Add wildcards check on new fields*/
        }
        return null;
    }

    /**
    * @description check exact match on configurations
    * @author Francesco Imperioli - fimperioli@deloitte.it | 29/5/2020 
    * @param mw 
    * @param resultMap 
    * @return void 
    **/
    private static void checkExactMatch(MopMatchWrapper mw,Map<String,List<MopWrapper>> resultMap){

        System.Debug('ENTERED MOP EXACT MATCH ' + mw + ' CURRENT RESULT ' + resultMap);
        
        List<XC_CM_Excluded_MOP_LE__mdt> confsList = mw.mopConfigurations;
        for(XC_CM_Excluded_MOP_LE__mdt conf : confsList){
            if(conf.XC_BillingModel__c == mw.billingModel && conf.XC_ProductSubtype__c == mw.productSubtype){
                manageProductFiltering(mw,resultMap,conf);
                break;
            }
        }
        
    }


    /**
    * @description check wild card match on configurations
    * @author Francesco Imperioli - fimperioli@deloitte.it | 29/5/2020 
    * @param mw 
    * @param resultMap 
    * @return void 
    **/
    private static void checkWildCardMatch(MopMatchWrapper mw,Map<String,List<MopWrapper>> resultMap){

        System.Debug('ENTERED MOP WILD CARD MATCH ' + mw + ' CURRENT RESULT ' + resultMap);
        
        List<XC_CM_Excluded_MOP_LE__mdt> confsList = mw.mopConfigurations;
        for(XC_CM_Excluded_MOP_LE__mdt conf : confsList){
            if(
                (conf.XC_BillingModel__c == mw.billingModel || conf.XC_BillingModel__c == '*') && 
                (conf.XC_ProductSubtype__c == mw.productSubtype || conf.XC_ProductSubtype__c == '*')
            ){
                manageProductFiltering(mw,resultMap,conf);
            }
        }
    }


    /**
    * @description manage filtering of mops based on configuration items properties
    * @author Francesco Imperioli - fimperioli@deloitte.it | 29/5/2020 
    * @param mw 
    * @param resultMap 
    * @param mopConfRow 
    * @return void 
    **/
    private static void manageProductFiltering (MopMatchWrapper mw,Map<String,List<MopWrapper>> resultMap,XC_CM_Excluded_MOP_LE__mdt mopConfRow){

        //get exclued mops for this particular configuration
        List<String> excludedMopsValues = mopConfRow.XC_Excluded_Payment_Methods__c.split(';');
        Set<String> excludedMopsSet = new Set<String>();
        excludedMopsSet.addAll(excludedMopsValues);
        System.Debug('EXCLUDED MOP SET ' + excludedMopsSet);
        //filter mops from global list
        List<MopWrapper> filteredMops = new List<MopWrapper>();
        for(MopWrapper mopElem : mw.allMops){
            if(!excludedMopsSet.contains(mopElem.mopValue)){
                filteredMops.add(mopElem);
            }
        }
        System.Debug('FILTER RESULT' + mw + ' AVAILABLE MOPS ' + filteredMops);
        if(!filteredMops.isEmpty()){
            if(!resultMap.containsKey(mw.confItemId)){
                resultMap.put(mw.confItemId,filteredMops);
            }else{

                //check if a wild card have been already processed
                //if there's a mop in the wild card filter that isn't in the specific filter, the mop has to be removed
                List<MopWrapper> alreadyProcessedFilteredMops = resultMap.get(mw.confItemId);
                List<MopWrapper> newFilterMops = new List<MopWrapper>();
                for(MopWrapper alreadyFilteredMW : alreadyProcessedFilteredMops){
                    if(!excludedMopsSet.contains(alreadyFilteredMW.mopValue)){
                        newFilterMops.add(alreadyFilteredMW);
                    }
                }
                resultMap.put(mw.confItemId,newFilterMops);
            }
        }
    }


    /**
    * @description get filtered mops with billing model stream and le
    * @author Francesco Imperioli - fimperioli@deloitte.it | 15/6/2020 
    * @param billingModel 
    * @param legalEntity 
    * @param stream 
    * @return List<MopWrapper> 
    **/
    private static List<MopWrapper> getAvailableMopsForLEAndBillingModel(String billingModel,String legalEntity,String stream,XC_UTIL_DependentPicklist.PicklistWrapper pw,List<XC_CM_Excluded_MOP_LE__mdt> mopConfs,Map<String,String> pickListLabelValueMap){

        List<MopWrapper> result = new List<MopWrapper>();

        List<String> availablePickValues = pw.pickListMap.containsKey(billingModel) ? pw.pickListMap.get(billingModel) : new List<String>();

        List<MopWrapper> tempMw = new List<MopWrapper>();
        for(String pickValString : availablePickValues){
            MopWrapper mw = new MopWrapper();
            mw.mopLabel = pickListLabelValueMap.get(pickValString);
            mw.mopValue = pickValString;
            tempMw.add(mw);
        }

        if(!mopConfs.isEmpty()){
            List<String> excludedMopsValues = mopConfs[0].XC_Excluded_Payment_Methods__c.split(';');
            Set<String> excludedMopsSet = new Set<String>();
            excludedMopsSet.addAll(excludedMopsValues);
    
            for(MopWrapper mw : tempMw){
                if(!excludedMopsSet.contains(mw.mopValue)){
                    result.add(mw);
                }
            }
        }
        return !result.isEmpty() ? result : tempMw;

    }

}