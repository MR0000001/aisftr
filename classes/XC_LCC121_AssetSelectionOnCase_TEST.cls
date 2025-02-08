/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com   Valeria Martino - valeria.martino@nttdata.com
* @date Creation 21/06/2019 
* @description XC_LCC121_AssetSelectionOnCase_TEST – Test class for XC_LCC121_AssetSelectionOnCase
*/
@isTest    
public with sharing class XC_LCC121_AssetSelectionOnCase_TEST {


    @TestSetup
    static void setup(){
        OneOrg__c org            = new OneOrg__c(); 
        org.Name                 = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org; 
        List<Lead> leadList = XC_DF_Lead.createResidentialLeads(1);
        insert leadList;    
    } 

    @isTest
    static void onAssetsAttachData(){


        List<XC_Address__c> listAddress = XC_DF_Address.createAddress(1);
        insert listAddress;
        List<Case> listCase= XC_DF_Case.createCases(1);
        
        List<XC_Address__c> listAccountAdd = [SELECT XC_Account__c FROM XC_Address__c WHERE Id = :listAddress[0].Id ];
        listCase[0].XC_Address__c=listAddress[0].id;
        listCase[0].AccountId = listAccountAdd[0].XC_Account__c;

        List<Contact> listContactAdd = XC_DF_Contact.createResidentialContacts(1);
        listContactAdd[0].AccountId =  listAccountAdd[0].XC_Account__c;
        insert listContactAdd;

        listCase[0].ContactId =  listContactAdd[0].Id;

        List<Asset> listAsset = XC_DF_Asset.createAssets(1);
        listAsset[0].XC_Product_Type__c = Label.XC_CL_ProductTypeEquipment;
        listAsset[0].XC_Address__c = listAddress[0].id;
        insert listAsset;

        insert listCase;
        XC_CaseAsset__c caseAsset = new XC_CaseAsset__c(); // da vedere
        caseAsset.XC_Case__c= listCase[0].id; 
        insert caseAsset;
        Test.startTest();
        XC_LCC121_AssetSelectionOnCase.attachAssets(listCase[0].id, listAsset);

        listAsset[0].Status = Label.XC_CL_Asset_StatusActive;
        update listAsset;
        XC_LCC121_AssetSelectionOnCase.getAssetsByAddress(listCase[0].id);

        listCase[0].XC_Address__c=null;
        listCase[0].Status = 'ESTA001';
        update listCase;
        XC_LCC121_AssetSelectionOnCase.getAssetsByAddress(listCase[0].id);
        Test.stopTest();

        System.assert(listCase!=null); 




    }

}