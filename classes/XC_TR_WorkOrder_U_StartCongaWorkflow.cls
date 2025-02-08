/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 10/07/2019
* @date Modification 26/03/2020 by Salvatore Scarpato - salvatore.scarpato@nttdata.com & Domenico Del Prete - domenico.delprete@nttdata.com
* @description  – XC_TR_WorkOrder_U_StartCongaWorkflow  - Class that recover the info from WorkOrder and related records and pass the info to the Conga call
*                                                             that start with a workflow  
*/ 
public without sharing class XC_TR_WorkOrder_U_StartCongaWorkflow {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_U_StartCongaWorkflow');
    public static Boolean restartForDiagnostic = false;
    public static Boolean avoidRecursion = false;

    /** 
    * @description populate Conga Field
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com/ Domenico Del Prete domenico.delprete@nttdata.com  | 26/3/2020    
    * @param listNew 
    * @param mapOld
    * @param mapNew
    */
    public static void populateCongaFieldOnWOLI(List<WorkOrder> listNew, Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
        List<WorkOrder> listWorkOrderChanged = XC_UTIL_SObject.getListChanged(new List<String>{'XC_CreateReducedReport__c'}, mapOld, mapNew);

        if(listWorkOrderChanged.isEmpty()){
            return; 
        }
        
        // TEMP METHOD (TO DELETE WHEN APP FIXES):
        reducedServiceReportWOChildren(XC_UTIL_SObject.getListChanged(new List<String>{'XC_CreateReducedReport__c'}, mapOld, mapNew), mapNew);

        XC_UTIL_Debug.debug(DEBUGACTIVE, '<---- @107 ENTER IN populateCongaField - list workorder changed--> ' + listWorkOrderChanged);
        List<String> woIdInFinalStatusList = new List<String>();
        List<WorkOrder> listOfWoToCheck = new List<WorkOrder>();
        List<String> listWoToUpdate = new List<String>();
        Map<String, String> orderIdWoIdMap = new Map<String, String>();
        Map<String,String> woIdproductSubtypeMap = new Map<String, String>();
        Boolean foundToBeManuallyDigitalized = false;
        for(WorkOrder wo : listWorkOrderChanged){
            WorkOrder woOld = (WorkOrder) mapOld.get(wo.Id);
            listOfWoToCheck.add(wo);
            /* REWORK Conga - Now the complete service report will be generated when 
                              the flag is changed and there will be no reduced service reports  [DDP] 03-08-2020
            if(wo.XC_Check_Final_Status__c && wo.Status != Label.XC_CL_WorkOrder_Canceled){
                woIdInFinalStatusList.add(wo.Id);
            } else*/ 
            if( (wo.XC_CreateReducedReport__c && !woOld.XC_CreateReducedReport__c) ){ // || (wo.XC_ToBeManuallyDigitalized__c && !woOld.XC_ToBeManuallyDigitalized__c) ){   FIX SS 04-11-20
               /*REWORK Conga Now the complete service report will be generated when 
                              the flag is changed and there will be no reduced service reports [DDP]  03-08-2020
               orderIdWoIdMap.put(wo.XC_Configuration__c, wo.Id);*/
               listWoToUpdate.add(wo.Id);
            } 
        }
        if(!listWoToUpdate.isEmpty()){
            /* REWORK Conga     Now the complete service report will be generated when 
                                the flag is changed and there will be no reduced service reports [DDP]  03-08-2020
            woIdproductSubtypeMap = populateBundleProductMap(orderIdWoIdMap);
            startingCongaWorkFlowReduced(woIdproductSubtypeMap, listNew, listOfWoToCheck);*/
            Map<Id, WorkOrder> woWithSubTypeMap = populateVerifySeriousDefects(listWoToUpdate, listNew);
            startingCongaWorkFlow(listNew, listOfWoToCheck, woWithSubTypeMap);
        }
    }

    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com/ Domenico Del Prete domenico.delprete@nttdata.com  | 26/3/2020 
    * @param wrapperList 
    **/
    private static void setDynamicApi(List<XC_UTIL_Conga.UtilWrapper> wrapperList){
        for(XC_UTIL_Conga.UtilWrapper wrapper : wrapperList){
            if(!String.isBlank(wrapper.templateId) || !String.isBlank(wrapper.congaQuery) ){
                String dynamicApi = '&Id=' + wrapper.workOrderToBeUpdated.Id + '&QueryId=' +  wrapper.congaQuery + '&TemplateId=' +  wrapper.templateId
                            + '&OFN= WorkOrder - SERVICE_REPORT' +
                            + '&DefaultPDF=1&qmode=SalesforceFile';
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ START CONGA ON WORK ORDER MAINTANANCE dynamicApi--> ' + dynamicApi);
                wrapper.workOrderToBeUpdated.XC_CongaDynamicAPI__c = wrapper.workOrderToBeUpdated.XC_CongaStaticAPI__c + dynamicApi;
            } 
        }
    }
 
    /**
    * @description method needed to populate a field on WO in order to define if there is a serious defect and print on the 
																Service Report a specific final note.
    * @author salvatore.scarpato@nttdata.com | 18/3/2020 
    * @param woIdToCheckList List<String>
    * @param listNew List<WorkOrder>
    * @return Map<Id, WorkOrder>
    **/
    private static Map<Id, WorkOrder> populateVerifySeriousDefects(List<String> woIdToCheckList, List<WorkOrder> listNew){
        
        List<XC_DictamenItem__c> dictamenList = new List<XC_DictamenItem__c>();
        Map<Id, WorkOrder> woWithSubTypeMap = new Map<Id, WorkOrder>([SELECT Id, XC_Configuration_Item__r.XC_Product_Subtype__c,  Asset.NE__ProdId__c,XC_Coverage__r.Parent.XC_Product_Name__c, 
                                                        (SELECT Id, XC_AnomalyResolvedIn__c, XC_WorkOrder__c, XC_DefectsSeverity__c, XC_WorkOrder__r.XC_Opportunity__r.StageName
                                                        FROM Dictamens_Items__r 
                                                        WHERE (XC_DefectsSeverity__c = 'Very Serious' OR XC_DefectsSeverity__c = 'Serious' OR XC_AnomalyResolvedIn__c !=: Label.XC_CL_DictamenAnomalyResolvedIn_Immediate) AND XC_WorkOrder__r.XC_Opportunity__r.StageName =: Label.XC_CL_Opportunity_ClosedLost)
                                                    FROM WorkOrder WHERE Id IN: woIdToCheckList]);

        for(WorkOrder wo : woWithSubTypeMap.values()){
            dictamenList.addAll(wo.Dictamens_Items__r);
        }             
        if(dictamenList.isEmpty()){
            return woWithSubTypeMap;
        } 
        Map<String, Boolean> woIdVerifyDefectMap = new Map<String, Boolean>();   
        for(XC_DictamenItem__c dicItem: dictamenList){
            woIdVerifyDefectMap.put(dicItem.XC_WorkOrder__c, true);
        }

        for(WorkOrder wo : listNew){
            if(woIdVerifyDefectMap.containsKey(wo.Id)){
                wo.XC_VerifySeriousDefects__c = true;
            }
        }
        return woWithSubTypeMap;                                       
    }

    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com/ Domenico Del Prete domenico.delprete@nttdata.com  | 26/3/2020
    * @param listOfWoChanged 
    * @param listOfWoToCheck 
    **/
    private static void startingCongaWorkFlow(List<WorkOrder> listOfWoChanged, List<WorkOrder> listOfWoToCheck, Map<Id, WorkOrder> woWithSubTypeMap){
        List<XC_UTIL_Conga.UtilWrapper> wrapperList = new List<XC_UTIL_Conga.UtilWrapper>();
        for(WorkOrder wo : listOfWoChanged){
            if(listOfWoToCheck.contains(wo)){
                XC_UTIL_Conga.UtilWrapper wrapper = new XC_UTIL_Conga.UtilWrapper();
                wrapper.workOrderToBeUpdated = wo;
                wrapper.legalEntity = wo.XC_LegalEntity__c;            
                wrapper.country = wo.XC_Country__c;
                wrapper.workType = wo.XC_WorkTypeCategory__c;
                wrapper.categoryName = getAssetProductName(wo, woWithSubTypeMap); 
                if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_PlannedMaintenance && 
                    (wo.State == 'Huesca' || wo.State == 'Zaragoza' || wo.State == 'Teruel')){
                    wrapper.forAragona = true;
                }
                wrapperList.add(wrapper);
            }
        }
        XC_UTIL_Conga.queryOnCongaTemplates(wrapperList, 'SERVICE_REPORT');
        for(XC_UTIL_Conga.UtilWrapper wrapper : wrapperList){
            if(String.isBlank(wrapper.templateId) && wrapper.workOrderToBeUpdated.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Diagnostic && !avoidRecursion ){
                restartForDiagnostic = true;
                startingCongaWorkFlow(listOfWoChanged, listOfWoToCheck, woWithSubTypeMap);
            }
        }
        setDynamicApi(wrapperList);
    }

    /**
    * @description 
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 24/10/2019  
    * @param workOrderChanged 
    * @return String 
    **/
    private static String getAssetProductName(WorkOrder workOrderChanged, Map<Id, WorkOrder> woWithSubTypeMap){ 
        if(restartForDiagnostic && workOrderChanged.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Diagnostic){
            avoidRecursion = true;
            return workOrderChanged.XC_ProductSubType__c;
        } else {
            if(workOrderChanged.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Repair && !woWithSubTypeMap.isEmpty()
                && woWithSubTypeMap.containsKey(workOrderChanged.Id) && String.isBlank(woWithSubTypeMap.get(workOrderChanged.id).Asset.NE__ProdId__c) 
                && String.isNotBlank(workOrderChanged.XC_Coverage__c) && String.isNotBlank(woWithSubTypeMap.get(workOrderChanged.id).XC_Coverage__r.Parent.XC_Product_Name__c) 
                && String.isBlank(workOrderChanged.XC_CatalogCategory_Name__c)){
                return woWithSubTypeMap.get(workOrderChanged.id).XC_Coverage__r.Parent.XC_Product_Name__c;
            } else if(workOrderChanged.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Repair && workOrderChanged.XC_CatalogCategory_Name__c == Label.XC_CL_Boiler){
                return Label.XC_CL_Boiler;
            } else if(workOrderChanged.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Repair && workOrderChanged.XC_CatalogCategory_Name__c == Label.XC_CL_AirConditioning){
                return Label.XC_CL_AirConditioning;
            } else if(!String.isBlank(workOrderChanged.XC_CoverageAssetName__c) && workOrderChanged.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Repair){
                return workOrderChanged.XC_CoverageAssetName__c;
            } else if(!String.isEmpty(workOrderChanged.XC_Conga_AssetProductName__c)){
                return workOrderChanged.XC_Conga_AssetProductName__c;   
            } else if(woWithSubTypeMap.containsKey(workOrderChanged.id) && !String.isEmpty(woWithSubTypeMap.get(workOrderChanged.id).XC_Configuration_Item__r.XC_Product_Subtype__c)){
                return woWithSubTypeMap.get(workOrderChanged.id).XC_Configuration_Item__r.XC_Product_Subtype__c;
            } else if(workOrderChanged.XC_WorkTypeLabel__c == 'Repair - Handy Assistance') {
                return 'OK Luz'; //SS 24/08/2020 MOMENTANEUOUS FIX IN ORDER TO CREATE THE SERVICE REPORT FOR THE HANDY ASSISTANCE WO
            } else {
                return '';
            }
        } 
    }

    /**
    * @description Copy flags for reduced Service Reports to Work Order Children (TEMP METHOD - TO DELETE WHEN APP FIXES)
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 19/08/2020
    * @param listOfWoChanged - List<WorkOrder>
    * @param mapNew - Map<Id, WorkOrder>
    **/
    private static void reducedServiceReportWOChildren(List<WorkOrder> listOfWoChanged, Map<Id, sObject> mapNew) {
        List<WorkOrder> listWorkOrderDI = new List<WorkOrder>([
            SELECT Id, XC_CreateReducedReport__c,
                (SELECT Id 
                FROM ChildWorkOrders) 
            FROM WorkOrder 
            WHERE Id IN :listOfWoChanged AND XC_WorkTypeLabel__c = :Label.XC_CL_WorkType_DeliveryInstallation
        ]);
        List<WorkOrder> listChildWorkOrderToUpdate = new List<WorkOrder>();
        for(WorkOrder parentWO : listWorkOrderDI) {
            for(WorkOrder childWO : parentWO.ChildWorkOrders) {
                childWO.XC_CreateReducedReport__c = (Boolean) mapNew.get(parentWO.Id).get('XC_CreateReducedReport__c');
                listChildWorkOrderToUpdate.add(childWO);
            }
        }
        XC_UTIL_Sobject.updateListRecords(listChildWorkOrderToUpdate);
    }
}