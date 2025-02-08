public with sharing class XC_TR_ClosureCaseMalFunctioning {
    public static void caseClosureMalfunctioning(List<WorkOrder> woList, Map <id,WorkOrder> mapOld){
        List<id> caseIdList=new List<id>();
        List<id> assetId=new List<id>();
        Map<id,DateTime> mapDueDateWO=new Map<id,DateTime>();
        for(WorkOrder wo:woList){
            system.debug('WorkOrder Status '+wo.Status);
            system.debug('oldWoStatus '+mapOld.get(wo.id).Status);
            if( wo.XC_WorkTypeCategory__c=='Malfunctioning' &&
                wo.CaseId!=null &&
                wo.Status=='Completed' &&
                (wo.XC_Segment__c=='B2B' || wo.XC_Segment__c=='B2G') &&
                 wo.Status!=mapOld.get(wo.id).Status
                ){
                    caseIdList.add(wo.CaseId);
                    assetId.add(wo.AssetId);
                    mapDueDateWO.put(wo.CaseId,wo.XC_DueDate__c);
                }    
        }
        system.debug('caseIdList '+caseIdList+' '+'AssetIdList '+assetId);
		 List<case> caseListToUpdate=new List<Case>();
        if(caseIdList.size()>0 && assetId.size()>0 ){
       // List<XC_CM_Case_Repair_Configuration__mdt> caseRepairList=[select id,XC_Reason__c, XC_Sub_Cause__c, XC_Sub_Type__c,XC_B2BWONeeded__c from XC_CM_Case_Repair_Configuration__mdt where XC_B2BWONeeded__c=true];
    //  Map<string,XC_CM_Case_Repair_Configuration__mdt> mapCaseRepairConfiguration=XC_TR_Case_U_CaseRepair_B2BG.mapCaseRepairConfiguration(); 
       //Map<string,XC_CM_Case_Repair_Configuration__mdt> mapCaseRepairConfiguration=mapCaseRepairConfiguration(caseRepairList);
       /* List<Case> newListCase=[select id,XC_Result__c, XC_Resolution__c,reason,Country__c, SubCause__c,XC_TechnicalAsset__c,XC_NeedInternalCheck__c, 
                                (select id,XC_Result__c, XC_Resolution__c,XC_Segment__c,Reason,SubCause__c,XC_Subtype__c,XC_Asset_B2B__c,Country__c,CaseRemarks__c from cases 
                                where XC_Segment__c='B2C' and Reason='XCMOT002' and SubCause__c='ATCL003' and XC_Subtype__c='XC199' and Status!='ESTA007' and 
                                Status!='ESTA008'),
                                 (select id,Status from workorders )  
                                 from case 
                                where id IN:caseIdList];*/
        List<Case> newListCase=[select id,XC_Result__c,Status, XC_Resolution__c,XC_Segment__c,Reason,SubCause__c,XC_Subtype__c,XC_Asset_B2B__c,Country__c,CaseRemarks__c,XC_NeedInternalCheck__c,XC_TechnicalAsset__c,XC_BusinessLine__c,XC_automaticClosure__c,XC_SLAImprese__c,
                                (select id,XC_Result__c,Status, XC_Resolution__c,XC_Segment__c,Reason,SubCause__c,XC_Subtype__c,XC_Asset_B2B__c,Country__c,CaseRemarks__c,XC_TechnicalAsset__c,XC_BusinessLine__c,XC_automaticClosure__c,XC_SLAImprese__c from cases 
                                 ),
                                (select id,Status from workorders )  
                                 from case 
                                 where (id IN:caseIdList 
                                          AND XC_NeedInternalCheck__c=false 
                                          AND Status!='ESTA007'
                                          AND Status!='ESTA008')];           
        XC_CM_CaseClosureDependencies__mdt cmClosure=[SELECT XC_Resolution__c, XC_Result__c, XC_CaseRemarks__c, XC_CaseRemarksEnelXItalia__c, XC_ClousureType__c, XC_ReasonCode__c,XC_SubCause__c,XC_Type_Intermediary__c,
                            							XC_CaseRemarksCogenio__c,XC_CaseRemarksEnelSole__c,XC_CaseRemarksEnelXMobility__c,	XC_CaseRemarksEnelXMSP__c,XC_CaseRemarksESCoComuniSrl__c,XC_CaseRemarksYouSaveSpA__c
                    									FROM XC_CM_CaseClosureDependencies__mdt 
                                                     where DeveloperName='XCMOT002_ATCL003'];  
        List<case> caseToupdate=new List<case>();  
		List<case> caseToupdateChild=new List<case>();
       // List<Case> listCaseRepair=new List<Case>();
       /* if( mapCaseRepairConfiguration.values().size()>0 &&
             newListCase.size()>0){
               listCaseRepair=listCaseRepair(mapCaseRepairConfiguration,newListCase);
             }*/
         List<case> automaticClosureCaseList=new List<Case>();
         system.debug('List Case newListCase '+newListCase);                           
        if(newListCase.size()>0){
            for (case c:newListCase){
                boolean trovato;
               // system.debug('')
               Long dtLongNow = Datetime.now().getTime();
               Long dtLongDueDateWO=mapDueDateWO.get(c.Id).getTime();
               system.debug('dtLongNow '+dtLongNow+' '+'dtLongDueDateWO '+dtLongDueDateWO);
               double difference;
                difference=(dtLongNow-dtLongDueDateWO);
                double diff=difference/(1000*60*60);
                system.debug('difference NowDueDate '+difference); 
               system.debug('diff hours '+diff);
            if(c.cases.size()>0){
                system.debug('List cases '+c.cases);
                for(case cChild:c.cases){
                   /*  string sChild;
                    if(!string.isBlank(c.XC_Subtype__c)){
                        sChild=cChild.Reason+'_'+cChild.SubCause__c+'_'+cChild.XC_Subtype__c;
                    }else if(string.isBlank(c.XC_Subtype__c)){
                        sChild=cChild.Reason+'_'+cChild.SubCause__c;
                    }*/
                    //boolean trovatoB2BC=XC_TR_Case_U_CaseRepair_B2BG.findCMRecord(cChild, mapCaseRepairConfiguration);
                    //if(trovatoB2BC==true){
                    if(cChild.Status!='ESTA007' && cChild.Status!='ESTA008' &&
                       (cChild.XC_Asset_B2B__c!=null ||cChild.XC_TechnicalAsset__c!=null)){
                        system.debug('AssetIdB2b '+c.XC_TechnicalAsset__c);
                        system.debug('AssetIdCaseChild '+cChild.XC_Asset_B2B__c+'_'+cChild.XC_TechnicalAsset__c);
                        cChild.XC_SLAImprese__c=Decimal.Valueof(diff);
                        cChild.XC_Result__c=cmClosure.XC_Result__c;
                        cChild.XC_Resolution__c=cmClosure.XC_Resolution__c;
                        cChild.XC_automaticClosure__c=true;
                        cChild.Status='ESTA007';
                        system.debug('cChildRow65'+cChild);
                        if(cChild.Country__c=='Italy'){
                            cChild.CaseRemarks__c=cmClosure.XC_CaseRemarksEnelXItalia__c;  
                            system.debug('cChildRow67'+cChild); 
                        }else{
                            cChild.CaseRemarks__c=cmClosure.XC_CaseRemarks__c;
                            system.debug('cB2CNEWRow71 '+cChild);  
                        }
                        caseToupdateChild.add(cChild);    
						caseListToUpdate.add(cChild);    
                       }
                        
                    
                }
                /* for(case cB2C:c.cases){
                   if(cB2C.XC_Asset_B2B__c==c.XC_TechnicalAsset__c){
                       system.debug('AssetIdB2b '+c.XC_TechnicalAsset__c);
                       system.debug('AssetB2C '+cB2C.XC_Asset_B2B__c);
                       cB2C.XC_Result__c=cmClosure.XC_Result__c;
                       cB2C.XC_Resolution__c=cmClosure.XC_Resolution__c;
                       system.debug('cB2CNEWRow35 '+cB2C);
                      if(cB2C.Country__c=='Italy'){
                       cB2C.CaseRemarks__c=cmClosure.XC_CaseRemarksEnelXItalia__c;  
                       system.debug('cB2CNEWRow39 '+cB2C); 
                      }else{
                        cB2C.CaseRemarks__c=cmClosure.XC_CaseRemarks__c;
                        system.debug('cB2CNEWRow42 '+cB2C);  
                      }
                      caseToupdateB2C.add(cB2C);       
                    }
             
                }*/
 
            } 
                for(WorkOrder wo:c.workorders){
                    c.XC_SLAImprese__c=Decimal.Valueof(diff);
                    trovato=false; 
                    if(wo.Status!='Completed'){
                        trovato=true;
                         system.debug('trovato '+trovato);
                     } 
                 }  
                 if( 
                    trovato==false &&
                    c.XC_NeedInternalCheck__c==false
                   ){     
                     c.XC_automaticClosure__c=true; 
                     //closure section filled only if not have child cases
                     system.debug('childCasessSize '+c.cases.size());
                      if(c.cases.size()==0){
                          system.debug('if condition case with no childs');
                           c.XC_Result__c=cmClosure.XC_Result__c;
                           c.XC_Resolution__c=cmClosure.XC_Resolution__c;
                          if(c.Country__c=='Italy'){
                             c.CaseRemarks__c=cmClosure.XC_CaseRemarksEnelXItalia__c;
                        }else{
                            c.CaseRemarks__c=cmClosure.XC_CaseRemarks__c;
                       }
                          c.Status='ESTA007'; 
                    }      
               }
               caseToupdate.add(c);
			   caseListToUpdate.add(c);
            }  
        }
		     if(caseListToUpdate.size()>0){
               if(caseToupdate.size()>0){
                    system.debug('caseTOuPDATE Parent '+caseToupdate);
               }if(caseToupdateChild.size()>0){
                   system.debug('caseToupdateChild '+caseToupdateChild);
               }
               update caseListToUpdate;
        }   
        /*if(caseToupdateChild.size()>0){
            system.debug('Updates with childs');
            update caseToupdate;
             update  caseToupdateChild; 
        }else{
            system.debug('Updates with no childs');
            update caseToupdate;
        }*/
       /* List<Case> toBeUpdatedParent=new List<Case>();
        if(automaticClosureCaseList.size()>0){
            update  automaticClosureCaseList;
           }*/
       /* if(caseToupdate.size()>0){
            for(case c:caseToupdate){
                c.XC_Result__c=cmClosure.XC_Result__c;
                c.XC_Resolution__c=cmClosure.XC_Resolution__c;
                if(c.Country__c=='Italy'){
                    c.CaseRemarks__c=cmClosure.XC_CaseRemarksEnelXItalia__c;
                }else{
                 c.CaseRemarks__c=cmClosure.XC_CaseRemarks__c;
                 }
                c.Status='ESTA007';
                 toBeUpdatedParent.add(c);
            }    
        }*/                                                 
        /*if( toBeUpdatedParent.size()>0){
            if(caseToupdateChild.size()>0){
                update  caseToupdateChild;        
            }
            update  toBeUpdatedParent;
          system.debug('caseToupdateChildNA '+caseToupdateChild);
          system.debug('toBeUpdatedParentNA '+toBeUpdatedParent);
        }*/                                                                                     
     }
    }
   
    /**
    * @author Nicola Arrigo
    * @date Creation 30/09/2020
    * @description Method retrieveid  
    * @param caseRepairList    
    * @return Map<id,XC_CM_Case_Repair_Configuration__mdt>       
    */
 /* public static Map<string,XC_CM_Case_Repair_Configuration__mdt> mapCaseRepairConfiguration(List<XC_CM_Case_Repair_Configuration__mdt> caseRepairList){
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
  
      /**
    * @author Nicola Arrigo
    * @date Creation 30/09/2020
    * @description Method listCaseRepair  
    * @param mapCaseRepairConfiguration
    * @param caseRepairList    
    * @return List<Case>       
    */
 /*   
  public static List<Case> listCaseRepair(Map<string,XC_CM_Case_Repair_Configuration__mdt> mapCaseRepairConfiguration, List<Case> newListCase){
    List<Case> listCaseRepair =new List<Case>();
      for(case c:newListCase){
        boolean trovato=XC_TR_Case_U_CaseRepair_B2BG.findCMRecord(c, mapCaseRepairConfiguration);  
        if(trovato==true){
            listCaseRepair.add(c);
         }   
        }
       return listCaseRepair;
    }*/

}