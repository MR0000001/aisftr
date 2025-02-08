/**
 * @File Name          : XC_TR_Task_U_VocalScriptSendEvent_TEST.cls
 * @Description        : 
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 22/5/2020, 11:38:06
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    22/5/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
**/
@isTest
public without sharing class XC_TR_Task_U_VocalScriptSendEvent_TEST {

    @isTest
    static void sendPlatformEventOnScriptCreation_TEST(){
        Task t = new Task(Subject= Label.XC_CL_LCP173_CongaActivitySubject.replace('+',' '),Description = 'TEST TASK');
        insert t;
        List<Task> taskList = new List<Task>{t};
        Test.startTest();
            XC_TR_Task_U_VocalScriptSendEvent.sendPlatformEventOnScriptCreation(taskList);
        Test.stopTest();
    }

}