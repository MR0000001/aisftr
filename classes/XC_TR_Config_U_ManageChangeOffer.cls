/**
 * @File Name          : XC_TR_Config_U_ManageChangeOffer.cls
 * @Description        : 
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 18/6/2020, 10:52:48
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    17/6/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
**/
public without sharing class XC_TR_Config_U_ManageChangeOffer {


    /**
    * @description perform change offer operation after update order flag
    * @author Francesco Imperioli - fimperioli@deloitte.it | 17/6/2020 
    * @param listNew 
    * @param mapOld 
    * @param mapNew 
    * @return void 
    **/
    public static void onAfterUpdateOrder(List<NE__Order__c> listNew,Map<Id,NE__Order__c> mapOld,Map<Id,NE__Order__c> mapNew){

        List<NE__Order__c> ordersToCheck = new List<NE__Order__c>();
        Set<String> ordersToCheckIds = new Set<String>();

        List<NE__Order__c> changedOrds = (List<NE__Order__c>) XC_UTIL_Sobject.getListChanged(new List<String>{'XC_CommercialChange__c'},mapOld,mapNew);

        System.Debug('XC_TR_Config_U_ManageChangeOffer CHANGED ORDS ' + changedOrds);

        for(NE__Order__c ord : changedOrds){
            if(ord.XC_CommercialChange__c){
                ordersToCheck.add(ord);
                ordersToCheckIds.add(ord.Id);
            }
        }

        if(!ordersToCheck.isEmpty()){
           System.enqueueJob(new XC_QueueableOperationCommercialOffer(ordersToCheckIds));
        }

    }

    /**
    * @description manage DocumentType of an ORDER 
    * @author Marco Ottaviano - mottaviano@deloitte.it | 17/6/2020 
    * @param orderIds 
    * @return List<XC_DocumentType__c> 
    **/

   private static void manageRelatedDocumentTypeCategory(Set<String> orderIdse,List<XC_DocumentType__c> documentTypelist) {
        if(!documentTypelist.isEmpty()) {
            for(XC_DocumentType__c doc : documentTypelist) {
                doc.Category__c = doc.Category__c +'_DELETED'; // ADD CUSTOM LABEL
            }
            XC_UTIL_Sobject.updateListRecords(documentTypelist);
        }
    }


    private static List<XC_DocumentType__c> getrelatedDocumentTypebycategory(Set<String> orderIds,List<String> categoryLike) {
        String query = 'SELECT Id,Category__c,XC_Configuration__c,numberOfFiles__c FROM XC_DocumentType__c WHERE XC_Configuration__c IN : orderIds AND Category__c IN : categoryLike';
        return (List<XC_DocumentType__c>)Database.query(query);
    }

    
    /**
    * @description marks all the document signature records of the order as DELETED --> XC_Step__c = 4
    * @author Francesco Imperioli - fimperioli@deloitte.it | 17/6/2020 
    * @param ordersToCheckIds 
    * @return void 
    **/
    private static void manageOTPDocumentSignatureDeletion(Set<String> ordersToCheckIds){
        List<XC_DocumentSignature__c> existingDocSignatures = [SELECT ID,XC_Step__c FROM XC_DocumentSignature__c WHERE XC_Order__c IN :ordersToCheckIds];
        for(XC_DocumentSignature__c docS : existingDocSignatures){
            docS.XC_Step__c = '4';
        }
        if(!existingDocSignatures.isEmpty()){
            XC_UTIL_Sobject.updateListRecords(existingDocSignatures);
        }
    }


    /**
    * @description delete credit assignment survey responses
    * @author Francesco Imperioli - fimperioli@deloitte.it | 18/6/2020 
    * @param oiItems 
    * @return void 
    **/
    private static void deleteCASurveyResponses(Map<Id,NE__Order__c> orderMap){
        
        List<NE__OrderItem__c> oiItems = new List<NE__OrderItem__c>();
        List<String> idlistOIwithoutCreditSurvey= new List<String>();

        for(NE__Order__c order : orderMap.values()){
            for(NE__OrderItem__c oi : order.NE__Order_Items__r){
                if(oi.XC_Product_Subtype__c == Label.XC_CL_ProductSubtypeIncentive && String.isNotBlank(oi.XC_CreditAssignmentSurvey__c)){
                    oiItems.add(oi);
                } else if(oi.XC_Product_Subtype__c == Label.XC_CL_ProductSubtypeIncentive && String.isBlank(oi.XC_CreditAssignmentSurvey__c)) {
                    idlistOIwithoutCreditSurvey.add(oi.Id);
                }
            }
        }

        Set<Id> orderItemsIds = XC_UTIL_Sobject.getSetIdsOnField(oiItems, 'Id');

        if(!orderItemsIds.isEmpty()){
            List<XC_GetFeedbackResponse__c> responsesToDelete = [SELECT Id FROM XC_GetFeedbackResponse__c WHERE XC_ConfigurationItem__c IN :orderItemsIds];
            XC_UTIL_Sobject.deleteListRecords(responsesToDelete, true);
        }

        if(!idlistOIwithoutCreditSurvey.isEmpty()) {
            String queryString=XC_UTIL_Sobject.selectAllFieldsGetSelect('NE__Order_Item_Attribute__c');
            queryString += ' FROM NE__Order_Item_Attribute__c WHERE NE__Order_Item__c IN : idlistOIwithoutCreditSurvey';
            List<NE__Order_Item_Attribute__c> listAttributeItem = (List<NE__Order_Item_Attribute__c>) Database.query(queryString);
            XC_TR_ConfItemAttr_U_PopulateConfItem.fillSubsidySurveyFields(listAttributeItem);
        }


    }

    /**
    * @description delete record XC_DocumentURL__c, of FILE WITH Category SIGNED related to the order
    * @author Marco ottaviano - mottaviano@deloitte.it | 06/07/2020 
    * @param ordersToCheckIds 
    * @return void 
    **/

    private static void deleteDocumentURLCategorySigned(Set<String> ordersToCheckIds) {
                            
        List<XC_DocumentURL__c> existingDocURL = [ SELECT id, XC_Configuration__c, XC_Url__c
                        FROM XC_DocumentURL__c
                        WHERE XC_Configuration__c IN : ordersToCheckIds
                        AND (XC_Category_Signed__c = 'SF_CREDIT_ASSIGNMENT_SIGNED'
                        OR XC_Category_Signed__c = 'SF_CONTRACT_SIGNED')];

        if(!existingDocURL.isEmpty()){
            XC_UTIL_Sobject.deleteListRecords(existingDocURL,true);
        }
    }

    /**
    * @description reset Flags for Commerial Order on Order, OrderItems and Opty. Check For Case for Order with External Financing
    * @author Marco ottaviano - mottaviano@deloitte.it | 18/6/2020 
    * @param orderMap 
    * @return void 
    **/

    public static void manageResetofOrder(Map<Id,NE__Order__c> orderMap, XC_CM_Case_Type_Setting__mdt caseMDT) {
    
        List<NE__OrderItem__c> oiItemstoUpdatelist = new List<NE__OrderItem__c>();
        List<NE__Order__c> orderToUpdateList = new List<NE__Order__c>();
        List<Opportunity> optyToUpdateList = new List<Opportunity>();
        List<XC_OrderEvent__e> orderEventList = new List<XC_OrderEvent__e>();
        List<Case> caseExternalFinancingToInsert = new List<Case>();
        List<Case> caseExternalFinancingToUpdate = new List<Case>();
        Map<String,List<Case>> mapListCaseExternalFinancing = new Map<String,List<Case>>{'InsertList' => caseExternalFinancingToInsert,
                                                                                        'UpdateList' => caseExternalFinancingToUpdate
        };
       
        
        
        for(NE__Order__c order : orderMap.values()){
            for(NE__OrderItem__c oi : order.NE__Order_Items__r){
                oi.NE__Hidden_in_Cart__c = true;
            }
            oiItemstoUpdatelist.addAll(order.NE__Order_Items__r);
            order.XC_TechnicalProductOnly__c = true;
            order.XC_CommercialChange__c = false;

            //check ExternalFinancing Payment and reset Field -- Chek only XC_FinancialInstitution__c is Not Blank
            if(String.isNotBlank(order.XC_FinancialInstitution__c) /*&& String.isNotEmpty(order.XC_FinancialPracticeNumber__c) && String.isNotEmpty(order.XC_FinancialPracticeStatus__c)*/ ) {
                checkCaseExternalFinancing(order,mapListCaseExternalFinancing,caseMDT);
                order.XC_FinancialPracticeStatus__c =null;
                order.XC_FinancialPracticeNumber__c =null;
                order.XC_FinancialApproval__c = null;
            }
          

            //create event COMMERCIALCHANGE COMPLETED
            XC_OrderEvent__e orderEvent = new XC_OrderEvent__e(XC_RecordId__c = order.Id,XC_Type__c = Label.XC_CL_OrderEvent_COMMERCIALCHANGECOMPLETED);
            orderEventList.add(orderEvent);
        }

        orderToUpdateList.addAll(orderMap.values());
      

        Set<Id> optyIdset = XC_UTIL_Sobject.getSetIdsOnField(orderToUpdateList, 'NE__OptyId__c');
        if(!optyIdset.isEmpty()) {
            optyToUpdateList = new Map<Id,Opportunity>([SELECT Id,XC_TechnicalProductOnly__c FROM Opportunity WHERE Id In : optyIdset]).values();
            for(Opportunity opty : optyToUpdateList) {
                opty.XC_TechnicalProductOnly__c = true;
            }
        }

        //Update Section --
        List<XC_UTIL_Sobject.WrapperResult> resltWrapperUp = new List<XC_UTIL_Sobject.WrapperResult>();
        resltWrapperUp.addAll(XC_UTIL_Sobject.updateListRecords(oiItemstoUpdatelist));
        resltWrapperUp.addAll(XC_UTIL_Sobject.updateListRecords(orderToUpdateList));
        resltWrapperUp.addAll(XC_UTIL_Sobject.updateListRecords(optyToUpdateList));
        

        // Publish EVENT */
        Eventbus.publish(orderEventList);

        //CASE EXTERNAL Financing
        XC_UTIL_Sobject.insertListRecords(caseExternalFinancingToInsert);
        XC_UTIL_Sobject.runAssignmentRules(caseExternalFinancingToInsert,'Case');
        XC_UTIL_Sobject.updateListRecords(caseExternalFinancingToUpdate);
    }


    
     /**
    * @description check if an Order has Closed Case for External Financing
    * @author Marco ottaviano - mottaviano@deloitte.it | 22/6/2020 
    * @param order
    * param caseExternalFinancig
    * param caseMDT
    * @return void 
    **/
    private static void checkCaseExternalFinancing(NE__Order__c order, Map<String,List<Case>> mapListCaseExternalFinancing,XC_CM_Case_Type_Setting__mdt caseMDT) {  
        List<Case> caseExternalFinancingToInsert=mapListCaseExternalFinancing.get('InsertList');
        List<Case> caseExternalFinancingToUpdate = mapListCaseExternalFinancing.get('UpdateList');

        if(order.XC_Cases__r.isEmpty() && caseMDT != null) {
           caseExternalFinancingToInsert.add(createCaseExternalFinancing(caseMDT,order)); 
        } else if(!order.XC_Cases__r.isEmpty() && caseMDT != null) {
            List<Case> caseNewForThisOrder = new List<Case>();
            for(Case thisCas : order.XC_Cases__r) {
                if(thisCas.Status == Label.XC_CL_Case_Status007 && caseNewForThisOrder.isEmpty())  { // Closed case create a new one
                    Case newCase = createCaseExternalFinancing(caseMDT,order);
                    caseNewForThisOrder.add(newCase);
                } else {
                    thisCas.Description = modifyDescriptionOnFinancingCase(order,thisCas.Description);
                    caseExternalFinancingToUpdate.add(thisCas);
                    caseNewForThisOrder.clear(); //If there is an open case, we don't create a new one. So let's clear the list of new ones
                    break;
                }
            }

            if(!caseNewForThisOrder.isEmpty()) {
                caseExternalFinancingToInsert.addAll(caseNewForThisOrder);
            }
        }  
    }

     /**
    * @description check if an Order has Closed Case for External Financing
    * @author Marco ottaviano - mottaviano@deloitte.it | 22/6/2020 
    * @param order
    * param caseMDT
    * @return c a new Case
    **/
    private static Case createCaseExternalFinancing(XC_CM_Case_Type_Setting__mdt caseMDT,NE__Order__c order) {
        Case c = XC_UTIL_Case.initCaseFromCaseSettings(caseMDT);
        c.AccountId = order.NE__AccountId__c;
        c.ContactId = order.NE__OptyId__r.XC_Contact__c;
        //c.Origin = Label.XC_CL_CaseOriginCAN002;
        c.XC_Order__c = order.Id;
        c.Description = modifyDescriptionOnFinancingCase(order,c.Description);
        return c;
    }

    private static String modifyDescriptionOnFinancingCase(NE__Order__c order,String currentDescription) {
        String labelPraticeNumber=Schema.getGlobalDescribe().get('NE__Order__c').getDescribe().fields.getMap().get('XC_FinancialPracticeNumber__c').getDescribe().getLabel();
        String labelPraticeInstitute=Schema.getGlobalDescribe().get('NE__Order__c').getDescribe().fields.getMap().get('XC_FinancialInstitution__c').getDescribe().getLabel();
        String newDescription = Label.XC_CL_DescriptionCaseExternalFinancing;
        String praticeNumber = String.isNotBlank(order.XC_FinancialPracticeNumber__c) ? order.XC_FinancialPracticeNumber__c : '';
        newDescription=newDescription.replace('<NR_Label>', labelPraticeNumber);
        newDescription=newDescription.replace('<NR_Value>', praticeNumber);
        newDescription=newDescription.replace('<FI_Label>', labelPraticeInstitute);
        newDescription=newDescription.replace('<FI_Value>', order.XC_FinancialInstitution__c);
        currentDescription = (String.isNotBlank(currentDescription)) ? currentDescription : '';
        return currentDescription + '\n' + newDescription + '\n' + Label.XC_CL_ExternalFinancingAction;
    }

    /**
    * @description check if an Order has Closed Case for External Financing
    * @author Marco ottaviano - mottaviano@deloitte.it | 04/07/2020 
    * @param ordIdS
    **/
    private static void manageRelatedCustomerInteraction(Set<Id> ordIdS) {

        Map<Id, XC_Customer_Interaction__c> cimap = new Map<Id, XC_Customer_Interaction__c>([
                        SELECT Id, XC_Communication_Type__c, XC_Disabled__c, XC_OrderId__c,XC_Doc_URL_List__c
                        FROM XC_Customer_Interaction__c
                        WHERE XC_Communication_Type__c LIKE 'Welcome_Contract%'
                        AND XC_OrderId__c IN : ordIdS]); 
        List< XC_Customer_Interaction__c> citToUp =        new List<XC_Customer_Interaction__c>();          
        if(!cimap.isEmpty()) {
            for(XC_Customer_Interaction__c ci: cimap.values()) {
                if(ci.XC_Doc_URL_List__c!=null) {
                    ci.XC_Disabled__c = true;
                    citToUp.add(ci);
                }
                
            }
            XC_UTIL_Sobject.updateListRecords(citToUp);
        }
    }

    


       /**
     *@description The Class XC_QueueableOperationCommercialOffer.
     */
    public without sharing class XC_QueueableOperationCommercialOffer implements Queueable, Database.AllowsCallouts {

        /**
        * Instantiates a new XC_QueueableOperationCommercialOffer.
        */
        private Set<String> ordersToCheckIds;

        /* 
        * @description constructor of XC_QueueableOperationCommercialOffer
        * @param 
        */
        public XC_QueueableOperationCommercialOffer(Set<String> ordersToCheckIds) {
            this.ordersToCheckIds = ordersToCheckIds;
        }


        /**
        * Execute.
        *
        * @param qc the QueueableContext
        * @description execute of XC_REST_callDoxeeFileDelete
        */
        public void execute(QueueableContext qc) {

            Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_CMD_ExternalFinancing});
            XC_CM_Case_Type_Setting__mdt caseMDT = mapCaseSetting.get(Label.XC_CL_CMD_ExternalFinancing);
            if(caseMDT==null) {
                throw new XC_Exception(String.format(Label.XC_CL_NoMatchOnMetadata, new List<String>{'XC_CM_Case_Type_Setting__mdt', Label.XC_CL_CMD_ExternalFinancing}));
            }
            
            XC_REST_DoxeeFileDelete.RequestWrapper wrReq = new XC_REST_DoxeeFileDelete.RequestWrapper();
            Map<Id,NE__Order__c> mapIdOrder = new Map<Id,NE__Order__c>([SELECT Id,XC_Country__c,XC_LegalEntity__c,XC_Segment__c, NE__OptyId__c, XC_TechnicalProductOnly__c,
                                                                        XC_FinancialPracticeNumber__c,XC_FinancialPracticeStatus__c,XC_FinancialInstitution__c,XC_FinancialApproval__c,NE__OptyId__r.XC_Contact__c,NE__AccountId__c,
                                                                        (SELECT Id,XC_Product_Subtype__c,NE__Hidden_in_Cart__c,XC_CreditAssignmentSurvey__c FROM NE__Order_Items__r),(SELECT Id,Status,Description FROM XC_Cases__r WHERE SubCause__c =: caseMDT.XC_Sub_Cause__c AND Reason =: caseMDT.XC_Case_Reason__c AND XC_Subtype__c =: caseMDT.XC_Sub_Type__c /*AND Status =: Label.XC_CL_Case_Status007*/ ORDER BY LastModifiedDate DESC)
                                                                        FROM NE__Order__c WHERE Id IN :ordersToCheckIds]);
            List<NE__Order__c> listOrder = mapIdOrder.values();
            Set<String> streamSet = XC_UTIL_Sobject.getSetIdsStringOnField(listOrder, 'XC_Segment__c');
            Set<String> legalEntityset =  XC_UTIL_Sobject.getSetIdsStringOnField(listOrder, 'XC_LegalEntity__c');
            

            List<XC_CM_FileCategoryObjectTypeMapping__mdt> fileCategoryListdeleteOrder=[SELECT DeveloperName,  XC_FileCategory__c, XC_ObjectType__c,XC_Enabled_For_Delete__c FROM XC_CM_FileCategoryObjectTypeMapping__mdt WHERE XC_ObjectType__c ='CONFIGURATION' AND XC_Enabled_For_Delete__c = true];
            List<String> categoryFileList = new List<String>();
            List<XC_DocumentType__c> docTypecatList = new List<XC_DocumentType__c>();
            
            List<XC_CM_LegalEntity_Configuration__mdt>  ListconfigurationLEStream = [SELECT  XC_DoxeeCompany__c, XC_DoxeeCountry__c,XC_LegalEntity__c,XC_Stream__c
                                                            FROM  XC_CM_LegalEntity_Configuration__mdt 
                                                            WHERE XC_OrgId__c = : UserInfo.getOrganizationId() 
                                                            AND  XC_LegalEntity__c  IN : legalEntityset
                                                            AND XC_Stream__c IN : streamSet];


            if(!fileCategoryListdeleteOrder.isEmpty() && !ListconfigurationLEStream.isEmpty()) {
     
                for(XC_CM_FileCategoryObjectTypeMapping__mdt fileCat : fileCategoryListdeleteOrder ) {
                    categoryFileList.add(fileCat.XC_FileCategory__c);
                }

                Map<String,XC_CM_LegalEntity_Configuration__mdt> mapStreamLEconfig = new Map<String,XC_CM_LegalEntity_Configuration__mdt>();
                for(XC_CM_LegalEntity_Configuration__mdt  configLE : ListconfigurationLEStream) {
                    mapStreamLEconfig.put(configLE.XC_LegalEntity__c+configLE.XC_Stream__c,configLE);
                }
                
                docTypecatList=getrelatedDocumentTypebycategory(ordersToCheckIds,categoryFileList);
                Map<Id,List<XC_DocumentType__c>> mapOrderListCategoryFile = new Map<Id,List<XC_DocumentType__c>>();
                
                
                
                //FIX : We are no longer waiting for Doxee's fileINCategory callback. So let's not check the DocumentType__c records on the order first. 
               /* for(XC_DocumentType__c doc: docTypecatList) {
                    if(!mapOrderListCategoryFile.containsKey(doc.XC_Configuration__c)) {
                        mapOrderListCategoryFile.put(doc.XC_Configuration__c,new list<XC_DocumentType__c>());
                    }
                    mapOrderListCategoryFile.get(doc.XC_Configuration__c).add(doc);
                }*/

                //Doxee callout to delete document categories
              

                List<XC_REST_DoxeeFileDelete.FileWrapper> listFilwRapper= new List<XC_REST_DoxeeFileDelete.FileWrapper>();
                for(NE__Order__c conf: mapIdOrder.values()) {

                   // if(mapOrderListCategoryFile.containsKey(conf.Id)) {
                        //List<XC_DocumentType__c> categoryFileForOrder = mapOrderListCategoryFile.get(conf.Id);
                        XC_CM_LegalEntity_Configuration__mdt configLe = mapStreamLEconfig.get(conf.XC_LegalEntity__c+conf.XC_Segment__c);
                        //FIX : We are no longer waiting for Doxee's fileINCategory callback. So let's not check the DocumentType__c records on the order first.
                        // But call Doxee's File Delete on every document that can be deleted related to an order, retrieved from CM XC_CM_FileCategoryObjectTypeMapping__mdt
                        for(String categoryFileToDelete : categoryFileList) {

                            XC_REST_DoxeeFileDelete.FileWrapper filewrapper = new XC_REST_DoxeeFileDelete.FileWrapper();
                            filewrapper.Category = categoryFileToDelete;
                            filewrapper.ObjectType = 'CONFIGURATION';
                            filewrapper.Company = configLe.XC_DoxeeCompany__c;
                            filewrapper.Country = configLe.XC_DoxeeCountry__c.toUpperCase();
                            filewrapper.ObjectID = conf.Id;
                            filewrapper.NumberOfFileDeleted = null; // String.valueOf(categoryFile.numberOfFiles__c);
                        
                            listFilwRapper.add(filewrapper);
                        }
                 //   }
                    
               }

                wrReq.File=listFilwRapper;
                XC_REST_DoxeeFileDelete.sendRequest(wrReq);
            }

            /**OTHER ASYNCHRONOUS OPERATIONS**/
            manageRelatedDocumentTypeCategory(ordersToCheckIds,docTypecatList);
            deleteDocumentURLCategorySigned(ordersToCheckIds);
            manageOTPDocumentSignatureDeletion(ordersToCheckIds);
            deleteCASurveyResponses(mapIdOrder);
            manageResetofOrder(mapIdOrder,caseMDT);
            manageRelatedCustomerInteraction(mapIdOrder.keySet());
        }
    }

    


       

}