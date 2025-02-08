/**
* @author: Roberta Cossiga - rcossiga@deloitte.it & Marco Rosa - marco.rosa@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date: Creation: 10/09/2019
* @date Modification:
* @description XC_TR_ServiceAppointment_U_FillCoverage - Util class to populate the Coverage (Zip Code Work Type) on Service Appointment
*/
@isTest
public class XC_TR_ServApp_U_FillCoverage_TEST {
	@TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        org.XC_Spain_ValidationRules__c =  true;
        insert org;
    }
    
    static testMethod void populateZipCodeWorkTypeTest(){
        insert XC_DF_ServiceAppointment.createServiceAppointment(1);
        List<ServiceAppointment> saToUpdate = new List<ServiceAppointment>();
        List<ServiceAppointment> saList = [SELECT Id FROM ServiceAppointment];
        Test.startTest();
        for(ServiceAppointment sa : saList){
            sa.PostalCode = '28080';
            saToUpdate.add(sa);
        }
        update saToUpdate;
        List<ServiceAppointment> listSaUpdated = [SELECT Id FROM ServiceAppointment];
        System.assertEquals(1, listSaUpdated.size());
        Test.stopTest();
    }
}