/**
* @author: Donato Lombardi
* @date Creation Date: 09/09/2019
* @description calculate WBS class TEST
*/
@isTest
public class XC_Encode_Base62_TEST {
    static testMethod void generateBase62_Test(){
        String check = XC_Encode_Base62.generateBase62(0,1);
        System.debug('Check'+check);        
        
        }
    static testMethod void generateBase62_Test1(){
        String check = XC_Encode_Base62.generateBase62(1,1);
        System.debug('Check'+check);        
        
        }
    static testMethod void generateBase62_Test2(){
        String check = XC_Encode_Base62.generateBase62(1,10);
        System.debug('Check'+check);        
        
        }
    

}