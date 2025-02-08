/**
* @author Nicola Arrigo - narrigo@deloitte.it
* @description classes.XC_TR_U_CaseMalfunctioningB2C
*/
public with sharing class XC_TR_U_CaseMalfunctioningB2C {
   /**
* @author Nicola Arrigo - narrigo@deloitte.it 
*@description classes.onInsertCase
*/
    public static void onInsertCase(List<Case> newCase){
        List<id> assetId=new List<id>();
        List<Case>newListCase=new List<Case>();
        List<XC_CM_Case_Repair_Configuration__mdt> caseRepairList=[select id,XC_Reason__c, XC_Sub_Cause__c, XC_Sub_Type__c,XC_B2BWONeeded__c from XC_CM_Case_Repair_Configuration__mdt where XC_B2BWONeeded__c=true];
        if(caseRepairList.size()>0){
        Map<string,XC_CM_Case_Repair_Configuration__mdt> mapCaseRepairConfiguration=mapCaseRepairConfiguration(caseRepairList);
        List<string> listBusinessLine=new List<string>();
        for(case c:newCase){
           /* string s;
            if(!string.isBlank(c.XC_Subtype__c)){
              s=c.reason+'_'+c.SubCause__c+'_'+c.XC_Subtype__c;
            }else if(string.isBlank(c.XC_Subtype__c)){
               s=c.reason+'_'+c.SubCause__c;
            }*/
            if(//c.reason=='XCMOT002' && 
                //c.XC_Subtype__c =='XC199' && 
                //c.SubCause__c =='ATCL003' &&
               // mapCaseRepairConfiguration.get(s)!=null &&
                ( c.XC_Segment__c=='B2C' ) &&
                (c.XC_Asset_B2B__c!=null)){
                    assetId.add(c.XC_Asset_B2B__c);
                    listBusinessLine.add(c.XC_BusinessLine__c);
                    newListCase.add(c);
             }
        }
        if(newListCase.size()>0){
            List<Case> caseB2BList=createnewListB2B(assetId,listBusinessLine);
            system.debug('List B2B '+caseB2BList);
            if(caseB2BList.size()>0){
                assignParentId(newListCase,caseB2BList);
            }
           /* for(case c:newListCase){
                if(mapB2BCase.get(c.XC_Asset_B2B__c)!=null){
                    case cB2B=mapB2BCase.get(c.XC_Asset_B2B__c);
                    c.ParentId=c.id;
                }
            }*/            
        }
     }  
    }
      /**
        * @author Nicola Arrigo - narrigo@deloitte.it 
        *@description classes.onUpdateCase
        */
    public static void onUpdateCase(List<Case> newCase,Map<id,Case> oldMapCase){
        List<id> assetId=new List<id>();
        List<Case>newListCase=new List<Case>();
        //List<XC_CM_Case_Repair_Configuration__mdt> caseRepairList=[select id,XC_Reason__c, XC_Sub_Cause__c, XC_Sub_Type__c,XC_B2BWONeeded__c from XC_CM_Case_Repair_Configuration__mdt where XC_B2BWONeeded__c=true];
        for(case c:newCase){
            if(//c.reason=='XCMOT002' && 
                //c.XC_Subtype__c =='XC199' && 
                //c.SubCause__c =='ATCL003' && 
                ( c.XC_Segment__c=='B2C' ) &&
                   c.XC_Asset_B2B__c!=oldMapCase.GET(c.id).XC_Asset_B2B__c &&
                   c.XC_Asset_B2B__c!=null){
                    assetId.add(c.XC_Asset_B2B__c);
                    newListCase.add(c);
             }/*else if(( c.XC_Segment__c=='B2C' ) &&
                        c.XC_Asset_B2B__c!=oldMapCase.GET(c.id).XC_Asset_B2B__c &&
                        c.XC_Asset_B2B__c==null){
                        c.ParentId=null;    
                        }*/
        }
        if(newListCase.size()>0){
           /* Map<string,case> mapB2BCase=createNewMap(assetId);
            if(mapB2BCase.values().size()>0){
                assignParentId(newListCase,mapB2BCase);*/
                onInsertCase(newListCase);      
           /* for(case c:newListCase){
                if(mapB2BCase.get(c.XC_Asset_B2B__c)!=null){
                    case cB2B=mapB2BCase.get(c.XC_Asset_B2B__c);
                    c.ParentId=c.id;
                }
            }*/            
        }
    }
   /** 
    * @author Nicola Arrigo
    * @date Creation 19/09/2020
    * @description Method createNewMap  
    * @param assetId  
    * @param listBusinessLine  
    * @return map<string,Case>       
    */
    public static List<Case> createnewListB2B(List<id> assetId, List<string> listBusinessLine){
       system.debug('enter createNewMap');
       system.debug('newListAssetId '+assetId);
        Map<string,case> mapB2BCase=new  Map<string,case>();
       /* List<Case> caseB2BList=[select id,XC_Subtype__c,SubCause__c from case
                               where reason='XCMOT002' and
                               XC_Subtype__c ='XC199' and 
                               SubCause__c ='ATCL003'and
                             SubCause__c ='ATCL003'and
                               ( XC_Segment__c='B2B' OR  XC_Segment__c='B2G') and
                               c.XC_TechnicalAsset__c IN:assetId and
                               Status!='ESTA007' and 
                               Status!='ESTA008'
                               ];*/
        List<Case> caseB2BList=[select id,XC_Subtype__c,SubCause__c, XC_Segment__c,XC_TechnicalAsset__c,Status,ParentId,reason,XC_BusinessLine__c from case
                                    where 
                                    //reason='XCMOT002' and
                                    //XC_Subtype__c ='XC199' and 
                                    //SubCause__c ='ATCL003'and
                                ( XC_Segment__c='B2B' OR  XC_Segment__c='B2G') and
                                 XC_TechnicalAsset__c IN:assetId and 
                                 XC_BusinessLine__c IN:listBusinessLine and
                                 Status!='ESTA007' and 
                               Status!='ESTA008' 
                               order by createddate asc];
   
        system.debug('List Case B2B '+caseB2BList);                                              
        return caseB2BList;                       
    }
     /** 
    * @author Nicola Arrigo
    * @date Creation 19/09/2020
    * @description Method assignParentId  
    * @param newListCase
    * @param  mapB2BCase     
    */
    public static void assignParentId(List<Case>newListCase, List<Case> caseB2BList){
       system.debug('enter assignParentId');
      /*
       for(case c:newListCase){ 
                if(mapB2BCase.get(c.XC_Asset_B2B__c)!=null){
                    system.debug('caseB2B '+mapB2BCase.get(c.XC_Asset_B2B__c));                  
                    case cB2B=mapB2BCase.get(c.XC_Asset_B2B__c);
                    c.ParentId=cB2B.id;
                }
        }*/
        for(case cB2C:newListCase){
            for(case cB2B:caseB2BList){
                if(
                    cB2B.XC_BusinessLine__c ==cB2C.XC_BusinessLine__c &&
                    cB2B.XC_TechnicalAsset__c==cB2C.XC_Asset_B2B__c &&
                    cB2B.reason==cB2C.reason &&
                    cB2B.SubCause__c==cB2C.SubCause__c &&
                    ((cB2B.XC_Subtype__c==cB2C.XC_Subtype__c)||
                    (string.isBlank(cB2B.XC_Subtype__c) && string.isBlank(cB2C.XC_Subtype__c)) 
                    )
                ){
                    cB2C.parentId=cB2B.id;
					if(cB2B.Status=='ESTA002'){
                        system.debug('parent case in pending status');
                        cB2C.Status='ESTA002';
                    }if(cB2B.isStopped==true){
                        cB2C.isStopped=true;
                    }
                    break;
                }
            }
        }
        system.debug('Parent Id '+newListCase[0].ParentId);
    }
  /** 
    * @author Nicola Arrigo
    * @date Creation 28/09/2020
    * @description Method retrieveid  
    * @param caseRepairList    
    * @return Map<id,XC_CM_Case_Repair_Configuration__mdt>       
    */
  public static Map<string,XC_CM_Case_Repair_Configuration__mdt> mapCaseRepairConfiguration(List<XC_CM_Case_Repair_Configuration__mdt> caseRepairList){
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
    return mapCaseRepairConfiguration;
  }
}