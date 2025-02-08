@isTest
public class XC_JSON2Apex_Test {
    static testMethod void test(){
        String jsonStr = '[{"glBookEntryId":"12345","quantity":"2"},{"glBookEntryId":"123345","quantity":"4"}]';
        XC_JSON2Apex.parse(jsonStr); 
    }
}