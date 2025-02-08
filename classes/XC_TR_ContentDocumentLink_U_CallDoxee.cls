/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
* @date Creation 22/02/2019
* @date Modification 07/03/2019 by Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
* @description XC_TR_ContentDocumentLink_U_CallDoxee – logic to send document to Doxee
*/

public without sharing class XC_TR_ContentDocumentLink_U_CallDoxee {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ContentDocumentLink_U_CallDoxee');
    
    /**
    * @description Call doxee.
    * @param listNew the list new
    */
    public static void callDoxee(List<ContentDocumentLink> listNew) {
        System.debug('$$ In callDoxee');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'ListNEW -> ' + listNew);
        if(!XC_UTIL_Sobject.getObjectType(listNew[0].LinkedEntityId).equals('User')) {
            sendDocumentToDoxee(listNew[0].Id);
        } else if(listNew.size() > 1 && !XC_UTIL_Sobject.getObjectType(listNew[1].LinkedEntityId).equals('User')) {
            sendDocumentToDoxee(listNew[1].Id);
        } else {
            return;
        }
    } 
    
    
    /**
    * @description Send document to doxee.
    * @param contentDocLinkId the content doc link id
    */
    @future(callout=true)
    public static void sendDocumentToDoxee(String contentDocLinkId) {
        System.debug('$$ In sendDocumentToDoxee');
        Map<Id, ContentDocumentLink> contentDocumentMap = new Map<Id, ContentDocumentLink>([SELECT Id, Contentdocument.LatestPublishedVersion.Id, Contentdocument.LatestPublishedVersion.XC_Category__c,
                                                     Contentdocument.LatestPublishedVersion.PathOnClient, Contentdocument.LatestPublishedVersion.ContentSize,
                                                     Contentdocument.LatestPublishedVersion.Description, Contentdocument.LatestPublishedVersion.versiondata, LinkedEntityId, ContentDocument.FileExtension
                                                     FROM ContentDocumentLink
                                                     WHERE Id = :contentDocLinkId]);
        Organization org = [SELECT Id FROM Organization LIMIT 1];
        List<ContentDocumentLink> contentDocument = contentDocumentMap.values();
        
        if(contentDocument.isEmpty()||contentDocument[0].Contentdocument==null||contentDocument[0].Contentdocument.LatestPublishedVersion==null||contentDocument[0].Contentdocument.LatestPublishedVersion.PathOnClient==null){
            return;
        }
        //SS 19/01/21: NEW LOGIC RELATED TO THE VOCAL SCRIPT FILE
        if(contentDocument[0].Contentdocument.LatestPublishedVersion.PathOnClient.contains('VOCAL_SCRIPT_')){
            launchEventRelatedToScript(contentDocument[0]);
            return;
        }
        List<String> categoryNameList = contentDocument[0].Contentdocument.LatestPublishedVersion.PathOnClient.split(' - ');
        if( !Schema.sObjectType.User.isAccessible() || !Schema.sObjectType.XC_CM_LegalEntity_Configuration__mdt.isAccessible()){
            return;
        }

        if(!contentDocument.isEmpty() && categoryNameList.size() > 1) {
            String categoryName = 'SF_' + categoryNameList[1].replace(' ', '_');
            categoryName = categoryName.split('\\.')[0].toUpperCase();
            categoryName = categoryName.replace('(', '');
            categoryName = categoryName.replace(')', '');
            
            XC_REST_DoxeeFileSend_U.RequestWrapper wrapper = new XC_REST_DoxeeFileSend_U.RequestWrapper();
            wrapper.File.FileSize = contentDocument[0].Contentdocument.LatestPublishedVersion.ContentSize;
            wrapper.File.FileName = contentDocument[0].Contentdocument.LatestPublishedVersion.PathOnClient;
            // SS 23/06/2020 Set a limit to te characters of a string for doxee limits
            if(wrapper.File.FileName.length() >= 85){
                if(!String.isBlank(contentDocument[0].Contentdocument.FileExtension)){
                    wrapper.File.FileName = wrapper.File.FileName.left(85) + '.' + contentDocument[0].Contentdocument.FileExtension;
                } else {
                    wrapper.File.FileName = wrapper.File.FileName.left(85);
                }
            }
            wrapper.File.FileDescription = contentDocument[0].Contentdocument.LatestPublishedVersion.Description;
            wrapper.File.FileCreationDate = String.valueOf(Datetime.Now().format('yyyyMMddhhmm') +'T'+ Datetime.Now().format('hh:mm:ss'));
            wrapper.File.FileCategory = categoryName;
            wrapper.File.FileBase64 = EncodingUtil.base64Encode(contentDocument[0].Contentdocument.LatestPublishedVersion.versiondata);
            if(contentDocument[0].LinkedEntityId.getSobjectType().getDescribe().getName() == 'NE__Order__c') {
                wrapper.File.ObjectType = 'CONFIGURATION';
                NE__Order__c order = [Select  XC_LegalEntity__c, XC_Segment__c   from NE__Order__c where id =: contentDocument[0].LinkedEntityId ];
                XC_CM_LegalEntity_Configuration__mdt configurationLE = [SELECT  XC_DoxeeCompany__c, XC_DoxeeCountry__c 
                                                            FROM  XC_CM_LegalEntity_Configuration__mdt 
                                                            WHERE XC_OrgId__c = : org.Id 
                                                            AND  XC_LegalEntity__c  = : order.XC_LegalEntity__c
                                                            AND XC_Stream__c  = : order.XC_Segment__c  ];
                wrapper.File.Company = configurationLE.XC_DoxeeCompany__c;
                wrapper.File.Country = configurationLE.XC_DoxeeCountry__c;

                //NR2501 mciavarra@deloitte.it Start
                String inputTextNew = contentDocument[0].Contentdocument.LatestPublishedVersion.PathOnClient.split('\\.')[0];

                Map<Id, NE__OrderItem__c> mapOI = new Map<id,NE__OrderItem__c>([Select id, XC_Product_Subtype__c, XC_CongaDynamicAPI__c  from NE__OrderItem__c where NE__OrderId__c=: contentDocument[0].LinkedEntityId]);
                List<NE__OrderItem__c> listOI = new List<NE__OrderItem__c>();
                for (NE__OrderItem__c oi : mapOI.values()){
                    if(oi.XC_CongaDynamicAPI__c != null){
                        listOI.add(oi);
                    }
                }

                if(!listOI.isEmpty()){
                    for(NE__OrderItem__c ci : listOI){
                        List<String> congaString = ci.XC_CongaDynamicAPI__c.split('&');
                        System.debug(congaString[6]);
                        List<String> templateName = congaString[6].split('=');
                        System.debug(templateName[1]);
                        if(templateName[1] == inputTextNew){
                            System.debug('trovato ' + ci.XC_Product_Subtype__c);
                            wrapper.File.ContractProductCategory = ci.XC_Product_Subtype__c;
                            break;
                        }

                    }
                }
                //NR2501 mciavarra@deloitte.it End

            } else if(contentDocument[0].LinkedEntityId.getSobjectType().getDescribe().getName() == 'Workorder') {    
                wrapper.File.ObjectType = 'WORKORDER';
                Workorder wo = [Select  XC_LegalEntity__c, XC_Segment__c  from Workorder where id =: contentDocument[0].LinkedEntityId ];
                XC_CM_LegalEntity_Configuration__mdt configurationLE = [SELECT  XC_DoxeeCompany__c, XC_DoxeeCountry__c 
                                                            FROM  XC_CM_LegalEntity_Configuration__mdt 
                                                            WHERE XC_OrgId__c = : org.Id 
                                                            AND  XC_LegalEntity__c  = : wo.XC_LegalEntity__c 
                                                            AND XC_Stream__c  = : wo.XC_Segment__c  ];
                wrapper.File.Company = configurationLE.XC_DoxeeCompany__c;
                wrapper.File.Country = configurationLE.XC_DoxeeCountry__c;
            } else if(contentDocument[0].LinkedEntityId.getSobjectType().getDescribe().getName() == 'NE__Billing_Profile__c'){
                wrapper.File.ObjectType = 'BILLING_PROFILE';
                NE__Billing_Profile__c bp = [Select  XC_LegalEntity__c, XC_Segment__c  from NE__Billing_Profile__c where id =: contentDocument[0].LinkedEntityId ];
                XC_CM_LegalEntity_Configuration__mdt configurationLE = [SELECT  XC_DoxeeCompany__c, XC_DoxeeCountry__c 
                                                            FROM  XC_CM_LegalEntity_Configuration__mdt 
                                                            WHERE XC_OrgId__c = : org.Id 
                                                            AND  XC_LegalEntity__c  = : bp.XC_LegalEntity__c 
                                                            AND XC_Stream__c = : bp.XC_Segment__c ];
                wrapper.File.Company = configurationLE.XC_DoxeeCompany__c;
                wrapper.File.Country = configurationLE.XC_DoxeeCountry__c;
            }
              else if(contentDocument[0].LinkedEntityId.getSobjectType().getDescribe().getName() == 'Account'){
                wrapper.File.ObjectType = 'ACCOUNT';
                Account con = [Select  XC_ContactToNotify__r.XC_MainLegalEntity__c, XC_Segment__c  From Account
                                         where id =: contentDocument[0].LinkedEntityId 
										 AND XC_ContactToNotify__c !=null];
                XC_CM_LegalEntity_Configuration__mdt configurationLE = [SELECT  XC_DoxeeCompany__c, XC_DoxeeCountry__c 
                                                            FROM  XC_CM_LegalEntity_Configuration__mdt 
                                                            WHERE XC_OrgId__c = : org.Id 
                                                            AND  XC_LegalEntity__c  = : con.XC_ContactToNotify__r.XC_MainLegalEntity__c 
                                                            AND XC_Stream__c = : con.XC_Segment__c ];
                wrapper.File.Company = configurationLE.XC_DoxeeCompany__c;
                wrapper.File.Country = configurationLE.XC_DoxeeCountry__c;
            }

            else if(contentDocument[0].LinkedEntityId.getSobjectType().getDescribe().getName() == 'Contract'){
                wrapper.File.ObjectType = 'CONTRACT';
                Contract con = [Select XC_LegalEntity__c, XC_Segment__c  From Contract
                                         where id =: contentDocument[0].LinkedEntityId ];
                XC_CM_LegalEntity_Configuration__mdt configurationLE = [SELECT  XC_DoxeeCompany__c, XC_DoxeeCountry__c 
                                                            FROM  XC_CM_LegalEntity_Configuration__mdt 
                                                            WHERE XC_OrgId__c = : org.Id 
                                                            AND  XC_LegalEntity__c  = : con.XC_LegalEntity__c 
                                                            AND XC_Stream__c = : con.XC_Segment__c ];
                wrapper.File.Company = configurationLE.XC_DoxeeCompany__c;
                wrapper.File.Country = configurationLE.XC_DoxeeCountry__c;
            }

            else if(contentDocument[0].LinkedEntityId.getSobjectType().getDescribe().getName() == 'WorkOrderLineItem') {    
                wrapper.File.ObjectType = 'WORKORDER_LINEITEM';
                Workorderlineitem woli = [Select WorkOrder.XC_LegalEntity__c, WorkOrder.XC_Segment__c from Workorderlineitem where id =: contentDocument[0].LinkedEntityId ];
                XC_CM_LegalEntity_Configuration__mdt configurationLE = [SELECT  XC_DoxeeCompany__c, XC_DoxeeCountry__c 
                                                            FROM  XC_CM_LegalEntity_Configuration__mdt 
                                                            WHERE XC_OrgId__c = : org.Id 
                                                            AND  XC_LegalEntity__c  = : woli.WorkOrder.XC_LegalEntity__c 
                                                            AND XC_Stream__c  = : woli.WorkOrder.XC_Segment__c  ];
                wrapper.File.Company = configurationLE.XC_DoxeeCompany__c;
                wrapper.File.Country = configurationLE.XC_DoxeeCountry__c;
			}else if(contentDocument[0].LinkedEntityId.getSobjectType().getDescribe().getName() == 'Case') {    
                wrapper.File.ObjectType = 'CASE';
                Case cas = [Select Id, XC_LegalEntity__c, XC_Segment__c from Case where id =: contentDocument[0].LinkedEntityId ];
                XC_CM_LegalEntity_Configuration__mdt configurationLE = [SELECT  XC_DoxeeCompany__c, XC_DoxeeCountry__c 
                                                            FROM  XC_CM_LegalEntity_Configuration__mdt 
                                                            WHERE XC_OrgId__c = : org.Id 
                                                            AND  XC_LegalEntity__c  = : cas.XC_LegalEntity__c 
                                                            AND XC_Stream__c  = : cas.XC_Segment__c  ];
                wrapper.File.Company = configurationLE.XC_DoxeeCompany__c;
                wrapper.File.Country = configurationLE.XC_DoxeeCountry__c;
			}
            
            else {
                wrapper.File.ObjectType = contentDocument[0].LinkedEntityId.getSobjectType().getDescribe().getName().toUpperCase();
            }
            wrapper.File.ObjectID = contentDocument[0].LinkedEntityId;
            
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'wrapper.File.ObjectType  ->' + wrapper.File.ObjectType);
            
            
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'all field wrapper  --->' + wrapper);
            
            Id objectId = (Id) wrapper.File.ObjectID;
            XC_UTIL_Debug.debug(DEBUGACTIVE,  'Object -->' + objectId.getSobjectType().getDescribe().getName());
            if(objectId.getSobjectType().getDescribe().getName() == 'Account' || objectId.getSobjectType().getDescribe().getName() == 'NE__Order__c' || objectId.getSobjectType().getDescribe().getName() == 'WorkOrder' || objectId.getSobjectType().getDescribe().getName() == 'NE__Billing_Profile__c' || objectId.getSobjectType().getDescribe().getName() == 'Contract' || objectId.getSobjectType().getDescribe().getName() == 'WorkOrderLineItem' || objectId.getSobjectType().getDescribe().getName() == 'Case') {
                updateListRecordsObject(objectId, wrapper);
            }
            
            // update ContentVersion for Category
            ContentVersion cv = new ContentVersion();
            cv.Id = contentDocument[0].Contentdocument.LatestPublishedVersion.Id;
            cv.XC_Category__c = categoryName;
            XC_UTIL_Sobject.updateRecord(cv);
        }
    }

    /**
    * @description Update List Record (Account/Order)
    * @param objectId
    * @param wrapper
    */
    private static void updateListRecordsObject(Id objectId, XC_REST_DoxeeFileSend_U.RequestWrapper wrapper) {
        System.debug('$$ In updateListRecordsObject');
        XC_REST_DoxeeFileSend_U.ResponseWrapper res = XC_REST_DoxeeFileSend.createFile(wrapper);
        List<Id> listObjectId = new List<Id>{objectId};
        String query = String.escapeSingleQuotes('SELECT Id, XC_Response_From_Doxee__c FROM ' + objectId.getSobjectType().getDescribe().getName() + ' WHERE Id IN :listObjectId');
        if(objectId.getSobjectType().getDescribe().getName() == 'Account') {
            List<Account> accList = (List<Account>) Database.query(query);
            checkUpdateListAccount(accList, res, wrapper);
        } else if(objectId.getSobjectType().getDescribe().getName() == 'NE__Order__c'){
            query = String.escapeSingleQuotes('SELECT Id, XC_LegalEntity__c, NE__OptyId__r.XC_Contact__r.Email, NE__OptyId__r.XC_Contact__r.Name, NE__AccountId__c, NE__OptyId__r.XC_Contact__c, XC_Response_From_Doxee__c, NE__Quote__c, XC_Channel__c, (SELECT NE__ProdId__r.XC_LIC_Product_Name__c FROM NE__Order_items__r) FROM ' + objectId.getSobjectType().getDescribe().getName() + ' WHERE Id IN :listObjectId');
            List<NE__Order__c> orList = (List<NE__Order__c>) Database.query(query);
            if(!orList.isEmpty() && res.Result != null && res.File != null){
                //orList[0].XC_Response_From_Doxee__c = String.isBlank(orList[0].XC_Response_From_Doxee__c) ? wrapper.File.FileName + ' ' + res.File.Purl : orList[0].XC_Response_From_Doxee__c + ',\n' + wrapper.File.FileName + ' ' + res.File.Purl;
                if(String.isBlank(orList[0].XC_Response_From_Doxee__c)) {
                    orList[0].XC_Response_From_Doxee__c = wrapper.File.FileName + ' ' + res.File.Purl;
                } else {
                    orList[0].XC_Response_From_Doxee__c += ',\n' + wrapper.File.FileName + ' ' + res.File.Purl;
                }

                List<XC_UTIL_SObject.WrapperResult> updResults = XC_UTIL_Sobject.updateListRecords(orList);
                if(XC_UTIL_Sobject.checkDMLResults(updResults) && wrapper.File.FileCategory.contains('PRECONTRACTUAL_CONDITIONS')) {
                    createCustomerInteractionQuoteAccepted(orList[0], res.File.Purl);
                
                } else if(XC_UTIL_Sobject.checkDMLResults(updResults) && wrapper.File.FileCategory.contains('CONTRACT_SIGNED') && orList[0].XC_LegalEntity__c != 'EnelXItalia' && orList[0].XC_LegalEntity__c != 'EnelXMobilityItalia' && orList[0].XC_LegalEntity__c != 'EnelXMSP' && orList[0].XC_LegalEntity__c != 'EnelXMobilityHolding') {
                    createCustomerInteractionDocSigned(orList[0], res.File.Purl);
                }
            }
        }else if(objectId.getSobjectType().getDescribe().getName() == 'WorkOrder'){
            
            if(wrapper.File.FileCategory.contains('SERVICE_REPORT')){
                WorkOrder wo = new WorkOrder(id=objectId);
                Map<Id, WorkOrder> allWoMap = XC_TR_WorkOrder_U_CreateCustomInter.getWoMap(new List<WorkOrder>{wo});
                Map<Id, List<NE__Order__c>> quotesMap = XC_TR_WorkOrder_U_CreateCustomInter.getQuotesMap(allWoMap.values(), allWoMap);
                List<XC_Customer_Interaction__c> ciToInsert = XC_TR_WorkOrder_U_CreateCustomInter.createCutomerInteractionCustomerActivityReport(allWoMap.values(), allWoMap, quotesMap);
                insertCI(ciToInsert, res);
            }
        }
    }

    private static void insertCI(List<XC_Customer_Interaction__c> ciToInsert, XC_REST_DoxeeFileSend_U.ResponseWrapper res){
        System.debug('$$ In insertCI');
        if(!ciToInsert.isEmpty()){
            ciToInsert[0].XC_Doc_URL_List__c = !String.isBlank(res.File.Purl) ? res.File.Purl : '';    
        }
        XC_UTIL_Sobject.insertListRecords(ciToInsert);
    }
	
    @TestVisible
    private static void createCustomerInteractionQuoteAccepted(NE__Order__c configuration, String docUrl){
        System.debug('$$ In createCustomerInteractionQuoteAccepted');
        if(configuration.XC_Channel__c=='Market'){
            return;
        }

        XC_Customer_Interaction__c ci = new XC_Customer_Interaction__c();
        ci.XC_OrderId__c = configuration.Id;
        ci.XC_ContactId__c = configuration.NE__OptyId__r.XC_Contact__c;
        ci.XC_AccountId__c = configuration.NE__AccountId__c;
        ci.XC_Recipient__c = configuration.NE__OptyId__r.XC_Contact__r.Name;
        ci.XC_Email__c = configuration.NE__OptyId__r.XC_Contact__r.Email;
        ci.XC_LegalEntity__c = configuration.XC_LegalEntity__c;

        ci.XC_Channel__c = !String.isBlank(ci.XC_Email__c) ? Label.XC_CL_CustomerInter_ChannelEmail : Label.XC_CL_CustomerInter_ChannelSms;
        ci.XC_Communication_Type__c = 'Quote_Accepted';
        //
        List<Ne__Orderitem__c> odItemList = configuration.Ne__Order_Items__r;
        Boolean found=false;
        for(Ne__Orderitem__c item : odItemList) {
            if(item.NE__ProdId__r.XC_LIC_Product_Name__c.Contains(Label.XC_CL_OK)) {
                found=true;
                break;
            }
        }
        
        ci.XC_SurveyId__c = (found) ? 'S0' : null;
        ci.XC_Doc_URL_List__c = docUrl;
    
        XC_UTIL_Sobject.insertRecord(ci);
    }

    /**
    * @description Check for Update Account List Record
    * @param accList
    * @param res
    * @param wrapper
    */
    @TestVisible
    private static void checkUpdateListAccount(List<Account> accList, XC_REST_DoxeeFileSend_U.ResponseWrapper res, XC_REST_DoxeeFileSend_U.RequestWrapper wrapper) {
        System.debug('$$ In checkUpdateListAccount');
        if(!accList.isEmpty() && res.Result != null && res.File != null){
            if(String.isBlank(accList[0].XC_Response_From_Doxee__c)) {
                accList[0].XC_Response_From_Doxee__c = wrapper.File.FileName + ' ' + res.File.Purl;
            } else {
                accList[0].XC_Response_From_Doxee__c += ',\n' + wrapper.File.FileName + ' ' + res.File.Purl;
            }
            XC_UTIL_Sobject.updateListRecords(accList);
        }
    }

    /*
	 * @author Giuseppe Di Bonito - gdibonito@deloitte.it
	 * @param listNew
	 * @date Creation 06/04/2020
	 * @description creates the customer interaction 'Order_Send_Signed_contract_Email' when the XC_DocumentType__c 'SF_CONTRACT_SIGNED' is created
	 */
	public static void createCustomerInteractionDocSigned(NE__Order__c configuration, String docUrl){
        
        System.debug('In createCustomerInteractionDocSigned for DocumentToSign');
		List<Map<String,Object>> interactions = new List<Map<String,Object>>();

		Map<String,Object> ciInfo = new Map<String,Object>();
		ciInfo.put('customerType', 'Order_Send_Signed_contract_Email');
		ciInfo.put('docURL', docUrl);
		//ciInfo.put('docID', ...);
		ciInfo.put('orderId', configuration.Id);
		ciInfo.put('accountId', configuration.NE__AccountId__c);
		ciInfo.put('fullName', configuration.NE__OptyId__r.XC_Contact__r.Name);
		ciInfo.put('contactId', configuration.NE__OptyId__r.XC_Contact__c);
		ciInfo.put('skipComunication', false);
		ciInfo.put('sent', false);
		ciInfo.put('legalEntity', configuration.XC_LegalEntity__c);
		ciInfo.put('email', configuration.NE__OptyId__r.XC_Contact__r.Email);
		
        interactions.add(ciInfo);	

		System.debug('interactions: ' + interactions);	
		if(!interactions.isEmpty()){
			List<XC_UTIL_Sobject.WrapperResult> results = XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromOrders(interactions);
			XC_UTIL_Sobject.WrapperResult globalDMLResult= XC_UTIL_Sobject.getGlobalDMLResults(results);
			XC_UTIL_Debug.debug(DEBUGACTIVE, 'newEmailForCustomerFromOrders globalDMLResult = ' + globalDMLResult);
		}
    }

    /*
	 * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
	 * @param ContentDocumentLink cdl
	 * @date Creation 19/01/2021
	 * @description launch an event when a script file is launched
	 */
    private static void launchEventRelatedToScript(ContentDocumentLink cdl) {
        // fileName has ths format 'VOCAL_SCRIPT_' + oiItems.Name + '_' + UserInfo.getUserId()
        List<String> valuesList = cdl.Contentdocument.LatestPublishedVersion.PathOnClient.split('_');
        XC_CTI_Call_Event__e event = new XC_CTI_Call_Event__e();
        event.XC_EventType__c = 'TRIGGER_SCRIPT_GENERATED';
        event.XC_ContextRecordId__c = getOrderId(cdl.LinkedEntityId);
        if(valuesList.size() > 3){
            String userId = valuesList[3].replace('.pdf','');
            event.XC_ContextUserId__c = userId;
        }
        XC_UTIL_PlatformEvent.publishListEvent(event);
    }

    /*
	 * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
	 * @param String orderItemId
	 * @date Creation 19/01/2021
	 * @description launch an event when a script file is launched
	 */
    private static String getOrderId(String orderItemId){
        List<NE__OrderItem__c> orderItemList = new List<NE__OrderItem__c>([SELECT Id, NE__OrderId__c FROM NE__OrderItem__c WHERE Id =: orderItemId]);
        String orderId = '';
        if(!orderItemList.isEmpty()){
            orderId = orderItemList[0].NE__OrderId__c;
        }   
        return orderId;
    }
}