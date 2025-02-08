/**
* @author Emanuela Cacace ecacace@deloitte.it
* @date Creation  14/05/2019 
* @description XC_TR_Asset_U_CancelOpenSA_TEST – Test class for XC_TR_Asset_U_CancelOpenSA
*/ 
@isTest
public with sharing class XC_TR_Asset_U_CancelOpenSA_TEST {
    //Test method getServiceAppointmentToUpdate
    static testMethod void cancelOpenServiceAppointments(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Asset> a = XC_DF_Asset.createAssets(1);
        insert a;
        a[0].Status= Label.XC_CL_Asset_StatusInactive;
        update a; 
      
        Test.stopTest();
    }

}