/**
* @author Nicola Arrigo - narrigo@deloitte.it
* @description classes. XC_TR_WoMalFunctioning
*/
public with sharing class XC_TR_WoMalFunctioning {
  /**
* @author Nicola Arrigo - narrigo@deloitte.it
*@description classes.onInsertCase
*/
  
  public static void insertCaseFut(List<Case> caseList){
      List<Case> newCase = new List<Case>();
      system.debug('enter onInsertCase');
      Map<id,CaseMilestone> retrieveCaseMilestoneMap=new Map<id,CaseMilestone>();
      //List<id> techAssetListId=new List<id>();
      List<CaseMilestone> liCMList = new List<CaseMilestone>();
      List<Case> caseToCreateWo=new List<case>();
      List<id> assetId=new List<id>();
      List<id> caseIdList=new List<id>();
      system.debug('NewCaseTest ' + caseList );
      Map<string,XC_CM_Case_Repair_Configuration__mdt> mapCaseRepairConfiguration= XC_TR_Case_U_CaseRepair_B2BG.mapCaseRepairConfiguration();
      if(mapCaseRepairConfiguration.values().size()>0){
          Map<string,case> mapCaseB2B=new Map<string,case>();
          for(case c:caseList){
              boolean trovato=XC_TR_Case_U_CaseRepair_B2BG.findCMRecord(c, mapCaseRepairConfiguration);
              system.debug('boolean trovato '+trovato);
              if(( c.XC_Segment__c=='B2B' ||C.XC_Segment__c=='B2G' ) &&
                 (c.XC_TechnicalAsset__c!=null) &&
                 trovato==true){
                     caseToCreateWo.add(c);
                     assetId.add(c.XC_TechnicalAsset__c);
                     caseIdList.add(c.id);
                     mapCaseB2B.put(c.XC_TechnicalAsset__c,c);
                 }
          }
          if(caseIdList.size()==0){
              return;
          }
          List<WorkOrder> listWo=[select id,CaseId from WorkOrder
                                  where ((Status!='Canceled' and status!='Completed') and XC_WorkTypeCategory__c='Malfunctioning' and CaseId IN:caseIdList)
                                 ];
          system.debug('ListWo Size related to the case '+listWo.size());
          Map<Case,WorkOrder> mapWOByCase=mapWOByCase(caseToCreateWo,listWo);
         /* if(caseIdList.size()>0 && Schema.sObjectType.CaseMilestone.isAccessible()){
              liCMList=[SELECT id, Caseid, StartDate, TargetDate, TargetResponseInMins FROM CaseMilestone WHERE Caseid in :caseIdList ORDER BY TargetDate desc];
          }*/
          system.debug('liCMList '+liCMList);   
      
          //check on contract
          if(assetId.size()>0){
              Map<id,Asset> technicalAssetMap=new Map<id,Asset>([select id,XC_Contract__c,AssetServicedById,XC_Address__c,TAM_PartnerContractId__c,TAM_PartnerContract__c,TAM_CommercialAsset__c,
                                                                 TAM_CommercialAsset__r.NE__Order_Config__r.NE__OptyId__c,TAM_IsLogical__c
                                                                 from Asset
                                                                 where id IN:assetId]);
              system.debug('CaseTocreateWo List'+caseToCreateWo);
              
              List<case> caseWithoutWO=checkErrorWO(mapWOByCase,caseToCreateWo);
              system.debug('caseWithoutWO '+caseWithoutWO);
              List<Case> caseNew=checkError(technicalAssetMap,caseWithoutWO) ;
              system.debug('caseNew '+caseNew);
      Set<Id> caseIds = new Set<Id>();
      for(Case c : caseNew){
          caseIds.add(c.id);
            }
            if(caseIds.size()>0){
               //  XC_TR_WoMalFunctioning.onInsertCase(caseIds);
            System.enqueueJob(new  XC_TR_SC040_UTIL_MalFunctioning(caseIds));
            }else{
                return;
            }
          }
      }          
  }

  /**
* @author Nicola Arrigo - narrigo@deloitte.it
*@description classes.onUpdate
*/
  public static void onUpdate(List<Case> newCase,Map<id,Case> oldMapCase){
      system.debug('enter onUpdateCase Malfunctioning');
      List<case> caseListNew=new List<case>();
     // Set<Id>caseIdList=new Set<id>();
      for(case c:newCase){
         if((c.XC_Segment__c=='B2B' ||C.XC_Segment__c=='B2G' ) &&
             (
                (c.XC_TechnicalAsset__c!=oldMapCase.get(c.id).XC_TechnicalAsset__c && c.XC_TechnicalAsset__c!=null) ||
                  c.XC_Subtype__c!=oldMapCase.get(c.id).XC_Subtype__c && c.XC_Subtype__c!=null
              )
                
                ){
                  caseListNew.add(c);
        }
      }
      if(newCase.size()==0){
          return;
      }else{
          insertCaseFut(caseListNew);
      }
      system.debug('List Case '+caseListNew);
  }
  /**
* @author Nicola Arrigo
* @date Creation 2/10/2020
* @description Method mapWobyCase
* @param caseToCreateWo
* @param listWo
* @return mapWOByCase
*/
  public static map<Case,WorkOrder> mapWOByCase( List<Case> caseToCreateWo, List<WorkOrder> listWo){
      map<Case,WorkOrder> mapWoByCase=new map<Case,WorkOrder> ();
      for(case c:caseToCreateWo){
          for(WorkOrder wo:listWo){
              if(c.id==wo.CaseId){
                  mapWOByCase.put(c,wo);
                  break;
              }
          }
      }
      system.debug('mapWOByCase '+mapWOByCase);
      return mapWOByCase;
  }
  /**
* @author Nicola Arrigo
* @date Creation 2/10/2020
* @description Method mapWobyCase
* @param newCase
* @param oldMapCase
* @return caseWithoutWO
*/
  public static List<Case> checkErrorWO( Map<Case,WorkOrder> mapWOByCase,List<Case> caseToCreateWo){
      List<case> caseWithoutWO=new list<Case>();
      for(case c:caseToCreateWo){
          if(mapWOByCase.get(c)!=null){
              system.debug('enter on check error'); 
              c.adderror(Label.XC_CL_CaseErrorMessage_WoMal);
          }else{
              caseWithoutWO.add(c);
          }
      }
      return caseWithoutWO;
  }
  
  public static List<Case> checkError(Map<id,Asset> technicalAssetMap,List<Case> caseToCreateWo){
      List<Case> caseNew=new List<Case>();
      Map<id, AssetRelationship> assetRelationAssetMap = new Map<id, AssetRelationship>();
      system.debug('checkError');
      List<AssetRelationship> assetRelationships = [SELECT id, AssetId, RelatedAssetId, RelatedAsset.TAM_PartnerContract__c  FROM AssetRelationship  WHERE AssetId IN: technicalAssetMap.keySet()  AND RelationshipType = 'Root'];
      for(AssetRelationship ar : assetRelationships){
          assetRelationAssetMap.put(ar.AssetId, ar);
      }
      for(case c:caseToCreateWo){
          if(c.ParentId!=null &&  c.XC_AssetSubType__c == null){
              continue;
          }
          else if((assetRelationAssetMap.get(c.XC_TechnicalAsset__c) != null && assetRelationAssetMap.get(c.XC_TechnicalAsset__c).RelatedAsset.TAM_PartnerContract__c!=null) ||
                  (assetRelationAssetMap.get(c.XC_TechnicalAsset__c) == null && technicalAssetMap.get(c.XC_TechnicalAsset__c).TAM_PartnerContract__c != null) ||
                  c.XC_Force_Work_Order_creation__c==true ||technicalAssetMap.get(c.XC_TechnicalAsset__c).TAM_IsLogical__c == true 
                 ){
                     caseNew.add(c);
                 }else {
                    system.debug('c technical asset error '+c); 
                   c.adderror(Label.XC_CL_CaseErrorMessage_TechnicalAsset);
                 }
      }
      system.debug('case without error '+caseNew);
      return caseNew;
  }
  
  public static void createWO(List<Case> caseNew, Map<id,Asset> technicalAssetMap,Map<id,CaseMilestone> retrieveCaseMilestoneMap){
      Map<String, String> MapAssetPreferredAccountPartner =  createMapAssetPreferredAccountPartner( technicalAssetMap);
      system.debug('enter CreateWO');
      /* List<WorkOrder> createWOList = new List<WorkOrder>();
for(case c:newCase){
workorder wo=new workorder();
wo.AssetId=assetId;
}*/
      /*List<Asset> technicalAsset=[select id,XC_Contract__c,AssetServicedById,XC_Address__c
from Asset
where id IN:assetId];*/
      List<id> addressId=new List<id>();
      List<id> addressIdByCase=new List<id>();
      List<string> segmentCase=new List<string>();
      List<string> streamCase=new List<string>();
      List<string> ListDevName=new List<string>();
      for(case c:caseNew){
          string DevName;
          segmentCase.add(c.XC_LegalEntity__c);
          streamCase.add(c.XC_Segment__c);
          addressId.add(technicalAssetMap.get(c.XC_TechnicalAsset__c).XC_Address__c);
          DevName=c.XC_LegalEntity__c+' '+c.XC_Segment__c;
          ListDevName.add(DevName);
          addressIdByCase.add(c.XC_Address__c);
      }
      system.debug(' ListDevName '+ ListDevName);
      Map<id,XC_Address__c> newMapAddress=new Map<id,XC_Address__c>([select id,XC_City__c,
                                                                     XC_AddressCountry__c,XC_PostalCode__c,XC_Address__c
                                                                     from XC_Address__c
                                                                     where (id IN:addressId or id IN:addressIdByCase) ]);
      // id orgId=UserInfo.getOrganizationId();
      List<XC_CM_LegalEntity_Configuration__mdt>cmList= retrieveCMRTList(segmentCase,streamCase);
      Map<string,string> cmMap=retrieveCMMap(cmList);
      Map<string,string> newMapRecordType=newMapRecordType(ListDevName,cmMap);
      List<WorkOrder> newWOList=new List<WorkOrder>();
      List<Asset> listAssetNew=new List<Asset>();
      List<case>caseListToUpdate=new List<case>();
      for(case c:caseNew){
          workorder wo=new WorkOrder();
          Asset a=technicalAssetMap.get(c.XC_TechnicalAsset__c);
          wo.AssetId=c.XC_TechnicalAsset__c;
          if(c.XC_AssetSubType__c != null){
              wo.XC_ProductSubType__c = c.XC_AssetSubType__c;
          }
          wo.Priority='High';
          system.debug('id TechnicalAsset '+c.XC_TechnicalAsset__c);
          wo.Description=c.Description;
          //wo.city=newMapAddress.get(a.XC_Address__c).XC_City__c;
          a.ContactId=c.contactId;
          listAssetNew.add(a);
          system.debug('ContactId'+' '+c.contactId);
          wo.AccountId=c.AccountId;
          wo.ContactId=c.ContactId;
          //DeAv 08.07.2022 - NR2330 START
          List<String> segmentList = new List<String>{'B2B','B2G'};
          List<String> legEntItaly = new List<String>{'EnelXItalia','EnelSole'};
          if(newMapAddress.get(c.XC_Address__c)!=null && 'XCMOT002'.equalsIgnoreCase(c.Reason) && 
             segmentList.contains(c.XC_Segment__c) && 'eCity'.equalsIgnoreCase(c.XC_BusinessLine__c) && 
             'Italy'.equalsIgnoreCase(c.Country__c) && legEntItaly.contains(c.XC_LegalEntity__c)){
            wo.city=newMapAddress.get(c.XC_Address__c).XC_City__c;
            wo.Country=newMapAddress.get(c.XC_Address__c).XC_AddressCountry__c;
            wo.PostalCode=newMapAddress.get(c.XC_Address__c).XC_PostalCode__c;
            wo.street=newMapAddress.get(c.XC_Address__c).XC_Address__c;
            wo.XC_Address__c=newMapAddress.get(c.XC_Address__c).id;
          }else if(newMapAddress.get(a.XC_Address__c)!=null){          
          //if(newMapAddress.get(a.XC_Address__c)!=null){
          //DeAv 08.07.2022 - NR2330 END
              wo.city=newMapAddress.get(a.XC_Address__c).XC_City__c;
              wo.Country=newMapAddress.get(a.XC_Address__c).XC_AddressCountry__c;
              wo.PostalCode=newMapAddress.get(a.XC_Address__c).XC_PostalCode__c;
              wo.street=newMapAddress.get(a.XC_Address__c).XC_Address__c;
              wo.XC_Address__c=newMapAddress.get(a.XC_Address__c).id;
          }else if(newMapAddress.get(c.XC_Address__c)!=null){
              wo.city=newMapAddress.get(c.XC_Address__c).XC_City__c;
              wo.Country=newMapAddress.get(c.XC_Address__c).XC_AddressCountry__c;
              wo.PostalCode=newMapAddress.get(c.XC_Address__c).XC_PostalCode__c;
              wo.street=newMapAddress.get(c.XC_Address__c).XC_Address__c;
              wo.XC_Address__c=newMapAddress.get(c.XC_Address__c).id;
          }
          string DevNameKey=c.XC_LegalEntity__c+' '+c.XC_Segment__c;
          system.debug('map rt key'+' '+DevNameKey);
          system.debug('rt devName'+' '+cmMap.get(DevNameKey));
          string devNameRT=cmMap.get(DevNameKey);
          system.debug('id rt'+' '+newMapRecordType.get(devNameRT));
          wo.RecordTypeId=newMapRecordType.get(devNameRT);
          wo.CaseId=c.id;
          // wo.XC_DueDate__c=system.today()+1;
          wo.XC_LegalEntity__c=c.XC_LegalEntity__c;
          wo.XC_Segment__c=c.XC_Segment__c;
          if(MapAssetPreferredAccountPartner.get(a.Id)!= null){
              wo.XC_PreferredPartner__c=MapAssetPreferredAccountPartner.get(a.Id);
          }
          system.debug('Partner Preffered '+wo.XC_PreferredPartner__c);
          if(retrieveCaseMilestoneMap.get(c.id)!=null){
              wo.startDate=retrieveCaseMilestoneMap.get(c.id).StartDate;
             // wo.DueDate__c=retrieveCaseMilestoneMap.get(c.id).TargetDate;
             wo.XC_DueDate__c=retrieveCaseMilestoneMap.get(c.id).TargetDate;
              system.debug('DueDateWOwithMilestone '+wo.XC_DueDate__c);
          }else{
              wo.startDate=system.now();
              wo.XC_DueDate__c=wo.DurationInMinutes != null ? Datetime.now().addMinutes(Integer.valueOf(wo.DurationInMinutes)+10) : XC_UTIL_Schedule_D.getDueDate(Datetime.now(), 10);
              system.debug('DueDateWOnoMilestone '+wo.XC_DueDate__c);
          }
          wo.XC_WorkTypeCategory__c='Malfunctioning';
          //Update on case Object
          /* if((c.AssetId!=a.TAM_CommercialAsset__c && a.TAM_CommercialAsset__c!=null )||
(c.XC_Opportunity__c!=a.TAM_CommercialAsset__r.NE__Order_Config__r.NE__OptyId__c && a.TAM_CommercialAsset__r.NE__Order_Config__r.NE__OptyId__c!=null)){
c.AssetId=a.TAM_CommercialAsset__c;
c.XC_Opportunity__c=a.TAM_CommercialAsset__r.NE__Order_Config__r.NE__OptyId__c;
caseListToUpdate.add(c);
}*/
          system.debug('WorkTypeCategoryNic'+' '+ wo.XC_WorkTypeCategory__c);
          newWOList.add(wo);
          system.debug('WorkOrder'+' '+wo);
      }
      if(newWoList.size()>0){
          update listAssetNew;
          // update caseListToUpdate;
          insert newWoList;
          system.debug('PF wo '+newWoList[0].XC_PreferredPartner__c);
          //XC_TR_CreateWoli.createWoli(newWoList);
      }
  }
  public static List<XC_CM_LegalEntity_Configuration__mdt> retrieveCMRTList(List<string> segmentCase,List<string> streamCase){
      id orgId=UserInfo.getOrganizationId();
      
      List<XC_CM_LegalEntity_Configuration__mdt> cmList=[select id,XC_Stream__c, XC_LegalEntity__c, XC_RecordType_WorkOrder__c
                                                         from XC_CM_LegalEntity_Configuration__mdt
                                                         where XC_LegalEntity__c IN:segmentCase and
                                                         XC_Stream__c IN:streamCase and
                                                         XC_OrgId__c=:orgId and
                                                         XC_RecordType_WorkOrder__c!=null
                                                        ];
      system.debug('CM legalEntity Configurations List '+cmList);
      return cmList;
  }
  public static Map<string,string> retrieveCMMap(List<XC_CM_LegalEntity_Configuration__mdt>cmList){
      Map<string,string> retrieveCMMap= new Map<string,string>();
      for(XC_CM_LegalEntity_Configuration__mdt cm:cmList){
          string devName=cm.XC_LegalEntity__c+' '+cm.XC_Stream__c;
          retrieveCMMap.put(devName,cm.XC_RecordType_WorkOrder__c);
      }
      system.debug('Map cm'+' '+retrieveCMMap);
      return retrieveCMMap;
  }
  public static Map<string,string> newMapRecordType(List<string> ListDevName,Map<string,string> cmMap){
      List<string> developerNameList=new List<string>();
      for(string s:ListDevName){
          developerNameList.add(cmMap.get(s));
      }
      List<RecordType> rtList=[select id,DeveloperName from RecordType
                               where DeveloperName IN:developerNameList];
      Map<string,Id> newMapRecordType=new Map<string,Id>();
      for(RecordType rt:rtList){
          newMapRecordType.put(rt.DeveloperName,rt.Id);
      }
      system.debug('Map rt'+' '+ newMapRecordType);
      return newMapRecordType;
  }
  /* public static void createWoMalfunctioning(){

}*/
  /* public static map<id,id> mapTecAssetAddress(List<Asset> technicalAsset){
map<id,id> mapTecAssetAddress=new map<id,id>();
for(Asset a:technicalAsset){
mapTecAssetAddress.put(a.id,a.XC_Contract__c);
}
return mapTecAssetAddress;
}*/
  /**
* @author Nicola Arrigo
* @date Creation 02/09/2020
* @description Method retrieveid
* @param caId
* @return List Case Milestone
*/
  public static Map<id,CaseMilestone> retrieveCaseMilestoneMap(List<CaseMilestone> liCMList,List<Case> caseNew){
      Map<id,CaseMilestone> liCMmap = new Map<id,CaseMilestone>();
      for(case c:caseNew){
          for(CaseMilestone licm: liCMList){
              if(c.id==licm.Caseid){
                  liCMmap.put(licm.Caseid,licm);
                  break;
              }
          }
      }
      return liCMmap;
  }
  /**
* @author Nicola Arrigo
* @date Creation 02/09/2020
* @description Method retrieveid
* @param techAssetListId
*@param mapCaseRepairConfiguration
* @return map<string,Case>
*/
  public static map<string,List<Case>> mapB2CcaseList(List<id> techAssetListId){
      Map<string,List<Case>> mapB2CCaseList=new Map<string,List<Case>>();
      system.debug('List id Asset '+' '+techAssetListId);
      List<Case> caseB2CList=[select id,XC_Asset_B2B__c,ParentId,XC_Subtype__c,SubCause__c,XC_Segment__c,Status,XC_BusinessLine__c,reason
                              from case
                              where
                              XC_Asset_B2B__c IN:techAssetListId and
                              Status!='ESTA007' and
                              Status!='ESTA008' and
                              // reason='XCMOT002' and
                              // XC_Subtype__c ='XC199' and
                              // SubCause__c ='ATCL003'and
                              XC_Segment__c='B2C' and
                              ParentId=null
                             ];
      system.debug('CaseB2cList '+CaseB2cList);
      if(caseB2CList.size()>0){
          for(id techId:techAssetListId){
              List<Case> caseList=new List<case>();
              for(case c:caseB2CList){
                  /* string s;
if(!string.isBlank(c.XC_Subtype__c)){
s=c.reason+'_'+c.SubCause__c+'_'+c.XC_Subtype__c;
}else if(string.isBlank(c.XC_Subtype__c)){
s=c.reason+'_'+c.SubCause__c;
}*/
                  if(techId==c.XC_Asset_B2B__c){
                      // String.isBlank(c.ParentId)){
                      caseList.add(c);
                      SYSTEM.DEBUG('Case B2C '+c);
                  }
              }
              mapB2CcaseList.put(techId,caseList);
              system.debug('Map Case B2C '+mapB2CcaseList);
          }
      }
      return mapB2CcaseList;
  }
  public static void relateParent( List<Case> caseNew,map<string,List<Case>> mapB2CcaseList){
      List<case> caseToBeUpdated=new List<Case>();
      for(case c:caseNew){
          if(mapB2CcaseList.get(c.XC_TechnicalAsset__c).size()>0){
              List<Case> caseList=mapB2CcaseList.get(c.XC_TechnicalAsset__c);
              for(case cB2C:caseList){
                  if( c.XC_BusinessLine__c==cB2C.XC_BusinessLine__c &&
                     c.reason==cB2C.reason &&
                     c.SubCause__c==cB2C.SubCause__c &&
                     ((c.XC_Subtype__c==cB2C.XC_Subtype__c)||
                      (string.isBlank(c.XC_Subtype__c) && string.isBlank(cB2C.XC_Subtype__c))) ){
                          cB2C.ParentId=c.id;
                          caseToBeUpdated.add(cB2C);
                      }
              }
          }
      }
      update caseToBeUpdated;
  }
  /**
* @author Nicola Arrigo
* @date Creation 28/09/2020
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
return mapCaseRepairConfiguration;
} */
  /**
* @author Nicola Arrigo
* @date Creation 1/10/2020
* @description Method onInsertSerialNumber
* @param newCase
*/
  public static void onInsertSerialNumber(List<Case> newCase){
      List<id> technicalAssetId=new List<id>();
      List<case> newListCase=new List<Case>();
      //Map<case,id> assetIdMap=new Map<case,id>();
      for(case c:newCase){
          if(( c.XC_Segment__c=='B2B' ||C.XC_Segment__c=='B2G' ) &&
             (c.XC_TechnicalAsset__c!=null)){
                 technicalAssetId.add(c.XC_TechnicalAsset__c);
                 newListCase.add(c);
                 // assetIdMap.put(c,c.XC_TechnicalAsset__c);
             }else if(c.XC_Segment__c=='B2C' &&
                      c.XC_Asset_B2B__c!=null ){
                          technicalAssetId.add(c.XC_Asset_B2B__c);
                          newListCase.add(c);
                          // assetIdMap.put(c,c.XC_Asset_B2B__c);
                      }
      }
      if(technicalAssetId.size()>0){
          Map<id,Asset> technicalAssetMap=new Map<id,Asset>([select id,XC_Contract__c,AssetServicedById,XC_Address__c,TAM_PartnerContractId__c,TAM_PartnerContract__c,SerialNumber,TAM_CommercialAsset__c,
                                                             TAM_CommercialAsset__r.AccountId,TAM_CommercialAsset__r.NE__Order_Config__r.NE__OptyId__c
                                                             from Asset
                                                             where id IN:technicalAssetId]);
          for(case c:newListCase){
              asset a=technicalAssetMap.get(c.XC_TechnicalAsset__c);
              if( c.XC_Segment__c=='B2B' ||C.XC_Segment__c=='B2G' ){
                  c.XC_SerialNumber__c=technicalAssetMap.get(c.XC_TechnicalAsset__c).SerialNumber;
                  system.debug('AccountIdCommericalAsset '+a.TAM_CommercialAsset__r.AccountId);
                  if(c.AssetId!=a.TAM_CommercialAsset__c &&
                     a.TAM_CommercialAsset__c!=null &&
                     c.AccountId==a.TAM_CommercialAsset__r.AccountId ){
                         c.AssetId=a.TAM_CommercialAsset__c;
                     }
                  if(
                      (c.XC_Opportunity__c!=a.TAM_CommercialAsset__r.NE__Order_Config__r.NE__OptyId__c && a.TAM_CommercialAsset__r.NE__Order_Config__r.NE__OptyId__c!=null)){
                          //c.AssetId=a.TAM_CommercialAsset__c;
                          c.XC_Opportunity__c=a.TAM_CommercialAsset__r.NE__Order_Config__r.NE__OptyId__c;
                          //caseListToUpdate.add(c);
                      }
              }else if(c.XC_Segment__c=='B2C'){
                  c.XC_SerialNumber__c=technicalAssetMap.get(c.XC_Asset_B2B__c).SerialNumber;
              }
              
          }
      }
  }
  /**
* @author Nicola Arrigo
* @date Creation 1/10/2020
* @description Method onInsertSerialNumber
* @param newCase
*@param oldMapCase
*/
  public static void onUpdateSerialNumber(List<Case> newCase,Map<id,Case> oldMapCase){
      List<case> caseWithAsset=new List<Case>();
      List<Case> caseWithNoAsset=new List<Case>();
      List<id>asssetIdList=new List<id>();
      for(case c:newCase){
          if(( c.XC_Segment__c=='B2B' ||C.XC_Segment__c=='B2G' ) &&
             c.XC_TechnicalAsset__c!=oldMapCase.get(c.id).XC_TechnicalAsset__c) {
                 if(c.XC_TechnicalAsset__c!=null){
                     caseWithAsset.add(c);
                 }else if(c.XC_TechnicalAsset__c==null){
                     caseWithNoAsset.add(c);
                 }
                 // asssetIdList.add(c.XC_TechnicalAsset__c);
             }else if(c.XC_Segment__c=='B2C' && c.XC_Asset_B2B__c!=oldMapCase.get(c.id).XC_Asset_B2B__c){
                 if(c.XC_Asset_B2B__c!=null){
                     caseWithAsset.add(c);
                 }else if(c.XC_Asset_B2B__c==null){
                     caseWithNoAsset.add(c);
                 }
             }
      }
      if(caseWithAsset.size()>0){
          onInsertSerialNumber(caseWithAsset);
      }
      if(caseWithNoAsset.size()>0){
          for(case c:caseWithNoAsset){
              c.XC_SerialNumber__c='';
          }
      }
      
  }
  /**
* @author Andrea Di Cicco
* @date Creation 08/03/2021
* @description This method is used to create a MAP of technical asset and Preferred Partner getting the information from the passive contract of the Network
* @param technicalAssetMap Map of the technical asset used to create the malfunctioning workorder
*/
  public static Map<String, String> createMapAssetPreferredAccountPartner(Map<id,Asset> technicalAssetMap){
    List<AssetRelationship> assetRelationShips = [SELECT id, AssetId, RelatedAssetId, RelatedAsset.TAM_PartnerContract__r.XC_ContractAccount__c, RelatedAsset.AssetServicedById  FROM AssetRelationship  WHERE AssetId  IN: technicalAssetMap.keySet()  AND RelationshipType = 'Root']; 
    Map<String, String> mapAssetPreferredAccountPartner = new Map<String, String>();

    for(Asset a : technicalAssetMap.values()){
        for(AssetRelationship relation : AssetRelationships){
            if(relation.AssetId == a.id && relation.RelatedAsset.AssetServicedById != null){
                mapAssetPreferredAccountPartner.put(a.id, relation.RelatedAsset.AssetServicedById);
                break;
            }
        }
        if(mapAssetPreferredAccountPartner.get(a.id) == null){
            mapAssetPreferredAccountPartner.put(a.id, a.AssetServicedById);
        }
    }
    return mapAssetPreferredAccountPartner;

  }
  
}