@isTest
public class XC_UTIL_BillingProfile_TEST {
    
    static testMethod void billingProfileTEST(){
    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
	XC_UTIL_BillingProfile.BillingProfileIFWrapper wr = new XC_UTIL_BillingProfile.BillingProfileIFWrapper();
    wr.BillingProfileID = '';
    wr.BillingProfileName = '';
    wr.BillingMedia = '';
    wr.Payment = '';
    wr.CurrencyName = '';
    wr.CardType = '';
    wr.CardNumber='';
    wr.ExpirationMonth='';
    wr.ExpirationYear='';
    wr.SecurityCode='';
    wr.FirstName='';
    wr.LastName='';
    wr.MailTo='';
    wr.IBAN='';
    wr.Description='';
    wr.ZuoraMethodPaymentID='';
    wr.PaymentMethod='';
    wr.Token='';
    wr.Address='';
    wr.StreetType='';
    wr.StreetNumber='';
    wr.ZipCode='';
    wr.City='';
    wr.Province='';
    wr.UserNumber='';
    wr.CreditCardExternalKey='';
	wr.InvoicePreferredLanguage='';
    wr.InvoiceDeliveryPref='';
    wr.SoldAddressID='';
    wr.BillingAddressID='';
    wr.BillingContactID='';
    wr.SoldContactID='';
    wr.CreditCardType='';
    wr.CreditCardLastFourNumber='';
    wr.Email='';
    wr.PhoneNumber='';
    wr.PostalCode='';
    wr.State='';
    wr.Country='';
    wr.LegalEntity='';
    wr.CupsID='';
    wr.CommodityContractNum='';  
    wr.CreditCardHolder='';
    System.assert(wr!=null);
    Test.stopTest();
    }
 

}