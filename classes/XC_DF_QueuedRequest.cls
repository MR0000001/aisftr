/**
 * @description       : 
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 11-04-2020
 * @last modified by  : Francesco Imperioli - fimperioli@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   07-13-2020   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
**/
@isTest
public  class XC_DF_QueuedRequest {

    public static List<XC_QueuedRequest__c> createQueuedRequest(Integer n){

        List<XC_QueuedRequest__c> result = new List<XC_QueuedRequest__c>();

        for(Integer i=0;i<n;i++){
            XC_QueuedRequest__c qr = new XC_QueuedRequest__c();
            qr.XC_IntegrationId__c = 'Test1234'+i;
            qr.XC_ClientSystem__c = 'CommodityItalyB2C';
            qr.XC_TransactionId__c = XC_UTIL_UUID.newGuid();
            qr.XC_RequestBody__c = JSON.serialize(generateRequestBody());
            result.add(qr);
        }

        return result;

    }

    public static List<XC_QueuedRequest__c> createQueuedRequestAccountOpportunity(Integer n){
        
        List<XC_QueuedRequest__c> result = new List<XC_QueuedRequest__c>();


        for(Integer i=0;i<n;i++){
            XC_QueuedRequest__c qr = new XC_QueuedRequest__c();
            qr.XC_IntegrationId__c = 'Test1234'+i;
            qr.XC_ClientSystem__c = 'CommodityItalyB2B';
            qr.XC_TransactionId__c = XC_UTIL_UUID.newGuid();
            qr.XC_RequestBody__c = JSON.serialize(generateRequestBodyAccountOpportunity());
            result.add(qr);
        }

        return result;
    }


    private static XC_UTIL_QueuedRequest_W.WrapperRequest generateRequestBody(){
        
        XC_UTIL_QueuedRequest_W.WrapperRequest req = new XC_UTIL_QueuedRequest_W.WrapperRequest();
        
        //POPULATE ACCOUNT SECTION
        req.Account = new XC_UTIL_Account.AccountIFWrapper();
        req.Account.AccountType = 'Residential';
        req.Account.UniqueID = 'd72face1-5088-4f16-9fd4-80a412a1ce6c';
        req.Account.FirstName = 'GIOVANNI';
        req.Account.LastName = 'MORI';
        req.Account.Name = 'MORI GIOVANNI';
        req.Account.MainPhonePrefix = '+39';
        req.Account.MainPhone = '3485812402';
        req.Account.PrimaryEmail = 'giovanni.mori@enel.com';
        req.Account.PhonePrefix = '+39';
        req.Account.Phone = '0683052323';


        // //ADDRESS SECTION
        // req.Address = new List<XC_UTIL_Address.AddressWrapper> ();
        // XC_UTIL_Address.AddressWrapper addrWr = new XC_UTIL_Address.AddressWrapper();
        // addrWr.StreetType = 'VIA';
        // addrWr.Address = 'ARDUINO FORA';
        // addrWr.StreetNumber = '1';
        // addrWr.ZipCode = '06062';
        // addrWr.City = 'CITTA DELLA PIEVE';
        // addrWr.Country = 'Italy';
        // addrWr.Stair = '';
        // addrWr.Floor = '';
        // addrWr.Province = 'PERUGIA';
        // addrWr.ShippingAddress = true;
        // addrWr.BillingAddress = true;
        // addrWr.InstallationAddress = false;
        // addrWr.AddressValidated = false;
        // addrWr.DeliveryAddress = false;
        // addrWr.Region = 'UMBRIA';
        // req.Address.add(addrWr);

        //IDENTITY SECTION
        req.Identity = new List<XC_UTIL_Account.IdentityIFWrapper>();
        XC_UTIL_Account.IdentityIFWrapper idWr = new XC_UTIL_Account.IdentityIFWrapper();
        idWr.Country = 'Italy';
        idWr.IdentityType = 'CF';
        idWr.IdentityNumber = 'MROGNN80E01C662L';
        req.Identity.add(idWr);

        //CONTACT SECTION
        req.Contact = new List<XC_UTIL_Account.ContactIFWrapper>();
        XC_UTIL_Account.ContactIFWrapper contactWr = new XC_UTIL_Account.ContactIFWrapper();
        contactWr.LastName = 'MORI';
        contactWr.FirstName = 'GIOVANNI';
        contactWr.PrimaryContact = true;
        contactWr.Email = 'giovanni.mori@enel.com';
        contactWr.MainPhonePrefix = '+39';
        contactWr.MainPhone = '3485812402';
        contactWr.PhonePrefix = '+39';
        contactWr.Phone = '0683052323';
        contactWr.ShippingContact = true;
        contactWr.BillingContact = true;
        //GDPR AND LE
        contactWr.GDPR = new XC_UTIL_Account.gdprWrapper();
        contactWr.GDPR.LegalEntity = new List<XC_UTIL_Account.LegalEntityWrapper>();
        XC_UTIL_Account.LegalEntityWrapper leWr = new XC_UTIL_Account.LegalEntityWrapper();
        contactWr.GDPR.GiveDataToThirdParties = 'N';
        leWr.LegalEntity = 'EnelXItalia';
        leWr.GiveDataToLegalEntity = 'Y';
        leWr.GiveDataForMarketing = 'N';
        leWr.GiveDataForProfiling = 'N';
        contactWr.GDPR.LegalEntity.add(leWr);
        req.Contact.add(contactWr);

        //ORDER SECTION
        req.Order = new XC_UTIL_Order.OrderIFWrapper();
        req.Order.OrderItem = new List<XC_UTIL_Order.OrderItemWrapper>();
        req.Order.Document = new List<XC_UTIL_Order.DocumentWrapper>();

        req.Order.LegalEntity = 'EnelXItalia';
        req.Order.Channel = 'EnelEnergiaItalia';
        req.Order.OrderType = 'New';
        req.Order.IntegrationID = '12378128381823';

        //DOCUMENT
        XC_UTIL_Order.DocumentWrapper dwr = new XC_UTIL_Order.DocumentWrapper();
        dwr.ContractUrl = 'https://test.salesforce.com';
        req.Order.Document.add(dwr);

        //ORDER ITEM 
        XC_UTIL_Order.OrderItemWrapper oiWr = new XC_UTIL_Order.OrderItemWrapper();
        req.Order.OrderItem.add(oiWr);
        oiWr.ProdID = 'ECMAN24';
        oiWr.Quantity = 1;
        oiWr.BaseOneTimeFee = 0.0;
        oiWr.BaseRecurringCharge = 6.0;
        oiWr.ContractType = 'Gas';

        oiWr.Attribute = new List<XC_UTIL_Order.WrapperAttribute>();
        XC_UTIL_Order.WrapperAttribute attrWr1 = new XC_UTIL_Order.WrapperAttribute();
        attrWr1.Name = 'Payment details:Payment Method';
        attrWr1.Value = 'Monthly';
        attrWr1.ProductFamilyPropertyID = 'a1V1l000000PNaMEAW';

        oiWr.Attribute.add(attrWr1);
        req.Order.OrderItem.add(oiWr);

        //BILLING PROFILE SECTION
        req.BillingProfile = new List<XC_UTIL_BillingProfile.BillingProfileIFWrapper>();
        XC_UTIL_BillingProfile.BillingProfileIFWrapper bpWr = new XC_UTIL_BillingProfile.BillingProfileIFWrapper();
        bpWr.LegalEntity = 'EnelXItalia';
        bpWr.PaymentMethod = 'Commodity Bill';
        bpWr.InvoicePreferredLanguage = 'Italian';
        bpWr.InvoiceDeliveryPref = 'Email';
        bpWr.CupsID = '00994599809123';
        bpWr.CommodityContractNum = '0039256378';
        bpWr.CommodityBP = '0039636921';
        bpWr.Email = 'giovanni.mori@enel.com';
        bpWr.RecipientCode = '0000000';
        req.BillingProfile.add(bpWr);        



        return req;
    }


    private static XC_UTIL_QueuedRequest_W.WrapperRequest generateRequestBodyAccountOpportunity(){
        
        XC_UTIL_QueuedRequest_W.WrapperRequest req = new XC_UTIL_QueuedRequest_W.WrapperRequest();
        
        //POPULATE ACCOUNT SECTION
        req.Account = new XC_UTIL_Account.AccountIFWrapper();
        req.Account.AccountType = 'Residential';
        req.Account.UniqueID = 'd72face1-5088-4f16-9fd4-80a412a1ce6c';
        req.Account.FirstName = 'GIOVANNI';
        req.Account.LastName = 'MORI';
        req.Account.Name = 'MORI GIOVANNI';
        req.Account.MainPhonePrefix = '+39';
        req.Account.MainPhone = '3485812402';
        req.Account.PrimaryEmail = 'giovanni.mori@enel.com';
        req.Account.PhonePrefix = '+39';
        req.Account.Phone = '0683052323';
        req.Account.AccountType = 'B2B';
        req.Account.Country = 'Italy';
        req.Account.Sector = 'Agriculture,forestryandfishing';
        req.Account.Subsector = 'Cropandanimalproduction,huntingandrelatedserviceactivities';
        req.Account.Theatre = 'Italy';

        req.Opportunity = new XC_UTIL_Opportunity.OpportunityIFWrapper();
        req.Opportunity.LeadID = 'ExternalId_abc0000DEFG';
        req.Opportunity.ProductCategoryOfInterest = 'CHP';
        req.Opportunity.OpportunityType = 'B2B Business Plan Italy';
        req.Opportunity.Status = 'Draft';
        req.Opportunity.ReceivingChannel = 'Web';
        req.Opportunity.LegalEntity = 'EnelXItalia';
        

        //IDENTITY SECTION
        req.Identity = new List<XC_UTIL_Account.IdentityIFWrapper>();
        XC_UTIL_Account.IdentityIFWrapper idWr = new XC_UTIL_Account.IdentityIFWrapper();
        idWr.Country = 'Italy';
        idWr.IdentityType = 'Codice Fiscale';
        idWr.IdentityNumber = 'MROGNN80E01C662L';
        req.Identity.add(idWr);
        
        //CONTACT SECTION
        req.Contact = new List<XC_UTIL_Account.ContactIFWrapper>();
        XC_UTIL_Account.ContactIFWrapper contactWr = new XC_UTIL_Account.ContactIFWrapper();
        contactWr.LastName = 'MORI';
        contactWr.FirstName = 'GIOVANNI';
        contactWr.PrimaryContact = true;
        contactWr.Email = 'giovanni.mori@enel.com';
        contactWr.MainPhonePrefix = '+39';
        contactWr.MainPhone = '3485812402';
        contactWr.PhonePrefix = '+39';
        contactWr.Phone = '0683052323';
        contactWr.ShippingContact = true;
        contactWr.BillingContact = true;
        //GDPR AND LE
        contactWr.GDPR = new XC_UTIL_Account.gdprWrapper();
        contactWr.GDPR.LegalEntity = new List<XC_UTIL_Account.LegalEntityWrapper>();
        XC_UTIL_Account.LegalEntityWrapper leWr = new XC_UTIL_Account.LegalEntityWrapper();
        contactWr.GDPR.GiveDataToThirdParties = 'N';
        leWr.LegalEntity = 'EnelXItalia';
        leWr.GiveDataToLegalEntity = 'Y';
        leWr.GiveDataForMarketing = 'N';
        leWr.GiveDataForProfiling = 'N';
        contactWr.GDPR.LegalEntity.add(leWr);
        req.Contact.add(contactWr);

        return req;


    }


}