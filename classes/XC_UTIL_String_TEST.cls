/**
* @author Luca Tedeschi ltedeschi@deloitte.it
* @date Creation  21/05/2019 
* @description XC_UTIL_String_TEST – Test class for XC_UTIL_String
*/
@istest
public class XC_UTIL_String_TEST{
    
    //Test Method stringsAreEqual
    @isTest
    static  void stringsAreEqual(){ 
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        Test.startTest(); 
        
        
        boolean equal = XC_UTIL_String.stringsAreEqual('test', 'test');
        
        System.assertEquals(true,equal);
        Test.stopTest();
        
    }
    
    //Test Method stringsAreEqual
    @isTest

    static  void stringsAreEqual2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        Test.startTest(); 
        
        
        boolean equal = XC_UTIL_String.stringsAreEqual( '', '');
        
        System.assertEquals(true,equal);
        Test.stopTest();
        
    }
    
    
    //Test Method stringsAreEqual
    @isTest

    static  void stringsAreEqual3(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        Test.startTest(); 
        
        
        boolean equal = XC_UTIL_String.stringsAreEqual( 'test', '');
        
        System.assertEquals(false,equal);
        Test.stopTest();
        
    }

    @isTest
    static void removeDiacriticsTest(){
        String s = 'ª';
        Test.startTest();
            XC_UTIL_String.removeDiacritics(s);
        Test.stopTest();
    }
   

}