/**
 * @author Monica Cutillo - monica.cutillo@nttdata.com
 * @date Creation 11/07/2019
 * @date Modification 
 * @description XC_LCC132_CallToCommodityContract – Controller for XC_LCP132_CallToCommodityContract Component
 */
public class XC_LCC132_CallToCommodityContract {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC005_AccountCallToCommodity');

    /**
     * @description call to Commodity getContract
     * @param recordId the record id
     * @param sobjectType the sobject Type
     * @return the result wrapper
     */
    /*@AuraEnabled(continuation=true cacheable=true)
    public static Object callCommodityContract(String recordId, String sobjectType){    //OLD Output XC_LCC005_AccountCallToCommodity.ResultWrapper
        String identityNumber = XC_LCC005_AccountCallToCommodity.retrieveIdentityNumber(recordId, sobjectType);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ callCommodityContract -> identityNumber='+identityNumber);
        if(identityNumber == ''){
            XC_LCC005_AccountCallToCommodity.ResultWrapper rw = new XC_LCC005_AccountCallToCommodity.ResultWrapper(false, Label.XC_CL_NoDocForAccountMess);
            return rw;
        }

        Map<String,Object> callResult;
        try {
            HttpRequest req = XC_REST_Contract_Outbound.initContractOutboundRequest(identityNumber);
            // Create a Continuation for the HTTPRequest        
            Continuation con = new Continuation(40);
            con.continuationMethod='processCommodityContractResponse';
            con.state = 'CommodityContractResponse OK';
            con.addHttpRequest(req);
            // Return it to the system for processing
            return con;
        } catch (XC_Exception ex) {
            callResult = XC_REST_Contract_Outbound.manageResponseFake();
            return manageGetContractResponse((List<Object>)callResult.get('Contract'));
        }

        //Map<String,Object> callResult = XC_REST_Contract_Outbound.callToGetContract(identityNumber, '');
        /*if(callResult.isEmpty() || callResult.get('Contract')==null) {
            XC_LCC005_AccountCallToCommodity.ResultWrapper rw = new XC_LCC005_AccountCallToCommodity.ResultWrapper();
            rw.success = false;
            rw.resultMessage = (String)callResult.get('Message');
            return rw;
        }* /
        //return manageGetContractResponse((List<Object>)callResult.get('Contract'));
    }
    
    // Callback method
    /*@AuraEnabled(cacheable=true)
    public static Object processCommodityContractResponse(List<String> labels, Object state) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ processCommodityContractResponse Callbac');
        // Get the response by using the unique label
        HttpResponse response = Continuation.getResponse(labels[0]);
        Map<String,Object> wrapperResult = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
        return manageGetContractResponse((List<Object>)wrapperResult.get('Contract'));
    }*/

    /**
     * @description call to Commodity getContract
     * @param recordId the record id
     * @param sobjectType the sobject Type
     * @return the result wrapper
     */
    /*@AuraEnabled
    public static XC_LCC005_AccountCallToCommodity.ResultWrapper callCommodityReadCase(String recordId, String sobjectType){
        String identityNumber = XC_LCC005_AccountCallToCommodity.retrieveIdentityNumber(recordId, sobjectType);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ callCommodityReadCase -> identityNumber='+identityNumber);
        if(identityNumber == ''){
            XC_LCC005_AccountCallToCommodity.ResultWrapper rw = new XC_LCC005_AccountCallToCommodity.ResultWrapper(false, Label.XC_CL_NoDocForAccountMess);
            return rw;
        }

        Date endD = Date.today();
        Date startD = endD.addDays(-180);
        XC_REST_Case_W.WrapperCaseResponseGET  callCaseResult = XC_REST_Case_Outbound.callToGetCase(new Map<String, String> 
        { 'IdentityNumberAccount' => identityNumber,
          'StartDate' => String.valueOf(startD),
          'EndDate' => String.valueOf(endD) });
        
        if(callCaseResult.CaseList==null || callCaseResult.CaseList.isEmpty()) {
            XC_LCC005_AccountCallToCommodity.ResultWrapper rw = new XC_LCC005_AccountCallToCommodity.ResultWrapper();
            rw.success = false;
            rw.resultMessage = callCaseResult.Result.Message;
            return rw;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ response CaseList='+callCaseResult.CaseList);

        return manageGetCaseResponse(callCaseResult.CaseList);
    }*/

    /**
     * @description call to Commodity ReadInvoiceList
     * @param recordId the record id
     * @param sobjectType the sobject Type
     * @return the result wrapper
     */
    /*@AuraEnabled
    public static XC_LCC005_AccountCallToCommodity.ResultWrapper callCommodityInvoice(String recordId, String sobjectType){
        String identityNumber = XC_LCC005_AccountCallToCommodity.retrieveIdentityNumber(recordId, sobjectType);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ callCommodityReadCase -> identityNumber='+identityNumber);
        if(identityNumber == ''){
            XC_LCC005_AccountCallToCommodity.ResultWrapper rw = new XC_LCC005_AccountCallToCommodity.ResultWrapper(false, Label.XC_CL_NoDocForAccountMess);
            return rw;
        }

        XC_REST_Invoice_W.ReadInvoiceListResponse callInvoiceListResult = XC_REST_ReadInvoiceList.callToReadInvoiceList(new Map<String, String> { 'DocumentationID' => identityNumber });
        
        if(callInvoiceListResult.Invoice == null || callInvoiceListResult.Invoice.isEmpty()) {
            XC_LCC005_AccountCallToCommodity.ResultWrapper rw = new XC_LCC005_AccountCallToCommodity.ResultWrapper();
            rw.success = false;
            rw.resultMessage = callInvoiceListResult.Result.Message;
            return rw;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ response ReadInvoiceList=' + callInvoiceListResult.Invoice);

        return manageInvoiceListResponse(callInvoiceListResult.Invoice);
    }*/

    /**
     * @description manage readInvoiceList Response
     * @param invoiceList invoiceList Response
     * @return the result wrapper
     */
    public static XC_LCC005_AccountCallToCommodity.ResultWrapper manageInvoiceListResponse(List<XC_REST_Invoice_W.InvoiceWrapper> invoiceList){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ manageInvoiceListResponse -> invoiceList='+invoiceList);
        XC_LCC005_AccountCallToCommodity.ResultWrapper rw = new XC_LCC005_AccountCallToCommodity.ResultWrapper();
        XC_LCC005_AccountCallToCommodity.SectionFieldWrapper section = new XC_LCC005_AccountCallToCommodity.SectionFieldWrapper();
        section.sectionLabel = Label.XC_CL_Invoice;
        section.dataObjects = new List<String>();
        List<List<XC_LCC005_AccountCallToCommodity.FieldWrapper>> objsFields = new List<List<XC_LCC005_AccountCallToCommodity.FieldWrapper>>();
        //List<XC_LCC005_AccountCallToCommodity.FieldWrapper> fields;
        Map<String,XC_LCC005_AccountCallToCommodity.FieldWrapper> fieldsMap;
        //Map<String,Object> invoiceDataMap;
        String addressValue = '';
        for(XC_REST_Invoice_W.InvoiceWrapper invObj : invoiceList){
            if(invObj == null){
                continue;
            }
            section.dataObjects.add(JSON.serialize(invObj));
            //invoiceDataMap = XC_REST_ReadAccont_U.buildMapFromWrapperObject(invObj);
            //fields = buildFieldsWrapper(invoiceDataMap, (XC_UTIL_ViewDefinitionsReadAccount.getCommodityViewDefinitions()).get('Invoice'));
            fieldsMap = XC_LCC005_AccountCallToCommodity.buildFieldsWrapperMap(invObj, (XC_UTIL_ViewDefinitionsReadAccount.getCommodityViewDefinitions()).get('Invoice'));
            //modifico nell'Invoice il campo relativo al suo Address, se valorizzato
            if(invObj.Address != null){
                XC_LCC005_AccountCallToCommodity.FieldWrapper wr = fieldsMap.get('Address');
                fieldsMap.remove('Address');
                if(wr != null){
                    addressValue = invObj.Address.StreetType+' '+invObj.Address.Street+', '+invObj.Address.StreetNumber+' '+invObj.Address.City;
                    wr.fieldValue = addressValue;
                    fieldsMap.put('Address',wr);
                }
            }
            if(!fieldsMap.isEmpty()){
                objsFields.add(fieldsMap.values());
            }
        }
        //section.dataObjects = dataObjects;
        section.objectsRecordFields = objsFields;
        rw.sections.put('Invoice', section);
        rw.success = true;
        return rw;
    }

    /**
     * @description manage getCase Response
     * @param commodityCases getCase Response
     * @return the result wrapper
     */
    public static XC_LCC005_AccountCallToCommodity.ResultWrapper manageGetCaseResponse(List<XC_UTIL_Case.CaseRESTWrapper> commodityCases,  Map<String,String> addressMap){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ manageGetCaseResponse -> commodityCases='+commodityCases);
        XC_LCC005_AccountCallToCommodity.ResultWrapper rw = new XC_LCC005_AccountCallToCommodity.ResultWrapper();
        XC_LCC005_AccountCallToCommodity.SectionFieldWrapper section = new XC_LCC005_AccountCallToCommodity.SectionFieldWrapper();
        section.sectionLabel = Label.XC_CL_Case;
        List<List<XC_LCC005_AccountCallToCommodity.FieldWrapper>> objsFields = new List<List<XC_LCC005_AccountCallToCommodity.FieldWrapper>>();
        List<XC_LCC005_AccountCallToCommodity.FieldWrapper> fields;
        Map<String,Object> caseDataMap;
        for(XC_UTIL_Case.CaseRESTWrapper caseObj : commodityCases){
            caseDataMap = XC_REST_ReadAccont_U.buildMapFromWrapperObject(caseObj);
            if(caseDataMap.get('AddressID')!= null){
                caseDataMap.put('AddressID', addressMap.get(String.valueOf(caseDataMap.get('AddressID')))!= null? addressMap.get(String.valueOf(caseDataMap.get('AddressID'))): '');
            }
            fields = buildFieldsWrapper(caseDataMap, (XC_UTIL_ViewDefinitionsReadAccount.getCommodityViewDefinitions()).get('Case'));
            if(!fields.isEmpty()){
                objsFields.add(fields);
            }
        }
        section.objectsRecordFields = objsFields;
        rw.sections.put('Case', section);
        rw.success = true;
        return rw;
    }

    /**
     * @description manage getContract Response
     * @param commodityContracts getContract Response
     * @return the result wrapper
     */
    public static XC_LCC005_AccountCallToCommodity.ResultWrapper manageGetContractResponse(List<Object> commodityContracts, Map<String,String> addressMap){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ manageGetContractResponse -> commodityContracts='+commodityContracts);
        XC_LCC005_AccountCallToCommodity.ResultWrapper rw = new XC_LCC005_AccountCallToCommodity.ResultWrapper();
        XC_LCC005_AccountCallToCommodity.SectionFieldWrapper section = new XC_LCC005_AccountCallToCommodity.SectionFieldWrapper();
        section.sectionLabel = Label.XC_CL_Contract;
        List<List<XC_LCC005_AccountCallToCommodity.FieldWrapper>> objsFields = new List<List<XC_LCC005_AccountCallToCommodity.FieldWrapper>>();
        List<XC_LCC005_AccountCallToCommodity.FieldWrapper> fields;
        Map<String,Object> contractData;
        for(Object contractObj : commodityContracts){
            contractData = (Map<String,Object>)contractObj;
            if(contractData.get('Status') != null && 'Active' != (String)contractData.get('Status') && 'Inactive' != (String)contractData.get('Status')){
                continue;
            }
            /*if(contractData.get('AddressID')!= null){
                contractData.put('AddressID', addressMap.get(String.valueOf(contractData.get('AddressID')))!= null? addressMap.get(String.valueOf(contractData.get('AddressID'))): '');
            }*/
            fields = buildFieldsWrapper(contractData, (XC_UTIL_ViewDefinitionsReadAccount.getCommodityViewDefinitions()).get('Contract'));
            if(!fields.isEmpty()){
                objsFields.add(fields);
            }
        }
        section.objectsRecordFields = objsFields;
        rw.sections.put('Contract', section);
        rw.success = true;
        return rw;
    }

    /**
     * @description Builds the fields wrapper.
     * @param objectDataMap commodity object Data Map
     * @param viewDef the ReadAccountViewDefinition
     * @return fields list
     */
    public static List<XC_LCC005_AccountCallToCommodity.FieldWrapper> buildFieldsWrapper(Map<String,Object> objectDataMap, XC_UTIL_ViewDefinitionsReadAccount.ReadAccountViewDefinition viewDef){
        List<XC_LCC005_AccountCallToCommodity.FieldWrapper> fieldsWr = new List<XC_LCC005_AccountCallToCommodity.FieldWrapper>();
        Map<String,String> labels = viewDef.labels;
        Map<String,String> types = viewDef.types;
        for(String key : viewDef.keySet){
            if(labels.get(key)!=null){
                XC_LCC005_AccountCallToCommodity.FieldWrapper wr = new XC_LCC005_AccountCallToCommodity.FieldWrapper();
                if(String.isNotBlank(key)){
                    wr.fieldKey   = key;
                    wr.fieldLabel = labels.get(key);
                    wr.fieldValue = String.valueOf(objectDataMap.get(key));
                    if(types!=null && types.get(key) != null){
                        wr.fieldType = types.get(key);
                    }
                    fieldsWr.add(wr);
                }
            }
        }
        return fieldsWr;
    }

    /**
     * @description call to REST Commodity ReadInvoicePDF
     * @param invoiceDataObj invoive stringyfied wrapper
     * @return the result wrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper callReadInvoicePDF(String invoiceDataObj, String country){
        XC_UTIL_ResultWrapper result = new XC_UTIL_ResultWrapper();
        String invDataStr = (String)JSON.deserializeUntyped(invoiceDataObj);
        Map<String,Object> invDataMap = (Map<String,Object>)JSON.deserializeUntyped(invDataStr);
        XC_REST_RetrieveInvoicePDF.WrapperRetrieveInvoice invWR = new XC_REST_RetrieveInvoicePDF.WrapperRetrieveInvoice();
        invWR.InvoiceID = (String)invDataMap.get('InvoiceNumber');
        invWR.InvoiceSequential = (String)invDataMap.get('InvoiceSequential');
        invWR.ContractID = (String)invDataMap.get('ContractNumber'); //ContractID
        invWR.CompanyOwner = (String)invDataMap.get('CompanyCode');
        invWR.BusinessLine = (String)invDataMap.get('BusinessLine');
        invWR.ProcessDate = (Datetime.now()).format('yyyyMMdd');
        invWR.PaymentGateway  = 'EE';
        invWR.ContractNumber = (String)invDataMap.get('ContractSequential'); //ContractNumber
        invWR.InvoiceCode = (String)invDataMap.get('InvoiceReference');
        invWR.Market = 'ML';
        invWR.User = 'X-CUSTOMER';
        invWR.SystemDate = (Datetime.now()).format('yyyyMMdd');
        invWR.UserID = 'X-CUSTOMER';
        invWR.Password = Label.XC_CL_PasswordCommodity;
        invWR.InvoiceType = '04';
        invWR.DocumentType = '';
        invWR.OrigenSystem = '33';
        XC_REST_RetrieveInvoicePDF.WrapperResponse invPDFres = XC_REST_RetrieveInvoicePDF.callToRetrieveInvoice(invWR);
        result.success = true;
        if(invPDFres != null && invPDFres.RetrieveInvoice != null && invPDFres.RetrieveInvoice.InvoicePDF != null){
            //result.objectInfo = JSON.serialize(invPDFres.RetrieveInvoice.InvoicePDF);
            result.objectResult = invPDFres.RetrieveInvoice.InvoicePDF;
            //result.objectResult = EncodingUtil.base64Decode(invPDFres.RetrieveInvoice.InvoicePDF).toString();
            result.objectInfo = System.URL.getSalesforceBaseUrl().toExternalForm();
        } else {
            if(invPDFres.Result != null && invPDFres.Result.Message != null){
                result.success = false;
                result.resultMessage = invPDFres.Result.Message;
            }
        }
        return result;
    }
}