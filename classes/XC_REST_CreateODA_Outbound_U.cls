/**
* @author Andrea Di Cicco
* @date Creation 10/09/2020
* @description REST INTERFACE : 
*/
public class XC_REST_CreateODA_Outbound_U {
    /**
     * @description wrapper class for request 
     */
    public class RequestWrapper {
        public ODAWrapper purchase_order;
    }

    /**
     * @description wrapper class for response
     */
    public class ResponseWrapper {
        public XC_UTIL_Integration.ResultSnakeCase result;
        
        /**
        * @description constructor
        */
        public ResponseWrapper(){ 
            this.result = new XC_UTIL_Integration.ResultSnakeCase();
        }
    }
    /**
     * @description wrapper class for request 
     */
    public class ODAWrapper {
        public String sfdc_id;
        public String source_system;
        public String target_system;
        public String purchase_order_type;
        public String partner_sap_id;
        public Date purchase_order_date;
        public String purchasing_org ;
        public String purchasing_group;
        public String company;
        public String payment_condition;
        public String po_currency;
        public String contract_supervisor;
        public String cessionary;
        public Date transfer_date;
        public String tender_category;
        public String short_subject;
        public String cig;
        public String cup;
        public String solidal_resp;
        public String contract_number;
        public String supplier_code_io;
        public String supplier_code_ef;
        public List<ItemsWrapper> items = new List<ItemsWrapper>();
    }

    public class ItemsWrapper{
        public Integer sap_pos_po;
        public String sap_pos_category;
        public String accounting_category;
        public String material_code;
        public String short_description;
        public Decimal qty;
        public String unit_of_measure;
        public String net_price;
        public String price_unit;
        public String division;
        public String goods_group;
        public String applicant_unit;
        public String communication_language;
        public String iva_code;
        public String contract_number;
        public Integer contract_pos_number;
        public String cost_center;
        public String wbs_element;
        public List<ItemsServiceWrapper> items_services = new List<ItemsServiceWrapper>();
    }

    public class ItemsServiceWrapper{
        public Integer sap_pos_po;
        public Integer sap_row_number;
        public String sap_service_code;
        public String short_description;

        public Decimal qty;

        public String unit_of_measure;
        public String gross_price;
        public String sap_currency;
        public Decimal price_unit;
        public String cost_center;
        public String wbs_element;
        
    }

    /**
     * @description wrapper class for po_results
     */
    public class PoResultsWrapper {
        public String class_message;
        public Integer message_number;
        public String message;
        public String error_code;
    }
}