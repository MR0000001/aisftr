/**
 * The Class XC_LCC177_PaymentNotDone_TEST.
 *
 * @author Domenico Del Prete domenico.delprete@nttadata.com
 * @date Creation 05/03/2020 
 * @description XC_UTIL_Date_TEST – Test class for XC_UTIL_Date 
 */
@isTest
public without sharing class XC_UTIL_Date_TEST {

    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }

    @isTest
    static void saturdayDate (){
        Datetime dateToManage = Datetime.newInstance(2020, 03, 05, 2 , 30, 2);
        Integer numberHourToAdd = 48;
        Datetime workingDay= XC_UTIL_Date.addWorkingDays(dateToManage, numberHourToAdd);
        System.assertEquals(workingDay == null, false);
    }

    @isTest
    static void sundayDate (){
        Datetime dateToManage = Datetime.newInstance(2020, 03, 05, 2 , 30, 2);
        Integer numberHourToAdd = 72;
        Datetime workingDay= XC_UTIL_Date.addWorkingDays(dateToManage, numberHourToAdd);
        System.assertEquals(workingDay == null, false);
    }

    @isTest
    static void addNotWorkingDay (){
        Datetime dateToManage = Datetime.newInstance(2020, 03, 07, 2 , 30, 2);
        Integer numberHourToAdd = 48;
        Datetime workingDay= XC_UTIL_Date.addWorkingDays(dateToManage, numberHourToAdd);
        System.assertEquals(workingDay == null, false);
    }
}