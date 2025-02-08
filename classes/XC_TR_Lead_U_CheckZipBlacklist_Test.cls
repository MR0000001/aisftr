/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/

    @isTest
    public with sharing class XC_TR_Lead_U_CheckZipBlacklist_Test {
        @TestSetup
        static void setup(){

            insert XC_DF_OneOrg.createOneOrg('Spain');
            User u = XC_DF_User.createUserAdmin();
            insert u;
    
            NE__Matrix_Parameter__c matrix = new NE__Matrix_Parameter__c(Name = 'eHome_ITA_BlackListCap');
            insert matrix;
            NE__Matrix_Parameter_Row__c row2 = new NE__Matrix_Parameter_Row__c(NE__Active__c = true,XC_Rule_Type__c = 'Incompatibility' ,NE__Matrix_Parameter__c = matrix.Id, XC_Value2__c ='871700', XC_Name2__c= 'CAP' , XC_Name1__c = 'ProductSubType', XC_Value1__c = 'Boiler', XC_Value3__c = 'Boiler');
            insert row2;
            XC_ProductCategoryOfInterest__c poi1 = new XC_ProductCategoryOfInterest__c (Name = 'Calentador',XC_ProductSubType__c='Boiler');
            insert poi1;
            XC_ProductCategoryOfInterest__c poi2 = new XC_ProductCategoryOfInterest__c (Name = 'Caldera',XC_ProductSubtype__c='Boiler',XC_SecondaryProductSubtype__c='Boiler');
            insert poi2;
    
        }
        @isTest
        static void checkBlackListOnInsert_Test() {
            List<Lead> leadListToInsert = XC_DF_Lead.createResidentialLeads(1);
            //insert listLead;
            //List<Lead> listLeadNew = XC_DF_Lead.createResidentialLeads(1);
            //insert listLeadNew;
            //Map<Id,Lead> mapLead = new Map<Id,Lead>(listLead);
    
            Lead ld =leadListToInsert[0];
            ld.RecordTypeID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Residential').getRecordTypeId();
            ld.XC_DocumentCountry__c = 'Spain';
            ld.Email = 'test@testlead.it';
            ld.XC_MainLegalEntity__c = 'EnelXItalia';
            ld.FirstName = 'LeadTest';
            ld.LastName= 'LeadTest';
            ld.XC_PhonePrefix__c='+39';
            ld.XC_LeadPhone__c= '0817898788';
            ld.XC_DocumentType__c = 'NIF';
            ld.XC_DocumentNumber__c = '52802393D';
            ld.XC_GenericZipCode__c='8717';
            ld.XC_ZipCode__c='8717';
            ld.XC_ProductCategoryOfInterest__c= 'Calentador';
            ld.XC_Channel__c = 'Commodity Partner';
            ld.XC_LeadSource__c = null;
            List<Lead>listLead = new List<Lead>() ;
            listLead.add(ld);
            insert listLead;
    
    
    
            Test.startTest();
                //test insert
                XC_TR_Lead_U_CheckZipBlacklist.checkBlackListOnInsert(listLead);
                //test update
                listLead[0].XC_GenericZipCode__c='871700';
                listLead[0].XC_ZipCode__c='871700';
                listLead[0].XC_ProductCategoryOfInterest__c= 'Caldera';
                try{
                    update listLead;
                }catch(Exception e){

                }
            Test.stopTest();
    
    
        }
        
        @IsTest
        static void testUtilClass(){
            XC_UTIL_ZipCodeBlacklist.InputWrapper iw = new XC_UTIL_ZipCodeBlacklist.InputWrapper('Boiler','871700','Boiler');
            List<XC_UTIL_ZipCodeBlacklist.InputWrapper> iws = new List<XC_UTIL_ZipCodeBlacklist.InputWrapper>{iw};

            Test.startTest();
                XC_UTIL_ZipCodeBlacklist.checkZipBlacklistByProductSubtype(iws, 'EnelXItalia','B2C');
            Test.stopTest();
        }
        
    }