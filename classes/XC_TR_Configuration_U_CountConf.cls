/**
* @author Giulio Serra
* @date Creation 26/09/2018
* @date Modification 02/12/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_TR_Configuration_U_CountConf – Utility class for Configuration to manage Configuration Items
*/

public without sharing class XC_TR_Configuration_U_CountConf {
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Configuration_U_CountConf'); 
    public static Boolean wasCalled = false;
    public static final String FROM_UPDATE = 'FROM_UPDATE';
    public static final String FROM_DELETE = 'FROM_DELETE';
    public static final String FROM_INSERT = 'FROM_INSERT';
    
    /** @description CheckWrapper */
    public class CheckWrapper {
        public Opportunity opp = new Opportunity();
        public String confRecordType;
        public String eventCall;
        public Map<Id,NE__Order__c> oldConfigurations = new Map<Id,NE__Order__c>();
        public NE__Order__c configuration = new NE__Order__c();
    }
    
    /** @description UtilWrapper */
    public class UtilWrapper { 
        public Opportunity opp = new Opportunity();
        public NE__Order__c configuration = new NE__Order__c();
        public String eventCall;
        public Map<Id,NE__Order__c> oldConfigurations = new Map<Id,NE__Order__c>();
        public Set<NE__Order__c> configurationsToUpdate = new Set<NE__Order__c>();
    }
    
    /** @description ManageChildrenWrapper */
    private class ManageChildrenWrapper {
        Set<Id> oppIdSet;
        String eventCall;
        Map<Id, NE__Order__c> mapOld;
        Map<Id, NE__Order__c> mapNew;
        List<NE__Order__c> listNew;
        Map<Id, Opportunity> mapIdOpportunity;
    }
    
    /**
    * @author Giulio Serra - giserra@deloitte.it
    * @description manage the configuration on insert
    * @param listNew - List<NE__Order__c>
    */
    public static void onCountConfigurationInsert(List<NE__Order__c> listNew) { 
        List<NE__Order__c> listConfigurationNew = XC_UTIL_Configuration.getConfigurationNew(listNew); 
        Set<Id> oppidSet = new Set<Id>((List<Id>)XC_UTIL_Sobject.getListFieldValues(listConfigurationNew,'NE__OptyId__c'));
        if(!oppidSet.isEmpty()) {
            ManageChildrenWrapper mcWrapper = new ManageChildrenWrapper();
            mcWrapper.oppIdSet = oppIdSet;
            mcWrapper.mapOld = null;
            mcWrapper.mapNew = null;
            mcWrapper.listNew = listNew;
            mcWrapper.eventCall = FROM_INSERT;
            manageChildren(mcWrapper);
        }
    }
    
    /**
    * @author Giulio Serra giserra@deloitte.it
    * @param listNew - List<NE__Order__c> 
    * @param mapOld - Map<Id,NE__Order__c>
    * @param mapNew - Map<Id,NE__Order__c>
    * @description Manage the configuration on update
    */
    public static void onCountConfigurationUpdate(List<NE__Order__c> listNew, Map<Id,NE__Order__c> mapOld, Map<Id,NE__Order__c> mapNew){
        if(wasCalled) {
            return;
        }

        List<NE__Order__c> listConfigurationNew = XC_UTIL_Configuration.getConfigurationNew(listNew);
        List<String> fieldList = new List<String>{'NE__OptyId__c', 'XC_Status__c', 'NE__OrderStatus__c', 'XC_LossReason__c'};
        List<NE__Order__c> clearedOppConfiguration = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(clearedOppConfiguration.isEmpty()){
            return;
        }

        Set<Id> oppIdSet = new Set<Id>((List<Id>) XC_UTIL_Sobject.getListFieldValues(clearedOppConfiguration,'NE__OptyId__c'));
        if(!mapOld.isEmpty()){ // updated old father values
            List<NE__Order__c> listOfOldOrders = mapOld.values();
            Set<Id> oldOppIdSet = new Set<Id>((List<Id>) XC_UTIL_Sobject.getListFieldValues(listOfOldOrders, 'NE__OptyId__c'));
            /*for(Id opportunityId : oldOppIdSet){
                if(!oppIdSet.contains(opportunityId)){
                    oppIdSet.add(opportunityId);
                }
            }*/
            oppIdSet.addAll(oldOppIdSet);
        }

        if(!oppIdSet.isEmpty()) {
            ManageChildrenWrapper mcWrapper = new ManageChildrenWrapper();
            mcWrapper.oppIdSet = oppIdSet;
            mcWrapper.mapOld = mapOld;
            mcWrapper.mapNew = mapNew;
            mcWrapper.eventCall = FROM_UPDATE;
            manageChildren(mcWrapper);
        }
    }
    
    /**
    * @author Giulio Serra giserra@deloitte.it
    * @param mcWrapper - ManageChildrenWrapper
    * @description  Manage the child object on all the modified opportunities
    */
    public static void manageChildren(ManageChildrenWrapper mcWrapper){
        // maps of opportunities fathers of the configurations to update
        Map<Id, Opportunity> mapMyOpportunity = XC_TR_Configuration_U_CountConf_D.retrieveOpportunitiesWithChildrenConfigurations(mcWrapper.oppIdSet);
        mcWrapper.mapIdOpportunity = mapMyOpportunity;
        manageOpportunities(mcWrapper);
    }
    
    /**
    * @author Giulio Serra giserra@deloitte.it
    * @description exectute some operations on the opportunities related to all the updated configurations
    * @param mcWrapper - ManageChildrenWrapper
    */
    public static void manageOpportunities(ManageChildrenWrapper mcWrapper){
        List<Opportunity> oppToUpdate = new List<Opportunity>(); // contains a list of opportunities to update
        Set<NE__Order__c> configurationsToUpdate = new Set<NE__Order__c>(); 
        Map<Id, Opportunity> opportunities = mcWrapper.mapIdOpportunity;
        List<NE__Order__c> listToUpdate = new List<NE__Order__c>();
        //update WorkOrder and Service Appointment
        List<NE__Order__c> listOrder = new List<NE__Order__c>();
        //D.D.D-L.D - Retrieve id from opportunity and check if RecType Of order == RTQuote. 
        for(Opportunity opp : opportunities.values()){
            for(NE__Order__c configuration : opp.NE__Orders__r){
                if(configuration.XC_Status__c == Label.XC_CL_Configuration_Cancelled){
                    listOrder.add(configuration);
                }
                UtilWrapper wrapper = new UtilWrapper(); 
                wrapper.opp = opp;
                wrapper.configuration = configuration;
                wrapper.eventCall = mcWrapper.eventCall;
                wrapper.oldConfigurations = mcWrapper.mapOld;
                wrapper.configurationsToUpdate = configurationsToUpdate;
                XC_TR_Configuration_U_CountConfUtil.utilMethod(wrapper);  
            }
            
            Boolean orderClosedCondition = manageOrderConfiguration(opp);
            Boolean updateOpportunity = checkIfAllQuotesAreClosed(opp, mcWrapper.mapNew);
            Boolean updateNumberOfConfigurations = populateNumberOfConfigurationField(opp); // number of configuration update
            if(updateOpportunity || updateNumberOfConfigurations || orderClosedCondition) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@Charge Opportunity');
                oppToUpdate.add(opp);
            } 
        } 
        XC_TR_Configuration_U_CountConfUtil.updateStatusWoWithSa(listOrder);
        //UPDATE CONFTGURATION-OPPORTUNITY-WORK ORDER 
        listToUpdate.addAll(configurationsToUpdate);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'conf to update' + listToUpdate);
        XC_UTIL_Sobject.updateListRecords(listToUpdate); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'opp to update ' + oppToUpdate);
        XC_UTIL_Sobject.updateListRecords(oppToUpdate); 
    }
    
    /**
    * @description  Check if all quotes are closed
    * @author Giulio Serra giserra@deloitte.it
    * @param opp - Opportunity
    * @param mapNew - Map<Id, NE__Order__c>
    * @return Boolean
    */
    public static Boolean checkIfAllQuotesAreClosed(Opportunity opp, Map<Id, NE__Order__c> mapNew){
        Map<Id, String> mapOrderToStatus = new Map<ID, String>();
        for(NE__Order__c configuration : opp.NE__Orders__r){
            if(configuration.RecordType.DeveloperName == Label.XC_CL_Configuration_RtQuote) {
                mapOrderToStatus.put(configuration.ID, configuration.XC_Status__c);
            }
            /*if(configuration.RecordType.DeveloperName == Label.XC_CL_Configuration_RtQuote && configuration.XC_Status__c == Label.XC_CL_Configuration_QuoteRejected) {
                mapOrderToStatus.put(configuration.ID, configuration.XC_Status__c);
            }*/
        }
        if(mapOrderToStatus.values().isEmpty()) {
            return false;
        }
        for(String value : mapOrderToStatus.values()) {
            if(value != Label.XC_CL_Configuration_QuoteRejected){
                return false;
            }
        }

        /* @Federico Amici - At this point it is sure all quotes are rejected */
        NE__Order__c lastQuoteRejected = XC_TR_Configuration_U_CountConfUtil.getLastQuoteRejected(mapNew);
        opp.StageName = Label.XC_CL_Opportunity_ClosedLost;
        opp.XC_LossReason__c = lastQuoteRejected.XC_LossReason__c;//D.D.D 29.10 Opportunity/Quote Expireation rules -Modify custom label From XC_CL_Configuration_Other
        return true;
    }
    
    /**
    * @author Giulio Serra giserra@deloitte.it
    * @param opp - Opportunity
    * @return Boolean
    * @description Populates the field of an opportunity with the number of related Configurations
    */
    public static Boolean populateNumberOfConfigurationField(Opportunity opp){
        List<NE__Order__c> confList = opp.NE__Orders__r;
        Integer numberOfConfigurations = 0;
        if(!confList.isEmpty()){
            numberOfConfigurations = confList.size();
        }
        if(opp.XC_NumberOfConfiguration__c != numberOfConfigurations) {
            opp.XC_NumberOfConfiguration__c = numberOfConfigurations;
            return true;
        } else {
            return false;
        }  
    }
    
    /**
    * @description Sets the opportunity with children in progress
    * @author Giulio Serra giserra@deloitte.it
    * @param opp - Opportunity
    */
    private static void setOpportunityWithChildrenInProgress(Opportunity opp){
        if(opp.StageName == Label.XC_CL_Opportunity_Draft && opp.XC_NumberOfConfiguration__c > 0){
            opp.StageName = Label.XC_CL_Configuration_OrderInProgress;
        }
    }
    
    /**
    * @description Manage order configuration
    * @author Giulio Serra giserra@deloitte.it
    * @param opp - Opportunity
    * @return Boolean
    */
    private static Boolean manageOrderConfiguration(Opportunity opp){
        Boolean check = false;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@entered manageOrder');
        for(NE__Order__c configuration : opp.NE__Orders__r){
            String confRecordType = configuration.RecordType.DeveloperName;
            if(confRecordType == Label.XC_CL_Configuration_Order && configuration.NE__Type__c == 'inOrder') {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ORDERSTATUS' + configuration.XC_Status__c);
                if(configuration.XC_Status__c == Label.XC_CL_Configuration_Closed) {
                    opp.StageName = Label.XC_CL_Opportunity_ClosedWon;
                    opp.XC_EnableChangeStage__c = true;
                    check = true;
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'GS TRIGGER CLOSEDWON');
                    break;
                }  
                if(configuration.XC_Status__c == Label.XC_CL_Configuration_Cancelled) {
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'GS TRIGGER CLOSEDLOST');
                    opp.StageName = Label.XC_CL_Opportunity_ClosedLost;
                    //opp.XC_LossReason__c = Label.XC_CL_Opportunity_BudgetNotAccepted; // to be defined
                    opp.XC_LossReason__c = Label.XC_CL_Opportunity_OrderCanceled; // to be defined
                    opp.XC_EnableChangeStage__c = true;
                    check = true;
                    break;
                }
            }
        }
        return check;
    }
    
    /**
    * @author Giulio Serra giserra@deloitte.it
    * @param opp - Opportunity
    * @param completedConf - NE__Order__c
    * @return List<NE__Order__c>
    * @description set all the configurations of an opportunity to 'Rejected', except for the one passed in the parameters
    */
    public static List<NE__Order__c> setQuoteConfToRejected(Opportunity opp, NE__Order__c completedConf){
        //Il vecchio configuration deve venire da uno stato != da accepted
        List<NE__Order__c> confToUpdate = new List<NE__Order__c>();
        for(NE__Order__c configuration : opp.NE__Orders__r){
            String confRecordType = configuration.RecordType.DeveloperName;
            if((configuration.Id != completedConf.Id) && (confRecordType == Label.XC_CL_Configuration_RtQuote)){
                NE__Order__c conf = new NE__Order__c();
                conf.Id = configuration.Id;
                conf.XC_Status__c = Label.XC_CL_Configuration_QuoteRejected;
                conf.XC_LossReason__c = Label.XC_CL_Configuration_RejectedReason;
                confToUpdate.add(conf);
            }
        }
        return confToUpdate;
    } 
    
}