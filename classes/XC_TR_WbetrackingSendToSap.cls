/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Send WBE to SAP
    **/
public with sharing class XC_TR_WbetrackingSendToSap {
    @Future(callout=true)
    public static void sentToSap(Set<Id> wbeTrackIDs){
        Map<Id,XC_WbeTracking__c> salesOrder = new Map<id,XC_WbeTracking__c>([select Id, XC_ConfigurationId__c from XC_WbeTracking__c  where id in :wbeTrackIDs]);
        Set<Id> setSalesOrder = New Set<Id>();
        for(XC_WbeTracking__c wb : salesOrder.values()){
            setSalesOrder.add(wb.XC_ConfigurationId__c);
        }



        Map<Id,XC_WbeTracking__c> mapNews = new Map<id,XC_WbeTracking__c>([select Id, XC_Wbe__c, XC_ProfitCenter__c, XC_CostCenter__c, XC_Status__c, XC_Result__c, XC_Counter__c, XC_BusinessModelCode__c, XC_ClientIdentifier__c, XC_ConfigurationId__c, XC_ConfigurationItemId__c, XC_ExecutionProjectId__c, XC_InvestmentReason__c, XC_OrderNumber__c,
                XC_ProductService__c, XC_ProjectType__c, XC_ReturnDate__c, XC_ReturnErrorDescription__c, XC_SapPillar__c, XC_Scope__c, XC_SentDate__c,
                XC_TypeOfSending__c, XC_Activity__c, XC_Applicant__c, XC_Channel__c, XC_CompanyCode__c, XC_Contract__c,
                XC_CostCenterApplicant__c, XC_CostCenterResponsible__c, XC_CustomerGeography__c, XC_CustomerRelevance__c,
                XC_CustomerSegment__c, XC_CustomerSize__c, XC_KitLogistic__c, XC_LegalEntityGeography__c, XC_Market__c,
                XC_OdvIntercompany__c, XC_ProductLine__c, XC_Responsible__c, XC_ReturnErrorcode__c, XC_SalesOrder__c,
                XC_TypeOfCustomer__c, XC_TypeOfLocation__c, XC_WBS__c, XC_WbeIDescription__c, XC_WbeIIDescription__c,
                XC_WbeIIIDescription__c, XC_WbeIII__c, XC_WbeII__c, XC_WbeI__c, XC_WbsDescription__c,XC_ContractStartDate__c,
                XC_ContractEndDate__c, XC_EstimatedRevenue__c, XC_EstimatedCost__c, XC_WBEcapexUpdate__c, XC_ContractType__c, XC_DocumentType__c,
                XC_DocumentNumber__c, XC_CustomerName__c, XC_Ownership__c, XC_Location__c
        from XC_WbeTracking__c  where XC_ConfigurationId__c in :setSalesOrder]);

        XC_REST_WBE_Inbound_U.RequestWrapper rqw = new XC_REST_WBE_Inbound_U.RequestWrapper();
        List<XC_REST_WBE_Inbound_U.WbeWrapper> wbess = new List<XC_REST_WBE_Inbound_U.WbeWrapper>();
        for(XC_WbeTracking__c wb : mapNews.values()){
            if(wb.XC_Wbe__c.substring(10,11) == 'Y') {
                XC_REST_WBE_Inbound_U.WbeWrapper wbes = mapOpex(wb);
                wbess.add(wbes);
            }

        }
        rqw.wbes = wbess;

        List<XC_WbeTracking__c> listToUpdateError = new List<XC_WbeTracking__c>();
        XC_REST_WBE_Inbound_U.ResponseWrapper rsw = new XC_REST_WBE_Inbound_U.ResponseWrapper();
        if(!wbess.isEmpty()){
            String sapSystem =wbess[0].sap_pillar.startsWith('D4')? 'D4P': 'S4P';
            rsw = XC_REST_WBE_Outbound.callToPostWBE(rqw, sapSystem);
            if(rsw.result.error_code!='0' && rsw.result!= null){
                for(XC_WbeTracking__c wbTErrore :mapNews.values()){
                    wbTErrore.XC_Status__c ='Rejected';
                    wbTErrore.XC_ReturnErrorDescription__c = rsw.result.message != null ? rsw.result.message.left(250) : '0';
                    listToUpdateError.add(wbTErrore);
                }
            }
        }
        if(!listToUpdateError.isEmpty()) {
            update listToUpdateError;
        }

    }

    @Future(callout=true)
    public static void sentToSapCapex(Set<Id> wbeTrackIDs){
        Map<Id,XC_WbeTracking__c> salesOrder = new Map<id,XC_WbeTracking__c>([select Id, XC_ConfigurationId__c from XC_WbeTracking__c  where id in :wbeTrackIDs]);
        Set<Id> setSalesOrder = New Set<Id>();
        for(XC_WbeTracking__c wb : salesOrder.values()){
            setSalesOrder.add(wb.XC_ConfigurationId__c);
        }

        Map<Id,XC_WbeTracking__c> mapNews = new Map<id,XC_WbeTracking__c>([select Id, XC_Wbe__c, XC_ProfitCenter__c, XC_CostCenter__c, XC_Status__c, XC_Result__c, XC_Counter__c, XC_BusinessModelCode__c, XC_ClientIdentifier__c, XC_ConfigurationId__c, XC_ConfigurationItemId__c,
                XC_ExecutionProjectId__c, XC_InvestmentReason__c, XC_OrderNumber__c, XC_ProductService__c, XC_ProjectType__c, XC_ReturnDate__c, XC_ReturnErrorDescription__c,
                XC_SapPillar__c, XC_Scope__c, XC_SentDate__c, XC_TypeOfSending__c, XC_Activity__c, XC_Applicant__c, XC_Channel__c,
                XC_CompanyCode__c, XC_Contract__c, XC_CostCenterApplicant__c, XC_CostCenterResponsible__c, XC_CustomerGeography__c,
                XC_CustomerRelevance__c, XC_CustomerSegment__c, XC_CustomerSize__c, XC_KitLogistic__c, XC_LegalEntityGeography__c,
                XC_Market__c, XC_OdvIntercompany__c, XC_ProductLine__c, XC_Responsible__c, XC_ReturnErrorcode__c, XC_SalesOrder__c,
                XC_TypeOfCustomer__c, XC_TypeOfLocation__c, XC_WBS__c, XC_WbeIDescription__c, XC_WbeIIDescription__c,
                XC_WbeIIIDescription__c, XC_WbeIII__c, XC_WbeII__c, XC_WbeI__c, XC_WbsDescription__c, XC_ContractStartDate__c, XC_ContractEndDate__c,
                XC_EstimatedRevenue__c, XC_EstimatedCost__c, XC_WBEcapexUpdate__c, XC_ContractType__c, XC_DocumentType__c,
                XC_DocumentNumber__c, XC_CustomerName__c, XC_Ownership__c, XC_Location__c
        from XC_WbeTracking__c  where XC_ConfigurationId__c in :setSalesOrder]);

        XC_REST_WBE_Inbound_U.RequestWrapper rqw = new XC_REST_WBE_Inbound_U.RequestWrapper();
        List<XC_REST_WBE_Inbound_U.WbeWrapper> wbess = new List<XC_REST_WBE_Inbound_U.WbeWrapper>();
        for(XC_WbeTracking__c wb : mapNews.values()){
            if(wb.XC_Wbe__c.substring(10,11) == 'W') {
                XC_REST_WBE_Inbound_U.WbeWrapper wbes = mapCapex(wb);
                wbess.add(wbes);
            }

        }
        rqw.wbes = wbess;




        XC_REST_WBE_Inbound_U.ResponseWrapper rsw = new XC_REST_WBE_Inbound_U.ResponseWrapper();
        List<XC_WbeTracking__c> listToUpdateError = new List<XC_WbeTracking__c>();
        if(!wbess.isEmpty()){
            String sapSystem =wbess[0].sap_pillar.startsWith('D4')? 'D4P': 'S4P';
            rsw = XC_REST_WBE_Outbound.callToPostWBE(rqw, sapSystem);
            if(rsw.result.error_code!='0' && rsw.result != null){
                for(XC_WbeTracking__c wbTErrore :mapNews.values()){
                    wbTErrore.XC_Status__c ='Rejected';
                    wbTErrore.XC_ReturnErrorDescription__c = rsw.result.message != null ? rsw.result.message.left(250) : '0';
                    listToUpdateError.add(wbTErrore);
                }
            }
        }
        if(!listToUpdateError.isEmpty()){
            update listToUpdateError;
        }

    }


    private static XC_REST_WBE_Inbound_U.WbeWrapper mapOpex(XC_WbeTracking__c wb){
        XC_REST_WBE_Inbound_U.WbeWrapper wbes = new XC_REST_WBE_Inbound_U.WbeWrapper();
        wbes.wbe = wb.XC_Wbe__c;		//24 char Code
        wbes.wbs = wb.XC_WBS__c;							//Project Code
        wbes.scope = wb.XC_Scope__c;							//"B2C", "B2B/G" (Scope of the WBE Dimension)
        wbes.sap_pillar = wb.XC_SapPillar__c;						//"D4P", "S4P" (SAP pillar where WBE are updated)
        wbes.company_code = wb.XC_CompanyCode__c;						//Prime 4 cifre della wbe
        wbes.product_line = wb.XC_ProductLine__c;						//Seconde 4 cifre della wbe, campo del catalog item (SAP Organization)
        wbes.product_service_code = wb.XC_ProductService__c;				//Contains the WBE digit 13-15. It represents the field 'Codice Prodotti' requested in AFC
        wbes.cost_center_responsible = wb.XC_CostCenterResponsible__c;	//Centro di costo, prime 10 cifre della WBE
        wbes.market = wb.XC_Market__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.business_model_code = wb.XC_BusinessModelCode__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.order_number = wb.XC_OrderNumber__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.configuration_id = wb.XC_ConfigurationId__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.configuration_item_id = wb.XC_ConfigurationItemId__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.execution_project_id = wb.XC_ExecutionProjectId__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.client_identifier = wb.XC_ClientIdentifier__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.customer_segment = wb.XC_CustomerSegment__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.legal_entity_geografy = wb.XC_LegalEntityGeography__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.channel = wb.XC_Channel__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.customer_relevance = wb.XC_CustomerRelevance__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.customer_size = wb.XC_CustomerSize__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.type_of_customer = wb.XC_TypeOfCustomer__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.customer_geografy = wb.XC_CustomerGeography__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.kit_logistic = wb.XC_KitLogistic__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.contract = wb.XC_Contract__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.activity = wb.XC_Activity__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.wbe_first_level = wb.XC_WbeI__c;			//First level of WBE, 12 char
        wbes.sfdc_id = wb.id;			// tracking id
        wbes.wbe_second_level = wb.XC_WbeII__c;				//Second level of WBE, 6 char
        wbes.wbe_third_level = wb.XC_WbeIII__c;					//Third level of WBE, 6 char
        wbes.type_of_sending = wb.XC_TypeOfSending__c;			//"Service Creation", "Order Submit"
        wbes.status = wb.XC_Status__c;							//"New", "Not sent", "Sent", "Rejected", "Approved"
        wbes.sales_order = wb.XC_SalesOrder__c;				//
        wbes.odv_intercompany = wb.XC_OdvIntercompany__c;				//
        //wbes.order_id = wb.XC_ConfigurationId__c;				//

        wbes.contractStartDate      = wb.XC_ContractStartDate__c;
        wbes.contractEndDate        = wb.XC_ContractEndDate__c;
        wbes.estimatedRevenue       = wb.XC_EstimatedRevenue__c;
        wbes.estimatedCost          = wb.XC_EstimatedCost__c;
        wbes.updateWBEcapex         = wb.XC_WBEcapexUpdate__c;
        wbes.contractType           = wb.XC_ContractType__c;
        wbes.DocumentType           = wb.XC_DocumentType__c;
        wbes.DocumentNumber         = wb.XC_DocumentNumber__c;
        wbes.customerName           = wb.XC_CustomerName__c;
        wbes.ownership              = wb.XC_Ownership__c;
        wbes.location               = wb.XC_Location__c;


        return wbes;
    }

    private static XC_REST_WBE_Inbound_U.WbeWrapper mapCapex(XC_WbeTracking__c wb){
        XC_REST_WBE_Inbound_U.WbeWrapper wbes = new XC_REST_WBE_Inbound_U.WbeWrapper();
        wbes.wbe = wb.XC_Wbe__c;		//24 char Code
        wbes.wbs = wb.XC_WBS__c;							//Project Code
        wbes.scope = wb.XC_Scope__c;							//"B2C", "B2B/G" (Scope of the WBE Dimension)
        wbes.sap_pillar = wb.XC_SapPillar__c;						//"D4P", "S4P" (SAP pillar where WBE are updated)
        wbes.company_code = wb.XC_CompanyCode__c;						//Prime 4 cifre della wbe
        wbes.product_line = wb.XC_ProductLine__c;						//Seconde 4 cifre della wbe, campo del catalog item (SAP Organization)
        wbes.product_service_code = wb.XC_ProductService__c;				//Contains the WBE digit 13-15. It represents the field 'Codice Prodotti' requested in AFC
        wbes.cost_center_responsible = wb.XC_CostCenterResponsible__c;	//Centro di costo, prime 10 cifre della WBE
        wbes.market = wb.XC_Market__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.business_model_code = wb.XC_BusinessModelCode__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.order_number = wb.XC_OrderNumber__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.configuration_id = wb.XC_ConfigurationId__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.configuration_item_id = wb.XC_ConfigurationItemId__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.execution_project_id = wb.XC_ExecutionProjectId__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.client_identifier = wb.XC_ClientIdentifier__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.customer_segment = wb.XC_CustomerSegment__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.legal_entity_geografy = wb.XC_LegalEntityGeography__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.channel = wb.XC_Channel__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.customer_relevance = wb.XC_CustomerRelevance__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.customer_size = wb.XC_CustomerSize__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.type_of_customer = wb.XC_TypeOfCustomer__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.customer_geografy = wb.XC_CustomerGeography__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.kit_logistic = wb.XC_KitLogistic__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.contract = wb.XC_Contract__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.activity = wb.XC_Activity__c;								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.wbe_first_level = wb.XC_WbeI__c;			//First level of WBE, 12 char
        wbes.sfdc_id = wb.id;			// tracking id
        wbes.wbe_second_level = wb.XC_WbeII__c;				//Second level of WBE, 6 char
        wbes.wbe_third_level = wb.XC_WbeIII__c;					//Third level of WBE, 6 char
        wbes.type_of_sending = wb.XC_TypeOfSending__c;			//"Service Creation", "Order Submit"
        wbes.status = wb.XC_Status__c;							//"New", "Not sent", "Sent", "Rejected", "Approved"
        wbes.sales_order = wb.XC_SalesOrder__c;				//
        wbes.odv_intercompany = wb.XC_OdvIntercompany__c;				//
        //wbes.order_id = wb.XC_ConfigurationId__c;				//

        wbes.contractStartDate      = wb.XC_ContractStartDate__c;
        wbes.contractEndDate        = wb.XC_ContractEndDate__c;
        wbes.estimatedRevenue       = wb.XC_EstimatedRevenue__c;
        wbes.estimatedCost          = wb.XC_EstimatedCost__c;
        wbes.updateWBEcapex         = wb.XC_WBEcapexUpdate__c;
        wbes.contractType           = wb.XC_ContractType__c;
        wbes.DocumentType           = wb.XC_DocumentType__c;
        wbes.DocumentNumber         = wb.XC_DocumentNumber__c;
        wbes.customerName           = wb.XC_CustomerName__c;
        wbes.ownership              = wb.XC_Ownership__c;
        wbes.location               = wb.XC_Location__c;

        return wbes;
    }

    public static void sendUpdateCapexSAP(Map<Id,XC_WbeTracking__c> mapOlds, Map<Id,XC_WbeTracking__c> mapNews){
        Set<Id> toSend = new Set<Id>();
        for(XC_WbeTracking__c wbt : mapNews.values()){
            if(mapOlds.get(wbt.Id).XC_WBEcapexUpdate__c != wbt.XC_WBEcapexUpdate__c && wbt.XC_WBEcapexUpdate__c == true){
                toSend.add(wbt.Id);
            }
        }
        if(!toSend.isEmpty()) {
            sentToSapCapex(toSend);
        }
    }

    public static void updateWbeTrackingOnClosedOrder(Map<Id,NE__Order__c> mapOlds, Map<Id,NE__Order__c> mapNews){
        List<NE__Order__c> closedOrders = new List<NE__Order__c>();
        for(NE__Order__c  ord : mapNews.values()){
            if(mapOlds.get(ord.Id).XC_Status__c != ord.XC_Status__c && ord.XC_Status__c == Label.XC_CL_Configuration_OrderClosed){
                closedOrders.add(ord);
            }
        }

        if(closedOrders.isEmpty()){
            return;
        }

        List<XC_WbeTracking__c> capexWbe = [select id,XC_Wbe__c from XC_WbeTracking__c where XC_ConfigurationId__c  in :XC_UTIL_Sobject.getIds(closedOrders)];
        List<XC_WbeTracking__c> toUpdate = new List<XC_WbeTracking__c>();

        for(XC_WbeTracking__c wbe : capexWbe){
            if(wbe.XC_Wbe__c.substring(10,11) == 'W'){
                wbe.XC_WBEcapexUpdate__c = true;
                toUpdate.add(wbe);
            }
        }
        if(!toUpdate.isEmpty()){
            XC_UTIL_Sobject.updateListRecords(toUpdate);
        }
    }



}