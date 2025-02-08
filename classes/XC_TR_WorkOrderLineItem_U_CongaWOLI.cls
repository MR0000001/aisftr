/**
* @author Daniele Lico
* @date Creation 2/07/2020
* @date Modification -
* @description XC_TR_WorkOrderLineItem_U_CongaWOLI
*/			   

public without sharing class XC_TR_WorkOrderLineItem_U_CongaWOLI {

    /*   public static void populateWoliField(List<WorkOrderLineItem> listNew, Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){ 
           List<NE__Order__c> listWoliChanged = XC_UTIL_SObject.getListChanged(new List<String>{'XC_LCLDocumentRequired__c'}, mapOldS, mapNewS);
               if(!listWoliChanged.isEmpty()){
                   congaTemplateIdForWoli(listNew); 
                   }
          }    */
           /**
            * @author Daniele Lico - dlico@deloitte.it 
            * @date Creation 2/07/2020
            * @description Method to insert Id Conga Templete
            * @param listContract List WorkOrderLineItem Instance of the Trigger handler
           */
       
           public static void congaTemplateIdForWoli (List<WorkOrderLineItem> listWoli){
       
              
       
               
               Set<String> sohoType = new Set<String>();
               Set<String> country = new Set<String>();
               Set<String> legalEntity = new Set<String>();
               Set<Id> idWoli = new Set<Id> ();
               Map<Id,WorkOrderLineItem> woliMap = new Map<Id,WorkOrderLineItem> ([SELECT Id,WorkOrder.XC_Segment__c, WorkOrder.XC_LegalEntity__c,WorkOrder.XC_Country__c 
                                                                                       FROM WorkOrderLineItem WHERE id in: listWoli]);
                                                    
                                                    
                                                    
                                                    
                                                    
               for(WorkOrderLineItem w1: woliMap.values()){
                  
                   legalEntity.add(w1.WorkOrder.XC_LegalEntity__c);
                   sohoType.add(w1.WorkOrder.XC_Segment__c);           
                   country.add(w1.WorkOrder.XC_Country__c);          
                   idWoli.add(w1.id);
                      
               }
       
              
       
               List<XC_CongaTemplateMapping__c> ctM = new List<XC_CongaTemplateMapping__c>();
               if(Schema.sObjectType.XC_CongaTemplateMapping__c.isAccessible()){
                   ctM = [ Select id,XC_CongaIdTemplate__c,Name,XC_AccountType__c,XC_IsNDA__c,XC_CongaQuery__c
                           from XC_CongaTemplateMapping__c 
                           where XC_AccountType__c in: sohoType and XC_Country__c in: country 
                             and XC_PartnerEngagement__c= true and XC_LCL__c = true ];
                           System.debug('DL@@@ in cmt' + ctM );
               }
       
               
               String templateId;
               String congaTemplateId;
               for(WorkOrderLineItem w1:listWoli){
                   for(XC_CongaTemplateMapping__c ctM1: ctM){
                      
                               congaTemplateId = ctM1.XC_CongaQuery__c;
                               templateId = ctM1.XC_CongaIdTemplate__c;
                         
                               String concatenatedOrder=String.valueOf(idWoli);
                               concatenatedOrder = concatenatedOrder.removeEnd('}').removeStart('{');
                               
                               String staticApi = w1.XC_CongaStaticAPI__c;
                               String dynamicApi = '&Id=' + concatenatedOrder + '&QueryId=' +  congaTemplateId + '&TemplateId=' +  templateId // ON ORDERITEM: '&Id=' + quoteItemId + '&AttachmentParentID=' + orderId +
                                   + '&OFN=Doc LCL - LCL_MANAGEMENT' //CR729 05.07.2022
   
                                   + '&DefaultPDF=1&qmode=SalesforceFile&WordStripIfs=1'; //CR759
   
                               w1.XC_CongaDynamicAPI__c = staticApi + dynamicApi;
                               w1.XC_RequiredPurchaseOrderDocument__c = true;
                               
                       
                           break;
                           
                                    
               }
           }
       
           
       //        XC_UTIL_Sobject.updateListRecords(listWoli);  
                       
             
           }
   
   
            public static void congaTemplateIdForWoliModArt26 (List<WorkOrderLineItem> listWoli){
   
   
   
   
               Set<String> sohoType = new Set<String>();
               Set<String> country = new Set<String>();
               Set<String> legalEntity = new Set<String>();
               Set<Id> idWoli = new Set<Id> ();
               Map<Id,WorkOrderLineItem> woliMap = new Map<Id,WorkOrderLineItem> ([SELECT Id,WorkOrder.XC_Segment__c, WorkOrder.XC_LegalEntity__c,WorkOrder.XC_Country__c 
                                                                                       FROM WorkOrderLineItem WHERE id in: listWoli]);
                                                    
               System.debug('WOLI ' + listWoli );                                     
                                                    
                                                    
                                                    
               for(WorkOrderLineItem w1: woliMap.values()){
                  
                   legalEntity.add(w1.WorkOrder.XC_LegalEntity__c);
                   sohoType.add(w1.WorkOrder.XC_Segment__c);           
                   country.add(w1.WorkOrder.XC_Country__c);          
                   idWoli.add(w1.id);
                      
               }
               
              
       
               List<XC_CongaTemplateMapping__c> ctM = new List<XC_CongaTemplateMapping__c>();
               if(Schema.sObjectType.XC_CongaTemplateMapping__c.isAccessible()){
                   ctM = [SELECT id,XC_CongaIdTemplate__c,Name,XC_AccountType__c,XC_IsNDA__c,XC_CongaQuery__c
                           FROM XC_CongaTemplateMapping__c 
                           WHERE XC_AccountType__c IN: sohoType AND 
                                 XC_Country__c IN: country AND 
                                 XC_PartnerEngagement__c= true AND 
                                 XC_LCL__c = false AND 
                                 XC_DocumentType__c = null];
                           System.debug('DL@@@ in cmt' + ctM );
               }
       
               
               String templateId;
               String congaTemplateId;
               for(WorkOrderLineItem w1:listWoli){
                   for(XC_CongaTemplateMapping__c ctM1: ctM){
                      
                               congaTemplateId = ctM1.XC_CongaQuery__c;
                               templateId = ctM1.XC_CongaIdTemplate__c;
                               System.debug(templateId) ;
                         
                               String concatenatedOrder=String.valueOf(idWoli);
                               concatenatedOrder = concatenatedOrder.removeEnd('}').removeStart('{');
                               
                               String staticApi = w1.XC_CongaStaticAPI__c;
                               String dynamicApi = '&Id=' + concatenatedOrder + '&QueryId=' +  congaTemplateId + '&TemplateId=' +  templateId 
                                   + '&OFN=Doc ModArt 26 - MOD_ART_26' //CR729 01.07.2022
                                   + '&DefaultPDF=1&qmode=SalesforceFile&WordStripIfs=1'; //CR759 vdb
                               w1.XC_CongaDynamicAPI__c = staticApi + dynamicApi;
                               w1.XC_RequiredPurchaseOrderDocument__c = true;
                               
                       
                           break;
                           
                                    
               }
           }
       
           
               //      XC_UTIL_Sobject.updateListRecords(listWoli);  
                      
                       
           }
       
           /**
          * @author Saikat Garai (saikat.garai@accenture.com)
          * @description congaTemplateIdForWoliChiusuraLavori method
          * @date  Jan 05, 2022
          * @param List<WorkOrderLineItem> listWoli
          *
          */
           public static void congaTemplateIdForWoliChiusuraLavori (List<WorkOrderLineItem> listWoli){
   
               Set<String> sohoType = new Set<String>();
               Set<String> country = new Set<String>();
               Set<String> legalEntity = new Set<String>();
               Set<Id> idWoli = new Set<Id> ();
               Map<Id,WorkOrderLineItem> woliMap = new Map<Id,WorkOrderLineItem> ([SELECT Id,WorkOrder.XC_Segment__c, WorkOrder.XC_LegalEntity__c,WorkOrder.XC_Country__c 
                                                                                       FROM WorkOrderLineItem WHERE id in: listWoli]);
   
               for(WorkOrderLineItem w1: woliMap.values()){
                   legalEntity.add(w1.WorkOrder.XC_LegalEntity__c);
                   sohoType.add(w1.WorkOrder.XC_Segment__c);
                   country.add(w1.WorkOrder.XC_Country__c);
                   idWoli.add(w1.id);
                   system.debug('sohotypeRaf '+ sohoType +'countryRAF' + country);
               }
   
               List<XC_CongaTemplateMapping__c> ctM = new List<XC_CongaTemplateMapping__c>();
               if(Schema.sObjectType.XC_CongaTemplateMapping__c.isAccessible()){
                   ctM = [ SELECT id,XC_CongaIdTemplate__c,Name,XC_AccountType__c,XC_IsNDA__c,XC_CongaQuery__c
                           FROM XC_CongaTemplateMapping__c
                           WHERE XC_AccountType__c in: sohoType and XC_Country__c in: country
                           AND XC_PartnerEngagement__c= true AND XC_LCL__c = false  AND XC_DocumentType__c = 'Chiusura Lavori' ];
                           System.debug('LCL@@@ in cmt' + ctM );
               }
   
               String templateId;
               String congaTemplateId;
               for(WorkOrderLineItem w1:listWoli){
                   for(XC_CongaTemplateMapping__c ctM1: ctM){
                               congaTemplateId = ctM1.XC_CongaQuery__c;
                               templateId = ctM1.XC_CongaIdTemplate__c;
   
                               String concatenatedOrder=String.valueOf(idWoli);
                               concatenatedOrder = concatenatedOrder.removeEnd('}').removeStart('{');
   
                               String staticApi = w1.XC_CongaStaticAPI__c;
                               String dynamicApi = '&Id=' + concatenatedOrder + '&QueryId=' +  congaTemplateId + '&TemplateId=' +  templateId // ON ORDERITEM: '&Id=' + quoteItemId + '&AttachmentParentID=' + orderId +
                                   + '&OFN=Doc ' + Label.XC_CL_ChiusuraLavori + ' - CLOSURE' //CR729 5-07-22
                                   + '&DefaultPDF=0&qmode=SalesforceFile&WordStripIfs=1';
                               w1.XC_CongaDynamicAPI__c = staticApi + dynamicApi;
                               System.debug('GS@@@ dynamic API' + dynamicApi );
                               w1.XC_RequiredPurchaseOrderDocument__c = true;
                               w1.XC_DeclarationDateEndWork__c	= Date.today();
   
                           break;
                   }
               }
               //XC_UTIL_Sobject.updateListRecords(listWoli);
           }
   
           //[CR729 start sooraji.sajan@accenture.com 10.05.2022]
       public static void congaTemplateIdForWoliSospensione (List<WorkOrderLineItem> listWoli){
   
           Set<String> sohoType = new Set<String>();
           Set<String> country = new Set<String>();
           Set<String> legalEntity = new Set<String>();
           Set<Id> idWoli = new Set<Id> ();
           Map<Id,WorkOrderLineItem> woliMap = new Map<Id,WorkOrderLineItem> ([SELECT Id,WorkOrder.XC_Segment__c, WorkOrder.XC_LegalEntity__c,WorkOrder.XC_Country__c 
                                                                                   FROM WorkOrderLineItem WHERE id in: listWoli]);
   
           for(WorkOrderLineItem w1: woliMap.values()){
               legalEntity.add(w1.WorkOrder.XC_LegalEntity__c);
               sohoType.add(w1.WorkOrder.XC_Segment__c);
               country.add(w1.WorkOrder.XC_Country__c);
               idWoli.add(w1.id);
               system.debug('sohotypeRaf '+ sohoType +'countryRAF' + country);
           }
   
           List<XC_CongaTemplateMapping__c> ctM = new List<XC_CongaTemplateMapping__c>();
           if(Schema.sObjectType.XC_CongaTemplateMapping__c.isAccessible()){
               ctM = [ SELECT id,XC_CongaIdTemplate__c,Name,XC_AccountType__c,XC_IsNDA__c,XC_CongaQuery__c
                       FROM XC_CongaTemplateMapping__c
                       WHERE XC_AccountType__c in: sohoType and XC_Country__c in: country
                       AND XC_PartnerEngagement__c= true AND XC_DocumentType__c = 'Sospensione' ];
                       System.debug('LCL@@@ in cmt' + ctM );
           }
   
           String templateId;
           String congaTemplateId;
           for(WorkOrderLineItem w1:listWoli){
               for(XC_CongaTemplateMapping__c ctM1: ctM){
                           congaTemplateId = ctM1.XC_CongaQuery__c;
                           templateId = ctM1.XC_CongaIdTemplate__c;
   
                           String concatenatedOrder=String.valueOf(idWoli);
                           concatenatedOrder = concatenatedOrder.removeEnd('}').removeStart('{');
   
                           String staticApi = w1.XC_CongaStaticAPI__c;
                           String dynamicApi = '&Id=' + concatenatedOrder + '&QueryId=' +  congaTemplateId + '&TemplateId=' +  templateId // ON ORDERITEM: '&Id=' + quoteItemId + '&AttachmentParentID=' + orderId +
                               + '&OFN=Doc ' + Label.XC_CL_Sospensione + ' - SUSPENSION'  //CR729 01.07.2022
                               + '&DefaultPDF=1&qmode=SalesforceFile&WordStripIfs=1';
                           w1.XC_CongaDynamicAPI__c = staticApi + dynamicApi;
                           System.debug('GS@@@ dynamic API' + dynamicApi );
                           w1.XC_RequiredPurchaseOrderDocument__c = true;
                           //w1.XC_DeclarationDateEndWork__c	 = Date.today();
   
                       break;
               }
           }
           XC_UTIL_Sobject.updateListRecords(listWoli);
       }
   
   public static void congaTemplateIdForWoliProroga (List<WorkOrderLineItem> listWoli){
   
           Set<String> sohoType = new Set<String>();
           Set<String> country = new Set<String>();
           Set<String> legalEntity = new Set<String>();
           Set<Id> idWoli = new Set<Id> ();
           Map<Id,WorkOrderLineItem> woliMap = new Map<Id,WorkOrderLineItem> ([SELECT Id,WorkOrder.XC_Segment__c, WorkOrder.XC_LegalEntity__c,WorkOrder.XC_Country__c 
                                                                                   FROM WorkOrderLineItem WHERE id in: listWoli]);
   
           for(WorkOrderLineItem w1: woliMap.values()){
               legalEntity.add(w1.WorkOrder.XC_LegalEntity__c);
               sohoType.add(w1.WorkOrder.XC_Segment__c);
               country.add(w1.WorkOrder.XC_Country__c);
               idWoli.add(w1.id);
               system.debug('sohotypeRaf '+ sohoType +'countryRAF' + country);
           }
   
           List<XC_CongaTemplateMapping__c> ctM = new List<XC_CongaTemplateMapping__c>();
           if(Schema.sObjectType.XC_CongaTemplateMapping__c.isAccessible()){
               ctM = [ SELECT id,XC_CongaIdTemplate__c,Name,XC_AccountType__c,XC_IsNDA__c,XC_CongaQuery__c
                       FROM XC_CongaTemplateMapping__c
                       WHERE XC_AccountType__c in: sohoType and XC_Country__c in: country
                       AND XC_PartnerEngagement__c= true And XC_LCL__c = false  AND XC_DocumentType__c = 'Proroga' ];
                       System.debug('LCL@@@ in cmt' + ctM );
           }
   
           String templateId;
           String congaTemplateId;
           for(WorkOrderLineItem w1:listWoli){
               for(XC_CongaTemplateMapping__c ctM1: ctM){
                           congaTemplateId = ctM1.XC_CongaQuery__c;
                           templateId = ctM1.XC_CongaIdTemplate__c;
   
                           String concatenatedOrder=String.valueOf(idWoli);
                           concatenatedOrder = concatenatedOrder.removeEnd('}').removeStart('{');
   
                           String staticApi = w1.XC_CongaStaticAPI__c;
                           String dynamicApi = '&Id=' + concatenatedOrder + '&QueryId=' +  congaTemplateId + '&TemplateId=' +  templateId // ON ORDERITEM: '&Id=' + quoteItemId + '&AttachmentParentID=' + orderId +
                               + '&OFN=Doc ' + Label.XC_CL_Proroga + ' - EXTENSION' //CR729 01.07.2022
                               + '&DefaultPDF=1&qmode=SalesforceFile&WordStripIfs=1';
                           w1.XC_CongaDynamicAPI__c = staticApi + dynamicApi;
                           System.debug('GS@@@ dynamic API' + dynamicApi );
                           w1.XC_RequiredPurchaseOrderDocument__c = true;
                           //w1.XC_DeclarationDateEndWork__c= Date.today();
   
                       break;
               }
           }
           XC_UTIL_Sobject.updateListRecords(listWoli);
       }
   
   public static void congaTemplateIdForWoliRipresa (List<WorkOrderLineItem> listWoli){
   
           Set<String> sohoType = new Set<String>();
           Set<String> country = new Set<String>();
           Set<String> legalEntity = new Set<String>();
           Set<Id> idWoli = new Set<Id> ();
           Map<Id,WorkOrderLineItem> woliMap = new Map<Id,WorkOrderLineItem> ([SELECT Id,WorkOrder.XC_Segment__c, WorkOrder.XC_LegalEntity__c,WorkOrder.XC_Country__c 
                                                                                   FROM WorkOrderLineItem WHERE id in: listWoli]);
   
           for(WorkOrderLineItem w1: woliMap.values()){
               legalEntity.add(w1.WorkOrder.XC_LegalEntity__c);
               sohoType.add(w1.WorkOrder.XC_Segment__c);
               country.add(w1.WorkOrder.XC_Country__c);
               idWoli.add(w1.id);
               system.debug('sohotypeRaf '+ sohoType +'countryRAF' + country);
           }
   
           List<XC_CongaTemplateMapping__c> ctM = new List<XC_CongaTemplateMapping__c>();
           if(Schema.sObjectType.XC_CongaTemplateMapping__c.isAccessible()){
               ctM = [ SELECT id,XC_CongaIdTemplate__c,Name,XC_AccountType__c,XC_IsNDA__c,XC_CongaQuery__c
                       FROM XC_CongaTemplateMapping__c
                       WHERE XC_AccountType__c in: sohoType and XC_Country__c in: country
                       AND XC_PartnerEngagement__c= true AND XC_DocumentType__c = 'Ripresa' ];
                       System.debug('LCL@@@ in cmt' + ctM );
           }
   
           String templateId;
           String congaTemplateId;
           for(WorkOrderLineItem w1:listWoli){
               for(XC_CongaTemplateMapping__c ctM1: ctM){
                           congaTemplateId = ctM1.XC_CongaQuery__c;
                           templateId = ctM1.XC_CongaIdTemplate__c;
   
                           String concatenatedOrder=String.valueOf(idWoli);
                           concatenatedOrder = concatenatedOrder.removeEnd('}').removeStart('{');
   
                           String staticApi = w1.XC_CongaStaticAPI__c;
                           String dynamicApi = '&Id=' + concatenatedOrder + '&QueryId=' +  congaTemplateId + '&TemplateId=' +  templateId // ON ORDERITEM: '&Id=' + quoteItemId + '&AttachmentParentID=' + orderId +
                               + '&OFN=Doc ' +Label.XC_CL_Ripresa + ' - RESUMPTION' //fix 11-07-22 vdb 729
                               + '&DefaultPDF=1&qmode=SalesforceFile&WordStripIfs=1';
                           w1.XC_CongaDynamicAPI__c = staticApi + dynamicApi;
                           System.debug('GS@@@ dynamic API' + dynamicApi );
                           w1.XC_RequiredPurchaseOrderDocument__c = true;
                           //w1.XC_DeclarationDateEndWork__c	 = Date.today();
   
                       break;
               }
           }
           XC_UTIL_Sobject.updateListRecords(listWoli);
       }
   //[CR729 End sooraji.sajan@accenture.com 10.05.2022]
       
       
       }