/**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @date Creation 15/05/2019
* @date Modification 24/07/2019 monica.cutillo@nttdata.com
* @description XC_LCC005_AccountCallToCommodity_TEST 
*/  
@isTest
public class XC_LCC005_AccountCallToCommodity_UU_TEST {

    static testMethod void saveConsents(){

        List<Account> account = XC_DF_Account.createResidentialAccounts(1);
        account[0].IdentityNumber__c = '41550260R';
        account[0].IdentityType__c = 'NIF';
        insert account;
        
        List<Contact> contact = XC_DF_Contact.createResidentialContacts(account);
        contact[0].XC_ContactDocumentNumber__c = '41550260R';
        insert contact;

        Map<String,Object> inputDataToSave = new Map<String,Object>();
        inputDataToSave.put('recordId', account[0].id);
        inputDataToSave.put('sobjecttype', 'Account');

        Map<String,Object> address = new Map<String,Object>();
        address.put('Street', 'Street');
        address.put('Country', 'Spain');
        List<Map<String,Object>> addressList = new List<Map<String,Object>>();

        addressList.add(address);

        Map<String, Object> pod = new Map<String, Object>();
        pod.put( 'POSType', 'GAS');
        pod.put('POS', '1234567890');
        pod.put('Country', 'Spain');

        List<Map<String, Object>> cupList = new List<Map<String, Object>>();
        cupList.add(pod);
        List<List<Map<String, Object>>>cupListList = new List<List<Map<String, Object>>>();

        XC_ConsentDescription__c consentDescription = new XC_ConsentDescription__c();
        consentDescription.XC_LegalEntity__c = 'EndesaX';
        consentDescription.XC_Country__c = 'Spain' ;
        consentDescription.XC_ConsentVersion__c = '3';
        consentDescription.XC_ConsentStatus__c = 'Active';
        consentDescription.XC_ParentDescription__c = null;
        insert consentDescription;


        String json = '{																					'+
        '   "sections":{                                                                    '+
        '      "Contact":{                                                                  '+
        '         "objectsRecordFields":[                                                   '+
        '            [                                                                      '+
        '               {                                                                   '+
        '                  "fieldKey":"FirstName",                                          '+
        '                  "fieldLabel":"First Name",                                       '+
        '                  "fieldValue":"Santos"                                            '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"LastName",                                           '+
        '                  "fieldLabel":"Last Name or Business Name",                       '+
        '                  "fieldValue":"Lucio Sanchez"                                     '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"IdentityType",                                       '+
        '                  "fieldLabel":"Identity Type",                                    '+
        '                  "fieldValue":"NIF"                                               '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"IdentityNumber",                                     '+
        '                  "fieldLabel":"Identity Number",                                  '+
        '                  "fieldValue":"41550260R"                                          '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"PhonePrefix",                                        '+
        '                  "fieldLabel":"Primary Phone Prefix",                             '+
        '                  "fieldValue":"+34"                                               '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"Phone",                                              '+
        '                  "fieldLabel":"Primary Phone",                                    '+
        '                  "fieldValue":"623477603"                                         '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"MainPhonePrefix",                                    '+
        '                  "fieldLabel":"Secondary Phone Prefix"                            '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"MainPhone",                                          '+
        '                  "fieldLabel":"Secondary Phone"                                   '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"PrimaryEmail",                                       '+
        '                  "fieldLabel":"Primary Email",                                    '+
        '                  "fieldValue":"santos.lucio@gmail.com"                            '+
        '               }                                                                   '+
        '            ],                                                                     '+
        '            [                                                                      '+
        '               {                                                                   '+
        '                  "fieldKey":"FirstName",                                          '+
        '                  "fieldLabel":"First Name",                                       '+
        '                  "fieldValue":"Marcos"                                            '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"LastName",                                           '+
        '                  "fieldLabel":"Last Name or Business Name",                       '+
        '                  "fieldValue":"Sebastian Villagra"                                '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"IdentityType",                                       '+
        '                  "fieldLabel":"Identity Type",                                    '+
        '                  "fieldValue":"NIF"                                               '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"IdentityNumber",                                     '+
        '                  "fieldLabel":"Identity Number",                                  '+
        '                  "fieldValue":"43661258M"                                         '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"PhonePrefix",                                        '+
        '                  "fieldLabel":"Primary Phone Prefix",                             '+
        '                  "fieldValue":"+34"                                               '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"Phone",                                              '+
        '                  "fieldLabel":"Primary Phone",                                    '+
        '                  "fieldValue":"663770044"                                         '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"MainPhonePrefix",                                    '+
        '                  "fieldLabel":"Secondary Phone Prefix"                            '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"MainPhone",                                          '+
        '                  "fieldLabel":"Secondary Phone"                                   '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"PrimaryEmail",                                       '+
        '                  "fieldLabel":"Primary Email",                                    '+
        '                  "fieldValue":"marcos.vi@test.com"                                '+
        '               }                                                                   '+
        '            ]                                                                      '+
        '         ],                                                                        '+
        '         "sectionLabel":"Contact",                                                 '+
        '         "subsectionObjects":[                                                     '+
        '                                                                                   '+
        '         ]                                                                         '+
        '      },                                                                           '+
        '      "BillingProfile":{                                                           '+
        '         "objectsRecordFields":[                                                   '+
        '            [                                                                      '+
        '               {                                                                   '+
        '                  "fieldKey":"PaymentMethod",                                      '+
        '                  "fieldLabel":"Payment Method",                                   '+
        '                  "fieldValue":"Direct Debit"                                      '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"CommodityContractNum",                               '+
        '                  "fieldLabel":"Commodity Contract Num",                           '+
        '                  "fieldValue":"86154244451"                                       '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"IBAN",                                               '+
        '                  "fieldLabel":"IBAN",                                             '+
        '                  "fieldValue":"ES 91 2100 0418 4502 0005 1332"                    '+
        '               }                                                                   '+
        '            ]                                                                      '+
        '         ],                                                                        '+
        '         "sectionLabel":"BillingProfile"                                           '+
        '      },                                                                           '+
        '      "Address":{                                                                  '+
        '         "objectsRecordFields":[                                                   '+
        '            [                                                                      '+
        '               {                                                                   '+
        '                  "fieldKey":"Country",                                            '+
        '                  "fieldLabel":"Country",                                          '+
        '                  "fieldValue":"España"                                            '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"Category",                                           '+
        '                  "fieldLabel":"Category",                                         '+
        '                  "fieldValue":"Domicilio Principal"                               '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"City",                                               '+
        '                  "fieldLabel":"City",                                             '+
        '                  "fieldValue":"Madrid"                                            '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"Province",                                           '+
        '                  "fieldLabel":"Province",                                         '+
        '                  "fieldValue":"Madrid"                                            '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"StreetType",                                         '+
        '                  "fieldLabel":"Street Type",                                      '+
        '                  "fieldValue":"Calle"                                             '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"Address",                                            '+
        '                  "fieldLabel":"Address",                                          '+
        '                  "fieldValue":"Fereluz"                                           '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"StreetNumber",                                       '+
        '                  "fieldLabel":"Street Number",                                    '+
        '                  "fieldValue":"12"                                                '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"ZipCode",                                            '+
        '                  "fieldLabel":"Zip Code",                                         '+
        '                  "fieldValue":"80100"                                             '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"Floor",                                              '+
        '                  "fieldLabel":"Floor",                                            '+
        '                  "fieldValue":"2"                                                 '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"MunicipalName",                                      '+
        '                  "fieldLabel":"Town Hall",                                        '+
        '                  "fieldValue":"Madrid"                                            '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"Stair",                                              '+
        '                  "fieldLabel":"Stair",                                            '+
        '                  "fieldValue":"1"                                                 '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"Door",                                               '+
        '                  "fieldLabel":"Door",                                             '+
        '                  "fieldValue":"B"                                                 '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"ClarificatorType",                                   '+
        '                  "fieldLabel":"Clarificator Type"                                 '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"ClarificatorValue",                                  '+
        '                  "fieldLabel":"Clarificator Value"                                '+
        '               }                                                                   '+
        '            ],                                                                     '+
        '            [                                                                      '+
        '               {                                                                   '+
        '                  "fieldKey":"Country",                                            '+
        '                  "fieldLabel":"Country",                                          '+
        '                  "fieldValue":"Spain"                                             '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"Category",                                           '+
        '                  "fieldLabel":"Category",                                         '+
        '                  "fieldValue":"Segunda Residencia"                                '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"City",                                               '+
        '                  "fieldLabel":"City",                                             '+
        '                  "fieldValue":"Barcellona"                                        '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"Province",                                           '+
        '                  "fieldLabel":"Province",                                         '+
        '                  "fieldValue":"Barcelona"                                         '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"StreetType",                                         '+
        '                  "fieldLabel":"Street Type",                                      '+
        '                  "fieldValue":"Calle"                                             '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"Address",                                            '+
        '                  "fieldLabel":"Address",                                          '+
        '                  "fieldValue":"Port De Casablanca"                                '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"StreetNumber",                                       '+
        '                  "fieldLabel":"Street Number",                                    '+
        '                  "fieldValue":"11"                                                '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"ZipCode",                                            '+
        '                  "fieldLabel":"Zip Code",                                         '+
        '                  "fieldValue":"08039"                                             '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"Floor",                                              '+
        '                  "fieldLabel":"Floor",                                            '+
        '                  "fieldValue":"5"                                                 '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"MunicipalName",                                      '+
        '                  "fieldLabel":"Town Hall",                                        '+
        '                  "fieldValue":"Barcelona"                                         '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"Stair",                                              '+
        '                  "fieldLabel":"Stair",                                            '+
        '                  "fieldValue":""                                                  '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"Door",                                               '+
        '                  "fieldLabel":"Door",                                             '+
        '                  "fieldValue":"D"                                                 '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"ClarificatorType",                                   '+
        '                  "fieldLabel":"Clarificator Type"                                 '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"ClarificatorValue",                                  '+
        '                  "fieldLabel":"Clarificator Value"                                '+
        '               }                                                                   '+
        '            ]                                                                      '+
        '         ],                                                                        '+
        '         "sectionLabel":"Address",                                                 '+
        '         "subsectionObjects":[                                                     '+
        '            [                                                                      '+
        '               [                                                                   '+
        '                  {                                                                '+
        '                     "fieldKey":"POSType",                                         '+
        '                     "fieldLabel":"POS Type",                                      '+
        '                     "fieldValue":"Light"                                          '+
        '                  },                                                               '+
        '                  {                                                                '+
        '                     "fieldKey":"POS",                                             '+
        '                     "fieldLabel":"POS",                                           '+
        '                     "fieldValue":"ES4126119685457838CY"                           '+
        '                  }                                                                '+
        '               ]                                                                   '+
        '            ],                                                                     '+
        '            [                                                                      '+
        '               [                                                                   '+
        '                  {                                                                '+
        '                     "fieldKey":"POSType",                                         '+
        '                     "fieldLabel":"POS Type",                                      '+
        '                     "fieldValue":"Gas"                                            '+
        '                  },                                                               '+
        '                  {                                                                '+
        '                     "fieldKey":"POS",                                             '+
        '                     "fieldLabel":"POS",                                           '+
        '                     "fieldValue":"ES0186079796715968ZN"                           '+
        '                  }                                                                '+
        '               ],                                                                  '+
        '               [                                                                   '+
        '                  {                                                                '+
        '                     "fieldKey":"POSType",                                         '+
        '                     "fieldLabel":"POS Type",                                      '+
        '                     "fieldValue":"Light"                                          '+
        '                  },                                                               '+
        '                  {                                                                '+
        '                     "fieldKey":"POS",                                             '+
        '                     "fieldLabel":"POS",                                           '+
        '                     "fieldValue":"ES0013816078876368WM"                           '+
        '                  }                                                                '+
        '               ]                                                                   '+
        '            ]                                                                      '+
        '         ]                                                                         '+
        '      },                                                                           '+
        '      "LegalEntity":{                                                              '+
        '         "objectsRecordFields":[                                                   '+
        '            [                                                                      '+
        '               {                                                                   '+
        '                  "fieldKey":"LegalEntity",                                        '+
        '                  "fieldLabel":"Legal Entity",                                     '+
        '                  "fieldValue":"EndesaX"                                           '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"GiveDataToThirdParties",                             '+
        '                  "fieldLabel":"Give data to third parties",                       '+
        '                  "fieldValue":"Y"                                                 '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"GiveDataToLegalEntity",                              '+
        '                  "fieldLabel":"Give data to Legal Entity",                        '+
        '                  "fieldValue":"Y"                                                 '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"GiveDataForMarketing",                               '+
        '                  "fieldLabel":"Give data for Marketing",                          '+
        '                  "fieldValue":"N"                                                 '+
        '               },                                                                  '+
        '               {                                                                   '+
        '                  "fieldKey":"GiveDataForProfiling",                               '+
        '                  "fieldLabel":"Give data for Profiling",                          '+
        '                  "fieldValue":"Y"                                                 '+
        '               }                                                                   '+
        '            ]                                                                      '+
        '         ],                                                                        '+
        '         "sectionLabel":"Contact"                                                  '+
        '      }                                                                            '+
        '   }                                                                               '+
        '}																			        ';


        Test.startTest();
            XC_LCC005_AccountCallToCommodity_UU.saveConsents( account[0].id, json);
        Test.stopTest();
    }
}