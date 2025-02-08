/**
 * @description       : 
 * @author            : ebaenalabandera@deloitte.es
 * @group             : 
 * @last modified on  : 11-11-2021
 * @last modified by  : ebaenalabandera@deloitte.es
**/
public class XC_REST_Payment_Platform {
    private static final String CLASS_NAME = 'XC_REST_Payment_Platform';

    @AuraEnabled
    public static Map<String, String> checkIfIsPaymentPlatform( String recordId ) {
        Map<String, String> result = new Map<String, String>();
        Set<Id> orderItemIds = new Set<Id>();

        try {
            List<NE__OrderItem__c> orderItemList = new List<NE__OrderItem__c>();
            orderItemList = [SELECT Id, XC_PaymentMethodNeeded__c, XC_PaymentMethod__c FROM NE__OrderItem__c WHERE NE__OrderId__c = :recordId];
            if ( !orderItemList.isEmpty() ) {
                for ( NE__OrderItem__c oil : orderItemList ) {
                    if ( oil.XC_PaymentMethodNeeded__c ) {
                        //JDBM 24/11/2021 Inicio
                        if ( /*oil.XC_PaymentMethod__c == 'Credit Card'*/ oil.XC_PaymentMethod__c == 'Online') {
                            orderItemIds.add( oil.Id );
                        } else {
                            //result.put('message', 'The payment method must be "Credit Card".');
                            result.put('message', 'The payment method must be "Online".');
                        }
                        //JDBM 24/11/2021 Fin
                    } else {
                        result.put('message', 'Payment Method is Needed.');
                    }
                }

                System.debug('ebaena orderItemIds: ' + orderItemIds);
                if ( !orderItemIds.isEmpty() ) {
                    NE__OrderItem__c[] orderItems = [
                        SELECT Id, NE__OrderId__c, XC_BillingProfileLineItem__c, NE__Billing_Profile__c , XC_BillingModel__c, XC_PaymentMethodNeeded__c, XC_PaymentMethod__c,
                        NE__OrderId__r.CurrencyIsoCode, NE__OrderId__r.NE__One_Time_Fee_Total__c,
                        NE__OrderId__r.XC_LegalEntity__c, NE__OrderId__r.NE__Type__c, NE__OrderId__r.XC_Status__c, NE__OrderId__r.XC_Segment__c, NE__OrderId__r.Owner.Profile.Name
                        FROM NE__OrderItem__c 
                        WHERE Id IN :orderItemIds
                    ];
                    System.debug('ebaena orderItems: ' + orderItems);
                    if ( !orderItems.isEmpty() ) {
                        Id jobID = System.enqueueJob( new paymentPlatformHelper( orderItems ) );
                        result.put('message', 'Queue is launched.');
                    }
                }
            } else {
                result.put('message', 'Order Item List is empty.');
            }
        } catch( Exception e ) {
            System.debug('EXCEPTION error: ' + e);
        }
        return result;
    }

    /**
	* @description init the Payment Platform Request
	* @return the HttpRequest
	*/
	public static ResponseWrapper initPaymentPlatformRequest( NE__OrderItem__c orderItem ) {
         /*
        Map<String, String> paramsMap = new Map<String, String>();
        if(!Test.isRunningTest()){
            paramsMap.put('user_key', XC_paymentToken__c.getValues(UserInfo.getOrganizationId()).user_key__c);
        }
		*/
        
        //paramsMap.put('user_key', '7060ab7850ca1f9376ad0ac7475fa57d');
        ResponseWrapper res = new ResponseWrapper( '', '', '' );

        XC_UTIL_RESTCallout.CSWrapper wrapper = XC_UTIL_RESTCallout.checkActiveInterface2( Label.XC_CL_PaymentPlatformQuotasChile );
        if ( wrapper.activeInterface ) {
            //JJP 22-12-2021 - Start
            //String endpointUrl = XC_UTIL_RESTCallout.composeURL( wrapper.url, paramsMap );
            //Map<String,String> headerDefinitions = generateHeaderRequest();
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Read', 'PaymentMethodSIA', 'PaymentMethodSIA');
            headerDefinitions.put('X-Request-ID', '1');
            headerDefinitions.put('channel', 'CRMWEBAPP');
            headerDefinitions.put( 'billingSystem', 'ZUORA' );
            System.debug('ebaena initPaymentPlatformRequest headerDefinitions: ' + headerDefinitions);
            String body = generatePaymentPlatformBodyRequest( orderItem ).replace( '"currency_x":', '"currency":' );
            System.debug('ebaena initPaymentPlatformRequest body: ' + body);
            //HttpRequest request = XC_UTIL_RESTCallout.newRequest( 'POST', endpointUrl, headerDefinitions, body );
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', wrapper.url , headerDefinitions, body);
            request.setClientCertificateName('SIA_CERT');
            //JJP 22-12-2021 - End
            System.debug('ebaena initPaymentPlatformRequest request: ' + request);
            Http http = new Http();
            HttpResponse response = http.send( request );
            System.debug('ebaena initPaymentPlatformRequest real response: ' + response);
            System.debug('ebaena initPaymentPlatformRequest real response.getBody(): ' + response.getBody());
            res = ( ResponseWrapper ) JSON.deserialize( response.getBody(), ResponseWrapper.class );
            //System.debug('ebaena initPaymentPlatformRequest real res: ' + res);

            /*res.paymentStatus = 'TO_BE_PAID';
            res.redirectUrl = 'https://payhub-public-qa-enelxhub.tst-obp.sia.eu/channelpayment/sNFN9i0QlSeZSc8mOSNFSLqo8NBabR-ijyTrmOU-38dJV-ld';
            res.paymentCode = '20211026125032292141';*/
            System.debug('ebaena initPaymentPlatformRequest fake res: ' + res);

            if ( res.paymentStatus == 'TO_BE_PAID' ) {
                XC_BillingProfileLineItem__c billingProfileItem = [SELECT Id, XC_BillToContactId__c FROM XC_BillingProfileLineItem__c WHERE Id = :orderItem.XC_BillingProfileLineItem__c];
                Contact c = [SELECT Id, AccountId, Name, Email, XC_MainLegalEntity__c, XC_Preferredlanguageofcontact__c FROM Contact WHERE Id = :billingProfileItem.XC_BillToContactId__c];
                generateCustomerInteraction( orderItem, c, res );
            }
        }
        return res;
    }

    public static Map<String, String> generateHeaderRequest() {
        Map<String,String> headerDefinitions = new Map<String,String>();
        headerDefinitions.put( 'Content-Type', 'application/json' );
        headerDefinitions.put( 'X-Request-ID', '1' );
        headerDefinitions.put( 'billingSystem', 'ZUORA' );
        // headerDefinitions.put( 'cache-control', 'no-cache' );
        // headerDefinitions.put( 'channel', 'XSTORE_CL' );
        return headerDefinitions;
    }

    public static String generatePaymentPlatformBodyRequest( NE__OrderItem__c orderItem ) {
        String paymentMethod = orderItem.XC_BillingProfileLineItem__c + '|' + orderItem.NE__OrderId__c;
        
        AdditionalInfoWrapper additionalInfo = new AdditionalInfoWrapper();
        additionalInfo.paymentMethod = paymentMethod;

        RequestWrapper requestWr = new RequestWrapper(); 
        //JDBM 24/11/2021 Inicio
        requestWr.currency_x = 'CLP';
        //requestWr.currency_x = orderItem.NE__OrderId__r.CurrencyIsoCode;
        //JDBM 24/11/2021 Fin
        requestWr.type = orderItem.XC_BillingModel__c == 'One Shot' ? 'ONE_SHOT' : orderItem.XC_BillingModel__c;
        //JDBM 24/11/2021 Inicio
        //requestWr.debtorCode = '00000000000000100010';
        requestWr.debtorCode = '00000000000002200014';
        //JDBM 24/11/2021 Fin
        requestWr.additionalInfo = additionalInfo;
        requestWr.creditorCode = 'ENEL_X_CHILE';
        requestWr.gatewayCode = 'RDD_CL';
        requestWr.remittanceInformation = orderItem.NE__OrderId__c;
        requestWr.valueDate = System.today();
        requestWr.invoiceNumber = orderItem.NE__OrderId__c;
        requestWr.channelCode = 'CRMWEBAPP_CL';
        //JDBM 24/11/2021 Inicio
        //requestWr.amount = ( Decimal ) orderItem.NE__OrderId__r.NE__One_Time_Fee_Total__c;
        requestWr.amount = Integer.valueOf(orderItem.NE__OrderId__r.NE__One_Time_Fee_Total__c);
        //JDBM 24/11/2021 Fin
        return JSON.serialize( requestWr, true );
    }

    public static void generateCustomerInteraction( NE__OrderItem__c orderItem, Contact c, ResponseWrapper res ) {
        List<Map<String, Object>> listInteraction = new List<Map<String, Object>>();
        listInteraction.add( createValueMap( orderItem, c, res ) );
        System.debug( 'ebaena generateCustomerInteraction listInteraction: ' + JSON.serialize(listInteraction) );
        // XC_UTIL_CustomerInteractionGeneration.manageCustomerInteractionInsert( listInteraction );
        if ( !listInteraction.isEmpty() ) {
            List<XC_UTIL_Sobject.WrapperResult> results = XC_UTIL_CustomerInteractionGeneration.manageCustomerInteractionInsert(listInteraction);
            System.debug( 'ebaena generateCustomerInteraction results: ' + results );
            XC_UTIL_Sobject.WrapperResult globalDMLResult = XC_UTIL_Sobject.getGlobalDMLResults( results );
            System.debug( 'ebaena generateCustomerInteraction globalDMLResult: ' + globalDMLResult );
        }
    }

    private static Map<String,Object> createValueMap( NE__OrderItem__c orderItem, Contact c, ResponseWrapper res ) {
        Map<String,Object> interactionMap = new Map<String,Object>();
        interactionMap.put('sent', false);
        interactionMap.put('skipComunication', false);
        interactionMap.put('email', c.Email);
        interactionMap.put('segment', orderItem.NE__OrderId__r.XC_Segment__c);
        interactionMap.put('fullName', c.Name);
        interactionMap.put('contactId', c.Id);
        interactionMap.put('legalEntity', 'EnelX');
        // interactionMap.put('legalEntity', c.XC_MainLegalEntity__c);
        interactionMap.put('customerType', 'SIA_Redirect_URL');
        //interactionMap.put('customerType', 'XC_COL_B2C_SIARedirect_EN');
        //interactionMap.put('customerType', 'XC_COL_B2C_SIARedirect_ES');
        //interactionMap.put('customerType', 'XC_CHL_B2C_SIARedirect');
        //interactionMap.put('customerType', 'XC_CHL_B2C_SIARedirect_ES');
        //interactionMap.put('customerType', 'XC_CHL_B2C_QuoteAccepted_ES');
        //interactionMap.put('customerType', 'Survey_Call_Center');
        interactionMap.put('docURL', res.redirectUrl);
        interactionMap.put('accountId', c.AccountId);
        interactionMap.put('preferredlanguage', c.XC_Preferredlanguageofcontact__c);
        interactionMap.put('orderId', orderItem.NE__OrderId__c);
        return interactionMap;
    }

    public class paymentPlatformHelper implements Queueable, Database.AllowsCallouts {
        List<NE__OrderItem__c> oiList;
        
        public paymentPlatformHelper( List<NE__OrderItem__c> oiList ) {
            this.oiList = oiList;
        }

        public void execute( QueueableContext context ) {
            // The first record is retrieved.
            NE__OrderItem__c oil = oiList.remove(0);
        
            // The record is sent to the Payment Platform Request.
            initPaymentPlatformRequest( oil );

            // In case of running as a TEST, queueables are not queued and errors are prevented. The queueable is launched if there are records to be processed.
            if ( !Test.isRunningTest() && oil != null && oiList.size() > 0 ) {
                Id jobID = System.enqueueJob( new paymentPlatformHelper( oiList ) );
            }
        }
    }

    /**
     * @description The Class Request Wrapper.
     */
    public class RequestWrapper {
        public String currency_x;
        public String type;
        public String debtorCode;
        public String creditorCode;
        public String gatewayCode;
        public String remittanceInformation;
        public Date valueDate;
        public String invoiceNumber;
        public String channelCode;
        public Decimal amount;

        public AdditionalInfoWrapper additionalInfo;
    }

    /**
     * @description The Class Response Wrapper.
     */
    public class AdditionalInfoWrapper {
        public String paymentMethod;
    }

    // /**
    //  * @description The Class Response Wrapper.
    //  */
    // public class ResponseWrapper {
    //     public String paymentStatus;
    //     public String redirectUrl;
    //     public String paymentCode;
    // }

    /**
     * @description The Class Response Wrapper.
     */
    public class ResponseWrapper {
        @AuraEnabled public String paymentStatus    { get; set; }
        @AuraEnabled public String redirectUrl      { get; set; }
        @AuraEnabled public String paymentCode      { get; set; }
        
        public ResponseWrapper( String paymentStatus, String redirectUrl, String paymentCode ) {
            this.paymentStatus = paymentStatus;
            this.redirectUrl = redirectUrl;
            this.paymentCode = paymentCode;
        }
    }

}