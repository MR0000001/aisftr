/**
 * The Class XC_REST_CreateOrder_W.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 06/05/2019
 * @date Modification : dd/mm/yyyy
 * @description       : UTIL for XC_REST_CreateOrder
 **/


public without sharing class XC_REST_CreateOrder_W {
    

    /**
     * The Class WrapperRequest.
     *
     * @description wrapper request of REST call
     */
    public class WrapperRequest {
        
        /** The existing Account Number. */
        public String existingAccountNumber;
        
        /** The new Account. */
        public WrapperAccount newAccount;

        /** The order Date. */
        public String orderDate;    // Y

        /** The order Number. */
        public String orderNumber;

        /** The processing Options. */
        public WrapperProcessingOptions processingOptions;

        /** The subscriptions. */
        public List<Wrappersubscription> subscriptions = new List<Wrappersubscription>();   // Y

    }
    

    /**
     * The Class WrapperAccount.
     *
     * @description wrapper account
     */
    public class WrapperAccount {

        /** The account Number. */
        public String accountNumber;

        /** The additional Email Addresses. */
        public String additionalEmailAddresses;

        /** The allow Invoice Edit. */
        public Boolean allowInvoiceEdit;

        /** The auto Pay. */
        public Boolean autoPay;

        /** The batch. */
        public String batch;

        /** The bill Cycle Day. */
        public Integer billCycleDay;

        /** The bill To Contact. */
        public WrapperContact billToContact;

        /** The communication Profile Id. */
        public String communicationProfileId;

        /** The credit Card. */
        public WrapperCreditCard creditCard;

        /** The credit Memo Template Id. */
        public String creditMemoTemplateId;

        /** The crm Id. */
        public String crmId;

        /** The currency. */
        public String currencyX;

        /** The customer Service Rep Name. */
        public String customerServiceRepName;

        /** The debit Memo Template Id. */
        public String debitMemoTemplateId;

        /** The hpm Credit Card Payment Method Id. */
        public String hpmCreditCardPaymentMethodId;

        /** The invoice Delivery Prefs Email. */
        public Boolean invoiceDeliveryPrefsEmail;

        /** The invoice Delivery Prefs Print. */
        public Boolean invoiceDeliveryPrefsPrint;

        /** The invoice Template Id. */
        public String invoiceTemplateId;

        /** The name. */
        public String name;

        /** The notes. */
        public String notes;

        /** The parent Id. */
        public String parentId;

        /** The payment Gateway. */
        public String paymentGateway;

        /** The payment Term. */
        public String paymentTerm;

        /** The purchase Order Number. */
        public String purchaseOrderNumber;

        /** The sales Rep. */
        public String salesRep;

        /** The sequence Set Id. */
        public String sequenceSetId;

        /** The sold To Contact. */
        public WrapperContact soldToContact;

        /** The taxInfo. */
        public WrapperTaxInfo taxInfo;
    }


    /**
     * The Class WrapperContact.
     *
     * @description wrapper contact
     */
    public class WrapperContact {

        /** The address1. */
        public String address1;

        /** The address2. */
        public String address2;

        /** The city. */
        public String city;

        /** The contact Description. */
        public String contactDescription;

        /** The country. */
        public String country;

        /** The county. */
        public String county;

        /** The fax. */
        public String fax;

        /** The first Name. */
        public String firstName;

        /** The home Phone. */
        public String homePhone;

        /** The last Name. */
        public String lastName;

        /** The mobile Phone. */
        public String mobilePhone;

        /** The nickname. */
        public String nickname;

        /** The other Phone. */
        public String otherPhone;

        /** The other Phone Type. */
        public String otherPhoneType;

        /** The personal Email. */
        public String personalEmail;

        /** The postal Code. */
        public String postalCode;

        /** The state. */
        public String state;

        /** The tax Region. */
        public String taxRegion;

        /** The work Email. */
        public String workEmail;

        /** The work Phone. */
        public String workPhone;
    }


    /**
     * The Class WrapperCreditCard.
     *
     * @description wrapper credit card
     */
    public class WrapperCreditCard {

        /** The cardHolderInfo. */
        public WrapperCardHolderInfo cardHolderInfo;

        /** The card Number. */
        public String cardNumber;

        /** The card Type. */
        public String cardType;

        /** The expiration Month. */
        public Integer expirationMonth;

        /** The expiration Year. */
        public Integer expirationYear;

        /** The security Code. */
        public String securityCode;
    }


    /**
     * The Class WrapperCardHolderInfo.
     *
     * @description wrapper card holder info
     */
    public class WrapperCardHolderInfo {

        /** The address Line1. */
        public String addressLine1;

        /** The address Line2. */
        public String addressLine2;

        /** The card Holder Name. */
        public String cardHolderName;

        /** The city. */
        public String city;

        /** The country. */
        public String country;

        /** The email. */
        public String email;

        /** The phone. */
        public String phone;

        /** The state. */
        public String state;

        /** The zipCode. */
        public String zipCode;
    }


    /**
     * The Class WrapperTaxInfo.
     *
     * @description wrapper tax info
     */
    public class WrapperTaxInfo {

        /** The VAT Id. */
        public String VATId;

        /** The company Code. */
        public String companyCode;

        /** The exempt Certificate Id. */
        public String exemptCertificateId;

        /** The exempt Certificate Type. */
        public String exemptCertificateType;

        /** The exempt Description. */
        public String exemptDescription;

        /** The exempt Effective Date. */
        public String exemptEffectiveDate;

        /** The exempt Expiration Date. */
        public String exemptExpirationDate;

        /** The exempt Issuing Jurisdiction. */
        public String exemptIssuingJurisdiction;

        /** The exempt Status. */
        public String exemptStatus;
    }


    /**
     * The Class WrapperProcessingOptions.
     *
     * @description wrapper processing options
     */
    public class WrapperProcessingOptions {

        /** The apply Credit Balance. */
        public Boolean applyCreditBalance;

        /** The billing Options. */
        public WrapperBillingOptions billingOptions;

        /** The collect Payment. */
        public Boolean collectPayment;

        /** The electronic Payment Options. */
        public WrapperElectronicPaymentOptions electronicPaymentOptions;

        /** The run Billing. */
        public Boolean runBilling;
    }


    /**
     * The Class WrapperBillingOptions.
     *
     * @description wrapper billing options
     */
    public class WrapperBillingOptions {

        /** The document Date. */
        public String documentDate;

        /** The target Date. */
        public String targetDate;
    }


    /**
     * The Class WrapperElectronicPaymentOptions.
     *
     * @description wrapper electronic payment options
     */
    public class WrapperElectronicPaymentOptions {

        /** The payment Method Id. */
        public String paymentMethodId;
    }


    /**
     * The Class Wrappersubscription.
     *
     * @description wrapper subscription
     */
    public class Wrappersubscription {

        /** The order Actions. */
        public List<WrapperOrderActions> orderActions = new List<WrapperOrderActions>();

        /** The subscription Number. */
        public String subscriptionNumber;

        /** The status. */
        public String status;
    }


    /**
     * The Class WrapperOrderActions.
     *
     * @description wrapper order actions
     */
    public class WrapperOrderActions {

        /** The owner Transfer. */
        public WrapperOwnerTransfer ownerTransfer;

        /** The type. */
        public String type;
    }


    /**
     * The Class WrapperOwnerTransfer.
     *
     * @description wrapper owner transfer
     */
    public class WrapperOwnerTransfer {

        /** The destination Account Number. */
        public String destinationAccountNumber;

        /** The destination Invoice Account Number. */
        public String destinationInvoiceAccountNumber;
    }


    /**
     * The Class WrapperResponse.
     *
     * @description wrapper response of REST call
     */
    public class WrapperResponse {
        
        /** The success. */
        public Boolean success;
        
        /** The order Number. */
        public String orderNumber;
        
        /** The account Number. */
        public String accountNumber;
        
        /** The status. */
        public String status;
        
        /** The subscriptions. */
        public List<Wrappersubscription> subscriptions;

        /** The invoiceNumbers. */
        public List<String> invoiceNumbers;

        /** The paymentNumber. */
        public String paymentNumber;

        /** The paidAmount. */
        public String paidAmount;
        
        /** The reasons. */
        public List<Reasons> reasons;
    }


    /**
     * The Class Reasons.
     *
     * @description wrapper reasons of REST call
     */
    public class Reasons {
        
        /** The code. */
        public Integer code;
        
        /** The message. */
        public String message;
    }
}