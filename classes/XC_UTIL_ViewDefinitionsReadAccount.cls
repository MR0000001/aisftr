/**
 * @author Monica Cutillo - monica.cutillo@nttdata.it
 * @date Creation 11/06/2019
 * @date Modification dd/mm/yyyy
 * @description XC_UTIL_ViewDefinitionsReadAccount – UTIL to define how view Read Account data
 */
public class XC_UTIL_ViewDefinitionsReadAccount {
	
    /**
     * @description AccountViewDefinition wrapper
     */
    public class ReadAccountViewDefinition{
        public List<String> keySet;
        public Map<String,String> labels;
        //the default type is input text > it's used types map only to use different types > MC 25/04/2020
        public Map<String,String> types;
    }

    /**
     * @description getAccountSectionDefinition
     * @return ReadAccountViewDefinition wrapper for Account section
     */
    public static Map<String,ReadAccountViewDefinition> getReadAccountViewDefinitions(){
        Map<String,ReadAccountViewDefinition> result = new Map<String,ReadAccountViewDefinition>
        {
            'Account'        => getAccountSectionDefinition(),
            'Contact'        => getContactSectionDefinition(),
            'LegalEntity'    => getLESectionDefinition(),
            'BillingProfile' => getBillingProfileSectionDefinition(),
            'Address'        => getAddressSectionDefinition(),
            'PointOfService' => getPosSectionDefinition()
        };
        return result;
    }

    /**
     * @description getBillingProfileSectionDefinition
     * @return ReadAccountViewDefinition wrapper for BillingProfile section
     */
    private static ReadAccountViewDefinition getBillingProfileSectionDefinition(){
        ReadAccountViewDefinition vDef = new ReadAccountViewDefinition();
        vDef.labels = getBillingProfileLabels();
        List<String> keySet = new List<String>();
        keySet.add('PaymentMethod');
        keySet.add('CommodityContractNum');
        keySet.add('IBAN');
        //keySet.add('Country');
        /*keySet.add('BillingProfileName');
        keySet.add('PaymentMethod');
        keySet.add('InvoicePreferredLanguage');
        keySet.add('InvoiceDeliveryPref');
        keySet.add('IBAN');
        keySet.add('CupsID');
        keySet.add('CommodityContractNum');
        keySet.add('Token');
        keySet.add('CreditCardExternalKey');
        keySet.add('CreditCardType');
        keySet.add('ExpirationMonth');
        keySet.add('ExpirationYear');
        keySet.add('CreditCardLastFourNumber');
        keySet.add('UserNumber');
        keySet.add('Email');
        keySet.add('PhoneNumber');
        keySet.add('PostalCode');
        keySet.add('City');
        keySet.add('State');
        keySet.add('Country');*/
        vDef.keySet = keySet;
        return vDef;
    }

    /**
     * @description Gets the commodity labels.
     * @return the commodity labels
     */
    private static Map<String,String> getBillingProfileLabels(){
        Map<String,String> billingProfLabels = new Map<String,String>();
        billingProfLabels.put('PaymentMethod'               ,Label.XC_CL_360PaymentMethod);
        billingProfLabels.put('IBAN'                        ,Label.XC_CL_360IBAN);
        billingProfLabels.put('CommodityContractNum'        ,Label.XC_CL_360CommodityContractNum);
        return billingProfLabels;
    }

    /**
     * @description getAccountSectionDefinition
     * @return ReadAccountViewDefinition wrapper for Account section
     */
    private static ReadAccountViewDefinition getAccountSectionDefinition(){
        ReadAccountViewDefinition accDef = new ReadAccountViewDefinition();
        accDef.labels = getAccountLabels();
        List<String> accKeySet = new List<String>();
        accKeySet.add('AccountType');
        accKeySet.add('Status');
        accKeySet.add('FirstName');
        accKeySet.add('LastName');
        accKeySet.add('MainPhonePrefix');
        accKeySet.add('MainPhone');
        accKeySet.add('PhonePrefix');
        accKeySet.add('Phone');
        accKeySet.add('PrimaryEmail');
        accKeySet.add('CertifiedEmail');
        accKeySet.add('Country');
        accKeySet.add('PreferenceLanguage');
        accdef.keySet = accKeySet;
        return accDef;
    }

    /**
     * @description getContactSectionDefinition
     * @return ReadAccountViewDefinition wrapper for Contact section
     */
    private static ReadAccountViewDefinition getContactSectionDefinition(){
        ReadAccountViewDefinition contDef = new ReadAccountViewDefinition();
        contDef.labels = getContactLabels();
        List<String> contKeySet = new List<String>();
        //contKeySet.add('Salutation');
        contKeySet.add('FirstName');
        contKeySet.add('LastName');
        contKeySet.add('IdentityType');
        contKeySet.add('IdentityNumber');
        contKeySet.add('PhonePrefix');
        contKeySet.add('Phone');
        contKeySet.add('MainPhonePrefix');
        contKeySet.add('MainPhone');
        contKeySet.add('Email');
        contKeySet.add('ContactPreferredTime');
        //contKeySet.add('GiveDataToThirdParties');
        contDef.keySet = contKeySet;
        return contDef;
    }

    /**
     * @description getLESectionDefinition
     * @return ReadAccountViewDefinition wrapper for Legal Entity section
     */
    private static ReadAccountViewDefinition getLESectionDefinition(){
        ReadAccountViewDefinition leDef = new ReadAccountViewDefinition();
        leDef.labels = getLELabels();
        List<String> leKeySet = new List<String>();
        leKeySet.add('LegalEntity');
        leKeySet.add('GiveDataToThirdParties');
        leKeySet.add('GiveDataToLegalEntity');
        leKeySet.add('GiveDataForMarketing');
        leKeySet.add('GiveDataForProfiling');
        leDef.keySet = leKeySet;
        return leDef;
    }

    /**
     * @description getAddressSectionDefinition
     * @return ReadAccountViewDefinition wrapper for Address section
     */
    private static ReadAccountViewDefinition getAddressSectionDefinition(){
        ReadAccountViewDefinition vDef = new ReadAccountViewDefinition();
        vDef.labels = getAddressLabels();
        List<String> keySet = new List<String>();
        keySet.add('Country');       
        keySet.add('Category');
        keySet.add('City');            

        keySet.add('Province');
        keySet.add('StreetType');      
        keySet.add('Address');        
        keySet.add('StreetNumber');    
        keySet.add('ZipCode');         
        keySet.add('Floor');
        keySet.add('MunicipalName');           
        keySet.add('Stair');           
        keySet.add('Door');    
        keySet.add('ClarifierType');    
        keySet.add('ClarifierValue');    
        

        /*keySet.add('InstallationAddress');
        keySet.add('ShippingAddress');
        keySet.add('BillingAddress');*/
        vDef.keySet = keySet;
        return vDef;
    }

    /**
     * @description getPosSectionDefinition
     * @return ReadAccountViewDefinition wrapper for POS section
     */
    private static ReadAccountViewDefinition getPosSectionDefinition(){
        ReadAccountViewDefinition vDef = new ReadAccountViewDefinition();
        vDef.labels = getPosLabels();
        List<String> keySet = new List<String>();
        //keySet.add('POSID');
        keySet.add('POSType');
        keySet.add('POS');
        vDef.keySet = keySet;
        return vDef;
    }

    /**
     * @description Gets the commodity labels.
     * @return the commodity labels
     */
    private static Map<String,String> getPosLabels(){
        Map<String,String> posLabels = new Map<String,String>();
        posLabels.put('POSID'               ,Label.XC_CL_360POSID);
        posLabels.put('POSType'             ,Label.XC_CL_360POSType);
        posLabels.put('POS'                 ,Label.XC_CL_360POS);
        return posLabels;
    }

    /**
     * @description Gets the commodity labels.
     * @return the commodity labels
     */
    private static Map<String,String> getAddressLabels(){
        Map<String,String> addressLabels = new Map<String,String>();
        addressLabels.put('Country'             ,Label.XC_CL_360Country          ); 
        addressLabels.put('Category', Label.XC_CL_360Category);
        addressLabels.put('City'                ,Label.XC_CL_360City             ); 
        addressLabels.put('StreetType'          ,Label.XC_CL_360StreetType       ); 
        addressLabels.put('Address'             ,Label.XC_CL_360Address          ); 
        addressLabels.put('StreetNumber'        ,Label.XC_CL_360StreetNumber     ); 
        addressLabels.put('Floor'               ,Label.XC_CL_360Floor            ); 
        addressLabels.put('Stair'               ,Label.XC_CL_360Stair            ); 
        addressLabels.put('Door'                ,Label.XC_CL_360Door             ); 
        addressLabels.put('ZipCode'             ,Label.XC_CL_360ZipCode          ); 
        addressLabels.put('Province'            ,Label.XC_CL_360Province         ); 
        addressLabels.put('MunicipalName'    ,  Label.XC_CL_360MunicipalName); 
        addressLabels.put('ClarifierType', Label.XC_CL_360ClarificatorType);    //ClarificatorType
        addressLabels.put('ClarifierValue', Label.XC_CL_360ClarificatorValue);  //ClarificatorValue
        return addressLabels;
    }

    /**
     * @description Gets the commodity labels.
     * @return the commodity labels
     */
    private static Map<String,String> getContactLabels(){
        Map<String,String> contactLabels = new Map<String,String>();
            contactLabels.put('LastName',Label.XC_CL_360LastName);
            contactLabels.put('FirstName',Label.XC_CL_360FirstName);
        //contactLabels.put('Salutation','Salutation');
        //contactLabels.put('PrimaryContact','Primary Contact');
            contactLabels.put('Email',Label.XC_CL_360PrimaryEmail);
        contactLabels.put('PhonePrefix', Label.XC_CL_360MainPhonePrefix);
        contactLabels.put('Phone', Label.XC_CL_360MainPhone);
        contactLabels.put('MainPhonePrefix', Label.XC_CL_360PhonePrefix);
        contactLabels.put('MainPhone', Label.XC_CL_360Phone);
            contactLabels.put('IdentityType',Label.XC_CL_360IdentityType);
            contactLabels.put('IdentityNumber',Label.XC_CL_360IdentityNumber);
        //contactLabels.put('ReleaseDate','Release Date');
        //contactLabels.put('ExpiryDate','Expiry Date');
        //contactLabels.put('PrimaryEmail','Primary Email');
            contactLabels.put('PreferenceLanguage',Label.XC_CL_360PreferenceLanguage);
        //contactLabels.put('Role', 'Role');
        //contactLabels.put('ContactPreferredTime', Label.XC_CL_360ContactPreferredTime);
        //contactLabels.put('Birthdate', 'Birthdate');
        //contactLabels.put('GiveDataToThirdParties', 'Give Data To Third Parties');
        /*contactLabels.put('RobinsonContact','Robinson Contact');
        contactLabels.put('ConsentLegalEntity','Consent Legal Entity');
        contactLabels.put('ConsentCampaign','Consent Campaign');
        contactLabels.put('ConsentGroup','Consent Group');*/
        return contactLabels;
    }

    /**
     * @description Gets the commodity labels.
     * @return the commodity labels
     */
    private static Map<String,String> getLELabels(){
        Map<String,String> leLabels = new Map<String,String>();
        leLabels.put('LegalEntity',Label.XC_CL_360LegalEntity);
        leLabels.put('GiveDataToThirdParties',Label.XC_CL_360GiveDataToThirdParties);
        leLabels.put('GiveDataToLegalEntity', Label.XC_CL_360GiveDataToLegalEntity);
        leLabels.put('GiveDataForMarketing', Label.XC_CL_360GiveDataForMarketing);
        leLabels.put('GiveDataForProfiling', Label.XC_CL_360GiveDataForProfiling);

        return leLabels;

    }

    /**
     * @description Gets the commodity labels.
     * @return the commodity labels
     */
    private static Map<String,String> getAccountLabels(){
        Map<String,String> accountLabels = new Map<String,String>();
        accountLabels.put('AccountType',Label.XC_CL_360AccountType);
        accountLabels.put('LastName', Label.XC_CL_360LastName);
        accountLabels.put('FirstName', Label.XC_CL_360FirstName);
        accountLabels.put('Status',Label.XC_CL_360Status);
        //accountLabels.put('IdentityType', 'Identity Type');
        //accountLabels.put('IdentityNumber', 'Identity Number');
        accountLabels.put('MainPhonePrefix', Label.XC_CL_360MainPhonePrefix);
        accountLabels.put('MainPhone', Label.XC_CL_360MainPhone);
        accountLabels.put('PhonePrefix', Label.XC_CL_360PhonePrefix);
        accountLabels.put('Phone', Label.XC_CL_360Phone);
        accountLabels.put('PrimaryEmail', Label.XC_CL_360PrimaryEmail);
        accountLabels.put('Country', Label.XC_CL_360Country);
        //accountLabels.put('Birthdate', 'Birthdate');
        accountLabels.put('PreferenceLanguage', Label.XC_CL_360PreferenceLanguage);
        //accountLabels.put('Notes', 'Notes');
        accountLabels.put('CertifiedEmail', Label.XC_CL_360CertifiedEmail);
        //accountLabels.put('MobilityOrderID', 'Mobility Order ID');
        //accountLabels.put('PartnerID', 'Partner ID');
        //accountLabels.put('DataLakeScoring', 'Data Lake Scoring');
        //accountLabels.put('BlackList', 'Black List');
        //accountLabels.put('DestinationCode', 'Destination Code');
        //accountLabels.put('RegisteredOnRechargeApp', 'Registered On Recharge App');
        //accountLabels.put('CostCenter', 'Cost Center');
        //accountLabels.put('ContactMethod', 'Contact Method');
        //accountLabels.put('VulnerableCustomer', 'Vulnerable Customer');
        //accountLabels.put('ValueSegment', 'Value Segment');
        //accountLabels.put('QualityIndex', 'Quality Index');
        return accountLabels;
    }

    /**
     * @description getCommodityViewDefinitions
     * @return ReadAccountViewDefinition wrapper map
     */
    public static Map<String,ReadAccountViewDefinition> getCommodityViewDefinitions(){
        Map<String,ReadAccountViewDefinition> result = new Map<String,ReadAccountViewDefinition>
        {
            'Contract' => getContractSectionDefinition(),
            'Case'     => getCaseSectionDefinition(),
            'Invoice'  => getInvoiceSectionDefinition()
        };
        return result;
    }

    /**
     * @description getContractSectionDefinition
     * @return getContractViewDefinition wrapper for Contract section
     */
    private static ReadAccountViewDefinition getContractSectionDefinition(){
        ReadAccountViewDefinition contrDef = new ReadAccountViewDefinition();
        contrDef.labels = getContractLabels();
        List<String> contrKeySet = new List<String>();
        contrKeySet.add('ContractNumber');
        contrKeySet.add('Status');
        contrKeySet.add('ContractStartDate');
        contrKeySet.add('NameContractedService');
        contrKeySet.add('AddressID');
        contrKeySet.add('OwnerCompany');

        contrKeySet.add('ContractType');
        contrKeySet.add('ContractTerm');
        contrKeySet.add('TypeOfSocialBonus');
        contrKeySet.add('SocialBonus');
        contrKeySet.add('ContractedPower');
        contrKeySet.add('Tariff');
        contrKeySet.add('CIEAuthorizedMaximumPower');
        contrKeySet.add('CNAE');
        contrKeySet.add('MaximumPowerPOD');
        contrKeySet.add('MinimumElectricalConsumption');
        contrKeySet.add('TensionType');
        contrKeySet.add('CIEExpirationRules');
        contrKeySet.add('AddressData');
        contrDef.keySet = contrKeySet;

        contrDef.types = new Map<String,String>();
        contrDef.types.put('AddressData', 'inputTextArea');

        return contrDef;
    }

    /**
     * @description getContractSectionDefinition
     * @return getContractViewDefinition wrapper for Contract section
     */
    private static ReadAccountViewDefinition getCaseSectionDefinition(){
        ReadAccountViewDefinition caseDef = new ReadAccountViewDefinition();
        caseDef.labels = getCaseLabels();
        List<String> keySet = new List<String>();
        keySet.add('CaseReason');
        keySet.add('Status');
        keySet.add('CaseSubCause');
        keySet.add('Priority');
        keySet.add('CaseSubType');
        keySet.add('CreatedDate');

        keySet.add('ProductCategory');
        keySet.add('CaseResult');
        keySet.add('Channel');
        keySet.add('Country');
        keySet.add('ClosedDate');
        keySet.add('ContactPhone');
        keySet.add('NotificationEmail');
        keySet.add('Description');
        //keySet.add('CounterOfInsistences');
        keySet.add('TypeOfIntermediary');
        keySet.add('PresentationMedium');
        keySet.add('LastCaseComment');
        keySet.add('AddressID');
        caseDef.keySet = keySet;

        caseDef.types = new Map<String,String>();
        caseDef.types.put('Description', 'inputTextArea');
        caseDef.types.put('AddressID', 'inputTextArea');

        return caseDef;
    }

    /**
     * @description Gets the commodity labels.
     * @return the commodity labels
     */
    private static Map<String,String> getCaseLabels(){
        Map<String,String> labels = new Map<String,String>();
        labels.put('ProductCategory'      , Label.XC_CL_360ProductCategory	);
        labels.put('Status'               , Label.XC_CL_360Status);
        labels.put('CaseReason'           ,Label.XC_CL_360CaseReason);
        labels.put('CaseSubCause'         ,Label.XC_CL_360CaseSubCause);
        labels.put('CaseSubType'          , Label.XC_CL_360CaseSubType	);
        labels.put('CaseResult'           , Label.XC_CL_360CaseResult);
        labels.put('Channel'              , Label.XC_CL_360Channel );
        labels.put('Country'              , Label.XC_CL_360Country );
        labels.put('Priority'             , Label.XC_CL_360Priority );
        labels.put('CreatedDate'          , Label.XC_CL_360CreatedDate );
        labels.put('ClosedDate'           , Label.XC_CL_360ClosedDate );
        labels.put('ContactPhone'         , Label.XC_CL_360ContactPhone );
        labels.put('NotificationEmail'    , Label.XC_CL_360NotificationEmail );
        labels.put('Description'          , Label.XC_CL_360Description );
        //labels.put('CounterOfInsistences' , Label.XC_CL_360CounterOfInsistences );
        labels.put('TypeOfIntermediary'   , Label.XC_CL_360TypeOfIntermediary );
        labels.put('PresentationMedium'   , Label.XC_CL_360PresentationMedium );
        labels.put('LastCaseComment'      , Label.XC_CL_360LastCaseComment );
        labels.put('AddressID'            , Label.Address);
        return labels;
    }

    /**
     * @description getContractSectionDefinition
     * @return getContractViewDefinition wrapper for Contract section
     */
    private static ReadAccountViewDefinition getInvoiceSectionDefinition(){
        ReadAccountViewDefinition caseDef = new ReadAccountViewDefinition();
        caseDef.labels = getInvoiceLabels();
        List<String> keySet = new List<String>();
        keySet.add('InvoiceNumber');
        keySet.add('InvoiceStatus');
        keySet.add('ContractNumber');
        keySet.add('Amount');
        keySet.add('DateFrom');
        keySet.add('DateTo');
        /*keySet.add('BusinessLine');
        keySet.add('ContractID');
        keySet.add('ClientID');
        keySet.add('IssueDate');
        keySet.add('ObligationPaid');
        keySet.add('InvoiceSequential');
        keySet.add('CompanyCode');
        keySet.add('InvoiceReference');
        keySet.add('ContractSequential');
        keySet.add('ObligationSequential');
        keySet.add('FractionationIndicator');
        keySet.add('FractionalObligation');
        keySet.add('BroadcasterML');
        keySet.add('PaymentDateParentObligation');
        keySet.add('PaymentBrand');
        keySet.add('AuthorizedRegistrationDate');
        keySet.add('WithdrawalAuthorizedDate');
        keySet.add('TermEndDate');
        keySet.add('Address');*/
        caseDef.keySet = keySet;
        return caseDef;
    }

    /**
     * @description Gets the commodity labels.
     * @return the commodity labels
     */
    private static Map<String,String> getInvoiceLabels(){
        Map<String,String> labels = new Map<String,String>();
        labels.put('BusinessLine', Label.XC_CL_BusinessLine);
        labels.put('ContractNumber', Label.XC_CL_ContractNumber);
        labels.put('ContractID', Label.XC_CL_ContractID);
        labels.put('ClientID', Label.XC_CL_ClientID);
        labels.put('InvoiceNumber', Label.XC_CL_InvoiceNumber);
        labels.put('IssueDate', Label.XC_CL_IssueDate);
        labels.put('Amount',Label.XC_CL_Amount);
        labels.put('InvoiceStatus', Label.XC_CL_InvoiceStatus);
        labels.put('ObligationPaid', Label.XC_CL_ObligationPaid);
        labels.put('InvoiceSequential', Label.XC_CL_InvoiceSequential);
        labels.put('CompanyCode', Label.XC_CL_CompanyCode);
        labels.put('InvoiceReference', Label.XC_CL_InvoiceReference);
        labels.put('ContractSequential', Label.XC_CL_ContractSequential);
        labels.put('ObligationSequential', Label.XC_CL_ObligationSequential);
        labels.put('FractionationIndicator', Label.XC_CL_FractionationIndicator);
        labels.put('FractionalObligation', Label.XC_CL_FractionalObligation);
        labels.put('BroadcasterML', Label.XC_CL_BroadcasterML);
        labels.put('PaymentDateParentObligation', Label.XC_CL_PaymentDateParentObligation);
        labels.put('PaymentBrand', Label.XC_CL_PaymentBrand);
        labels.put('AuthorizedRegistrationDate', Label.XC_CL_AuthorizedRegistrationDate);
        labels.put('WithdrawalAuthorizedDate', Label.XC_CL_WithdrawalAuthorizedDate);
        labels.put('DateFrom', Label.XC_CL_DateFrom);
        labels.put('DateTo', Label.XC_CL_DateTo);
        labels.put('TermEndDate', Label.XC_CL_TermEndDate);
        labels.put('Address', Label.XC_CL_Address);
        return labels;
    }

    /**
     * @description Gets the commodity labels.
     * @return the commodity labels
     */
    private static Map<String,String> getContractLabels(){
        Map<String,String> contractLabels = new Map<String,String>();
        contractLabels.put('ContractNumber'                 , Label.XC_CL_360ContractNumber                 );        
        contractLabels.put('Status'                         , Label.XC_CL_360Status                         );
        contractLabels.put('ContractType'                   , Label.XC_CL_360ContractType                   );
        contractLabels.put('ContractStartDate'                      , Label.XC_CL_360ContractStartDate              );
        contractLabels.put('ContractTerm'                   , Label.XC_CL_360ContractTerm                   );
        contractLabels.put('NameContractedService'          , Label.XC_CL_360NameContractedService          );
        //contractLabels.put('AddressID'                      , Label.XC_CL_360Address                     );
        contractLabels.put('TypeOfSocialBonus'              , Label.XC_CL_360TypeOfSocialBonus              );
        contractLabels.put('SocialBonus'                    , Label.XC_CL_360SocialBonus                    );
        contractLabels.put('ContractedPower'                , Label.XC_CL_360ContractedPower                );
        contractLabels.put('Tariff'                         , Label.XC_CL_360Tariff                         );
        contractLabels.put('CIEAuthorizedMaximumPower'      , Label.XC_CL_360CIEAuthorizedMaximumPower      );
        contractLabels.put('MinimumElectricalConsumption'   , Label.XC_CL_360MinimumElectricalConsumption   );
        contractLabels.put('OwnerCompany'                   , Label.XC_CL_360OwnerCompany                   );
        contractLabels.put('MaximumPowerPOD'                , Label.XC_CL_360MaximumPowerPOD                );
        contractLabels.put('CNAE'                           , Label.XC_CL_360CNAE                           );
        contractLabels.put('TensionType'                    , Label.XC_CL_360TensionType                    );
        contractLabels.put('CIEExpirationRules'             , Label.XC_CL_360CIEExpirationRules             );
        contractLabels.put('AddressData'                    , Label.XC_CL_360Address                     );
        return contractLabels;
    }

    /**
    Map<String,String> contactLabels = new Map<String,String>();
        contactLabels.put('LastName','Last Name');
        contactLabels.put('FirstName','First Name');
        contactLabels.put('Salutation','Salutation');
        contactLabels.put('PrimaryContact','Primary Contact');
        contactLabels.put('Email','Email');
        contactLabels.put('MainPhonePrefix', 'Main Phone Prefix');
        contactLabels.put('MainPhone', 'Main Phone');
        contactLabels.put('PhonePrefix', 'PhonePrefix');
        contactLabels.put('Phone', 'Phone');
        contactLabels.put('IdentityType','Identity Type');
        contactLabels.put('IdentityNumber','Identity Number');
        contactLabels.put('ReleaseDate','Release Date');
        contactLabels.put('ExpiryDate','Expiry Date');
        //contactLabels.put('PrimaryEmail','Primary Email');
        contactLabels.put('PreferenceLanguage','Preference Language');
        contactLabels.put('Role', 'Role');
        contactLabels.put('ContactPreferredTime', 'Contact Preferred Time');
        contactLabels.put('Birthdate', 'Birthdate');
        /*contactLabels.put('RobinsonContact','Robinson Contact');
        contactLabels.put('ConsentLegalEntity','Consent Legal Entity');
        contactLabels.put('ConsentCampaign','Consent Campaign');
        contactLabels.put('ConsentGroup','Consent Group');* /
        commodityLabels.put('Contact', contactLabels);
    **/

    /**
     * @description Gets the commodity labels.
     * @return the commodity labels
     */
    /*private static Map<String,Map<String,String>> getCommodityLabels(){
        Map<String,Map<String,String>> commodityLabels = new Map<String,Map<String,String>>();
        
        //Account
        Map<String,String> accountLabels = new Map<String,String>();
        accountLabels.put('AccountType','Account Type');
        accountLabels.put('LastName', 'Last Name or Business Name');
        accountLabels.put('FirstName', 'First Name');
        accountLabels.put('Status', 'Status');
        //accountLabels.put('IdentityType', 'Identity Type');
        //accountLabels.put('IdentityNumber', 'Identity Number');
        accountLabels.put('MainPhonePrefix', 'Main Phone Prefix');
        accountLabels.put('MainPhone', 'Main Phone');
        accountLabels.put('PhonePrefix', 'PhonePrefix');
        accountLabels.put('Phone', 'Phone');
        accountLabels.put('PrimaryEmail', 'Primary Email');
        accountLabels.put('Country', 'Country');
        accountLabels.put('Birthdate', 'Birthdate');
        accountLabels.put('PreferenceLanguage', 'Preference Language');
        accountLabels.put('Notes', 'Notes');
        accountLabels.put('CertifiedEmail', 'Certified Email');
        accountLabels.put('MobilityOrderID', 'Mobility Order ID');
        accountLabels.put('PartnerID', 'Partner ID');
        accountLabels.put('DataLakeScoring', 'Data Lake Scoring');
        accountLabels.put('BlackList', 'Black List');
        accountLabels.put('DestinationCode', 'Destination Code');
        accountLabels.put('RegisteredOnRechargeApp', 'Registered On Recharge App');
        accountLabels.put('CostCenter', 'Cost Center');
        //accountLabels.put('ContactMethod', 'Contact Method');
        //accountLabels.put('VulnerableCustomer', 'Vulnerable Customer');
        //accountLabels.put('ValueSegment', 'Value Segment');
        //accountLabels.put('QualityIndex', 'Quality Index');
        commodityLabels.put('Account', accountLabels);

        //Contact
        Map<String,String> contactLabels = new Map<String,String>();
        contactLabels.put('LastName','Last Name');
        contactLabels.put('FirstName','First Name');
        contactLabels.put('Salutation','Salutation');
        contactLabels.put('PrimaryContact','Primary Contact');
        contactLabels.put('Email','Email');
        contactLabels.put('MainPhonePrefix', 'Main Phone Prefix');
        contactLabels.put('MainPhone', 'Main Phone');
        contactLabels.put('PhonePrefix', 'PhonePrefix');
        contactLabels.put('Phone', 'Phone');
        contactLabels.put('IdentityType','Identity Type');
        contactLabels.put('IdentityNumber','Identity Number');
        contactLabels.put('ReleaseDate','Release Date');
        contactLabels.put('ExpiryDate','Expiry Date');
        //contactLabels.put('PrimaryEmail','Primary Email');
        contactLabels.put('PreferenceLanguage','Preference Language');
        contactLabels.put('Role', 'Role');
        contactLabels.put('ContactPreferredTime', 'Contact Preferred Time');
        contactLabels.put('Birthdate', 'Birthdate');
        /*contactLabels.put('RobinsonContact','Robinson Contact');
        contactLabels.put('ConsentLegalEntity','Consent Legal Entity');
        contactLabels.put('ConsentCampaign','Consent Campaign');
        contactLabels.put('ConsentGroup','Consent Group');* /
        commodityLabels.put('Contact', contactLabels);

        //Billing Profile
        Map<String,String> billingProfLabels = new Map<String,String>();
        billingProfLabels.put('PaymentMethod'   ,'Payment Method');
        commodityLabels.put('BillingProfile', billingProfLabels);

        //Address
        Map<String,String> addressLabels = new Map<String,String>();
        //addressLabels.put('AddressType'         ,'Main Address');
        addressLabels.put('StreetType'          ,'Street Type');
        addressLabels.put('Address'             ,'Address');
        //addressLabels.put('Street'              ,'Street');
        addressLabels.put('StreetNumber'        ,'Street Number');
        addressLabels.put('Floor'               ,'Floor');
        addressLabels.put('Stair'               ,'Stair');
        addressLabels.put('Door'                ,'Door');
        addressLabels.put('ZipCode'             ,'Zip Code');
        addressLabels.put('City'                ,'City');
        addressLabels.put('Country'             ,'Country');
        addressLabels.put('Category'            ,'Category');
        addressLabels.put('Province'            ,'Province');
        addressLabels.put('MunicipalityCode'    ,'Municipality Code');
        addressLabels.put('StreetCode'          ,'Street Code');
        addressLabels.put('ShippingAddress'     ,'Shipping Address');
        addressLabels.put('BillingAddress'      ,'Billing Address');
        addressLabels.put('InstallationAddress' ,'Installation Address');
        commodityLabels.put('Address', addressLabels);

        //PointOfService
        Map<String,String> posLabels = new Map<String,String>();
        posLabels.put('POSID'               ,'POS ID');
        posLabels.put('POSType'             ,'POS Type');
        posLabels.put('POS'                 ,'POS');
        commodityLabels.put('PointOfService', posLabels);

        //PointOfDelivery
        /*Map<String,String> podLabels = new Map<String,String>();
        podLabels.put('CUPS'                      , 'CUPS');
        podLabels.put('Distributor'               , 'Distributor');
        podLabels.put('BusinessLine'              , 'Business Line');
        podLabels.put('Segment'                   , 'POD Segment');
        podLabels.put('CNAE'                      , 'Economic activity');
        podLabels.put('CNAEdescription'           , 'CNAE description');
        podLabels.put('VoltageType'               , 'Voltage Type');
        podLabels.put('Voltage'                   , 'Voltage (Volt)');
        podLabels.put('EstimatedAnnualConsumption', 'Estimated annual Consumption (kwh/year)');
        podLabels.put('MaximumAuthorizedPower'    , 'Maximum authorized power (KW)');
        podLabels.put('PowerAssignedAccess'       , 'Power Installed (KW)');
        podLabels.put('CIEExpirationDate'         , 'CIE Expiration Date');
        commodityLabels.put('PointOfDelivery', podLabels);* /

        //Cases
        Map<String,String> caseLabels = new Map<String,String>();
        caseLabels.put('CaseNumber'         , 'Case Number');
        caseLabels.put('Status'             , 'Status');
        caseLabels.put('Class'              , 'Class');
        caseLabels.put('CaseType'           , 'Case Type');
        caseLabels.put('CaseSubtype'        , 'Case Subtype');
        caseLabels.put('Reason'             , 'Reason');
        caseLabels.put('Priority'           , 'Priority');
        caseLabels.put('CaseCreationDate'   , 'Case Creation Date');
        caseLabels.put('CaseClosureDate'    , 'Case Closure Date');
        caseLabels.put('Description'        , 'Description');
        caseLabels.put('LastComment'        , 'Last comment');
        caseLabels.put('Result'             , 'Result');
        caseLabels.put('Channel'            , 'Channel');
        caseLabels.put('PresentationMedium' , 'Presentation Medium');
        commodityLabels.put('Cases', caseLabels);

        //Contract
        Map<String,String> contractLabels = new Map<String,String>();
        contractLabels.put('ContractNumber'           , 'Contract Number');
        contractLabels.put('Status'                   , 'Status');
        contractLabels.put('ContractType'             , 'Contract Type');
        contractLabels.put('HighDate'                 , 'High Date');
        contractLabels.put('LowDate'                  , 'Low Date');
        contractLabels.put('StartDateVersion'         , 'Start Date Version');
        contractLabels.put('Version'                  , 'Version');
        contractLabels.put('OwnerCompany'             , 'Owner Company');
        contractLabels.put('ServiceProductName'       , 'Service Product Name');
        contractLabels.put('CNAE'                     , 'Economic activity code');
        contractLabels.put('TypeOfSocialBonus'        , 'Type Of Social Bonus');
        contractLabels.put('ContractNotCuttable'      , 'Contract Not Cuttable');
        contractLabels.put('ShippingAddressType'      , 'Shipping Address Type');
        contractLabels.put('ShippingAddress'          , 'Shipping Address');
        contractLabels.put('ContractedPower1'         , 'Contracted Power 1');
        contractLabels.put('ContractedPower2'         , 'Contracted Power 2');
        contractLabels.put('ContractedPower3'         , 'Contracted Power 3');
        contractLabels.put('CIEAuthorizedMaximumPower', 'CIE Authorized Maximum Power');
        contractLabels.put('Tariff'                   , 'Tariff');
        contractLabels.put('Consumption'              , 'Consumption');
        contractLabels.put('SelfConsumption'          , 'Self Consumption');
        contractLabels.put('CUPS'                     , 'CUPS');
        contractLabels.put('BusinessLine'             , 'Business Line');
        contractLabels.put('DeliveryAddress'          , 'Delivery Address');
        contractLabels.put('BankAccountHolder'        , 'Bank Account Holder');
        contractLabels.put('BillingPeriod'            , 'Billing  Period');
        contractLabels.put('Telemeasure'              , 'Telemeasure');
        commodityLabels.put('Contracts', contractLabels);

        //Invoice
        Map<String,String> invoiceLabels = new Map<String,String>();
        invoiceLabels.put('InvoiceReference'   , 'Invoice Reference');
        invoiceLabels.put('InvoiceType'        , 'Invoice Type');
        invoiceLabels.put('Contract'           , 'Contract');
        invoiceLabels.put('InvoiceCreationDate', 'Invoice Creation Date');
        invoiceLabels.put('InvoiceAddress'     , 'Invoice Address');
        invoiceLabels.put('Amount'             , 'Amount');
        invoiceLabels.put('ProprietaryInvoice' , 'Proprietary Invoice');
        invoiceLabels.put('ContactInvoice'     , 'Contact Invoice');
        invoiceLabels.put('DateOfIssue'        , 'Date Of Issue');
        invoiceLabels.put('ExpirationDate'     , 'Expiration Date');
        invoiceLabels.put('PDFInvoice'         , 'PDF Invoice');
        commodityLabels.put('Invoices', invoiceLabels);

        return commodityLabels;
    }*/


}