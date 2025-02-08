/**
* @author Nicola Arrigo - narrigo@deloitte.it  
* @date Creation  20/03/2020
* @description XC_UTIL_FieldSet_Test – Test class for XC_UTIL_FieldSet
*/
@Istest
public class XC_UTIL_FieldSet_Test {
    static testmethod void getFieldSetFields(){
       string fieldSetName='XC_CHL_B2B_New_Source';
       string sObjectName='Lead';
        test.startTest();
         List<XC_Util_FieldSet.FieldWrapper> wrapper = new   List<XC_Util_FieldSet.FieldWrapper>();
         wrapper=XC_UTIL_FieldSet.getFieldSetFields(fieldSetName, sObjectName);
       test.stopTest();
    }
   
}