/**
 * Created by LCONATO00 on 06/08/2020.
 */
@isTest
public with sharing class IAMTest {
    @isTest
    public static void createUserTest() {
        Test.startTest();
        String rawFile = EncodingUtil.base64Encode(Blob.valueof('cn=Salesforce,ou=Groups,dc=cdr,dc=it'));
        Map<String, String> attributes = new Map<String,String>();
        attributes.put('iv_codfis','CNTLNZ92E22H501R');
        attributes.put('iv_email','test@testIAM.com');
        attributes.put('iv_mobile','3345468719');
        attributes.put('iv_nome','Test');
        attributes.put('iv_cognome','Test');
        attributes.put('iv_nascita_nazione','Italia');
        AutocreatedRegHandler1588063275906 auto = new AutocreatedRegHandler1588063275906();
        auto.handleJit(true, new user(), null, null, null,
        null, attributes, rawFile);
        auto.createUser(null, null, null,
                null, attributes, rawFile);
        Test.stopTest();

    }

}