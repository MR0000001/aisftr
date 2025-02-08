/**
 * Created by SNEKKANTI00 on 03/02/2021.
 */

@isTest
public with sharing class TestUtil {
    @isTest
    public static void utilTest() {
        String single = 'test';
        String multiplied = single.repeat(10000);
        Test.startTest();
        Util.abbreviateTo10k(single);
        Util.abbreviateTo10k(multiplied);
        Util.abbreviateToFieldLength(single, Case.Subject.getDescribe().getSObjectField());
        Test.stopTest();
    }
}