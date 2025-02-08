/**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @date Creation 15/05/2019
* @date Modification 24/07/2019 monica.cutillo@nttdata.com
* @description XC_LCC005_AccountCallToCommodity_TEST 
*/  
@isTest
public class XC_LCC005_AccountCallToCommodity_M_TEST {

    static testMethod void  manageResponseFake(){
        String fakeResponse = 
        '      {                                                                        '+
        '         "AccountType":"Residential",                                          '+
        '         "LastName":"Lopez Domínguez",                                         '+
        '         "FirstName":"Pablo",                                                  '+
        '         "Status":"Active",                                                    '+
        '         "AccountStaus":"Active",                                              '+
        '         "Country":"España",                                                   '+
        '         "MainPhonePrefix":"+ 34",                                               '+
        '         "PhonePrefix":"+ 34",                                                   '+
        '         "MainPhone":"623477603",                                              '+
        '         "Phone":"926577500",                                                  '+
        '         "PrimaryEmail":"pablo.lopez2@gmail.com",                              '+
        '         "CertifiedEmail":"pablo.lopez2@gmail.com",                            '+
        '         "PreferenceLanguage":"Español",                                       '+
        '         "ContactMethod":"",                                                   '+
        '         "VulnerableCustomer":"",                                              '+
        '         "ValueSegment":"",                                                    '+
        '         "QualityIndex":""                                                    '+
      
        '}                                                                              ';

        Test.startTest();
            XC_LCC005_AccountCallToCommodity_Manage.manageResponseFake(fakeResponse);
        Test.stopTest();

    }

    static testMethod void  manageCallCommodityMain(){
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;

        String json = '{																				'+
        '   "Account":[                                                                 '+
        '      {                                                                        '+
        '         "AccountType":"Residential",                                          '+
        '         "LastName":"Lopez Domínguez",                                         '+
        '         "FirstName":"Pablo",                                                  '+
        '         "Status":"Active",                                                    '+
        '         "AccountStaus":"Active",                                              '+
        '         "Country":"España",                                                   '+
        '         "MainPhonePrefix":"+34",                                               '+
        '         "PhonePrefix":"+34",                                                   '+
        '         "MainPhone":"623477603",                                              '+
        '         "Phone":"926577500",                                                  '+
        '         "PrimaryEmail":"pablo.lopez2@gmail.com",                              '+
        '         "CertifiedEmail":"pablo.lopez2@gmail.com",                            '+
        '         "PreferenceLanguage":"Español",                                       '+
        '         "ContactMethod":"",                                                   '+
        '         "VulnerableCustomer":"",                                              '+
        '         "ValueSegment":"",                                                    '+
        '         "QualityIndex":"",                                                    '+
        '         "Contact":[                                                           '+
        '            {                                                                  '+
        '               "LastName":"Lucio Sanchez",                                     '+
        '               "FirstName":"Santos",                                           '+
        '               "IdentityType":"NIF",                                           '+
        '               "IdentityNumber":"7742983X",                                    '+
        '               "Phone":"623477603",                                            '+
        '               "MobilePhone":"926577500",                                      '+
        '               "MobilePhonePrefix":"+34",                                       '+
        '               "PhonePrefix":"+34",                                             '+
        '               "PrimaryEmail":"santos.lucio@gmail.com",                        '+
        '               "PreferenceLanguage":"Español",                                 '+
        '               "Role":"Coach",                                                 '+
        '               "GDPR":{                                                        '+
        '                  "GiveDataToThirdParties":"Y",                                '+
        '                  "LegalEntity":[                                              '+
        '                     {                                                         '+
        '                        "LegalEntity":"EndesaX",                               '+
        '                        "GiveDataToLegalEntity":"Y",                           '+
        '                        "GiveDataForMarketing":"N",                            '+
        '                        "GiveDataForProfiling":"Y"                             '+
        '                     }                                                         '+
        '                  ]                                                            '+
        '               }                                                               '+
        '            },                                                                 '+
        '            {                                                                  '+
        '               "LastName":"Sebastian Villagra",                                '+
        '               "FirstName":"Marcos",                                           '+
        '               "IdentityType":"NIF",                                           '+
        '               "IdentityNumber":"43661258M",                                   '+
        '               "Phone":"663770044",                                            '+
        '               "MobilePhone":"987883377",                                      '+
        '               "PrimaryEmail":"marcos.vi@test.com",                             '+
        '               "PreferenceLanguage":"Español",                                 '+
        '               "MobilePhonePrefix":"+34",                                       '+
        '               "PhonePrefix":"+34",                                             '+
        '               "Role":""                                                       '+
        '            }                                                                  '+
        '         ],                                                                    '+
        '         "BillingProfile":[                                                    '+
        '            {                                                                  '+
        '               "PaymentMethod":"Direct Debit",                                 '+
        '               "IBAN":"ES 91 2100 0418 4502 0005 1332",                        '+
        '               "CommodityContractNum":"86154244451",                           '+
        '               "Country":"Spain"                                               '+
        '            }                                                                  '+
        '         ],                                                                    '+
        '         "Address":[                                                           '+
        '            {                                                                  '+
        '               "AddressType":"",                                               '+
        '               "Country":"España",                                             '+
        '               "Category":"Domicilio Principal",                               '+
        '               "Address":"Fereluz",                                            '+
        '               "StreetType":"Calle",                                           '+
        '               "Street":"Giolitti",                                            '+
        '               "StreetNumber":"12",                                            '+
        '               "Floor":"2",                                                    '+
        '               "Stair":"1",                                                    '+
        '               "Door":"B",                                                     '+
        '               "ZipCode":"80100",                                              '+
        '               "Province":"Madrid",                                            '+
        '               "MunicipalName":"Madrid",                                       '+
        '               "City":"Madrid",                                                '+
        '               "PointOfService":[                                              '+
        '                  {                                                            '+
        '                     "POS":"ES4126119685457838CY",                             '+
        '                     "POSID":"ESY",                                            '+
        '                     "POSType":"Light"                                         '+
        '                  }                                                            '+
        '               ]                                                               '+
        '            },                                                                 '+
        '            {                                                                  '+
        '               "AddressType":"Segunda Residencia",                             '+
        '               "Country":"Spain",                                              '+
        '               "Category":"Segunda Residencia",                                '+
        '               "Address":"Port De Casablanca",                                 '+
        '               "StreetType":"Calle",                                           '+
        '               "StreetNumber":"11",                                            '+
        '               "Floor":"5",                                                    '+
        '               "Stair":"",                                                     '+
        '               "Door":"D",                                                     '+
        '               "ZipCode":"08039",                                              '+
        '               "MunicipalName":"Barcelona",                                    '+
        '               "Province":"Barcelona",                                         '+
        '               "City":"Barcellona",                                            '+
        '               "PointOfService":[                                              '+
        '                  {                                                            '+
        '                     "POS":"ES0186079796715968ZN",                             '+
        '                     "POSID":"ES0186079796715968ZN",                           '+
        '                     "POSType":"Gas"                                           '+
        '                  },                                                           '+
        '                  {                                                            '+
        '                     "POS":"ES0013816078876368WM",                             '+
        '                     "POSID":"ES0013816078876368WM",                           '+
        '                     "POSType":"Light"                                         '+
        '                  }                                                            '+
        '               ]                                                               '+
        '            }                                                                  '+
        '         ]                                                                     '+
        '      },                                                                       '+
        '      {                                                                        '+
        '         "AccountType":"Residential",                                          '+
        '         "LastName":"Solinas",                                                 '+
        '         "FirstName":"Mario",                                                  '+
        '         "AccountStaus":"Active",                                              '+
        '         "MainPhonePrefix":"+34",                                               '+
        '         "PhonePrefix":"+34",                                                   '+
        '         "MainPhone":"987485754",                                                '+
        '         "Phone":"987384756",                                                  '+
        '         "PrimaryEmail":"MarioSolinas@gmail.com",                              '+
        '         "PreferenceLanguage":"EN",                                            '+
        '         "ContactMethod":"",                                                   '+
        '         "VulnerableCustomer":"",                                              '+
        '         "ValueSegment":"",                                                    '+
        '         "QualityIndex":"",                                                    '+
        '         "Contact":[                                                           '+
        '            {                                                                  '+
        '               "LastName":"Lucio Sanchez",                                     '+
        '               "FirstName":"Santos",                                           '+
        '               "IdentityType":"NIF",                                           '+
        '               "IdentityNumber":"7742983X",                                    '+
        '               "Phone":"623477603",                                            '+
        '               "MobilePhone":"926577500",                                      '+
        '               "MobilePhonePrefix":"+34",                                       '+
        '               "PhonePrefix":"+34",                                             '+
        '               "PrimaryEmail":"santos.lucio@gmail.com",                        '+
        '               "PreferenceLanguage":"Español",                                 '+
        '               "Role":"Coach",                                                 '+
        '               "GDPR":{                                                        '+
        '                  "GiveDataToThirdParties":"Y",                                '+
        '                  "LegalEntity":[                                              '+
        '                     {                                                         '+
        '                        "LegalEntity":"EndesaX",                               '+
        '                        "GiveDataToLegalEntity":"Y",                           '+
        '                        "GiveDataForMarketing":"N",                            '+
        '                        "GiveDataForProfiling":"Y"                             '+
        '                     }                                                         '+
        '                  ]                                                            '+
        '               }                                                               '+
        '            },                                                                 '+
        '            {                                                                  '+
        '               "LastName":"Sebastian Villagra",                                '+
        '               "FirstName":"Marcos",                                           '+
        '               "IdentityType":"NIF",                                           '+
        '               "IdentityNumber":"43661158M",                                   '+
        '               "Phone":"663770044",                                            '+
        '               "MobilePhone":"987883377",                                      '+
        '               "PrimaryEmail":"marcos.vi@test.com",                             '+
        '               "PreferenceLanguage":"Español",                                 '+
        '               "MobilePhonePrefix":"+34",                                       '+
        '               "PhonePrefix":"+34",                                             '+
        '               "Role":""                                                       '+
        '            }                                                                  '+
        '         ],                                                                    '+
        '         "BillingProfile":[                                                    '+
        '            {                                                                  '+
        '               "PaymentMethod":"Direct Debit",                                 '+
        '               "IBAN":"ES 91 2100 0418 4502 0005 1332",                        '+
        '               "CommodityContractNum":"86154244451",                           '+
        '               "Country":"Spain"                                               '+
        '            }                                                                  '+
        '         ],                                                                    '+
        '         "Address":[                                                           '+
        '            {                                                                  '+
        '               "AddressType":"",                                               '+
        '               "Country":"España",                                             '+
        '               "Category":"Domicilio Principal",                               '+
        '               "Address":"Fereluz",                                            '+
        '               "StreetType":"Calle",                                           '+
        '               "Street":"Giolitti",                                            '+
        '               "StreetNumber":"12",                                            '+
        '               "Floor":"2",                                                    '+
        '               "Stair":"1",                                                    '+
        '               "Door":"B",                                                     '+
        '               "ZipCode":"80100",                                              '+
        '               "Province":"Madrid",                                            '+
        '               "MunicipalName":"Madrid",                                       '+
        '               "City":"Madrid",                                                '+
        '               "PointOfService":[                                              '+
        '                  {                                                            '+
        '                     "POS":"ES4126119685457838CY",                             '+
        '                     "POSID":"ESY",                                            '+
        '                     "POSType":"Light"                                         '+
        '                  }                                                            '+
        '               ]                                                               '+
        '            },                                                                 '+
        '            {                                                                  '+
        '               "AddressType":"Segunda Residencia",                             '+
        '               "Country":"Spain",                                              '+
        '               "Category":"Segunda Residencia",                                '+
        '               "Address":"Port De Casablanca",                                 '+
        '               "StreetType":"Calle",                                           '+
        '               "StreetNumber":"11",                                            '+
        '               "Floor":"5",                                                    '+
        '               "Stair":"",                                                     '+
        '               "Door":"D",                                                     '+
        '               "ZipCode":"08039",                                              '+
        '               "MunicipalName":"Barcelona",                                    '+
        '               "Province":"Barcelona",                                         '+
        '               "City":"Barcellona",                                            '+
        '               "PointOfService":[                                              '+
        '                  {                                                            '+
        '                     "POS":"ES0186079796715968ZN",                             '+
        '                     "POSID":"ES0186079796715968ZN",                           '+
        '                     "POSType":"Gas"                                           '+
        '                  },                                                           '+
        '                  {                                                            '+
        '                     "POS":"ES0013816078876368WM",                             '+
        '                     "POSID":"ES0013816078876368WM",                           '+
        '                     "POSType":"Light"                                         '+
        '                  }                                                            '+
        '               ]                                                               '+
        '            }                                                                  '+
        '         ]                                                                     '+
        '      }                                                                        '+
        '   ]                                                                           '+
        '}                                                                              ';
        XC_REST_ReadAccont.WrapperResult callResult = (XC_REST_ReadAccont.WrapperResult) System.JSON.deserialize(json, XC_REST_ReadAccont.WrapperResult.class );
        Test.startTest();
            XC_LCC005_AccountCallToCommodity_Manage.manageCallCommodityMain(XC_REST_ReadAccont.setFakeResultForCommodityNew(), String.valueOf( accountList.get(0).id), 'Account'  );
        Test.stopTest();
    }


}