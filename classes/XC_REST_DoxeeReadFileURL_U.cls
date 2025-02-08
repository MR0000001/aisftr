/**
* The Class XC_REST_DoxeeReadFileURL_U.
*
* @author            :
* @date Creation     : dd/mm/yyyy
* @date Modification : 09/05/2019 by Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
* @description       : Util for XC_REST_DoxeeReadFileURL
**/


public without sharing class XC_REST_DoxeeReadFileURL_U {
    
    
    /**
    * @description Validate request.
    *
    * @param mapHeader the map header
    * @param wrReq the wr req
    * @return the x C UTI L integration. result
    */
    public static XC_UTIL_Integration.Result validateRequest(Map<String, String> mapHeader, XC_REST_DoxeeReadFileURL_W.WrapperRequest wrReq){
        XC_UTIL_Integration.Result validateResult = new XC_UTIL_Integration.Result();
        XC_UTIL_Integration.WrapperResult validate = XC_UTIL_RESTInbound.checkObjectPermission('XC_Document_to_sign__c', 'create');
        if(validate.errorFlag) {
            validateResult.Message = validate.errorMessage;
            validateResult.errorCode = '400';
            return validateResult;
        }
        
        validate = XC_UTIL_Integration.validateHeader(mapHeader);
        if(validate.errorFlag) {
            validateResult.Message = validate.errorMessage;
            validateResult.errorCode = '400';
            return validateResult;
        }
        
        
        if(wrReq.FileItem == null || wrReq.FileItem.isEmpty()) {
            validateResult.Message = Label.XC_CL_MandatoryField +' FileItem';
            validateResult.errorCode = '400';
            return validateResult;
        }
        validateResult = validateRequestFile(wrReq.FileItem);
        return validateResult;
    }
    
    
    /**
    * @description Validate request file.
    *
    * @param fileList the file list
    * @return the x C UTI L integration. result
    */
    public static XC_UTIL_Integration.Result validateRequestFile(List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> fileList){
        XC_UTIL_Integration.Result validateResult = new XC_UTIL_Integration.Result();
        
        for(XC_REST_DoxeeReadFileURL_W.WrapperRequestFile fileOne: fileList){
            
            if(String.isBlank(fileOne.ObjectType)){
                validateResult.Message = Label.XC_CL_MandatoryField +' FileItem.ObjectType';
                validateResult.errorCode = '400';
                return validateResult;
            }
            if(String.isBlank(fileOne.ObjectID)){
                validateResult.Message = Label.XC_CL_MandatoryField + ' FileItem.ObjectID';
                validateResult.errorCode = '400';
                return validateResult;
            }
            if(String.isBlank(fileOne.Category)){
                validateResult.Message = Label.XC_CL_MandatoryField + ' FileItem.Category';
                validateResult.errorCode = '400';
                return validateResult;
            }
            
            if(String.isBlank(fileOne.DocumentURL)){
                validateResult.Message = Label.XC_CL_MandatoryField + ' FileItem.DocumentURL';
                validateResult.errorCode = '400';
                return validateResult;
            }
            if(String.isBlank(fileOne.DocumentID)){
                validateResult.Message = Label.XC_CL_MandatoryField + ' FileItem.DocumentID';
                validateResult.errorCode = '400';
                return validateResult;
            }
            
            XC_UTIL_Integration.WrapperResult err = XC_UTIL_Integration.validateFileRequest(fileOne.ObjectType, fileOne.Category);
            if(err.errorFlag) {
                validateResult.Message = err.errorMessage;
                validateResult.errorCode = '400';
                return validateResult;
            }
            
        }
        
        return validateResult;
    }
    
    
    /**
    * **********************************************************************************************************************.
    *
    * @author      : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
    * @param fileList the file list
    * @param mapCase
    * @return the x C RES T doxee read file UR L u. wrapper response
    * @Date        : 13/03/2019
    * @description : Method to create Documents and Customer Interactions
    * ***********************************************************************************************************************
    */
    public static XC_REST_DoxeeReadFileURL_W.WrapperResponse createDocCustomerInteraction(List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> fileList, map<string,case> mapCase) {
        System.debug('$$ createDocCustomerInteraction');
        XC_REST_DoxeeReadFileURL_W.WrapperResponse response = new XC_REST_DoxeeReadFileURL_W.WrapperResponse();
        List<Map<String, Object>> listCustomerInteraction = new List<Map<String, Object>>();
        List<XC_Document_To_Sign__c> docListToInsert = new List<XC_Document_To_Sign__c>();
        
        Set<Id> orderItemIds = new Set<Id>();
        Set<Id> contractIds = new Set<Id>();
        Set<Id> contractSigned = new Set<Id>();
        Set<Id> assetIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> workOrderIds = new Set<Id>();
        Set<Id> orderIds = new Set<Id>();
        Set<Id> billingProfileIds = new Set<Id>();
        Set<Id> caseIds = new Set<Id>();
        Set<Id> opportunityIds=new Set<id>();
        List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> docListToSign = new List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile>();
        Set<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> docListNotToSign = new Set<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile>();
        Map<String,String> mapDocumentIdParentId = new Map<String,String>();
        
        //GDB START
        List<String> urlList = new List<String>();
        List<String> confList = new List<String>();
        for(XC_REST_DoxeeReadFileURL_W.WrapperRequestFile wrDoc : fileList) {
            System.debug('Category: ' + wrDoc.Category);
            String objectName = XC_UTIL_Sobject.getObjectType(wrDoc.ObjectID);
            if(objectName == 'NE__Order__c' && (wrDoc.Category == 'SF_CONTRACT_TO_SIGN' || wrDoc.Category == 'SF_CREDIT_ASSIGNMENT_TO_SIGN' || 
            wrDoc.Category == 'SF_CONTRACT_SIGNED' || wrDoc.Category == 'SF_CREDIT_ASSIGNMENT_SIGNED')){
                urlList.add(wrDoc.DocumentURL);
                confList.add(wrDoc.ObjectID);
            }
        }
        Set<String> urlListQuery = new Set<String>();
        if(!confList.isEmpty()){
            Map<String, NE__Order__c> docOrdMap = new Map<String, NE__Order__c>([
                SELECT Id, XC_Segment__c
                FROM NE__Order__c
                WHERE Id in: confList]);
        
            for(NE__Order__c ord: docOrdMap.values()){
                if(ord.XC_Segment__c != 'B2C'){
                    for(XC_REST_DoxeeReadFileURL_W.WrapperRequestFile wrDoc : fileList) {
                        if(ord.id == wrDoc.ObjectID){
                            urlListQuery.add(wrDoc.DocumentURL);
                        }
                    }
                }
            }
        }
        if(!urlList.isEmpty()){
            Map<String, XC_DocumentURL__c> docUrlMap = new Map<String, XC_DocumentURL__c>([
                SELECT Id, XC_Url__c, XC_Configuration__r.XC_Segment__c
                FROM XC_DocumentURL__c
                WHERE XC_Url__c in: urlList]);

            for(XC_DocumentURL__c docUrl : docUrlMap.values()) {
                urlListQuery.add(docUrl.XC_Url__c);
            }
        }
        System.debug('urlListQuery: ' + urlListQuery);
        //GDB END

        /*Set<Id> workOrderIds = new Set<Id>();
        List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> docListToSignWO = new List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile>();
        Set<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> docListNotToSignWO = new Set<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile>();
        Map<String,String> mapDocumentIdParentIdWO = new Map<String,String>();*/
        
        for(XC_REST_DoxeeReadFileURL_W.WrapperRequestFile wrDoc : fileList) {
            
            String objectName = XC_UTIL_Sobject.getObjectType(wrDoc.ObjectID);
            if(objectName == 'NE__Order__c' && !orderIds.contains(wrDoc.ObjectID)) {
                //GDB START
                if((wrDoc.Category == 'SF_CONTRACT_TO_SIGN' || wrDoc.Category == 'SF_CREDIT_ASSIGNMENT_TO_SIGN' || 
                    wrDoc.Category == 'SF_CONTRACT_SIGNED' || wrDoc.Category == 'SF_CREDIT_ASSIGNMENT_SIGNED') &&
                    !urlListQuery.contains(wrDoc.DocumentURL)){
                    continue;
                }//GDB END
                orderIds.add(wrDoc.ObjectID);
            }else if(objectName == 'WorkOrder' && !workOrderIds.contains(wrDoc.ObjectID)){
                workOrderIds.add(wrDoc.ObjectID);
            }else if(objectName == 'Account' && !accountIds.contains(wrDoc.ObjectID)){
                accountIds.add(wrDoc.ObjectID);
                system.debug(objectName);
            }else if(objectName == 'Asset' && !assetIds.contains(wrDoc.ObjectID)){
                assetIds.add(wrDoc.ObjectID);
            }else if(objectName == 'Contract' && !contractIds.contains(wrDoc.ObjectID)){
                contractIds.add(wrDoc.ObjectID);
                if(wrDoc.Category == 'SF_CONTRACT_SIGNED'){
                    contractSigned.add(wrDoc.ObjectID);
                } 
            }else if(objectName == 'NE__OrderItem__c' && !orderItemIds.contains(wrDoc.ObjectID)){
                orderItemIds.add(wrDoc.ObjectID);
            }else if(objectName == 'NE__Billing_Profile__c' && !billingProfileIds.contains(wrDoc.ObjectID)){
                billingProfileIds.add(wrDoc.ObjectID);
            }else if(objectName == 'Case' && !caseIds.contains(wrDoc.ObjectID)){
                caseIds.add(wrDoc.ObjectID); 
            }else if(objectName=='Opportunity' && !OpportunityIds.contains(wrDoc.ObjectID)){
                OpportunityIds.add(wrDoc.ObjectID);  
            }
            if(!mapDocumentIdParentId.containsKey(wrDoc.DocumentID) && wrDoc.Category.containsIgnoreCase(Label.XC_CL_Signature)){
                mapDocumentIdParentId.put(wrDoc.DocumentID, wrDoc.ObjectID);
                docListToSign.add(wrDoc);
            }else{
                docListNotToSign.add(wrDoc);
            }
        }
        /*if(objectName == 'NE__Order__c') {
            if(!orderIds.contains(wrDoc.ObjectID)){
                orderIds.add(wrDoc.ObjectID);
            }
            if(!mapDocumentIdParentId.containsKey(wrDoc.DocumentID) && wrDoc.Category.containsIgnoreCase(Label.XC_CL_Signature)){
                mapDocumentIdParentId.put(wrDoc.DocumentID, wrDoc.ObjectID);
                docListToSign.add(wrDoc);
            }else{
                docListNotToSign.add(wrDoc);
            }
        }else if (objectName == 'WorkOrder'){
            if(!workOrderIds.contains(wrDoc.ObjectID)){
                workOrderIds.add(wrDoc.ObjectID);
            }
            if(!mapDocumentIdParentIdWO.containsKey(wrDoc.DocumentID) && wrDoc.Category.containsIgnoreCase(Label.XC_CL_Signature)){
                mapDocumentIdParentIdWO.put(wrDoc.DocumentID, wrDoc.ObjectID);
                docListToSignWO.add(wrDoc);
            }else{
                docListNotToSignWO.add(wrDoc);
            }
        }*/
        
        //order
        if(!orderIds.isEmpty()){
            System.debug('$$ Order Doc to sign');
            Map<Id, NE__Order__c> orderMap = new Map<Id, NE__Order__c>([SELECT Id, NE__OptyId__c, NE__OptyId__r.XC_Contact__r.Email, NE__OptyId__r.XC_Contact__r.AccountId, NE__OptyId__r.XC_LegalEntity__c, XC_Segment__c,
                                                                        NE__OptyId__r.XC_Contact__r.Id, NE__OptyId__r.XC_Contact__r.Name, NE__OptyId__r.XC_Contact__r.XC_Preferredlanguageofcontact__c, NE__OptyId__r.XC_Contact__r.XC_MainLegalEntity__c, NE__OptyId__r.Owner.Email, RecordType.DeveloperName
                                                                        FROM NE__Order__c WHERE Id IN :orderIds]);
            
            if(!orderMap.values().isEmpty() && orderMap.values().size() == orderIds.size()) {
                Map<Id, XC_Document_to_sign__c> docToSignMap = new Map<Id, XC_Document_to_sign__c>([SELECT XC_Doxee_ID_external__c, XC_ConfigurationId__c
                                                                                                    FROM XC_Document_to_sign__c WHERE XC_ConfigurationID__c IN: mapDocumentIdParentId.values()
                                                                                                    AND XC_Doxee_ID_external__c IN :mapDocumentIdParentId.keySet()]);
                
                List<XC_Document_to_sign__c> docToSignList = docToSignMap.values();
                /*if(!docToSignList.isEmpty()){
                    String listId = '';
                    for(XC_Document_to_sign__c doc: docToSignList){
                        if(docToSignList.size()> 1){
                        listId +=  'DocumentID '+ doc.XC_Doxee_ID_external__c + ' '+ 'and ObjectID ' + doc.XC_ConfigurationID__c + ', ';
                        }else{
                            listId = 'DocumentID '+ doc.XC_Doxee_ID_external__c + ' '+ ' and ObjectID ' + doc.XC_ConfigurationID__c;
                        }
                    }
                    response.Result.Message = ('INTERNAL ERROR: Document with '+ listId +' already exists').replace(',  already', ' already');
                    response.Result.ErrorCode = '500';
                    return response;
                } */
                
                Map<String, String> mapDocIdOrderId = createMapDocIdObject(docToSignList,'NE__Order__c');
                
                Map<String, Object> mapUtil = new Map<String, Object>{  'docListToSign' => docListToSign,
                    'docListToInsert' => docListToInsert,
                    'mapDocIObjId' => mapDocIdOrderId,
                    'apiName' => 'XC_ConfigurationID__c'
                    };
                        
                system.debug('docToSignMapFOUND'+docToSignMap.values());
                system.debug('mapDocIdOrderId'+mapDocIdOrderId);
                
                Set<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> ciDocList = utilDoc(mapUtil);
                
                Map<String, Map<String,Object>> mapOrderIdCI = populateCustomerInteractionOrd(CIdocList, orderMap);
                Map<String, Map<String,Object>> mapOrdIdCI = populateCustomerInteractionOrd(docListNotToSign, orderMap);
                
                listCustomerInteraction.addAll(mapOrderIdCI.values());
                listCustomerInteraction.addAll(mapOrdIdCI.values());
            } else{
                response.Result.ErrorCode = '400';
                response.Result.Message = Label.XC_CL_ObjectId;
                response.Result.LogError = 'ERROR. ObjectId not Found';
                return response;
            }
            
        }
        
        
        // WorkOrder
        else if(!workOrderIds.isEmpty()){
            
            Map<Id, WorkOrder> workOrderMap = new Map<Id, WorkOrder>([SELECT XC_Opportunity__c, XC_Opportunity__r.XC_Contact__r.Name, XC_Opportunity__r.XC_Contact__c, XC_Opportunity__r.XC_LegalEntity__c,
                                                                      XC_Opportunity__r.XC_Contact__r.Email, XC_Opportunity__r.XC_Contact__r.AccountId, Id, XC_Opportunity__r.XC_Contact__r.XC_MainLegalEntity__c, XC_Opportunity__r.XC_Contact__r.XC_Preferredlanguageofcontact__c
                                                                      FROM WorkOrder WHERE Id IN :workOrderIds]);
            
            if(!workOrderMap.values().isEmpty() && workOrderMap.values().size() == workOrderIds.size()) {
                
                Map<Id, XC_Document_to_sign__c> docToSignMap = new Map<Id, XC_Document_to_sign__c> ([SELECT XC_Doxee_ID_external__c, XC_WorkOrder__c
                                                                                                     FROM XC_Document_to_sign__c WHERE XC_WorkOrder__c IN: mapDocumentIdParentId.values()
                                                                                                     AND XC_Doxee_ID_external__c IN :mapDocumentIdParentId.keySet()]);
                
                List<XC_Document_to_sign__c> docToSignList = docToSignMap.values();
                Map<String, String> mapDocIdWorkOrderId = createMapDocIdObject(docToSignList, 'WorkOrder');
                
                Map<String, Object> mapUtil = new Map<String, Object>{  'docListToSign' => docListToSign,
                    'docListToInsert' => docListToInsert,
                    'mapDocIObjId' => mapDocIdWorkOrderId,
                    'apiName' => 'XC_WorkOrder__c'
                    };
                        Set<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> ciDocList = utilDoc(mapUtil);
                
                Map<String, Map<String,Object>> mapWorkOrderIdCI = populateCustomerInteractionWorkOrd(CIdocList, workOrderMap);
                Map<String, Map<String,Object>> mapWorkOrdIdCI = populateCustomerInteractionWorkOrd(docListNotToSign, workOrderMap);
                
                listCustomerInteraction.addAll(mapWorkOrderIdCI.values());
                listCustomerInteraction.addAll(mapWorkOrdIdCI.values());
            } else{
                response.Result.ErrorCode = '400';
                response.Result.Message =  Label.XC_CL_ObjectId;
                return response;
            }
        }
        
        
        // Account
        else if(!accountIds.isEmpty()){
            
            
            
            Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id,XC_ContactToNotify__c,XC_GiveDataTo_EnelXItalia__c,XC_Segment__c,  (SELECT Id, Name, Email, XC_ContactPhone__c, XC_PhonePrefix__c, XC_MainLegalEntity__c, XC_Preferredlanguageofcontact__c FROM Contacts WHERE XC_PrimaryContact__c = true)
                                                                FROM Account WHERE Id IN :accountIds]);
            
            system.debug('prova: '+accountMap);
            
            if(!accountMap.values().isEmpty() && accountMap.values().size() == accountIds.size()) {
                system.debug('prova');
                
                Map<String, Object> mapUtil = new Map<String, Object>{ 'docListToSign' => docListToSign,
                    'docListToInsert' => docListToInsert,
                    'apiName' => 'XC_Account__c'
                    };
                        Set<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> ciDocList = utilDoc(mapUtil);
                
                Map<String, Map<String,Object>> mapAccountIdCI = populateCustomerInteractionAcc(CIdocList, accountMap, mapCase);
                Map<String, Map<String,Object>> mapAccIdCI = populateCustomerInteractionAcc(docListNotToSign, accountMap, mapCase);
                
                listCustomerInteraction.addAll(mapAccountIdCI.values());
                listCustomerInteraction.addAll(mapAccIdCI.values());
                
                system.debug('prova: '+listCustomerInteraction);
            } else{
                response.Result.ErrorCode = '400';
                response.Result.Message =  Label.XC_CL_ObjectId;
                return response;
            }
        }
        
        
        // Asset
        /*else if(!assetIds.isEmpty()){

            Map<Id, Asset> assetMap = new Map<Id, Asset>([SELECT Id, ContactId,Contact.Name, Contact.Email, Contact.AccountId
            FROM Asset WHERE Id IN :assetIds]);

            if(!assetMap.values().isEmpty() && assetMap.values().size() == assetIds.size()) {

                Map<Id, XC_Document_to_sign__c> docToSignMap = new Map<Id, XC_Document_to_sign__c> ([SELECT XC_Doxee_ID_external__c, XC_Asset__c
                FROM XC_Document_to_sign__c WHERE XC_Asset__c IN: mapDocumentIdParentId.values()
                AND XC_Doxee_ID_external__c IN :mapDocumentIdParentId.keySet()]);

                List<XC_Document_to_sign__c> docToSignList = docToSignMap.values();
                Map<String, String> mapDocIdAssetId = createMapDocIdObject(docToSignList, 'Asset');

                Map<String, Object> mapUtil = new Map<String, Object>{  'docListToSign' => docListToSign,
                'docListToInsert' => docListToInsert,
                'mapDocIObjId' => mapDocIdAssetId,
                'apiName' => 'XC_Asset__c'
                };
                Set<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> ciDocList = utilDoc(mapUtil);

                //Map<String, Map<String,Object>> mapAssetCI = populateCustomerInteractionWorkOrd(CIdocList, assetMap);
                //Map<String, Map<String,Object>> mapAssIdCI = populateCustomerInteractionWorkOrd(docListNotToSign, assetMap);

                //listCustomerInteraction.addAll(mapAssetIdCI.values());
                //listCustomerInteraction.addAll(mapAssIdCI.values());
            } else{
                response.Result.ErrorCode = '400';
                response.Result.Message =  'ERROR. ObjectId not Found';
                return response;
            }
        } */
        
        
        // Contract
        else if(!contractIds.isEmpty()){
            
            Map<Id, Contract> contractMap = new Map<Id, Contract>([SELECT Opportunity__c,  Id, Opportunity__r.XC_Contact__c, AccountId, Opportunity__r.XC_Contact__r.Name,  Opportunity__r.XC_Contact__r.Email, Opportunity__r.XC_Contact__r.XC_Preferredlanguageofcontact__c,  Opportunity__r.XC_LegalEntity__c, Opportunity__r.Owner.Email, XC_Configurations__c, XC_Segment__c  
                                                                   FROM Contract WHERE Id IN :contractIds]);
            
            if(!contractMap.values().isEmpty() && contractMap.values().size() == contractIds.size()) {
                
                Map<Id, XC_Document_to_sign__c> docToSignMap = new Map<Id, XC_Document_to_sign__c> ([SELECT XC_Doxee_ID_external__c, XC_ConfigurationID__c
                                                                                                     FROM XC_Document_to_sign__c WHERE XC_ConfigurationID__c IN: mapDocumentIdParentId.values()
                                                                                                     AND XC_Doxee_ID_external__c IN :mapDocumentIdParentId.keySet()]);
                
                List<XC_Document_to_sign__c> docToSignList = docToSignMap.values();
                /*Map<String, String> mapDocIdContractId = createMapDocIdObject(docToSignList, 'NE__Order__c');

                Map<String, Object> mapUtil = new Map<String, Object>{  'docListToSign' => docListToSign,
                'docListToInsert' => docListToInsert,
                'mapDocIObjId' => mapDocIdContractId,
                'apiName' => 'Contract'
                };
                Set<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> ciDocList = utilDoc(mapUtil);

                Map<String, Map<String,Object>> mapContractIdCI = populateCustomerInteractionContract(CIdocList, contractMap);*/
                Map<String, Map<String,Object>> mapContrIdCI = populateCustomerInteractionContract(docListNotToSign, contractMap);
                if(!contractSigned.isEmpty()){
                    for(Id contractID : contractSigned){
                        if(contractMap.get(contractID).XC_Segment__c == 'B2B' || contractMap.get(contractID).XC_Segment__c == 'B2G'){
                            mapContrIdCI.get(String.valueOf(contractID)).put('customerType', 'Order_Send_Signed_contract_Email'); 
                            mapContrIdCI.get(String.valueOf(contractID)).put('SurveyId', 'Survey_Signed_Contract');
                        }
                    }
                }
                //listCustomerInteraction.addAll(mapContractIdCI.values());
                listCustomerInteraction.addAll(mapContrIdCI.values());
            } else{
                response.Result.ErrorCode = '400';
                response.Result.Message =  'ERROR. ObjectId not Found';
                return response;
            }
        }


        
         // Order Item 
        else if(!orderItemIds.isEmpty()){
            List<NE__OrderItem__c> listOfOrderItem = new List<NE__OrderItem__c>([SELECT Id,  NE__OrderId__r.NE__OptyId__c, NE__OrderId__r.NE__OptyId__r.Contact__c, 
                                                                                 NE__OrderId__r.NE__OptyId__r.Contact__r.Name, NE__OrderId__r.NE__OptyId__r.Contact__r.Email
                                                                                 FROM NE__OrderItem__c 
                                                                                 WHERE Id IN :orderItemIds]);
            if(!listOfOrderItem.isEmpty() && listOfOrderItem.size() == orderItemIds.size()) {
                List<XC_DocumentType__c> listOfDocumentType = new List<XC_DocumentType__c> ([SELECT Id, XC_ConfigurationItem__c
                                                                                             FROM XC_DocumentType__c 
                                                                                             WHERE XC_ConfigurationItem__c IN: orderItemIds AND Category__c =: Label.XC_CL_Document_CIE
                                                                                             ORDER BY CreatedDate desc]); 
                List<XC_DocumentType__c> listOfDocTypeToUpdate = new List<XC_DocumentType__c>();
                for(XC_REST_DoxeeReadFileURL_W.WrapperRequestFile wrDoc : docListNotToSign) {
                    if(orderItemIds.contains(listOfDocumentType[0].XC_ConfigurationItem__c)) {
                       XC_DocumentType__c docToUpdate = new XC_DocumentType__c(Id= listOfDocumentType[0].id);
                        docToUpdate.XC_DoxeeUrl__c = wrDoc.DocumentURL;
                        listOfDocTypeToUpdate.add(docToUpdate);
                    }
                }
                XC_UTIL_Sobject.updateListRecords(listOfDocTypeToUpdate);
            } else{
                response.Result.ErrorCode = '400';
                response.Result.Message =  'ERROR. ObjectId not Found';
                return response;
            }
        }




        // Billing Profile 
        else if(!billingProfileIds.isEmpty()){

            Map<Id,NE__Billing_Profile__c> listOfbp = new Map<Id,NE__Billing_Profile__c>([
                SELECT Id, NE__Account__c
                FROM NE__Billing_Profile__c 
                WHERE Id IN :billingProfileIds
            ]);

            List<String> accId = new List<String>();
            for(NE__Billing_Profile__c b:listOfbp.values()){
                accId.add(b.NE__Account__c);
            }

            Map<Id,Account> listOfAcc = new Map<Id,Account>([
                SELECT id, 
                    (SELECT id, AccountId, Name, Email, XC_Preferredlanguageofcontact__c, XC_MainLegalEntity__c 
                    FROM Contacts where XC_PrimaryContact__c = true) 
                FROM Account
                WHERE Id IN :accId
            ]);

            Map<Id,Contact> mapCon = new Map<Id,Contact>();
            for(NE__Billing_Profile__c b:listOfbp.values()){
                mapCon.put(b.Id, listOfAcc.get(b.NE__Account__c).contacts[0]);
            }

            if(!listOfbp.values().isEmpty() && listOfbp.values().size() == billingProfileIds.size()) {
                Map<Id, XC_Document_to_sign__c> docToSignMap = new Map<Id, XC_Document_to_sign__c>([SELECT XC_Doxee_ID_external__c, XC_ConfigurationId__c 
                                                FROM XC_Document_to_sign__c WHERE XC_ConfigurationID__c IN: mapDocumentIdParentId.values() 
                                                AND XC_Doxee_ID_external__c IN :mapDocumentIdParentId.keySet()]);

                List<XC_Document_to_sign__c> docToSignList = docToSignMap.values();     

                Map<String, String> mapDoc = createMapDocIdObject(docToSignList, 'NE__Billing_Profile__c');

                Map<String, Object> mapUtil = new Map<String, Object>{  
                    'docListToSign' => docListToSign,
                    'docListToInsert' => docListToInsert,
                    'mapDocIObjId' => mapDoc,
                    'apiName' => 'NE__Billing_Profile__c'
                };
                Set<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> ciDocList = utilDoc(mapUtil);

                Map<String, Map<String,Object>> billingProfileCi = populateCustomerInteractionBp(CIdocList, mapCon);
                Map<String, Map<String,Object>> billingProfCi = populateCustomerInteractionBp(docListNotToSign, mapCon);

                listCustomerInteraction.addAll(billingProfileCi.values());
                listCustomerInteraction.addAll(billingProfCi.values());
            } else{
                response.Result.ErrorCode = '400';
                response.Result.Message =  Label.XC_CL_ObjectId;
                return response;
            }
        } 
        //Case
        else if(!caseIds.isEmpty()){
            
            Map<Id, Case> caseMap = new Map<Id, Case>([SELECT ContactId, AccountId, XC_Opportunity__c, Contact.Name, ContactEmail, contact.XC_Preferredlanguageofcontact__c, XC_LegalEntity__c FROM Case WHERE Id IN :caseIds]);
            
            if(!caseMap.values().isEmpty() && caseMap.values().size() == caseMap.size()) {
                
                
                Map<String, Map<String,Object>> mapCaseIdCI = populateCustomerInteractionCase(docListNotToSign, caseMap);
                
                //listCustomerInteraction.addAll(mapContractIdCI.values());

                //listCustomerInteraction.addAll(mapCaseIdCI.values()); //tbd 
            } else{
                response.Result.ErrorCode = '400';
                response.Result.Message =  'ERROR. ObjectId not Found';
                return response;
            }
        }else if(!OpportunityIds.isEmpty()){ 
            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT  XC_Contact__c, id, AccountId, XC_Contact__r.Name, XC_Contact__r.Email, XC_Contact__r.XC_Preferredlanguageofcontact__c, XC_LegalEntity__c, XC_Segment__c FROM  Opportunity WHERE Id IN: OpportunityIds]);
            if(!oppMap.values().isEmpty() && oppMap.values().size() == oppMap.size()){
                Map<String, Map<String,Object>> mapOppIdCI = populateCustomerInteractionOpp(docListNotToSign, oppMap);
                listCustomerInteraction.addAll(mapOppIdCI.values());
            }else{
                response.Result.ErrorCode = '400';
                response.Result.Message =  'ERROR. ObjectId not Found';
                return response;
            }
        }
        
        
        // Order Item
        /*else if(!orderItemIds.isEmpty()){

            Map<Id, NE__OrderItem__c> ordItemMap = new Map<Id, NE__OrderItem__c>([SELECT Id,  NE__OrderId__r.NE__OptyId__c, NE__OrderId__r.NE__OptyId__r.Contact__c,
            NE__OrderId__r.NE__OptyId__r.Contact__r.Name, NE__OrderId__r.NE__OptyId__r.Contact__r.Email
            FROM NE__OrderItem__c WHERE Id IN :orderItemIds]);

            if(!ordItemMap.values().isEmpty() && ordItemMap.values().size() == orderItemIds.size()) {

                Map<Id, XC_Document_to_sign__c> docToSignMap = new Map<Id, XC_Document_to_sign__c> ([SELECT XC_Doxee_ID_external__c, XC_OrderItem__c
                FROM XC_Document_to_sign__c WHERE XC_OrderItem__c IN: mapDocumentIdParentId.values()
                AND XC_Doxee_ID_external__c IN :mapDocumentIdParentId.keySet()]);

                List<XC_Document_to_sign__c> docToSignList = docToSignMap.values();
                Map<String, String> mapDocIdOrdItemId = createMapDocIdObject(docToSignList, 'NE__OrderItem__c');

                Map<String, Object> mapUtil = new Map<String, Object>{  'docListToSign' => docListToSign,
                'docListToInsert' => docListToInsert,
                'mapDocIObjId' => mapDocIdOrdItemId,
                'apiName' => 'XC_OrderItem__c'
                };
                Set<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> ciDocList = utilDoc(mapUtil);

                //Map<String, Map<String,Object>> mapOrderItemIdCI = populateCustomerInteractionWorkOrd(CIdocList, ordItemMap);
                //Map<String, Map<String,Object>> mapOrdItemIdCI = populateCustomerInteractionWorkOrd(docListNotToSign, ordItemMap);

                //listCustomerInteraction.addAll(mapOrderItemIdCI.values());
                //listCustomerInteraction.addAll(mapOrdItemIdCI.values());
            } else{
                response.Result.ErrorCode = '400';
                response.Result.Message =  'ERROR. ObjectId not Found';
                return response;
            }
        }*/
        
        //List<XC_UTIL_SObject.WrapperResult> resultInsert = new List<XC_UTIL_SObject.WrapperResult>();
        
        if(!docListToInsert.isEmpty()){
            List<XC_UTIL_SObject.WrapperResult> resultInsert = XC_UTIL_SObject.insertListRecords(docListToInsert);
            for(XC_UTIL_SObject.WrapperResult wr : resultInsert) {
                if(!wr.success) {
                    response.Result.ErrorCode = '500';
                    response.Result.Message = 'INTERNAL ERROR';
                    response.Result.LogError = 'INTERNAL ERROR' + wr.errorMessage;
                    return response;
                }
            }
        }
        if(!listCustomerInteraction.isEmpty()){
            XC_UTIL_CustomerInteractionGeneration.manageCustomerInteractionInsert(listCustomerInteraction);
        }
        
        /*if(!listCustomerInteraction.isEmpty() && !docListToInsert.isEmpty()){
            resultInsert = XC_UTIL_SObject.insertListRecords(docListToInsert);
            for(XC_UTIL_SObject.WrapperResult wr : resultInsert) {
                if(!wr.success) {
                    response.Result.ErrorCode = '500';
                    response.Result.Message = 'INTERNAL ERROR';
                    response.Result.LogError = 'INTERNAL ERROR' + wr.errorMessage;
                    return response;
                }
            }
            XC_UTIL_CustomerInteractionGeneration.manageCustomerInteractionInsert(listCustomerInteraction);
            }else if (!listCustomerInteraction.isEmpty() && (mapDocumentIdParentId.isEmpty() /*&& mapDocumentIdParentIdWO.isEmpty() && mapDocumentIdParentIdOpp.isEmpty()&& mapDocumentIdParentIdCase.isEmpty())){
            //XC_UTIL_CustomerInteractionGeneration.manageCustomerInteractionInsert(listCustomerInteraction);
        }else {
            response.Result.ErrorCode = '500';
            response.Result.Message = 'INTERNAL ERROR';
            response.Result.LogError = 'INTERNAL ERROR';
            return response;
        }*/
        
        response.Result.Message = 'Operation completed successfully';
        response.Result.ErrorCode = '0';
        
        return response;
    }
    
    
    /**
    * UtilDoc.
    *
    * @param mapUtil
    * @return Set<WrapperRequestFile> ->  the WrapperRequestFile
    * @description Method to populate a WrapperRequestFile
    */
    public static Set<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> utilDoc(Map<String, Object> mapUtil){
        
        List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> docListToSign  = (List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile>) mapUtil.get('docListToSign');
        List<XC_Document_To_Sign__c> docListToInsert = (List<XC_Document_To_Sign__c>) mapUtil.get('docListToInsert');
        Map<String, String> mapDocIObjId = (Map<String, String>) mapUtil.get('mapDocIObjId');
        String apiName = (String) mapUtil.get('apiName');
        
        Set<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> ciDocList = new Set<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> ();
        
        for(XC_REST_DoxeeReadFileURL_W.WrapperRequestFile wrDoc : docListToSign) {
            
            if(!mapDocIObjId.containsKey(wrDoc.DocumentID) || mapDocIObjId.get(wrDoc.DocumentID) != wrDoc.ObjectID) {
                XC_Document_To_Sign__c docToInsert = new XC_Document_To_Sign__c();
                docToInsert.XC_Doxee_URL__c = wrDoc.DocumentURL;
                docToInsert.XC_Doxee_ID_external__c = wrDoc.DocumentID;
                docToInsert.put(apiName , wrDoc.ObjectID);
                docListToInsert.add(docToInsert);
            }
            CIdocList.add(wrDoc);
        }
        
        return CIdocList;
    }

    
    
    
    /**
    * PopulateCustomerInteractionOrd.
    *
    * @param ciDocList the c idoc list
    * @param orderMap the order map
    * @return the map
    * @description Method to populate a Customer Interaction related to an Order
    */
    public static Map<String, Map<String,Object>> populateCustomerInteractionOrd(Set<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> ciDocList, Map<Id, NE__Order__c> orderMap){
        
        List<String> docUrlList = new List<String>();
        List<String> docIDList = new List<String>();
        Map<String, Object> mapCustInter = new Map<String, Object>();
        Map<String, Map<String,Object>> mapOrderIdCI = new Map<String, Map<String,Object>>();
        //List<XC_CM_CountryLegalEntityAssociation__mdt> listLegalEntityB2B = [select  XC_LegalEntity__c from XC_CM_CountryLegalEntityAssociation__mdt WHERE XC_Category__c = 'B2B'];
        for(XC_REST_DoxeeReadFileURL_W.WrapperRequestFile wrDoc : CIdocList) {
            if(mapOrderIdCI.containsKey(wrDoc.ObjectID)){
                String listUrl = (String)mapOrderIdCI.get(wrDoc.ObjectID).get('docURL');
                listUrl += ';\n' + wrDoc.DocumentURL;
                mapOrderIdCI.get(wrDoc.ObjectID).put('docURL', listUrl);
                String listIDs = (String)mapOrderIdCI.get(wrDoc.ObjectID).get('docID');
                listIDs += '|' + wrDoc.DocumentID;
                mapOrderIdCI.get(wrDoc.ObjectID).put('docID', listIDs);
            } else{
                docUrlList = new List<String>();
                docIdList = new List<String>();
                mapCustInter = new Map<String, Object>();
                mapCustInter.put('orderId', wrDoc.ObjectID);
                mapCustInter.put('opportunityId', orderMap.get(wrDoc.ObjectID).NE__OptyId__c);
                mapCustInter.put('accountId', orderMap.get(wrDoc.ObjectID).NE__OptyId__r.XC_Contact__r.AccountId);
                mapCustInter.put('contactId', orderMap.get(wrDoc.ObjectID).NE__OptyId__r.XC_Contact__r.Id);
                mapCustInter.put('fullName', orderMap.get(wrDoc.ObjectID).NE__OptyId__r.XC_Contact__r.Name);
                mapCustInter.put('email', orderMap.get(wrDoc.ObjectID).NE__OptyId__r.XC_Contact__r.Email);
                mapCustInter.put('preferredLanguage', orderMap.get(wrDoc.ObjectID).NE__OptyId__r.XC_Contact__r.XC_Preferredlanguageofcontact__c);
                mapCustInter.put('legalEntity', orderMap.get(wrDoc.ObjectID).NE__OptyId__r.XC_LegalEntity__c );
                mapCustInter.put('ownerEmail', orderMap.get(wrDoc.ObjectID).NE__OptyId__r.Owner.Email );
                docUrlList.add(wrDoc.DocumentURL);
                mapCustInter.put('docURL', String.join(docUrlList,','));
                docIDList.add(wrDoc.DocumentID);
                mapCustInter.put('docID', String.join(docIDList,','));
                //if(XC_UTIL_Sobject.getListFieldValues(listLegalEntityB2B, 'XC_LegalEntity__c').contains(orderMap.get(wrDoc.ObjectID).NE__OptyId__r.XC_LegalEntity__c)){
                if(orderMap.get(wrDoc.ObjectID).XC_Segment__c == 'B2B' || orderMap.get(wrDoc.ObjectID).XC_Segment__c == 'B2G') {
                    if(orderMap.get(wrDoc.ObjectID).RecordType.DeveloperName == 'Quote'){
                        mapCustInter.put('customerType', 'Quote_Doc');
                    }else{
                        mapCustInter.put('customerType', 'Contract_Doc');
                    }
                }else{
                    mapCustInter.put('customerType', 'Send_Documents');
                }
                mapOrderIdCI.put(wrDoc.ObjectID, mapCustInter);
            }
        }
        return  mapOrderIdCI;
    }
    
    
    
    /**
    * populateCustomerInteractionContract.
    *
    * @param ciDocList the c idoc list
    * @param orderMap the order map
    * @return the map
    * @description Method to populate a Customer Interaction related to an Order
    */
    public static Map<String, Map<String,Object>> populateCustomerInteractionContract(Set<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> ciDocList, Map<Id, Contract> orderMap){
        
        List<String> docUrlList = new List<String>();
        List<String> docIdList = new List<String>();
        Map<String, Object> mapCustInter = new Map<String, Object>();
        Map<String, Map<String,Object>> mapOrderIdCI = new Map<String, Map<String,Object>>();
        for(XC_REST_DoxeeReadFileURL_W.WrapperRequestFile wrDoc : CIdocList) {
            if(mapOrderIdCI.containsKey(wrDoc.ObjectID)){
                String listUrl = (String)mapOrderIdCI.get(wrDoc.ObjectID).get('docURL');
                String listId = (String)mapOrderIdCI.get(wrDoc.ObjectID).get('docID');
                listUrl += '|' + wrDoc.DocumentURL;
                listId += '|' + wrDoc.DocumentID;
                mapOrderIdCI.get(wrDoc.ObjectID).put('docURL', listUrl);
                mapOrderIdCI.get(wrDoc.ObjectID).put('docID', listId);
            } else{
                docUrlList = new List<String>();
                docIdList = new List<String>();
                mapCustInter = new Map<String, Object>();
                mapCustInter.put('orderId',  orderMap.get(wrDoc.ObjectID).XC_Configurations__c);
                mapCustInter.put('opportunityId', orderMap.get(wrDoc.ObjectID).Opportunity__c);
                mapCustInter.put('accountId', orderMap.get(wrDoc.ObjectID).AccountId);
                mapCustInter.put('contactId', orderMap.get(wrDoc.ObjectID).Opportunity__r.XC_Contact__c);
                mapCustInter.put('contractId', orderMap.get(wrDoc.ObjectID).id);
                mapCustInter.put('fullName', orderMap.get(wrDoc.ObjectID).Opportunity__r.XC_Contact__r.Name);
                mapCustInter.put('email', orderMap.get(wrDoc.ObjectID).Opportunity__r.XC_Contact__r.Email);
                mapCustInter.put('preferredLanguage', orderMap.get(wrDoc.ObjectID).Opportunity__r.XC_Contact__r.XC_Preferredlanguageofcontact__c);
                mapCustInter.put('legalEntity', orderMap.get(wrDoc.ObjectID).Opportunity__r.XC_LegalEntity__c );
                mapCustInter.put('ownerEmail', orderMap.get(wrDoc.ObjectID).Opportunity__r.Owner.Email );
                docUrlList.add(wrDoc.DocumentURL);
                docIdList.add(wrDoc.DocumentID);
                mapCustInter.put('docURL', String.join(docUrlList,'|'));
                mapCustInter.put('docID', String.join(docIdList,'|'));
                mapCustInter.put('customerType', 'Quote_Doc');
                mapOrderIdCI.put(wrDoc.ObjectID, mapCustInter);
            }
        }
        return  mapOrderIdCI;
    }
    
    
    /**
    * PopulateCustomerInteractionWorkOrd.
    *
    * @param ciDocList the c idoc list
    * @param workOrderMap the work order map
    * @return the map
    * @description Method to populate a Customer Interaction related to a WorkOrder
    */
    public static Map<String, Map<String,Object>> populateCustomerInteractionWorkOrd(Set<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> ciDocList, Map<Id, WorkOrder> workOrderMap){
        
        List<String> docUrlList = new List<String>();
        List<String> docIDList = new List<String>();
        Map<String, Object> mapCustInter = new Map<String, Object>();
        Map<String, Map<String,Object>> mapWorkOrderIdCI = new Map<String, Map<String,Object>>();
        for(XC_REST_DoxeeReadFileURL_W.WrapperRequestFile wrDoc : CIdocList) {
            if(mapWorkOrderIdCI.containsKey(wrDoc.ObjectID)){
                String listUrl = (String)mapWorkOrderIdCI.get(wrDoc.ObjectID).get('docURL');
                listUrl += ';\n' + wrDoc.DocumentURL;
                mapWorkOrderIdCI.get(wrDoc.ObjectID).put('docURL', listUrl);
                String listIDs = (String)mapWorkOrderIdCI.get(wrDoc.ObjectID).get('docID');
                listIDs += '|' + wrDoc.DocumentID;
                mapWorkOrderIdCI.get(wrDoc.ObjectID).put('docID', listIDs);
            } else{
                docUrlList = new List<String>();
                mapCustInter = new Map<String, Object>();
                mapCustInter.put('workorderId', wrDoc.ObjectID);
                mapCustInter.put('opportunityId', workOrderMap.get(wrDoc.ObjectID).XC_Opportunity__c);
                mapCustInter.put('accountId', workOrderMap.get(wrDoc.ObjectID).XC_Opportunity__r.XC_Contact__r.AccountId);
                mapCustInter.put('contactId', workOrderMap.get(wrDoc.ObjectID).XC_Opportunity__r.XC_Contact__r.Id);
                mapCustInter.put('fullName', workOrderMap.get(wrDoc.ObjectID).XC_Opportunity__r.XC_Contact__r.Name);
                mapCustInter.put('email', workOrderMap.get(wrDoc.ObjectID).XC_Opportunity__r.XC_Contact__r.Email);
                mapCustInter.put('preferredlanguage', workOrderMap.get(wrDoc.ObjectID).XC_Opportunity__r.XC_Contact__r.XC_Preferredlanguageofcontact__c);
                docUrlList.add(wrDoc.DocumentURL);
                mapCustInter.put('docURL', String.join(docUrlList,','));
                docIDList.add(wrDoc.DocumentID);
                mapCustInter.put('docID', String.join(docIDList,','));
                mapCustInter.put('customerType', 'Send_Documents');
                mapWorkOrderIdCI.put(wrDoc.ObjectID, mapCustInter);
                mapCustInter.put('legalEntity', workOrderMap.get(wrDoc.ObjectID).XC_Opportunity__r.XC_LegalEntity__c);
            }
        }
        return  mapWorkOrderIdCI;
        }


    /**
     * PopulateCustomerInteraction Account.
     *
     * @param ciDocList the c idoc list
     * @param accountMap the order map
     * @param mapCase 
     * @return the map
     * @description Method to populate a Customer Interaction related to an Order
     */
    public static Map<String, Map<String,Object>> populateCustomerInteractionAcc(Set<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> ciDocList, Map<Id, Account> accountMap, Map<String, Case> mapCase){

        List<String> docUrlList = new List<String>();
        List<String> docIDList = new List<String>();
        Map<String, Object> mapCustInter = new Map<String, Object>();
        Map<String, Map<String,Object>> mapAccountIdCI = new Map<String, Map<String,Object>>();
        for(XC_REST_DoxeeReadFileURL_W.WrapperRequestFile wrDoc : CIdocList) {
            if(mapAccountIdCI.containsKey(wrDoc.ObjectID)){
                String listUrl = (String)mapAccountIdCI.get(wrDoc.ObjectID).get('docURL');
                listUrl += ';\n' + wrDoc.DocumentURL;
                mapAccountIdCI.get(wrDoc.ObjectID).put('docURL', listUrl);
                String listIDs = (String)mapAccountIdCI.get(wrDoc.ObjectID).get('docID');
                listIDs += '|' + wrDoc.DocumentID;
                mapAccountIdCI.get(wrDoc.ObjectID).put('docID', listIDs);
            } else{
                docUrlList = new List<String>();
                mapCustInter = new Map<String, Object>();
                //mapCustInter.put('orderId', wrDoc.ObjectID);
                //mapCustInter.put('opportunityId', accountMap.get(wrDoc.ObjectID).NE__OptyId__c);
                if(accountMap.get(wrDoc.ObjectID).Contacts.size() > 0){
                    mapCustInter.put('accountId', accountMap.get(wrDoc.ObjectID).Id);
                    if((accountMap.get(wrDoc.ObjectID).XC_Segment__c == 'B2B' || accountMap.get(wrDoc.ObjectID).XC_Segment__c == 'B2G') 
					&& accountMap.get(wrDoc.ObjectID).XC_GiveDataTo_EnelXItalia__c == true) {
                    mapCustInter.put('contactId', accountMap.get(wrDoc.ObjectID).XC_ContactToNotify__c);
				  } else {
				    mapCustInter.put('contactId', accountMap.get(wrDoc.ObjectID).Contacts[0].Id);
				      } 
                   // mapCustInter.put('contactId', accountMap.get(wrDoc.ObjectID).Contacts[0].Id);
                    mapCustInter.put('fullName', accountMap.get(wrDoc.ObjectID).Contacts[0].Name);
                    mapCustInter.put('email', accountMap.get(wrDoc.ObjectID).Contacts[0].Email);
                    mapCustInter.put('preferredlanguage', accountMap.get(wrDoc.ObjectID).Contacts[0].XC_Preferredlanguageofcontact__c);
                    docUrlList.add(wrDoc.DocumentURL);
                    mapCustInter.put('docURL', String.join(docUrlList,','));
                    docIDList.add(wrDoc.DocumentID);
                    mapCustInter.put('docID', String.join(docIDList,','));
                    System.debug('*ID :' + wrDoc.DocumentID);
                    System.debug('*ID :' + mapCustInter.get('docId'));
                    mapCustInter.put('legalEntity', accountMap.get(wrDoc.ObjectID).Contacts[0].XC_MainLegalEntity__c);
                    if(wrDoc.Category == 'SF_INVOICE'){
                        mapCustInter.put('customerType', 'Send_Documents');
                        mapCustInter.put('phone', accountMap.get(wrDoc.ObjectID).Contacts[0].XC_PhonePrefix__c +''+ accountMap.get(wrDoc.ObjectID).Contacts[0].XC_ContactPhone__c);
                        mapCustInter.put('caseId', mapCase.get(wrDoc.DocumentID).Id);
                    } else{
                        mapCustInter.put('customerType', 'Send_Documents');
                    }
                    mapAccountIdCI.put(wrDoc.ObjectID, mapCustInter);
                }
            }
        }
        return  mapAccountIdCI;
    }

    /**
     * PopulateCustomerInteractionBP.
     *
     * @param ciDocList the c idoc list
     * @param bpMap the order map
     * @return the map
     * @description Method to populate a Customer Interaction related to an Order
     */
    public static Map<String, Map<String,Object>> populateCustomerInteractionBp(Set<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> ciDocList, Map<Id, Contact> bpMap){

        List<String> docUrlList = new List<String>();
        List<String> docIDList = new List<String>();
        Map<String, Object> mapCustInter = new Map<String, Object>();
        Map<String, Map<String,Object>> mapOrderIdCI = new Map<String, Map<String,Object>>();
                for(XC_REST_DoxeeReadFileURL_W.WrapperRequestFile wrDoc : CIdocList) {
                    if(mapOrderIdCI.containsKey(wrDoc.ObjectID)){
                        String listUrl = (String)mapOrderIdCI.get(wrDoc.ObjectID).get('docURL');
                        listUrl += ';\n' + wrDoc.DocumentURL;
                        mapOrderIdCI.get(wrDoc.ObjectID).put('docURL', listUrl);
                        String listIDs = (String)mapOrderIdCI.get(wrDoc.ObjectID).get('docID');
                        listIDs += '|' + wrDoc.DocumentID;
                        mapOrderIdCI.get(wrDoc.ObjectID).put('docID', listIDs);
                    } else{
                        docUrlList = new List<String>();
                        mapCustInter = new Map<String, Object>();
                        //mapCustInter.put('orderId', wrDoc.ObjectID);
                        //mapCustInter.put('opportunityId', bpMap.get(wrDoc.ObjectID).NE__OptyId__c);
                        mapCustInter.put('accountId', bpMap.get(wrDoc.ObjectID).AccountId);
                        mapCustInter.put('billingProfileId', wrDoc.ObjectID);
                        mapCustInter.put('contactId', bpMap.get(wrDoc.ObjectID).Id);
                        mapCustInter.put('fullName', bpMap.get(wrDoc.ObjectID).Name);
                        mapCustInter.put('email', bpMap.get(wrDoc.ObjectID).Email);
                        mapCustInter.put('preferredlanguage', bpMap.get(wrDoc.ObjectID).XC_Preferredlanguageofcontact__c);
                        docUrlList.add(wrDoc.DocumentURL);
                        mapCustInter.put('docURL', String.join(docUrlList,','));
                        docIDList.add(wrDoc.DocumentID);
                        mapCustInter.put('docID', String.join(docIDList,','));
                        mapCustInter.put('customerType', 'Send_Documents');
                        mapOrderIdCI.put(wrDoc.ObjectID, mapCustInter);
                        mapCustInter.put('legalEntity', bpMap.get(wrDoc.ObjectID).XC_MainLegalEntity__c);
                        System.debug('*****legalEntity: ' + mapCustInter.get('legalEntity'));
                    }
                }
        return  mapOrderIdCI;
    }
    /**
     * PopulateCustomerInteractionBP.
     *
     * @param ciDocList the c idoc list
     * @param bpMap the order map
     * @return the map
     * @description Method to populate a Customer Interaction related to an Order
     */
    public static Map<String, Map<String,Object>> populateCustomerInteractionCase(Set<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> ciDocList, Map<Id, Case> caseMap){

        List<String> docUrlList = new List<String>();
        List<String> docIDList = new List<String>();
        Map<String, Object> mapCustInter = new Map<String, Object>();
        Map<String, Map<String,Object>> mapOrderIdCI = new Map<String, Map<String,Object>>();
                for(XC_REST_DoxeeReadFileURL_W.WrapperRequestFile wrDoc : CIdocList) {
                    if(mapOrderIdCI.containsKey(wrDoc.ObjectID)){
                        String listUrl = (String)mapOrderIdCI.get(wrDoc.ObjectID).get('docURL');
                        listUrl += ';\n' + wrDoc.DocumentURL;
                        mapOrderIdCI.get(wrDoc.ObjectID).put('docURL', listUrl);
                        String listIDs = (String)mapOrderIdCI.get(wrDoc.ObjectID).get('docID');
                        listIDs += '|' + wrDoc.DocumentID;
                        mapOrderIdCI.get(wrDoc.ObjectID).put('docID', listIDs);
                    } else{
                        docUrlList = new List<String>();
                        mapCustInter = new Map<String, Object>();
                        //mapCustInter.put('orderId', wrDoc.ObjectID);
                        //mapCustInter.put('opportunityId', bpMap.get(wrDoc.ObjectID).NE__OptyId__c);
                        mapCustInter.put('accountId', caseMap.get(wrDoc.ObjectID).AccountId);
                        mapCustInter.put('caseId', wrDoc.ObjectID);
                        mapCustInter.put('contactId', caseMap.get(wrDoc.ObjectID).ContactId);
                        mapCustInter.put('fullName', caseMap.get(wrDoc.ObjectID).Contact.Name);
                        mapCustInter.put('email', caseMap.get(wrDoc.ObjectID).ContactEmail);
                        mapCustInter.put('preferredlanguage', caseMap.get(wrDoc.ObjectID).contact.XC_Preferredlanguageofcontact__c);
                        docUrlList.add(wrDoc.DocumentURL);
                        mapCustInter.put('docURL', String.join(docUrlList,','));
                        docIDList.add(wrDoc.DocumentID);
                        mapCustInter.put('docID', String.join(docIDList,','));
                        mapCustInter.put('customerType', 'Send_Documents');
                        mapOrderIdCI.put(wrDoc.ObjectID, mapCustInter);
                        mapCustInter.put('legalEntity', caseMap.get(wrDoc.ObjectID).XC_LegalEntity__c );
                        System.debug('*****legalEntity: ' + mapCustInter.get('legalEntity'));
                    }
                }
        return  mapOrderIdCI;
    }
        /**
     * PopulateCustomerInteractionBP.
     *
     * @param ciDocList the c idoc list
     * @param bpMap the order map
     * @return the map
     * @description Method to populate a Customer Interaction related to an Order
     */
    public static Map<String, Map<String,Object>> populateCustomerInteractionOpp(Set<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> ciDocList, Map<Id, Opportunity> oppMap){

        List<String> docUrlList = new List<String>();
        List<String> docIDList = new List<String>();
        Map<String, Object> mapCustInter = new Map<String, Object>();
        Map<String, Map<String,Object>> mapOrderIdCI = new Map<String, Map<String,Object>>();
                for(XC_REST_DoxeeReadFileURL_W.WrapperRequestFile wrDoc : CIdocList) {
                    if(mapOrderIdCI.containsKey(wrDoc.ObjectID)){
                        String listUrl = (String)mapOrderIdCI.get(wrDoc.ObjectID).get('docURL');
                        listUrl += ';\n' + wrDoc.DocumentURL;
                        mapOrderIdCI.get(wrDoc.ObjectID).put('docURL', listUrl);
                        String listIDs = (String)mapOrderIdCI.get(wrDoc.ObjectID).get('docID');
                        listIDs += '|' + wrDoc.DocumentID;
                        mapOrderIdCI.get(wrDoc.ObjectID).put('docID', listIDs);
                    } else if(wrDoc.Category == 'SF_REPORT_DEXMA'){
                        docUrlList = new List<String>();
                        mapCustInter = new Map<String, Object>();
                        //mapCustInter.put('orderId', wrDoc.ObjectID);
                        //mapCustInter.put('opportunityId', bpMap.get(wrDoc.ObjectID).NE__OptyId__c);
                        mapCustInter.put('accountId', oppMap.get(wrDoc.ObjectID).AccountId);
                        mapCustInter.put('opportunityId', wrDoc.ObjectID);
                        mapCustInter.put('contactId', oppMap.get(wrDoc.ObjectID).XC_Contact__c);
                        mapCustInter.put('fullName', oppMap.get(wrDoc.ObjectID).XC_Contact__r.Name);
                        mapCustInter.put('email', oppMap.get(wrDoc.ObjectID).XC_Contact__r.Email);
                        mapCustInter.put('preferredlanguage', oppMap.get(wrDoc.ObjectID).XC_Contact__r.XC_Preferredlanguageofcontact__c);
                        docUrlList.add(wrDoc.DocumentURL);
                        mapCustInter.put('docURL', String.join(docUrlList,','));
                        docIDList.add(wrDoc.DocumentID);
                        mapCustInter.put('docID', String.join(docIDList,','));
                        mapCustInter.put('customerType', 'Customer_Consumptions');
                        mapOrderIdCI.put(wrDoc.ObjectID, mapCustInter);
                        mapCustInter.put('legalEntity', oppMap.get(wrDoc.ObjectID).XC_LegalEntity__c );
                        System.debug('*****legalEntity: ' + mapCustInter.get('legalEntity'));
                    }
                }
        return  mapOrderIdCI;
    }
    /**
    * UtilDoc.
    *
    * @author: Riccardo Cossu - riccardo.cossu@nttdata.com
    * @param docID the doc ID
    * @param docUrl the doc url
    * @param orderId the order id
    * @description : util method for create a new record XC_Document_to_sign__c
    */
    /*@TestVisible
    private static void utilDoc(String docID, String docUrl, String orderId){
        List<XC_Document_to_sign__c> docToSignRecord = new List<XC_Document_to_sign__c>();
        XC_Document_to_sign__c docToSign = new XC_Document_to_sign__c ();
        docToSign.XC_Doxee_URL__c = docUrl;
        docToSign.XC_Doxee_ID_external__c = docID;
        docToSign.XC_ConfigurationID__c = orderId;
        docToSignRecord.add(docToSign);
        XC_UTIL_Sobject.insertListRecords(docToSignRecord);
}


    /**
    * CreateMapDocIdObject.
    *
    * @param listDocs the list docs
    * @param objectName the object name
    * @return the map
    * @description Method to create a map with Doxee ID External as key and the related object lookup as value
    */
    private static Map<String, String> createMapDocIdObject(List<XC_Document_To_Sign__c> listDocs, String objectName) {
        
        Map<String, String> mapRet = new Map<String, String>();
        system.debug('listDocs'+listDocs);
        for(XC_Document_To_Sign__c doc : listDocs) {
            system.debug('objectName'+objectName);
            if(objectName == 'NE__Order__c'){
                system.debug('IN order');
                mapRet.put(doc.XC_Doxee_ID_external__c, doc.XC_ConfigurationID__c);
                system.debug('mapRet'+mapRet);
            }else if(objectName == 'WorkOrder'){
                mapRet.put(doc.XC_Doxee_ID_external__c, doc.XC_WorkOrder__c);
            }/*else if (objectName == 'Asset'){
                mapRet.put(doc.XC_Doxee_ID_external__c, doc.XC_Asset__c);
                }else if (objectName == 'Contract'){
                mapRet.put(doc.XC_Doxee_ID_external__c, doc.XC_Contract__c);
                }else if (objectName == 'Account'){
                mapRet.put(doc.XC_Doxee_ID_external__c, doc.XC_Account__c);
                }else if (objectName == 'NE__OrderItem__c'){
                mapRet.put(doc.XC_Doxee_ID_external__c, doc.XC_OrderItem__c);
                }*/
        }
        system.debug('mapRet'+mapRet);
        return mapRet;
    }
    /**
    * createLeadDocument.
    *
    * @author Valeria Martino - valeria.martino@nttdata.com
    * @param fileWrapper the file wrapper
    * @return the  list Lead document
    * @description create the Lead Document
    **/
    public static void createLeadDocument(List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> fileWrapper) {
        
        List<XC_LeadDocument__c> listLeadDocument = new List<XC_LeadDocument__c> ();
        for(XC_REST_DoxeeReadFileURL_W.WrapperRequestFile wrapper : fileWrapper)  {
            String objectName = XC_UTIL_Sobject.getObjectType(wrapper.ObjectID);
            if(objectName.equals('Lead')) {
                XC_LeadDocument__c newLeadDoc = new XC_LeadDocument__c();
                newLeadDoc.XC_LeadId__c = wrapper.ObjectID;
                newLeadDoc.XC_DocumentUrl__c = wrapper.DocumentURL;
                listLeadDocument.add(newLeadDoc);
            }
        }
        List<XC_UTIL_Sobject.WrapperResult> resList = XC_UTIL_SObject.insertListRecords(listLeadDocument);
        if(!listLeadDocument.isEmpty() && XC_UTIL_Sobject.checkDMLResults(resList)){
            createLeadPhotovoltaicSimulationCI(listLeadDocument);
        }
    }
    
    private static void createLeadPhotovoltaicSimulationCI(List<XC_LeadDocument__c> listLeadDocument){
        List<String> leadIds = XC_UTIL_Sobject.getListFieldValues(listLeadDocument, 'XC_LeadId__c');
        Map<Id, Lead> leadMap = new Map<Id, Lead>([SELECT Id, XC_Preference_Language__c, Email, Name, XC_MainLegalEntity__c FROM Lead WHERE Id IN:leadIds]);
        List<XC_Customer_Interaction__c> ciToInsert = new List<XC_Customer_Interaction__c>();
        
        for (XC_LeadDocument__c ldoc : listLeadDocument) {
            Lead ld = leadMap.get(ldoc.XC_LeadId__c);
            if(!String.isBlank(ld.email)){
                XC_Customer_Interaction__c ci = new XC_Customer_Interaction__c();
                ci.XC_LeadId__c = ld.Id;
                ci.XC_Recipient__c = ld.Name;
                ci.XC_Email__c = ld.Email;
                ci.XC_Preferredlanguageofcontact__c = ld.XC_Preference_Language__c;
                ci.XC_Channel__c = 'Email';
                ci.XC_Communication_Type__c = 'Lead_Photovoltaic_Simulation';
                ci.XC_LegalEntity__c = ld.XC_MainLegalEntity__c;
                ci.XC_Doc_URL_List__c = ldoc.XC_DocumentUrl__c;
                ciToInsert.add(ci);
            }
        }
        XC_UTIL_SObject.insertListRecords(ciToInsert);
    }

    /**
    * createDocumentURL
    *
    * @author Giuseppe Di Bonito - gdibonito@deloitte.it
    * @param fileWrapper the file wrapper
    * @description create the DocumentURL objects
    **/
    public static void createDocumentURL(List<XC_REST_DoxeeReadFileURL_W.WrapperRequestFile> fileWrapper) {
    
        /*List<String> catList = new List<String>();
        for(XC_REST_DoxeeReadFileURL_W.WrapperRequestFile rf : fileWrapper){
            catList.add(rf.Category);
        }

        Map<Id, XC_CM_WelcomeContract_FileUrl__mdt> welcContMdtMap = new Map<Id, XC_CM_WelcomeContract_FileUrl__mdt>([
            SELECT XC_Category_Signed__c, XC_Category_ToSign__c, XC_ObjectType__c
            FROM XC_CM_WelcomeContract_FileUrl__mdt
            WHERE XC_Category_Signed__c in: catList]);
        System.debug('welcContMdtMap: ' + welcContMdtMap);*/

        //[BEGIN, NR2603, neeraj.saini@accenture.com, 06/09/2022, Doxee Report]
        Set<Id> objectIDs = new Set<Id>();
        for(XC_REST_DoxeeReadFileURL_W.WrapperRequestFile rf : fileWrapper){
            objectIDs.add(rf.ObjectID);
        }

        List<NE__OrderItem__c > orderItemList = [SELECT Id, RecordType.Name, NE__Parent_Order_Item__c,
         NE__CatalogItem__r.XC_Brand__c, NE__CatalogItem__r.NE__UsageCode__c, NE__CatalogItem__r.NE__Product_Name__c,NE__OrderId__c
         FROM NE__OrderItem__c where NE__OrderId__c IN :objectIDs AND NE__Parent_Order_Item__c = null AND NE__OrderId__r.NE__OptyId__r.XC_Country__c ='Brazil'];

         Map<Id,NE__OrderItem__c> configIdOIMap = new Map<Id,NE__OrderItem__c>();

        for(NE__OrderItem__c eachOI : orderItemList){
            configIdOIMap.put(eachOI.NE__OrderId__c, eachOI);
        }
        //[END, NR2603, neeraj.saini@accenture.com, 06/09/2022, Doxee Report]
        List<String> objects = new List<String>{'LEAD', 'CASE', 'ASSET', 'WORKORDER'}; 

        List<XC_DocumentURL__c> docUrlList = new List<XC_DocumentURL__c>();
        for(XC_REST_DoxeeReadFileURL_W.WrapperRequestFile rf : fileWrapper){
            /*if(rf.Category == 'SF_CREDIT_ASSIGNMENT_SIGNED'){
                XC_DocumentURL__c docUrl = new XC_DocumentURL__c();
                docUrl.XC_Category_Signed__c = rf.Category;
                docUrl.XC_Url__c = rf.DocumentURL;
                docUrl.XC_Configuration__c = rf.ObjectID;
                docUrlList.add(docUrl);
                
            } else*/ if(rf.Category == 'SF_CONTRACT_SIGNED'){
                XC_DocumentURL__c docUrl = new XC_DocumentURL__c();
                docUrl.XC_Category_Signed__c = rf.Category;
                docUrl.XC_Url__c = rf.DocumentURL;
                docUrl.XC_Configuration__c = rf.ObjectID;
                //[BEGIN, NR2603, neeraj.saini@accenture.com, 06/09/2022, Doxee Report]
                populateDocumentURL(docUrl,configIdOIMap,rf);
                //[END, NR2603, neeraj.saini@accenture.com, 06/09/2022, Doxee Report]
                if(rf.ObjectType != 'CONTRACT'){
                    docUrlList.add(docUrl);
                }
                
            } else if(rf.Category == 'SF_CONTRACT_TO_SIGN'){
                XC_DocumentURL__c docUrl = new XC_DocumentURL__c();
                docUrl.XC_Category_ToSign__c = rf.Category;
                docUrl.XC_Url__c = rf.DocumentURL;
                docUrl.XC_Configuration__c = rf.ObjectID;
                //[BEGIN, NR2603, neeraj.saini@accenture.com, 06/09/2022, Doxee Report]
                populateDocumentURL(docUrl,configIdOIMap,rf);
                //[END, NR2603, neeraj.saini@accenture.com, 06/09/2022, Doxee Report]
                docUrlList.add(docUrl);
            //DCR BEGIN 20012022 - MVP Brazil
            }else if(('SF_CF_FRONT'.equalsIgnoreCase(rf.Category) || 'SF_POWER_OF_ATTORNEY'.equalsIgnoreCase(rf.Category)) && FeatureManagement.checkPermission('XC_Brazil_MVP')){
                                                            
                XC_DocumentURL__c docUrl = new XC_DocumentURL__c();
                docUrl.XC_Category_Signed__c = rf.Category;
                docUrl.XC_Url__c = rf.DocumentURL;
                docUrl.XC_Configuration__c = rf.ObjectID;
                //[BEGIN, NR2603, neeraj.saini@accenture.com, 06/09/2022, Doxee Report]
                populateDocumentURL(docUrl,configIdOIMap,rf);
                //[END, NR2603, neeraj.saini@accenture.com, 06/09/2022, Doxee Report]
                docUrlList.add(docUrl);  
            //DCR END 20012022 - MVP Brazil     
            } else if(objects.contains(rf.ObjectType)){
                XC_DocumentURL__c docUrl = new XC_DocumentURL__c();
                docUrl.XC_Category_ToSign__c = rf.Category;
                docUrl.XC_Url__c = rf.DocumentURL;
                //[BEGIN, NR2603, neeraj.saini@accenture.com, 06/09/2022, Doxee Report]
                populateDocumentURL(docUrl,configIdOIMap,rf);
                //[END, NR2603, neeraj.saini@accenture.com, 06/09/2022, Doxee Report]
                String fieldToMap = rf.ObjectType.toLowerCase().capitalize();


                docUrl.put('XC_'+fieldToMap+'__C', rf.ObjectID); 


                docUrlList.add(docUrl);
                
            }/*else if(rf.Category == 'SF_CREDIT_ASSIGNMENT_TO_SIGN'){
                XC_DocumentURL__c docUrl = new XC_DocumentURL__c();
                docUrl.XC_Category_ToSign__c = rf.Category;
                docUrl.XC_Url__c = rf.DocumentURL;
                docUrl.XC_Configuration__c = rf.ObjectID;
            	docUrlList.add(docUrl);
            }*/
        }
        if(!docUrlList.isEmpty()){
            XC_UTIL_SObject.insertListRecords(docUrlList);
        }
    }

    /**
    * populateDocumentURL
    *
    * @author Neeraj Saini - neeraj.saini@accenture.com
    * @param XC_DocumentURL__c, Map<Id,NE__OrderItem__c>, XC_REST_DoxeeReadFileURL_W.WrapperRequestFile rf
    * @description pupulate some of the DocumentURL object fields
    **/
    public static void populateDocumentURL(XC_DocumentURL__c docUrl, Map<Id,NE__OrderItem__c> configIdOIMap,XC_REST_DoxeeReadFileURL_W.WrapperRequestFile rf){
        //[BEGIN, NR2603, neeraj.saini@accenture.com, 06/09/2022, Doxee Report]
        if(configIdOIMap.containsKey(rf.ObjectID) && configIdOIMap.get(rf.ObjectID)!=null){
            docUrl.XC_PartnerName__c = configIdOIMap.get(rf.ObjectID).NE__CatalogItem__r.XC_Brand__c;
            docUrl.XC_ProductName__c = configIdOIMap.get(rf.ObjectID).NE__CatalogItem__r.NE__Product_Name__c;
            docUrl.XC_ProductCode__c  = configIdOIMap.get(rf.ObjectID).NE__CatalogItem__r.NE__UsageCode__c;
        }
        docUrl.XC_FileUploadDate__c = rf.DateOfFileUpload;
        docUrl.XC_FileSize__c = rf.FileSize;
        //[END, NR2603, neeraj.saini@accenture.com, 06/09/2022, Doxee Report]
    }
}