/**
* @author Nicola Arrigo - narrigo@deloitte.it
* @createddate 24/09/2020
@description classes. XC_TR_WoMalFunctioning
*/
public with sharing class XC_TR_CheckParentMalfunctioning {
    public static void onInsert(list<Case> listNew){
        //system.debug('enter on XC_TR_CheckParentMalfunctioning.onInsert()');
        /* MC 20201012 - update to woek only cases related with this flow */
        List<Case> malfCases = filtedCaseForMalfuntioning(listNew); 
        if(malfCases.isEmpty()){
            return;
        }

       /* List<XC_CM_Case_Repair_Configuration__mdt> caseRepairList=[
            select id,XC_Reason__c, XC_Sub_Cause__c, XC_Sub_Type__c,XC_B2BWONeeded__c 
            from XC_CM_Case_Repair_Configuration__mdt 
            where XC_B2BWONeeded__c=true
        ];*/
        Map<string,XC_CM_Case_Repair_Configuration__mdt> mapCaseRepairConfiguration=XC_TR_Case_U_CaseRepair_B2BG.mapCaseRepairConfiguration();
        //system.debug('List record cm Case repair configuration'+' '+caseRepairList);
        List<Case> caseToBeCheck=new List<Case>();
        Set<String> listSubtype=new Set<string>();
        List<string> concList=new List<string>();
        if(mapCaseRepairConfiguration.values().size()>0){
            //system.debug('caserepairList greater than 0');
            // for(XC_CM_Case_Repair_Configuration__mdt cm:caseRepairList){
                   // Map<string,XC_CM_Case_Repair_Configuration__mdt> mapCaseRepairConfiguration=mapCaseRepairConfiguration(caseRepairList);
                    string s;
                     for(case c:malfCases){
                       /* if(!string.isBlank(c.XC_Subtype__c)){
                            s=c.reason+'_'+c.SubCause__c+'_'+c.XC_Subtype__c;
                        }else if(string.isBlank(c.XC_Subtype__c)){
                            s=c.reason+'_'+c.SubCause__c;
                        }*/
                        /*if(( c.XC_Segment__c=='B2B' ||C.XC_Segment__c=='B2G' ) &&
                            c.XC_TechnicalAsset__c!=null && */
                        // boolean trovato=XC_TR_Case_U_CaseRepair_B2BG.findCMRecord(c,mapCaseRepairConfiguration);   
                        caseToBeCheck.add(c);
                        listSubtype.add(c.XC_Subtype__c);
                        concList.add(c.ContactId);
                       /* if( trovato==true
                            //mapCaseRepairConfiguration.get(s)!=null
                            ){
                            //c.reason==cm.XC_Reason__c &&
                            //c.SubCause__c==cm.XC_Sub_Cause__c &&
                        // c.XC_Subtype__c==cm.XC_Sub_Type__c 
                        
                            //system.debug('case To check'+c);
                            caseToBeCheck.add(c);
                            listSubtype.add(c.XC_Subtype__c);
                            concList.add(c.ContactId);
                        }*/
                    }
            // }
            //system.debug('case to be checked '+caseToBeCheck);   
            //List<Case> listExistingCases=new List<case>();
            if(caseToBeCheck.isEmpty()){
                return;
            }

            List<Id> assetIdList=retrieveListId (caseToBeCheck);
            Map<id,Asset> mapAssetLogical=new Map<id,asset>([select id from asset
                                                                where id IN:assetIdList and 

                                                                TAM_IsLogical__c=true]);


           // List<String> accList         = XC_UTIL_Sobject.getListFieldValues(caseToBeCheck, 'AccountId');
            Set<String> listReason      = XC_UTIL_Sobject_U_Retrieve.getSetFieldValues(caseToBeCheck, 'Reason');
            Set<String> listSubcause    = XC_UTIL_Sobject_U_Retrieve.getSetFieldValues(caseToBeCheck, 'Subcause__c');
            listSubtype.add(null);
           // List<String> listSubtype     = XC_UTIL_Sobject.getListFieldValuesWithNullValue(caseToBeCheck, 'XC_Subtype__c');
            Set<String> listAssetTechnical = XC_UTIL_Sobject_U_Retrieve.getSetFieldValues(caseToBeCheck, 'XC_TechnicalAsset__c');
            //system.debug('List fields to be checked'+'_'+concList+'_'+listReason+'_'+listSubcause+'_'+'_'+listSubtype+'_'+listAssetTechnical);
            Set<string> listBusinessLine= XC_UTIL_Sobject_U_Retrieve.getSetFieldValues(caseToBeCheck, 'XC_BusinessLine__c');
            //List<Case> listExistingCases=new List<Case>();
            Map<Id,Case> listExistingCases = new Map<Id,Case>([
                SELECT Id,Status, AccountId, ContactId, ParentId, CaseNumber, Subcause__c, XC_Subtype__c, Reason, Priority,isStopped,
                XC_WorkOrder__c, XC_Opportunity__c, XC_Order__c, XC_OrderItem__c, AssetId, XC_Type_Intermediary__c,XC_TechnicalAsset__c, XC_BusinessLine__c
                FROM Case 
                WHERE (ContactId IN:concList
                        AND Reason IN :listReason
                        AND Subcause__c IN :listSubcause
                        AND XC_Subtype__c IN :listSubtype
                        AND XC_TechnicalAsset__c IN:listAssetTechnical
                        AND XC_BusinessLine__c IN:listBusinessLine
                        AND Status NOT IN ('ESTA007','ESTA008')
                        AND ParentId=null)
                order by createddate asc]);
            
            //system.debug('List existing Case '+listExistingCases);
            if(!listExistingCases.isEmpty()){
                for(Case c: caseToBeCheck){
                    for(Case cp: listExistingCases.values()){
                        if( c.XC_BusinessLine__c==cp.XC_BusinessLine__c &&
                            c.ContactId==cp.ContactId &&
                            c.Reason==cp.Reason &&
                            c.Subcause__c==cp.Subcause__c &&
                            c.XC_TechnicalAsset__c==cp.XC_TechnicalAsset__c &&
                            mapAssetLogical.get(c.XC_TechnicalAsset__c)==null
                        ){
                           //system.debug('enter if condition to Parent Case');
                            c.ParentId=cp.Id;
							if(cp.Status=='ESTA002'){
                                system.debug('parent case in pending status');
                                c.Status='ESTA002';
                            }if(cp.isStopped==true){
                                c.isStopped=true;
                            }
                            if(c.XC_IsCloned__c==false){
                                    c.XC_IsCloned__c=true;
                            } 
                            //system.debug('ParentId '+c.ParentId);
                            break;
                        }
                    }
                }
            }
        }  
    }

    /**
    * @author Monica Cutillo
    * @description return filted Cases for Malfuntioning flow
    * @param listNew
    */
    private static List<Case> filtedCaseForMalfuntioning(List<Case> listNew){
        List<Case> malfCases = new List<Case>();
        for(case caso : listNew){
            if(( caso.XC_Segment__c=='B2B' || caso.XC_Segment__c=='B2G' ) && caso.XC_TechnicalAsset__c!=null){
                malfCases.add(caso);
            }
        }
        return malfCases;
    }

    /**
    * @author Nicola Arrigo
    * @description onUpdate
    * @param listNew
    * @param oldMap
    */
    public static void onUpdate(list<Case> listNew, map<id,case>oldMap){
       List<case> caseList=new List<Case>();
        for(case c:listNew){
            if( c.XC_TechnicalAsset__c!=null &&
                c.XC_TechnicalAsset__c!=oldMap.get(c.id).XC_TechnicalAsset__c){
                caseList.add(c);        
            }
        }
        onInsert(caseList);
    }
    /**
    * @author Nicola Arrigo
    * @description onUpdate
    * @param caseToBeCheck
    * @return List<Id>
    */
    public static List<Id> retrieveListId (List<Case> caseToBeCheck){
        List<Id> assetIdList=new List<Id>();
        for(Case c:caseToBeCheck){
            assetIdList.add(c.XC_TechnicalAsset__c);
        }
        return assetIdList;
    }
             
    /**
    * @author Nicola Arrigo
    * @date Creation 28/09/2020
    * @description Method retrieveid  
    * @param caseRepairList    
    * @return Map<id,XC_CM_Case_Repair_Configuration__mdt>       
    */
  /*public static Map<string,XC_CM_Case_Repair_Configuration__mdt> mapCaseRepairConfiguration(List<XC_CM_Case_Repair_Configuration__mdt> caseRepairList){
    Map<string,XC_CM_Case_Repair_Configuration__mdt> mapCaseRepairConfiguration=new Map<string,XC_CM_Case_Repair_Configuration__mdt>();
    for(XC_CM_Case_Repair_Configuration__mdt cm:caseRepairList){
        if(!string.isBlank(cm.XC_Sub_Type__c)){
            string s=cm.XC_Reason__c+'_'+cm.XC_Sub_Cause__c+'_'+cm.XC_Sub_Type__c;
            mapCaseRepairConfiguration.put(s,cm);
        }else if(string.isBlank(cm.XC_Sub_Type__c)){
            string s=cm.XC_Reason__c+'_'+cm.XC_Sub_Cause__c;
            mapCaseRepairConfiguration.put(s,cm);
        }    
    }
    system.debug('Map case repair configuration '+mapCaseRepairConfiguration);
    return mapCaseRepairConfiguration;
  }*/
}