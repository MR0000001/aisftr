/**
* @author Riccardo Cossu - riccardo.cossu@nttdata.com & Emanuela Cacace ecacace@deloitte.it
* @date Creation  08/05/2019 
* @description XC_LCC004_SendMailComponent_TEST – Test class for XC_LCC004_SendMailComponent
*/ 
@isTest
private class XC_LCC004_SendMailComponent_TEST {
    
    //Test method sendMailtoCustomer
    static testMethod void sendMailtoCustomer(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
       // String mapCustomerString1 = '';
        //String sendMail1 = XC_LCC004_SendMailComponent.sendMailtoCustomer(mapCustomerString1);
       // System.assertEquals('NO DATA', sendMail1);

        emailMessage emailToSend = new emailMessage();
        
        emailToSend.Subject = 'Subject';       
        emailToSend.FromAddress = 'test@test.it';
        emailToSend.BccAddress = 'test@test.it';
        emailToSend.ToAddress = 'test@test.it';
        emailToSend.TextBody = 'body';
        emailToSend.MessageDate = DateTime.now();
        insert emailToSend;         
        
        Map<String,Object> mapCustomer = new Map<String,Object>{
                'emailId' => emailToSend.Id,
                'to' => 'to',
                'fromMail' => 'fromMail',
                'bcc' =>'bcc',
                'subj' =>'subj',
                'body' =>'body',
                'retatedToId' =>'retatedToId'
                };
                    

        
        List<String> attachmentList = new List<String>();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        List<String> emailList = new List<String>(); 
        emailList.add(String.valueOf(emailToSend));
        message.setSenderDisplayName('servizio clienti');
        message.toAddresses = emailList;
        message.setReplyTo('xc_es_enelxsupport@t-2467zechvc9sok4i7jodeaaya9nhpz3qgruqjauavnwwueh6ll.1w-nu3eam.cs105.apex.sandbox.salesforce.com');
        message.optOutPolicy = 'FILTER';
        
        message.setEntityAttachments(attachmentList);
        message.subject = emailToSend.Subject +'-- Identificativo ;' +emailToSend.RelatedToId;
        message.setHtmlBody(emailToSend.TextBody);
        String mapCustomerString2 = JSON.serialize(mapCustomer);       
        String sendMail2 = XC_LCC004_SendMailComponent.sendMailtoCustomer(mapCustomerString2);
        //String result = XC_UTIL_OpportunityEmail.sendMail(emailToSend, attachmentList); 
        string resultsuccess  = 'KO';
        System.assertEquals(resultsuccess, sendMail2);
        Test.stopTest();
    } 
    
    //Test method insertEmailMessage 
    static testMethod void insertEmailMessage(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        Test.startTest();
        XC_LCC004_SendMailComponent.emailWrapper eWr = new XC_LCC004_SendMailComponent.emailWrapper();
        eWr.bcc = 'bcc';
        eWr.body = 'body';
        eWr.emailId = 'emailId';
        eWr.fromMail = 'fromMail';
        eWr.retatedToId = 'retatedToId';
        eWr.subj = 'subj';
        eWr.to = 'to';
    
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1,true);
        insert oppList;
        String relatedToObj = oppList[0].Id;
            
        
        emailMessage em = new emailMessage();
        em.Subject = null;
        em.FromAddress = 'test@test.it';
        em.CcAddress = 'test@test.it';
        em.BccAddress = 'test@test.it';
        em.ToAddress = null ;
        em.TextBody = 'TextBody';    
        em.RelatedToId= oppList[0].Id; 
        insert em;      
        String insertMail = XC_LCC004_SendMailComponent.insertEmailMessage(relatedToObj);
        System.debug('@@@@@@insertMail  ' + insertMail);
       
        System.assert(!String.isBlank(insertMail));
        Test.stopTest();
    }  
    
    //Test method insertEmailMessage2 
    static testMethod void insertEmailMessage2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        Test.startTest();
           
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1,true);
        insert oppList;
        String relatedToObj = oppList[0].Id;
        
        String insertMail = XC_LCC004_SendMailComponent.insertEmailMessage(relatedToObj);
        System.debug('@@@@@@insertMail  ' + insertMail);
       // String result= JSON.serialize(mail); 
        System.assert(!String.isBlank(insertMail));
        Test.stopTest(); 
        
    } 
    
    
}