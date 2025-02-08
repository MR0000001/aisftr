/**
* @author Valentina De Blasio - valentina.de.blasio@accenture.com
* @date Creation 04/05/2022
* @description XC_TR_GenericNotification-test generic class notification cr 729 
*/

@isTest
public class XC_TR_GenericNotification_Test {
    
    static testMethod void testEngagementDocument(){
        Test.startTest();
        String requestType='Documento di ingaggio';
        String accountName='test name';
        String signatureStatus='SignatureStatus';
        Set<String> OwnerId=new Set<String>();
        OwnerId.add('testo');
        String internalId='test';
        String targetId= Userinfo.getUserId();
        XC_TR_GenericNotification.notifyUsers(requestType,accountName,signatureStatus,OwnerId,internalId,targetId);
        Test.stopTest();
        
    } 
    static testMethod void testWorkRequest(){
        Test.startTest();
        String requestType='Sospensione';
        String accountName='test name';
        String signatureStatus='SignatureStatus';
        Set<String> OwnerId=new Set<String>();
        OwnerId.add('testo');
        String internalId='test';
        String targetId= Userinfo.getUserId();
        XC_TR_GenericNotification.notifyUsers(requestType,accountName,signatureStatus,OwnerId,internalId,targetId);
        Test.stopTest();
        
    }    

}