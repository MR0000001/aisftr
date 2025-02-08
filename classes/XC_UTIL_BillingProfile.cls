/*****************************************************************************************************
* @author :             Nicola Mariniello nmariniello@deloitte.it
* @date Creation :      18/12/2018
* @date Modification :  dd/mm/yyyy
* @description :        XC_UTIL_BillingProfile – Util Class for Billing Profile
******************************************************************************************************/

public class XC_UTIL_BillingProfile {


    /*****************************************************************************************************
    * @author :             Nicola Mariniello nmariniello@deloitte.it
    * @date Creation :      18/12/2018
    * @date Modification :  dd/mm/yyyy
    * @description :        XC_UTIL_BillingProfile – Util Class for Billing Profile
    ******************************************************************************************************/
    public class BillingProfileIFWrapper {
        public String BillingProfileID {get;set;}
        public String BillingProfileName {get;set;}
        public String BillingMedia {get;set;}
        public String Payment {get;set;}
        public String CurrencyName {get;set;}
        public String CardType {get;set;}
        public String CardNumber {get;set;}
        public String ExpirationMonth {get;set;}
        public String ExpirationYear {get;set;}
        public String SecurityCode {get;set;}
        public String FirstName {get;set;} 
        public String LastName {get;set;}
        public String MailTo {get;set;}
        public String IBAN {get;set;}
        public String Description {get;set;}
        public String ZuoraMethodPaymentID {get;set;}
        public String PaymentMethod {get;set;}
        public String Token {get;set;}
        public String Address {get;set;}
        public String StreetType {get;set;}
        public String StreetNumber {get;set;}
        public String ZipCode {get;set;}
        public String City {get;set;}
        public String Province {get;set;}
        public String UserNumber {get;set;}
        public String CreditCardExternalKey {get;set;}
	    public String InvoicePreferredLanguage {get;set;}
        public String InvoiceDeliveryPref {get;set;}
        public String SoldAddressID {get;set;}
        public String BillingAddressID {get;set;}
        public String BillingContactID {get;set;}
        public String SoldContactID {get;set;}
        public String CreditCardType {get;set;}
        public String CreditCardLastFourNumber {get;set;}
        public String Email {get;set;}
        public String PhoneNumber {get;set;}
        public String PostalCode {get;set;}
        public String State {get;set;}
        public String Country {get;set;}
        public String LegalEntity {get;set;}
        public String CupsID {get;set;}
        public String CommodityContractNum {get;set;}  
        public String CreditCardHolder {get;set;}
        public String SEPAMandateID {get;set;}
        public String SEPAMandateDate {get;set;}
        public String SEPABIC {get;set;}
        public String SEPAMandateType {get;set;}
        public String Action; 
        public String EmployeeID;

        public String BillingAddressIndex;
        public String SoldAddressIndex;
        public String ActiveEmobAPPflag;

        public String CertifiedEmail;
        public String RecipientCode;
        public String CommodityBP;
        public String CommodityCC;

        public String CommodityBillingCycleFrequency;

        public String CommodityCupsID;

        public String PayPalUsername;

        public String SAPBusinessPartner;
        public String Status;
        public String Reason;
        public String ReasonDetails;
        public Date EventDate;
        public String CommodityUsage;
        public String ConsumptionNumber;
        //public String ProductID;
        //public String OrderID;
        public String OPDocumentNumber;
        public String OPDocumentType;
        public Boolean SkipDuplication;
        public Boolean CurrentActiveEmobApp;
        public List<BillingProfileLineItemIFWrapper> BillingProfileLineItem;
    }

    public class BillingProfileLineItemIFWrapper {

        public String BillToAddressText;
        public String SoldToAddressText;
        public String SoldToAddress;
        public String BilltoAddress;
        public String LegalEntity;
    }
}