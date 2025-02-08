/**
 * The Class XC_UTIL_TranslationWorkbench_TEST.
 *
 * @author            : Nicolo Fodera nicolo.fodera@enel.com
 * @date Creation     : 25/03/2022
 * @date Modification : dd/mm/yyyy
 * @description       : Test Class for XC_UTIL_TranslationWorkbench
 **/


@isTest
public without sharing class XC_UTIL_TranslationWorkbench_TEST {

    @TestSetup 
    static void setup(){ 
        List<XC_APIDynamicFieldTranslation__c> css = new List<XC_APIDynamicFieldTranslation__c>();
        XC_APIDynamicFieldTranslation__c cs = new XC_APIDynamicFieldTranslation__c();
        cs.Name = 'CommodityItalyB2C';
        cs.XC_ClientSystem__c = 'CommodityItalyB2Cx';
        cs.XC_FieldAPINameList__c = 'XC_Subtype__c;';
        cs.XC_SobjectName__c = 'Case';
        insert cs; 
    }


     
    @isTest
    static void testToLabelizeQueryFields(){ 
        test.startTest(); 
        String inputQueryFields = 'SELECT XC_Subtype__c,id FROM CASE WHERE  ';
        String outputQueryFields = XC_UTIL_TranslationWorkbench.toLabelizeQueryFields('Case', 'CommodityItalyB2Cx',  inputQueryFields);
        String expectedOutputQueryFields = 'SELECT toLabel(XC_SUBTYPE__C),ID FROM CASE WHERE '; 
        System.assertEquals(expectedOutputQueryFields, outputQueryFields, 'Wrong assert result');
        test.stopTest();
    }
    
    
     






}