/**
* @author Nicola Arrigo narrigo@deloitte.it 
* @date Creation  18/02/2020 
* @description XC_SkipTrigger_Test – Test class for  XC_UTIL_SkipTrigger
*/ 
@isTest
public class XC_SkipTrigger_Test {
    static testMethod void checkObjToSKip(){
    XC_UTIL_SkipTrigger.checkObjToSKip('Opportunity');
    }    
}