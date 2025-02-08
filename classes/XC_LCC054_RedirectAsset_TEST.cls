/**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @date Creation 15/05/2019
* @date Modification 15/05/2019 Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @description XC_LCC054_RedirectAsset_TEST
*/  
@isTest
public class XC_LCC054_RedirectAsset_TEST {

 /**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @description  Method to test getRecordTypeIdByName
*/
static testMethod void getRecordTypeIdByNameTest(){

    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
    	String s =  XC_LCC054_RedirectAsset.getRecordTypeIdByName('XC_ESP_Customer');
        System.assert(s!=null);
    Test.stopTest();
    
   
    }
}