/**
* @author v.1 VBV vbarquero@deloitte.es 
* @author v.2 Monica Cutillo monica.cutillo@nttdata.com
* @date Creation 16/01/2019
* @date Modification 24/01/2019
* @description XC_TR_Case_U_Care_ActionPlan – Util class to change associate un Action Plane Template on Case creation
*/
public without sharing class  XC_TR_Case_U_Care_ActionPlan {
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Case_U_Care_ActionPlan');

    /**
     * @description Sets the action plan 
     * @author Monica Cutillo monica.cutillo@nttdata.com
     * @param listNew the new action plan
     * @description Methods to create ActionPlan associate to new Cases
     */  
    public static void setActionPlan(List<Case> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ CALL XC_TR_Case_U_Care_ActionPlan setActionPlan START');
        //Map<Id, String> caseTemplateMap = retriveCasesActionPlanTemplateRelations(listNew);
        Map<String, XC_CM_CaseMapping__mdt> caseTemplateMap = XC_UTIL_Case_U.retriveCaseMappingMtdFromCases(listNew);
        
        if(caseTemplateMap.isEmpty()){
            return;
        }

        createActionPlans(listNew, caseTemplateMap);
    }

    /**
     * Creates the action plans.
     *
     * @author Monica Cutillo monica.cutillo@nttdata.com
     * @param listNew the list new
     * @param caseTemplateMap the case template map
     * @description Methods to retrive data from custo metadata XC_CM_CaseMapping__mdt
     */  
    /*private static Map<Id, String> retriveCasesActionPlanTemplateRelations(List<Case> listNew){
        Map<Id, String> caseTemplateMap = new Map<Id, String>();
        for(Case newCase : listNew){
            if( newCase.Status==XC_AT_Constants.TRIGGER_STATUS_ESTA007 || newCase.Reason==null || newCase.Subcause__c==null){
                continue;
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ newCase.Reason='+newCase.Reason+' - newCase.Subcause='+newCase.Subcause__c+' - newCase.XC_Subtype='+newCase.XC_Subtype__c);
            List<XC_CM_CaseMapping__mdt> templates = [ SELECT Id, XC_CaseReason__c, XC_SubCause__c, XC_SubType__c, XC_ActionPlanTemplate__c
                                                         FROM XC_CM_CaseMapping__mdt
                                                        WHERE XC_CaseReason__c =: newCase.Reason 
                                                          AND XC_SubCause__c   =: newCase.Subcause__c 
                                                          AND XC_SubType__c    =: newCase.XC_Subtype__c ];
            if(!templates.isEmpty()){
                caseTemplateMap.put(newCase.Id, templates[0].XC_ActionPlanTemplate__c);
            }
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ caseTemplateMap='+caseTemplateMap);
        return caseTemplateMap;
    }*/

    /**
     * @author Monica Cutillo monica.cutillo@nttdata.com
     * @lastModifiedBy Nicola Arrigo narrigo@deloitte.it
     * @description Methods to call an 
     * @param listNew
     * @param caseTemplateMap
     **/  
    private static void createActionPlans(List<Case> listNew, Map<String, XC_CM_CaseMapping__mdt> caseTemplateMap){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ XC_TR_Case_U_Care_ActionPlan - creating ActionPlans');
        //List<ActionPlan__c> actionPlansToCreate = new List<ActionPlan__c>();
      //  Map<String, String> apTemplatesMap = new Map<String, String>();
        
        List<String> templateNameList = new List<String>();
        for(XC_CM_CaseMapping__mdt row : caseTemplateMap.values()){
            templateNameList.add(row.XC_ActionPlanTemplate__c);
        }
        Map<Id,ActionPlanTemplate__c> apTemplatesMapX = new Map<Id,ActionPlanTemplate__c>(
         [SELECT Id, Name,XC_LegalEntity__c FROM ActionPlanTemplate__c WHERE Name IN: templateNameList]);
         List<ActionPlanTemplate__c> apTemplates  = apTemplatesMapX.values();  
      
        /*
        for (ActionPlanTemplate__c apTemplate: apTemplates) {
            apTemplatesMap.put(apTemplate.Name, apTemplate.Id);  
        }*/
       /* for (ActionPlanTemplate__c apTemplate: apTemplates) {
            String[] s = apTemplate.XC_LegalEntity__c.split(';'); 
            for(string l:s){
            apTemplatesMap.put(l, apTemplate.Id); 
            }  
        }*/
         Map<String, String> apTemplatesMap=apTemplatesMap(apTemplates); 
        /*for (String caseId : caseTemplateMap.keySet()) {
            String tempName = caseTemplateMap.get(caseId);
            String templateId = apTemplatesMap.get(tempName);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ CALL futureActionPlanCreation templateId=' + templateId + ' - tempName='+tempName); 
            XC_AT_Utils.futureActionPlanCreation(templateId, caseId, 'Case');
        }*/
       
        String mtdKey;
        XC_CM_CaseMapping__mdt mappingRow;
        List<String> apData = new List<String>();
        for(Case newCase: listNew){
            mtdKey = newCase.Reason + '_' + newCase.Subcause__c;
            if(newCase.XC_Subtype__c != null){
                mtdKey = mtdKey + '_' + newCase.XC_Subtype__c;
            }
            mappingRow = caseTemplateMap.get(mtdKey);
            if(mappingRow==null && newCase.XC_Subtype__c != null){
                mtdKey = newCase.Reason + '_' + newCase.Subcause__c;
                mappingRow = caseTemplateMap.get(mtdKey);
            }
            if(mappingRow==null){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ ActionPlans Creation - No Match on XC_CM_CaseMapping__mdt for Case='+newCase);
                continue;
            }

            String tempName = caseTemplateMap.get(mtdKey).XC_ActionPlanTemplate__c;
            system.debug('case legal entity'+' '+newCase.XC_LegalEntity__c);       
            string tempLegalEntity=newCase.XC_LegalEntity__c;
            String templateId = apTemplatesMap.get(tempName+'_'+tempLegalEntity);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ CALL futureActionPlanCreation templateId=' + templateId + ' - tempLegalEntity='+tempLegalEntity+' - tempName='+tempName); 
            //XC_AT_Utils.futureActionPlanCreation(templateId, newCase.Id, 'Case'); /*MC 20190612 > tolta chiamata future dal ciclo*/
            XC_AT_Utils.ActionPlanCreationWrapper apWr = new XC_AT_Utils.ActionPlanCreationWrapper(templateId, newCase.Id, 'Case');
            apData.add(JSON.serialize(apWr));
        }

        if(!apData.isEmpty()){
            XC_AT_Utils.futureActionPlanCreation(apData);
        }
        
        /*if(!actionPlansToCreate.isEmpty()){
            XC_UTIL_Sobject.insertListRecords(actionPlansToCreate);
        }*/
    }

    private static Map<String, String> apTemplatesMap(List<ActionPlanTemplate__c> apTemplates){
       /*The KeyValue of the map is   
         the concatenation between the  Name and Legal Entity of the Action Plan Template record*/
        Map<String, String> apTemplatesMap=new Map<String, String>();      
        for (ActionPlanTemplate__c apTemplate: apTemplates) {
           if(apTemplate.XC_LegalEntity__c!=null){
            String[] s = apTemplate.XC_LegalEntity__c.split(';'); 
            for(string le:s){
                apTemplatesMap.put(apTemplate.Name+'_'+le, apTemplate.Id); 
                system.debug('Key Value'+' '+apTemplate.Name+'_'+le);
            }
           }   
        }
        return apTemplatesMap;   
    }
}