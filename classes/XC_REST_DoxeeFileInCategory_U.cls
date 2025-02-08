/**
 * The Class XC_REST_DoxeeFileInCategory_U.
 *
 * @author            : Giulio Serra
 * @date Creation     : 03/01/19
 * @date Modification : 21/11/19 PA NTT DATA - 05/06/2019 by Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @description       : Util for XC_REST_DoxeeFileInCategory
 **/
public without sharing class XC_REST_DoxeeFileInCategory_U {


    /**
     * The Class FileWrapper.
     *
     * @description the file wrapper
     */
    public class FileWrapper{
       public String ObjectType, ObjectID, Category, DossierID, ContractProductCategory;
       public Date ExpirationDate;
       public Integer NumberOfFile;
       public String Purl;
    }


    /**
     * The Class RequestWrapper.
     *
     * @description the request wrapper
     */
    public class RequestWrapper{

       /** The Category item. */
       public List<FileWrapper> CategoryItem;
    }


    /**
     * The Class ResponseWrapper.
     *
     * @description the response wrapper
     */
    public class ResponseWrapper{

        /** The Result. */
        public XC_UTIL_Integration.Result Result = new XC_UTIL_Integration.Result();

        /** The Category item. */
        public List<FileWrapper> CategoryItem;
    }


    /**
     * Validate request.
     *
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @param mapHeader the map header
     * @param rw the request wrapper
     * @return the Wrapper Result
     * @description check if the request is valid or not
     **/
    public static XC_UTIL_Integration.WrapperResult validateRequest(Map<String, String> mapHeader, RequestWrapper rw){

        XC_UTIL_Integration.WrapperResult validateResult = XC_UTIL_RESTInbound.checkObjectPermission('XC_DocumentType__c', 'create');
        if(validateResult.errorFlag) {
            return validateResult;
        }

        validateResult = XC_UTIL_Integration.validateHeader(mapHeader);
        if(validateResult.errorFlag) {
            return validateResult;
        }

        if(rw.CategoryItem == null) {
            validateResult.errorMessage = Label.XC_CL_MandatoryField +' CategoryItem';
            validateResult.errorFlag = true;
            return validateResult;
        }

        Integer i = 1;
        for(FileWrapper file : rw.CategoryItem){

            Map<String, String> requiredParameters = new Map<String, String>{'ObjectType' => file.ObjectType,
                                                                                'ObjectID' => file.ObjectID,
                                                                                'Category' => file.Category
                                                                            };
            for(String key : requiredParameters.keySet()) {
                if(String.isBlank(requiredParameters.get(key))) {
                    validateResult.errorMessage = 'Missing field: CategoryItem.' + key + ' in ' + i + '-th file';
                    validateResult.errorFlag = true;
                    return validateResult;
                }
            }

            if(file.NumberOfFile == null) {
                validateResult.errorMessage = 'Missing field: CategoryItem.NumberOfFile in ' + i + '-th file';
                validateResult.errorFlag = true;
                return validateResult;
            }

            if(file.NumberOfFile == 0) {
                validateResult.errorMessage = 'CategoryItem.NumberOfFile in ' + i + '-th file cannot be 0';
                validateResult.errorFlag = true;
                return validateResult;
            }

            i++;

            validateResult = XC_UTIL_Integration.validateFileRequest(file.ObjectType, file.Category);
            if(validateResult.errorFlag) {
                return validateResult;
            }
        }

        return validateResult;
    }


    /**
     * Create Files.
     *
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @param request the request
     * @return the Response Wrapper
     * @description create the documents types on the requested objects
     **/
    public static XC_REST_DoxeeFileInCategory_U.ResponseWrapper createFiles(XC_REST_DoxeeFileInCategory_U.RequestWrapper request){

        XC_REST_DoxeeFileInCategory_U.ResponseWrapper response = new XC_REST_DoxeeFileInCategory_U.ResponseWrapper();

        List<XC_DocumentType__c> documents = new List<XC_DocumentType__c>();

        Set<Id> parentIdList = new Set<Id>();
        for(XC_REST_DoxeeFileInCategory_U.FileWrapper file : request.CategoryItem) {
            parentIdList.add(file.ObjectID);
        }

        if(!Schema.sObjectType.XC_DocumentType__c.isAccessible()){
            response.Result.Message = 'INTERNAL ERROR';
            response.Result.ErrorCode = '500';
            response.Result.logError = 'XC_DocumentType__c object is not accessible';
            return response;
        }
        // 21/11/19 PA NTTDATA - Add Logistic Object 
        //NA 17062020
        List<XC_DocumentType__c> docList = [SELECT Id, XC_Configuration__c, XC_Account__c, XC_DossierId__c, XC_WorkOrder__c, XC_Contract__c, XC_PurchaseOrder__c, XC_PurchaseOrderReceipt__c,

                                            XC_Asset__c, XC_Individual__c, XC_ConfigurationItem__c, XC_WorkOrderLineItem__c, Category__c, XC_TransferOrder__c, 

                                            XC_Shipment__c, XC_ReturnToSupplier__c, Opportunity__c, XC_BillingProfile__c, XC_Lead__c, Case__c, XC_ExpirationDate__c, XC_Contact__c, XC_QualityCheck__c, XC_ContractProductCategory__c

                                            FROM XC_DocumentType__c
                                            WHERE XC_Configuration__c IN: parentIdList
                                            OR XC_Account__c IN: parentIdList
                                            OR XC_WorkOrder__c IN: parentIdList
                                            OR XC_Contract__c IN: parentIdList
                                            OR XC_Asset__c IN: parentIdList
                                            OR XC_Individual__c IN: parentIdList
                                            OR XC_ConfigurationItem__c IN: parentIdList
                                            OR XC_WorkOrderLineItem__c IN: parentIdList
                                            OR XC_PurchaseOrder__c IN: parentIdList
                                            OR XC_PurchaseOrderReceipt__c IN: parentIdList
                                            OR XC_TransferOrder__c IN: parentIdList
                                            OR XC_Shipment__c IN: parentIdList
                                            OR XC_ReturnToSupplier__c IN: parentIdList
                                            OR Opportunity__c IN: parentIdList
                                            //OR XC_ProjectTask__c IN: parentIdList
                                            OR XC_BillingProfile__c IN: parentIdList

                                            OR XC_Lead__c IN: parentIdList
                                            OR Case__c IN: parentIdList
                                            OR XC_Contact__c IN: parentIdList
                                            OR XC_QualityCheck__c IN: parentIdList];



        for(XC_REST_DoxeeFileInCategory_U.FileWrapper fileWrapper : request.CategoryItem){

            String objName = XC_UTIL_SObject.getObjectType(fileWrapper.ObjectID);


            // Se esiste un record con stessa lookup e stessa category, bisogna aggiornare il numero di file
            Boolean checkUpdate = updateDocumentType(objName, fileWrapper, docList);

            if(!checkUpdate) {
                XC_DocumentType__c newDoc = createDocumentType(objName, fileWrapper, response);

                if(response.Result.ErrorCode != '0') {
                    return response;
                }

                documents.add(newDoc);
            }

        }

        docList.addAll(documents);
        List<XC_UTIL_SObject.WrapperResult> results = XC_UTIL_SObject.upsertListRecords(docList);
        response = generateWrapperFromInsert(results);
        return response;
    }


    /**
     * UpdateDocumentType.
     *
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @param objName the object name
     * @param fileWrapper the file wrapper
     * @param docList the document list
     * @return the boolean
     * @description update document type
     **/
    public static Boolean updateDocumentType(String objName, XC_REST_DoxeeFileInCategory_U.FileWrapper fileWrapper, List<XC_DocumentType__c> docList){

        Boolean checkUpdate = false;

        for(XC_DocumentType__c doc : docList) {

            if(doc.Category__c == fileWrapper.Category) {
                // 21/11/19 PA NTTDATA - Add Logistic Object
                Map<String,String> fieldsMap = new Map<String, String>{
                    'NE__Order__c' => doc.XC_Configuration__c,
                    'Account' => doc.XC_Account__c,
                    'WorkOrder' => doc.XC_WorkOrder__c,
                    'Contract' => doc.XC_Contract__c,
                    'Asset' => doc.XC_Asset__c,
                    'Individual' => doc.XC_Individual__c,
                    'NE__OrderItem__c' => doc.XC_ConfigurationItem__c,
                    'WorkOrderLineItem' => doc.XC_WorkOrderLineItem__c,
                    'gii__PurchaseOrder__c' => doc.XC_PurchaseOrder__c,
                    'gii__PurchaseOrderReceipt__c' => doc.XC_PurchaseOrderReceipt__c,
                    'gii__TransferOrder__c' => doc.XC_TransferOrder__c,
                    'gii__Shipment__c' => doc.XC_Shipment__c,
                    'gii__ReturnToSupplier__c' => doc.XC_ReturnToSupplier__c,
                    'Opportunity' => doc.Opportunity__c,
                    //'project_cloud__Project_Task__c' => doc.XC_ProjectTask__c,
                    'NE__Billing_Profile__c' => doc.XC_BillingProfile__c,

                    'Lead' => doc.XC_Lead__c, 


                    'Case' => doc.Case__c,
                    'XC_B2BG_QualityCheck__c' => doc.XC_QualityCheck__c,
                    'Contact' => doc.XC_Contact__c



                };
                for(String key : fieldsMap.keySet()) {
                    if(objName.equals(key) && fileWrapper.ObjectID == fieldsMap.get(key)) {
                        doc.numberOfFiles__c = fileWrapper.NumberOfFile;
                        if(String.isBlank(doc.XC_ContractProductCategory__c)){
                            doc.XC_ContractProductCategory__c = fileWrapper.ContractProductCategory;
                        }
                        checkUpdate = true;
                        if(!String.isBlank(fileWrapper.DossierID)){
                            doc.XC_DossierId__c = fileWrapper.DossierID;
                        }
                        break;
                    }
                }
            }
        }

        return checkUpdate;
    }


    /**
     * CreateDocumentType.
     *
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @param objName the object name
     * @param fileWrapper the file wrapper
     * @param response the response
     * @return the document type
     * @description create the document type
     **/
    public static XC_DocumentType__c createDocumentType(String objName, XC_REST_DoxeeFileInCategory_U.FileWrapper fileWrapper, XC_REST_DoxeeFileInCategory_U.ResponseWrapper response) {

        XC_DocumentType__c newDoc = new XC_DocumentType__c();
        // 21/11/19 PA NTTDATA - Add Logistic Object
        
        if('NE__Order__c'.equals(objName)) {
            newDoc.XC_Configuration__c = fileWrapper.ObjectID;
        } else if('Account'.equals(objName)) {
            newDoc.XC_Account__c = fileWrapper.ObjectID;
        } else if('WorkOrder'.equals(objName)) {
            newDoc.XC_WorkOrder__c = fileWrapper.ObjectID;
        } else if('Contract'.equals(objName)) {
            newDoc.XC_Contract__c = fileWrapper.ObjectID;
        } else if('Asset'.equals(objName)) { 
            newDoc.XC_Asset__c = fileWrapper.ObjectID;
        } else if('Individual'.equals(objName)) {
            newDoc.XC_Individual__c = fileWrapper.ObjectID;
        } else if('NE__OrderItem__c'.equals(objName)) {
            newDoc.XC_ConfigurationItem__c = fileWrapper.ObjectID;
        } else if('WorkOrderLineItem'.equals(objName)) {
            newDoc.XC_WorkOrderLineItem__c = fileWrapper.ObjectID;
        } else if('gii__PurchaseOrder__C'.equals(objName)) {
            newDoc.XC_PurchaseOrder__c = fileWrapper.ObjectID;
        } else if('gii__PurchaseOrderReceipt'.equals(objName)) {
            newDoc.XC_PurchaseOrderReceipt__c = fileWrapper.ObjectID;
        } else if('gii__TransferOrder__c'.equals(objName)) {
            newDoc.XC_TransferOrder__c = fileWrapper.ObjectID;
        } else if('gii__Shipment__c'.equals(objName)) {
            newDoc.XC_Shipment__c = fileWrapper.ObjectID;
        } else if('gii__ReturnToSupplier'.equals(objName)) {
            newDoc.XC_ReturnToSupplier__c = fileWrapper.ObjectID;
        } else if('Opportunity'.equals(objName)){
            newDoc.Opportunity__c = fileWrapper.ObjectID;
        //}else if('project_cloud__Project_Task__c'.equals(objName)){
        //    newDoc.XC_ProjectTask__c=fileWrapper.ObjectID;
        } else if('NE__Billing_Profile__c'.equals(objName)){
            newDoc.XC_BillingProfile__c = fileWrapper.ObjectID;
        } else if('Lead'.equals(objName)){
            newDoc.XC_Lead__c = fileWrapper.ObjectID;

        } else if('Case'.equals(objName)){
            newDoc.Case__c = fileWrapper.ObjectID;


        } else if('XC_B2BG_QualityCheck__c'.equals(objName)){
            newDoc.XC_QualityCheck__c = fileWrapper.ObjectID;
        } else if('Contact'.equals(objName)){
            newDoc.XC_Contact__c = fileWrapper.ObjectID;
        } 


        else {
            response.Result.Message = Label.XC_CL_TypeObject + fileWrapper.ObjectID + Label.XC_CL_IsNotCorrect;
            response.Result.ErrorCode = '400';
            return null;
        }

        response.Result.ErrorCode = '0';
        newDoc.numberOfFiles__c = fileWrapper.NumberOfFile;
        newDoc.Category__c = fileWrapper.Category;
        newDoc.XC_DossierId__c = fileWrapper.DossierID;
        newDoc.XC_ExpirationDate__c = fileWrapper.ExpirationDate;
        newDoc.XC_ContractProductCategory__c = fileWrapper.ContractProductCategory;


        return newDoc;
    }

    /**
     * GenerateWrapperFromInsert.
     *
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @param results the results
     * @return the Response Wrapper
     * @description manage the response of the records insert
     */
    public static XC_REST_DoxeeFileInCategory_U.ResponseWrapper generateWrapperFromInsert(List<XC_UTIL_SObject.WrapperResult> results){

        XC_REST_DoxeeFileInCategory_U.ResponseWrapper response = new XC_REST_DoxeeFileInCategory_U.ResponseWrapper();

        for(XC_UTIL_SObject.WrapperResult insertResult : results){
            if(!insertResult.success){
                response.Result.Message = 'INTERNAL ERROR';
                response.Result.ErrorCode = '500';
                response.Result.logError = insertResult.errorMessage;
                return response;
            }
        }

        response.Result.Message = 'Operation completed successfully';
        response.Result.ErrorCode = '0';

        return response;
    }

    public static void updateDocumentSignature(RequestWrapper rw) {
        XC_DocumentSignature__c[] docSignToUpdate = new XC_DocumentSignature__c[]{};
        FileWrapper[] fwL = rw.CategoryItem;
        for(FileWrapper fw : fwL) {
            if(fw.NumberOfFile<0){
                return; 
            } 
            if(String.isBlank(fw.DossierID)){
                continue;  
            } 
            docSignToUpdate.add(new XC_DocumentSignature__c(XC_DossierId__c = fw.DossierID, XC_Step__c = '3'));
            break;
        }
        
        if (docSignToUpdate.size() == 0) {
            return;
        }
        
        upsert docSignToUpdate XC_DossierId__c;

        //GDB 07-05-2020
        List<XC_DocumentSignatureItem__c> dsiList = new List<XC_DocumentSignatureItem__c>();
        for(FileWrapper fw : fwL) {
            if (String.isBlank(fw.DossierID)||fw.Purl==null) {
                continue;
            } else {
                if(fw.Purl.split('@').size()==1){
                    XC_DocumentSignatureItem__c dsi = new XC_DocumentSignatureItem__c();
                    dsi.XC_Category__c = fw.Category;
                    dsi.XC_DocumentSignature__c = docSignToUpdate[0].id;
                    dsi.XC_Purl__c = fw.Purl;
                    dsiList.add(dsi);
                } else {
                    for(String u : fw.Purl.split('@')){
                        XC_DocumentSignatureItem__c dsi = new XC_DocumentSignatureItem__c();
                        dsi.XC_Category__c = fw.Category;
                        dsi.XC_DocumentSignature__c = docSignToUpdate[0].id;
                        dsi.XC_Purl__c = u;
                        dsiList.add(dsi);
                    }
                }
            }
        }

        XC_UTIL_SObject.insertlistrecords(dsiList);
        //GDB fine

        docSignToUpdate = [SELECT Id, XC_SignerId__c, XC_Order__c FROM XC_DocumentSignature__c WHERE Id IN :docSignToUpdate];
        Set<XC_DigitalSignature__e> digiSignS = new Set<XC_DigitalSignature__e>();
        for (XC_DocumentSignature__c ds : docSignToUpdate) {
            digiSignS.add(new XC_DigitalSignature__e(XC_SignerId__c = ds.XC_Order__c));
        }
        
        EventBus.publish(new List<XC_DigitalSignature__e>(digiSignS));
    }
}