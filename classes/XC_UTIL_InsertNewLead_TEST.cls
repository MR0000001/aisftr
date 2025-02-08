/**
* @author Riccardo Cossu - riccardo.cossu@nttdata.com
* @description Test Class for XC_UTIL_InsertNewLead
* @date 06/06/2019
**/

@isTest
private class XC_UTIL_InsertNewLead_TEST {
    static testMethod void checkForInsertRollBackTEST(){
        Test.startTest();
        Lead l =  XC_DF_Lead.createResidentialLead();
        insert l;
        System.Savepoint beforeInsertSavepoint;
        XC_UTIL_Sobject.WrapperResult dmlResult = new XC_UTIL_Sobject.WrapperResult();
        dmlResult.errorMessage = 'errorMsg';
        dmlResult.errorfieldName= 'errorField';
        XC_LCC002_NewLead_W.RollBackWrapper rB 	   = XC_UTIL_InsertNewLead.checkForInsertRollBack(l,beforeInsertSavepoint);
        System.assert(rB != null);
        Test.stopTest(); 
    }
    
}