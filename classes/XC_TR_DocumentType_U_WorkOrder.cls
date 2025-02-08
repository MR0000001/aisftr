/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 04/05/2021
* @date Modification 
* @description XC_TR_DocumentType_U_WorkOrder – Check on document type records related to work orders
*/ 
public without sharing class XC_TR_DocumentType_U_WorkOrder {

      /**
      * @description 
      * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 04/05/2021
      * @param listNew 
      **/
      public static void onInsert(List<XC_DocumentType__c> listNew) {
            List<XC_DocumentType__c> docTypeWithWOinfoList = new List<XC_DocumentType__c>();
            List<String> woIdList = checkWorkOrder(listNew);
            if(woIdList.isEmpty()){
                  return;
            }
            List<XC_DocumentType__c> docTypesList = getDocumentTypeOnWO(woIdList);
            for(XC_DocumentType__c documentType : docTypesList){
                  if(documentType.XC_WorkOrder__r.XC_WasteDisposalBlock__c && documentType.XC_WorkOrder__r.XC_WasteDisposal__c){
                        docTypeWithWOinfoList.add(documentType);
                  } 
            }
            if(docTypeWithWOinfoList.isEmpty()){
                  return;
            }
            Map<String, List<String>> legEntitySegmentCategoriesListMap = getDocumentNeededFromCMDT(docTypeWithWOinfoList);
            Map<String, List<String>> mapWOIdDocumentCategories = checkCategories(docTypeWithWOinfoList);
            Set<String> woIdsToUpdate = verifyWOWIthAllDocuments(docTypeWithWOinfoList, legEntitySegmentCategoriesListMap, mapWOIdDocumentCategories);
            List<WorkOrder> woToUpdateList = new List<WorkOrder>();
            for(String woId : woIdsToUpdate){
                  WorkOrder wo = new WorkOrder(Id = woId, XC_WasteDisposalDocumentLoaded__c = true);
                  woToUpdateList.add(wo);
            }
            if(!woToUpdateList.isEmpty()){
                  XC_UTIL_Sobject.updateListRecords(woToUpdateList);
            }
      } 

      /**
      * @description 
      * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 04/05/2021 
      * @param listNew 
      * @return List<XC_DocumentType__c> 
      **/
      private static List<String> checkWorkOrder(List<XC_DocumentType__c> listNew){
            List<String> woIdList = new List<String>();
            for(XC_DocumentType__c docType : listNew){
                  if(!String.isEmpty(docType.XC_WorkOrder__c) ){
                        woIdList.add(docType.XC_WorkOrder__c);
                  }
            }
            return woIdList;
      }

      /**
      * @description 
      * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 04/05/2021
      * @param woIdList 
      * @return List<XC_DocumentType__c>
      **/
      private static List<XC_DocumentType__c> getDocumentTypeOnWO(List<String> woIdList){
            
            List<XC_DocumentType__c> documentTypeList = new List<XC_DocumentType__c>([SELECT Id,XC_WorkOrder__c, Category__c, XC_WorkOrder__r.XC_WasteDisposalBlock__c, XC_WorkOrder__r.XC_WasteDisposal__c,
                                                                                    XC_WorkOrder__r.XC_LegalEntity__c, XC_WorkOrder__r.XC_Segment__c
                                                                                    FROM XC_DocumentType__c
                                                                                    WHERE XC_WorkOrder__c IN: woIdList]);
            return documentTypeList;
      }

      /**
      * @description 
      * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 04/05/2021
      * @param docTypeWithWOinfoList 
      **/
      private static Map<String, List<String>> checkCategories(List<XC_DocumentType__c> docTypeWithWOinfoList){
            Map<String, List<String>> woIdDocumentCategoryMap = new Map<String, List<String>>();
            for(XC_DocumentType__c documentType : docTypeWithWOinfoList){
                  if(!woIdDocumentCategoryMap.containsKey(documentType.XC_WorkOrder__c)){
                        woIdDocumentCategoryMap.put(documentType.XC_WorkOrder__c, new List<String>());
                  }
                  woIdDocumentCategoryMap.get(documentType.XC_WorkOrder__c).add(documentType.Category__c);
            }
            return woIdDocumentCategoryMap;
      }

      /**
      * @description 
      * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 04/05/2021
      * @param docTypeWithWOinfoList 
      * @return Map<String, List<String>> 
      **/
      private static Map<String, List<String>> getDocumentNeededFromCMDT(List<XC_DocumentType__c> docTypeWithWOinfoList){
            Map<String, List<String>> legEntitySegmentCategoriesListMap = new  Map<String, List<String>>();
            List<String> legalEntityList = new List<String>();
            List<String> segmentList = new List<String>();
            for(XC_DocumentType__c docType : docTypeWithWOinfoList){
                  legalEntityList.add(docType.XC_WorkOrder__r.XC_LegalEntity__c);
                  segmentList.add(docType.XC_WorkOrder__r.XC_Segment__c);
            }
            List<XC_CM_CountryLegalEntityAssociation__mdt> countryLegalEntityAssociationList = new List<XC_CM_CountryLegalEntityAssociation__mdt>([SELECT Id,  XC_WorkOrderWasteDisposalBlock__c, XC_LegalEntity__c, XC_Stream__c
                                                                                                                                                FROM XC_CM_CountryLegalEntityAssociation__mdt
                                                                                                                                                WHERE XC_LegalEntity__c IN: legalEntityList
                                                                                                                                                AND XC_Stream__c IN: segmentList
                                                                                                                                                AND XC_WorkOrderWasteDisposalBlock__c = true]);
            /*for(XC_CM_CountryLegalEntityAssociation__mdt clea : countryLegalEntityAssociationList){
                  if(String.isEmpty(clea.XC_WorkOrderWasteDisposalBlockCategories__c)){
                        continue;
                  }
                  if(clea.XC_WorkOrderWasteDisposalBlockCategories__c.contains(',')){
                        legEntitySegmentCategoriesListMap.put(clea.XC_LegalEntity__c + clea.XC_Stream__c, clea.XC_WorkOrderWasteDisposalBlockCategories__c.split(','));
                  } else {
                        legEntitySegmentCategoriesListMap.put(clea.XC_LegalEntity__c + clea.XC_Stream__c, new List<String>{clea.XC_WorkOrderWasteDisposalBlockCategories__c});
                  }
            }*/
            return legEntitySegmentCategoriesListMap;
      }


      /**
      * @description 
      * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 04/05/2021
      * @param docTypeWithWOinfoList 
      * @param legEntitySegmentCategoriesListMap 
      * @param mapWOIdDocumentCategories 
      * @return Set<String> 
      **/
      private static Set<String> verifyWOWIthAllDocuments(List<XC_DocumentType__c> docTypeWithWOinfoList, Map<String, List<String>> legEntitySegmentCategoriesListMap, Map<String, List<String>> mapWOIdDocumentCategories){
            Set<String> woIdsToUpdate = new Set<String>();
            for(XC_DocumentType__c docType : docTypeWithWOinfoList){
                  Boolean found = false;
                  String key = docType.XC_WorkOrder__r.XC_LegalEntity__c + docType.XC_WorkOrder__r.XC_Segment__c;
                  if(legEntitySegmentCategoriesListMap.containsKey(key)){
                        for(String docCategory : legEntitySegmentCategoriesListMap.get(key)){
                              if(mapWOIdDocumentCategories.containsKey(docType.XC_WorkOrder__c) && mapWOIdDocumentCategories.get(docType.XC_WorkOrder__c).contains(docCategory)){
                                    found = true;
                              } else {
                                    found = false;
                                    break;
                              }
                        }
                  }
                  if(found){
                        woIdsToUpdate.add(docType.XC_WorkOrder__c);
                  }
            }
            return woIdsToUpdate;
      }
}