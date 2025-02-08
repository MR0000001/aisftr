/**
* @className        XC_AT_Utils
* @description      Class with general methods to ENEL X application
* @author           VBV
* @email            vbarquero@deloitte.es
* @version          V0.1
* @testClass        pte
* @dateCreated      2018/12/13
* @Modify           Federico Amici, [17/10/2018], Substituted some picklist values with custom labels
*/
public without sharing class XC_AT_Utils {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_AT_Utils');

    /** @description RemarkMessageWrapper */
    public class RemarkMessageWrapper {
        public String lastMessage = '';
        public Schema.DescribeFieldResult fieldDescribe;
        public String newValue = '';
        public String oldValue = '';
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description class to call ActionPlan Creation as Queueable
     **/
    public class ActionPlanCreation implements Queueable{

        public List<String> actionPlanData;

        public ActionPlanCreation(List<String> actionPlanData){
            this.actionPlanData = actionPlanData;
        }

        public void execute(QueueableContext context) {
            if(this.actionPlanData == null){
                return;
            }
            for(String apWrS : this.actionPlanData){
                ActionPlanCreationWrapper apWr = (ActionPlanCreationWrapper)JSON.deserialize(apWrS, ActionPlanCreationWrapper.class);
                ATCL_VFC032_ActionPlanAutoCreation actionPlanAutoCreation = new ATCL_VFC032_ActionPlanAutoCreation(apWr.templateId, apWr.refId, apWr.refType);
                actionPlanAutoCreation.initNewActionPlanFromTemplate();
                actionPlanAutoCreation.save();
            }
        }
    }

    /**
    * @description  getRelatedParentCasesByCaseIds
    * @return List<Case>
    * @author VBV
    * @param caseParentIds
    * @email vbarquero@deloitte.es
    **/
    public static List<Case> getRelatedParentCasesByCaseIds(Set<Id> caseParentIds){ 
        //Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_ESP_Case).getRecordTypeId();        
        List<Case> c = new List<Case>();
        if(!Schema.SObjectType.Case.isAccessible()) { 
            return c;
        }
        Map<Id,Case> caseLisOpenMap = new Map<Id,Case>([SELECT  Id, ParentId, Status , AssetId, OwnerId FROM Case WHERE Id IN: caseParentIds ]); //AND RecordTypeId =: recordTypeId
        List<Case> caseLisOpen = caseLisOpenMap.values();
        System.debug('isRelatedObjectOpen , caseLisOpen ' + caseLisOpen);
        return caseLisOpen;
    }
    
    /** 
    * @author           VBV
    * @param fieldName the field name
    * @param newValue the new value
    * @param oldValue the old value
    * @return         String
    * @name           addChangedValue
    * @description    method that adds values of changed fields
    * @params 
    * @email          vbarquero@deloitte.es
    */
    public static String addChangedValue(String fieldName, String newValue, String oldValue){
        String caseremarks;
        caseremarks = Label.XC_CL_ContactModification;
        if(fieldName!=null){
            caseremarks = caseremarks.replace('<param1>', fieldName);
        }
        if(oldValue!=null) {
            caseremarks = caseremarks.replace('<param2>', oldValue);
        }else{
            caseremarks = caseremarks.replace('<param2>', '');
        } 
        caseremarks = addChangedValueHelper(caseremarks,newValue);
        return caseremarks;
    }

    /** @description Add change value
    * @param caseremarks
    * @param newValue
    * @return Strung
    */
    @TestVisible 
    private static String addChangedValueHelper(String caseremarks, String newValue){
        if(newValue!=null){
            caseremarks = caseremarks.replace('<param3>', newValue);
        }  else{
            caseremarks = caseremarks.replace('<param3>', '');
        } return caseremarks;
    }

    /**
    * @author Monica Cutillo
    * @param remarkWrapper - RemarkMessageWrapper
    * @return new RemarkMessage value
    * @description Add to the last velue of RemarkMessage change message relative field parameter in input
    * @email monica.cutillo@nttdata.com
    */
    public static String addRemarkMessage(RemarkMessageWrapper remarkWrapper) {
        String newMessage = '';
        if(remarkWrapper.lastMessage!= null && !String.isEmpty(remarkWrapper.lastMessage)){
            newMessage = remarkWrapper.lastMessage + '\n ';
        }
        String fieldLabel = remarkWrapper.fieldDescribe.getLabel();   
        newMessage += XC_AT_Utils.addChangedValue(fieldLabel, remarkWrapper.newValue, remarkWrapper.oldValue); 
        return newMessage;
    }

    /**
    * @description    class ActionPlanCreationWrapper
    */
    public class ActionPlanCreationWrapper{
        Id templateId;
        String refId;
        String refType;

        /**
        * @description    constructor
        */
        public ActionPlanCreationWrapper(){
            XC_UTIL_Debug.debug(false, 'Costruttore senza parametri - NON CANCELLARE');
        }

        /**
        * @description    constructor
        * @param templateIdVal
        * @param refIdVal
        * @param refTypeVal
        */
        public ActionPlanCreationWrapper(Id templateIdVal, String refIdVal, String refTypeVal){
            this.templateId = templateIdVal;
            this.refId = refIdVal;
            this.refType = refTypeVal;
        }
    }

    /**
    * @description    method futureActionPlanCreation
    * @param apData   ActionPlanCreationWrapper
    */
    //@future
    //public static void futureActionPlanCreation (Id template, String ref, String relatedType){
    public static void futureActionPlanCreation (List<String> apData){
        ActionPlanCreation apCreationJob = new ActionPlanCreation(apData);
        // enqueue the job for processing
        ID jobID = System.enqueueJob(apCreationJob);

        /*for(String apWrS : apData){
            ActionPlanCreationWrapper apWr = (ActionPlanCreationWrapper)JSON.deserialize(apWrS, ActionPlanCreationWrapper.class);
            //ATCL_VFC032_ActionPlanAutoCreation actionPlanAutoCreation = new ATCL_VFC032_ActionPlanAutoCreation(template, ref, relatedType);
            ATCL_VFC032_ActionPlanAutoCreation actionPlanAutoCreation = new ATCL_VFC032_ActionPlanAutoCreation(apWr.templateId, apWr.refId, apWr.refType);
            actionPlanAutoCreation.initNewActionPlanFromTemplate();
            actionPlanAutoCreation.save();
        }*/
    }


    /*-------------------------------------------------NE__Catalog_Category__c utils--------------------------------------------------------------*/
    /**
    * @param assetIds the asset ids
    * @return         NE__Catalog_Category__c
    * @name           getCatalogCategory
    * @description    method that returns NE__Catalog_Category__c by Id
    * @params         Id id
    */
    public static Map<Id, String> getCatalogCategoryNamesMap(Set<Id> assetIds) {
        Map<Id, String> catalogCategoryNamesMap = new Map<Id, String>(); 
        Map<Id,Asset> assetListMap  =  new Map<Id,Asset>([SELECT id, AccountId, 
                                                          contactId, XC_Product_Catalog_Category__c, Name 
                                                          FROM Asset WHERE id in: assetIds]);
        List<Asset> assetList = assetListMap.values(); 
        Set<Id> catalogIds = new Set<Id>();
        if(!assetList.isEmpty()){
            for(Asset a : assetList){
                if(a.XC_Product_Catalog_Category__c!=null) {
                    catalogIds.add(a.XC_Product_Catalog_Category__c);
                }
            }   
            Map<Id,NE__Catalog_Category__c> catListMap = new  Map<Id,NE__Catalog_Category__c>([SELECT Id, Name 
                                                                                               FROM NE__Catalog_Category__c where id in : catalogIds]);
            List<NE__Catalog_Category__c> catList = catListMap.values();
             
            for(Asset a : assetList){
                for(NE__Catalog_Category__c c : catList) {
                    if(c.Id == a.XC_Product_Catalog_Category__c) {
                        catalogCategoryNamesMap.put(a.Id, c.Name);
                    }
                }
            } 
        } 
        return catalogCategoryNamesMap;
    }  
    /*------------------------------------------------FIN NE__Catalog_Category__c  utils--------------------------------------------------------------*/
    

    /*-------------------------------------------------SLA utils--------------------------------------------------------------*/
    /**
    * Gets the SLA entitlement.
    * @param          sObjectType to filter SlaProcess
    * @return         Map<String, Entitlement> slaMap
    * @name           getSLAEntitlement
    * @description    method that returns a map that contains as key AssetId en as value the catalog category Name
    */
    public static  Map<String, Entitlement> getSLAEntitlement(String sObjectType) {
        Map<String, Entitlement> slaMap = new  Map<String, Entitlement>();
        Set<Id> listSLAProcessIds = new Set<Id>();
        
        // vb queries a modo info no descomentar . pte cambiar codigo en desarrollo
        Map<Id,SlaProcess> sLAEntitlementProcessMap = new Map<Id,SlaProcess>([
            SELECT Id, Name FROM SlaProcess WHERE SobjectType =: sObjectType]);
        List<SlaProcess> sLAEntitlementProcess = SLAEntitlementProcessMap.values();
        
        if(!SLAEntitlementProcess.isEmpty() ) {
            for(SlaProcess sla : sLAEntitlementProcess){ 
                listSLAProcessIds.add(sla.Id);
            }
        }
        if(!listSLAProcessIds.isEmpty() ){
            System.debug('getSLAEntitlement ,listSLAProcessIds ' + listSLAProcessIds); 
            Map<Id,Entitlement> sLAIdMap = new 
                Map<Id,Entitlement>([SELECT Id, SlaProcessId 
                                     FROM Entitlement WHERE SlaProcessId in: listSLAProcessIds AND XC_EntitlmentCheck__c = false LIMIT 100]); //DeAv added AND condition CR760
            List<Entitlement> sLAId = SLAIdMap.values();
            System.debug('getSLAEntitlement ,XC_SLAProcess__c SLA encontrados ' + SLAId); 
                
            for(SlaProcess sla : SLAEntitlementProcess){
                for(Entitlement e : sLAId){
                    if(e.SlaProcessId == sla.Id){ 
                        slaMap.put(sla.Name, e);
                    }
                } 
            }  
        } else {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'getSLAEntitlement ,SlaProcess sin info ');
        }
        System.debug(slaMap);
        return slaMap;
    }  
    /*------------------------------------------------FIN SLA  utils--------------------------------------------------------------*/
}