/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/
@isTest
public with sharing class XC_REST_WBE_Outbound_Test {
    static testMethod void submitTest(){
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = 'CreateWBE';
        ic.XC_interfaceName__c = 'CreateWBE';
        insert ic;
        XC_REST_WBE_Inbound_U.RequestWrapper rqw = new XC_REST_WBE_Inbound_U.RequestWrapper();
        List<XC_REST_WBE_Inbound_U.WbeWrapper> wbess = new List<XC_REST_WBE_Inbound_U.WbeWrapper>();
        XC_REST_WBE_Inbound_U.WbeWrapper wbes = new XC_REST_WBE_Inbound_U.WbeWrapper();
        wbes.wbe = 'DL';		//24 char Code
        wbes.wbs = 'DL';						//Project Code
        wbes.scope = 'DL';							//"B2C", "B2B/G" (Scope of the WBE Dimension)
        wbes.sap_pillar = 'DL';						//"D4P", "S4P" (SAP pillar where WBE are updated)
        wbes.company_code = 'DL';					//Prime 4 cifre della wbe
        wbes.product_line = 'DL';						//Seconde 4 cifre della wbe, campo del catalog item (SAP Organization)
        wbes.product_service_code = 'DL';				//Contains the WBE digit 13-15. It represents the field 'Codice Prodotti' requested in AFC
        wbes.cost_center_responsible = 'DL';	//Centro di costo, prime 10 cifre della WBE
        wbes.market = 'DL';								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.business_model_code = 'DL';							//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.order_number = 'DL';							//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.configuration_id = 'DL';							//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.configuration_item_id = 'DL';							//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.execution_project_id = 'DL';								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.client_identifier = 'DL';								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.customer_segment = 'DL';								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.legal_entity_geografy = 'DL';							//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.channel = 'DL';							//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.customer_relevance = 'DL';							//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.customer_size = 'DL';					//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.type_of_customer = 'DL';						//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.customer_geografy = 'DL';						//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.kit_logistic = 'DL';								//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.contract = 'DL';						//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.activity = 'DL';							//The 16° digit of the WBE. It represents the Business Model used in the WBE calculation
        wbes.wbe_first_level = 'DL';//First level of WBE, 12 char
        wbes.sfdc_id ='DL';			// tracking id
        wbes.wbe_second_level = 'DL';			//Second level of WBE, 6 char
        wbes.wbe_third_level = 'DL';				//Third level of WBE, 6 char
        wbes.type_of_sending = 'DL';			//"Service Creation", "Order Submit"
        wbes.status = 'DL';						//"New", "Not sent", "Sent", "Rejected", "Approved"
        wbes.sales_order = 'DL';		//
        wbes.odv_intercompany = 'DL';
        wbess.add(wbes);

        rqw.wbes = wbess;
		
        Test.setMock(HttpCalloutMock.class, new XC_REST_WBE_Outbound_Mock());
        Test.startTest();
        XC_REST_WBE_Inbound_U.ResponseWrapper rsw = new XC_REST_WBE_Inbound_U.ResponseWrapper();
        rsw = XC_REST_WBE_Outbound.callToPostWBE(rqw, 'S4P');
        XC_REST_WBE_Inbound_U.ResponseWrapper rswFake = new XC_REST_WBE_Inbound_U.ResponseWrapper();
        rswFake = XC_REST_WBE_Outbound.manageResponseFake();
		Test.stopTest();






    }
}