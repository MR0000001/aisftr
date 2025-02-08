/**
 * @File Name          : XC_TR_Task_U_VocalScriptSendEvent.cls
 * @Description        : 
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 2/7/2020, 16:29:53
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    15/5/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
**/
public without sharing class XC_TR_Task_U_VocalScriptSendEvent {

    /**
    * @description check if a vocal script task has been created by conga and send an event to make the vocal script component show the text
    * @author Francesco Imperioli - fimperioli@deloitte.it | 15/5/2020 
    * @param listNew 
    * @return void 
    **/
    public static void sendPlatformEventOnScriptCreation(List<Task> listNew){

        List<XC_CTI_Call_Event__e> callScriptEvents = new List<XC_CTI_Call_Event__e>();
        for(Task t : listNew){
            if(String.isNotBlank(t.Subject) && t.Subject.equalsIgnoreCase(Label.XC_CL_LCP173_CongaActivitySubject.replace('+',' ')) && String.isNotBlank(t.Description)){
                XC_CTI_Call_Event__e scriptEvent = new XC_CTI_Call_Event__e(
                    XC_EventType__c = 'SCRIPT_GENERATED',
                    XC_ContextRecordId__c = t.WhatId,
                    XC_ContextUserId__c = UserInfo.getUserId(),
                    XC_ScriptTaskId__c = t.Id
                );
                callScriptEvents.add(scriptEvent);
            }
        }

        if(!callScriptEvents.isEmpty()){
            Eventbus.publish(callScriptEvents);
        }


    }


}