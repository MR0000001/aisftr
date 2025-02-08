/**
* @author dpalamides
* @date 16/09/2020
* @description classes.XC_UTIL_ReadGloviaInfoODA
*/


public without sharing class XC_UTIL_ReadGloviaInfoODA {
    private static Map<Id,XC_RequiredPosition__c> toUpdate = new Map<Id,XC_RequiredPosition__c>();

    public class PricebookEntryWrapper{
        public String categoryPosition;
        public String positionDescription;
        public String unitMeasure;
        public String materialGroup;
        public String unitRequisitioner;
        public String contractPosition;
        public String plant;
        public String accountAssignmentCategory;
        public String product;
        public String productName; 
        public String contractNumber;
        public String posDetailLineNumber;
        public String sapServiceCode;
    }

    public static Map<String,PricebookEntryWrapper> getPricebookEntryRecord(List<String> pricebookEntryId){
        Map<String,PricebookEntryWrapper> retRecord = new Map<String,PricebookEntryWrapper>();

        try{
            XC_UTIL_FSLLogistic.InputSelfCallout wrapper = new XC_UTIL_FSLLogistic.InputSelfCallout();
            wrapper.priceBookentryId = pricebookEntryId;
            wrapper.operation = 'getPricebookEntryRecord';
            XC_UTIL_FSLLogistic.OutputSelfCallout response = XC_UTIL_FSLLogistic.selfCalloutGlovia(wrapper);
            retRecord = response.pricebookEntryRecordWrapper;
        }
        catch(Exception e){
            System.debug( '@@@@ XC_UTIL_ReadGloviaInfoODA - getPricebookEntryRecord - Errore: '+e.getMessage()+' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
        }
		if(Test.isRunningTest()){
            PricebookEntryWrapper pbe = new PricebookEntryWrapper();
            pbe.contractPosition = '10';
            pbe.posDetailLineNumber = '10';
            retRecord.put('TEST',pbe);
        }
        return retRecord;

    }

    public static Contract getContractSAP(String recordId){
        Contract retRecord = null;

        try{
            retRecord=[select id,XC_IDSYSSAP__C
                    ,XC_SupplierCode__c
                    ,XC_CompanyCode__c
                    ,XC_PaymentTerm__c
                    ,XC_CurrencyKey__c
                    ,XC_CategoryRace__c
                    ,XC_ObjectSynthetic__c
                    ,XC_CIG__c
                    ,XC_CUP__c
                    ,XC_SolidalResponsability__c
                    ,XC_WarrantyReference__c
                    ,XC_ContractSAP__c
                    ,XC_SupplierCodeIO__c
                    ,XC_SupplierCodeEF__c
                    ,XC_Language__c
                    ,Name
            from Contract where id = :recordId];
        }
        catch(Exception e){
            System.debug( '@@@@ XC_UTIL_ReadGloviaInfoODA - getPricebookEntryRecord - Errore: '+e.getMessage()+' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
        }

        return retRecord;

    }

    /**
     * @author dpalamides
     */
    public static XC_UTIL_ResultWrapper sendODA(String woliId, String invoiceIssuer){
        XC_REST_CreateODA_Outbound_U.RequestWrapper wrapperInput = new XC_REST_CreateODA_Outbound_U.RequestWrapper();
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        XC_REST_CreateOda_Outbound_U.ODAWrapper wrapperODA = new XC_REST_CreateOda_Outbound_U.ODAWrapper();
        WorkOrderLineItem woli = retriveWoliInfo(woliId);
        if(woli.XC_SentToSap__c){
            rw.success = false;
            rw.resultMessage = 'Partner Engagement already sent to SAP';
            return rw;
        }
        List<String> pricebookEntryId = XC_UTIL_Sobject.getListFieldValues(woli.Required_Positions__r, 'XC_PricebookEntry__c');
        Map<String,PricebookEntryWrapper> priceBookEntry =  getPricebookEntryRecord( pricebookEntryId);
        
        String serverSystem = 'S4P';
        wrapperODA.sfdc_id = woliId;
        wrapperODA.source_system         = 'XCustomerB2C';
        wrapperODA.target_system         = woli.XC_ContractId__r.XC_IDSYSSAP__c; 
        wrapperODA.purchase_order_type   = null;
        wrapperODA.partner_sap_id        = woli.XC_ContractId__r.XC_SupplierCode__c;
        wrapperODA.purchase_order_date   = System.today();
        wrapperODA.purchasing_org        = woli.XC_PurchasingOrganization__c;
        wrapperODA.purchasing_group      = woli.XC_PurchasingGroup__c;
        wrapperODA.company               = woli.XC_ContractId__r.XC_CompanyCode__c;
        /*wrapperODA.payment_condition     = woli.XC_ContractId__r.XC_PaymentTerm__c;
        wrapperODA.po_currency           = woli.XC_ContractId__r.XC_CurrencyKey__c;
        wrapperODA.tender_category       = woli.XC_ContractId__r.XC_CategoryRace__c;
        wrapperODA.short_subject         = 
        wrapperODA.cig                   =
        wrapperODA.cup                   =
        wrapperODA.solidal_resp          =*/
        wrapperODA.contract_number       = woli.XC_ContractId__r.XC_ContractSAP__c;
        wrapperODA.supplier_code_io      = woli.XC_ContractId__r.XC_SupplierCodeIO__c;
        //wrapperODA.supplier_code_ef      = woli.XC_ContractId__r.XC_SupplierCodeEF__c;
        //NR2254 - Eleni Tsiolaki - added the invoiceIssuer parameter
        wrapperODA.supplier_code_ef      =  invoiceIssuer;
        woli.XC_Supplier_Code__c = invoiceIssuer;

        List<XC_REST_CreateODA_Outbound_U.ItemsWrapper> itemWrappers = groupPosition(woli.Required_Positions__r, priceBookEntry);
        for(XC_REST_CreateODA_Outbound_U.ItemsWrapper wr : itemWrappers){
            wr.contract_number = woli.XC_ContractId__r.XC_ContractSAP__c;
        }
        wrapperODA.items = itemWrappers;
        System.debug('wrapperODA->'+JSON.serialize(wrapperODA));

        wrapperInput.purchase_order = wrapperODA;
        XC_REST_CreateODA_Outbound.CreateODAOutboundResponseWrapper response =  XC_REST_CreateODA_Outbound.callToPostCreateODA(wrapperInput, serverSystem);

        XC_UTIL_Sobject.updateListRecords(toUpdate.values());

        Map<id,XC_ProductConsumed__c> productConsumeds = new Map<id,XC_ProductConsumed__c>([select id,XC_Product2Id__c,XC_UnitPrice__c from XC_ProductConsumed__c where XC_WorkOrderLineItem__r.XC_PartnerEngagement__c = :woliId]);
        for(XC_RequiredPosition__c rp : toUpdate.values()){
            for(XC_ProductConsumed__c pc : productConsumeds.values()) {
                Decimal polPos = rp.XC_POL_Position__c != null ? Decimal.valueOf(rp.XC_POL_Position__c) : null;
                Decimal poPos = rp.XC_POPos__c != null ? Decimal.valueOf(rp.XC_POPos__c) : null;
                if (pc.XC_Product2Id__c == rp.XC_ProductRequired__r.Product2Id && pc.XC_UnitPrice__c == rp.XC_UnitPrice__c) {
                    pc.XC_POPos__c = poPos;
                    pc.XC_POL_Position__c = polPos;
                }
            }
        }
        XC_UTIL_Sobject.updateListRecords(productConsumeds.values());

        rw.success = (response.result.result.error_code=='0'? true : false);
        rw.resultMessage = response.result.result.message;

        if(rw.success){
           woli.XC_SentToSap__c = true;
           woli.XC_ErrorMessage__c = null;
        }
        else{
            woli.XC_ErrorMessage__c = rw.resultMessage;
        }
        XC_UTIL_Sobject.updateRecord(woli);
        return rw;
    }

    private static WorkOrderLineItem retriveWoliInfo(String recordId){
        WorkOrderLineItem woli = new WorkOrderLineItem();
        if(Schema.sObjectType.WorkOrderLineItem.isAccessible()){
            woli = [SELECT XC_ContractId__r.XC_SupplierCode__c,
                    XC_PurchasingOrganization__c,
                    XC_PurchasingGroup__c,
                    XC_ContractId__r.XC_WarrantyReference__c,
                    //XC_ContractId__r.XC_ContrattoSAP__c,
                    XC_ContractId__r.XC_CompanyCode__c,
                    XC_ContractId__r.XC_SupplierCodeIO__c,
                    XC_ContractId__r.XC_SupplierCodeEF__c,
                    XC_ContractId__r.Name,
                    XC_ContractId__r.XC_ContractSAP__c,
                    XC_ContractId__r.XC_IDSYSSAP__c,
                    XC_SentToSap__c,
                    XC_ErrorMessage__c,
            (   SELECT Id,XC_PositionCode__c,XC_Quantity__c,XC_AccountAssignmentCategory__c,XC_WBE__c,XC_UnitRequisitioner__c,XC_Plant__c,XC_POPos__c, XC_UnitPrice__c,
                    XC_PricebookEntry__c, XC_CostCenter__c, XC_ProductRequired__r.Product2Id
            FROM Required_Positions__r)
            FROM WorkOrderLineItem
            WHERE Id = : recordId
            LIMIT 1];
        }
        return woli;
    }

    private static List<XC_REST_CreateODA_Outbound_U.ItemsWrapper> groupPosition( List<XC_RequiredPosition__c> requiredPositions, Map<String,PricebookEntryWrapper> priceBookEntry){
        List<XC_REST_CreateODA_Outbound_U.ItemsWrapper> itemWrappers = new List<XC_REST_CreateODA_Outbound_U.ItemsWrapper>();
        Map<String,XC_REST_CreateODA_Outbound_U.ItemsWrapper> managedPositions = new  Map<String,XC_REST_CreateODA_Outbound_U.ItemsWrapper>();
        Integer numPR = 0;
        Map<String,Integer> posNumFordetail = new Map<String,Integer>();
        Map<String,Integer> posPOFordetail = new Map<String,Integer>();
        for(XC_RequiredPosition__c pos : requiredPositions){
            PricebookEntryWrapper pbEntry = priceBookEntry.get(pos.XC_PricebookEntry__c);
            if(!managedPositions.containsKey(pos.XC_PositionCode__c)) {

                XC_REST_CreateODA_Outbound_U.ItemsWrapper posWrapper = new XC_REST_CreateODA_Outbound_U.ItemsWrapper();

                posWrapper.sap_pos_po = (numPR + 1) * 10;//Integer.valueOf(pbEntry.contractPosition); //valorizzare di 10 in 10 su pos
                pos.XC_POPos__c = String.valueOf((numPR + 1) * 10);
                //posNumFordetail.put(pos.XC_PositionCode__c,(numPR + 1) * 10);
                posPOFordetail.put(pos.XC_PositionCode__c,(numPR + 1) * 10);
                numPR = numPR + 1;

                posWrapper.sap_pos_category = pbEntry.categoryPosition;
                posWrapper.accounting_category = pos.XC_AccountAssignmentCategory__c; //una tantum 1
                //posWrapper.material_code = ;
                //posWrapper.short_description = ;
                posWrapper.qty = pos.XC_Quantity__c;
                //posWrapper.unit_of_measure = ;
                //posWrapper.net_price = ;
                //posWrapper.price_unit = ;
                posWrapper.division = pos.XC_Plant__c; //una tantum 2
                //posWrapper.goods_group = ;
                posWrapper.applicant_unit = pos.XC_UnitRequisitioner__c; //una tantum 3
                //posWrapper.communication_language = ;
                //posWrapper.iva_code = ;
                //////////posWrapper.contract_number = null;
                posWrapper.contract_pos_number = Integer.valueOf(pbEntry.contractPosition);
                //posWrapper.cost_center = ;
                posWrapper.wbs_element = pos.XC_WBE__c;

                //posWrapper.net_price = pos.XC_UnitPrice__c!=null ? String.valueOf(pos.XC_UnitPrice__c) : '0';

                posWrapper.net_price = '0';

                managedPositions.put(pos.XC_PositionCode__c,posWrapper);
                itemWrappers.add(posWrapper);
            }

            XC_REST_CreateODA_Outbound_U.ItemsWrapper posWrapperForPrest = managedPositions.get(pos.XC_PositionCode__c);
            XC_REST_CreateODA_Outbound_U.ItemsServiceWrapper itemDetail = new XC_REST_CreateODA_Outbound_U.ItemsServiceWrapper();

            Integer ind = posNumFordetail.containsKey(pos.XC_PositionCode__c) ? posNumFordetail.get(pos.XC_PositionCode__c) : 0;
            itemDetail.sap_pos_po = posPOFordetail.get(pos.XC_PositionCode__c);//(ind+1) * 10;
            
            if(pos.XC_POPos__c == null){
                pos.XC_POPos__c = String.valueOf(posPOFordetail.get(pos.XC_PositionCode__c));
            }
            
            pos.XC_POL_Position__c = String.valueOf((ind+1) * 10);
            posNumFordetail.put(pos.XC_PositionCode__c,(ind+1));

            itemDetail.sap_row_number = Integer.valueOf(pbEntry.posDetailLineNumber);
            itemDetail.sap_service_code = pbEntry.sapServiceCode != null ? (pbEntry.sapServiceCode.contains('_') ? pbEntry.sapServiceCode.substringAfter('_') : pbEntry.sapServiceCode) : null;
            //short_description = ; 
            itemDetail.qty = pos.XC_Quantity__c; //Integer.valueOf(pos.XC_Quantity__c);
            //unit_of_measure = ;
            //gross_price = ;
            //sap_currency = ;
            //price_unit = ;
            itemDetail.cost_center = pos.XC_CostCenter__c;
            itemDetail.wbs_element = pos.XC_WBE__c;

            //itemDetail.gross_price = pos.XC_UnitPrice__c!=null ? String.valueOf(pos.XC_UnitPrice__c) : '0';
            itemDetail.gross_price =  '0';

            posWrapperForPrest.items_services.add(itemDetail);

            toUpdate.put(pos.Id,pos);
        }

        return itemWrappers;
    }

}