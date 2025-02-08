/**
* @author fmanni
* @date 21/01/2022 from CR2249 - Gestione date contrattuali
* @description classes.XC_TR_Contract_U_PopulateFromRootOi
*/


public without sharing class XC_TR_Contract_U_PopulateFromRootOi {

    public static Map<String, Date> populatefields(Id optyId){
            
        Datetime startDate;
        Datetime endDate;
        
        Date startD;
        Date endD;
       	
        Map<String, Date> dates = new Map<String, Date>();
        if(optyId != null){
            //[DeAv 14.02.2022 Fix to reduce query START]
            //List<NE__Order__c> oQuotes = [SELECT id FROM NE__Order__c WHERE RecordType.DeveloperName = 'Quote' AND NE__OptyId__c = : optyId];
            List<NE__Order__c> oQuotes = new List<NE__Order__c>();
            List<NE__Order__c> oOpty = new List<NE__Order__c>();
            List<NE__OrderItem__c> oiQuotes = new List<NE__OrderItem__c>();
            List<NE__OrderItem__c> oiOpty = new List<NE__OrderItem__c>();
            List<NE__Order__c> orderList = [SELECT id, RecordType.DeveloperName, (SELECT Id, NE__StartDate__c, NE__EndDate__c FROM NE__Order_Items__r) FROM NE__Order__c WHERE RecordType.DeveloperName IN ('Quote','Opty') AND NE__OptyId__c = : optyId];
            for(NE__Order__c ord : orderList){
                if('Quote'.equalsIgnoreCase(ord.RecordType.DeveloperName)){
                    oQuotes.add(ord);
                    oiQuotes.addAll(ord.NE__Order_Items__r);
                }else{
                    oOpty.add(ord);
                    oiOpty.addAll(ord.NE__Order_Items__r);
                }
            }
            
            if(!oQuotes.isEmpty()){
                //List<NE__OrderItem__c> oiQuotes = [SELECT id,NE__StartDate__c,NE__EndDate__c FROM NE__OrderItem__c WHERE NE__OrderId__c in : oQuotes];
                if(!oiQuotes.isEmpty()){
                    startDate = calculateStartDate(oiQuotes);
                    endDate = calculateEndDate(oiQuotes);
                    
                    System.debug('@@@@  StartDate: '+startDate);
                    System.debug('@@@@  EndDate: '+endDate);
                    if(startDate!=null){
                        startD = Date.newInstance(startDate.year(), startDate.month(), startDate.day());
                    }
                    
                    if(endDate!=null){
                        endD = Date.newInstance(endDate.year(), endDate.month(), endDate.day());
                    }
                    dates.put('Start',startD);
                    dates.put('End',endD);
                    
                }
            }else if(!oOpty.isEmpty()){ 
                //List<NE__Order__c> oOpty = [SELECT id FROM NE__Order__c WHERE RecordType.DeveloperName = 'Opty' AND NE__OptyId__c = : optyId];
                //if(!oOpty.isEmpty()){
                //List<NE__OrderItem__c> oiOpty = [SELECT id,NE__StartDate__c,NE__EndDate__c FROM NE__OrderItem__c WHERE NE__OrderId__c in : oOpty];
                if(!oiOpty.isEmpty()){
                    startDate = calculateStartDate(oiOpty);
                    endDate = calculateEndDate(oiOpty);
                    
                    System.debug('@@@@ StartDate: '+startDate);
                    if(startDate!=null){
                        startD = Date.newInstance(startDate.year(), startDate.month(), startDate.day());
                    }
                    System.debug('@@@@ EndDate: '+endDate);
                    if(endDate!=null){
                        endD = Date.newInstance(endDate.year(), endDate.month(), endDate.day());
                    }
                    
                    dates.put('Start',startD);
                    dates.put('End',endD);
                }
                //}                    
            }
            //[DeAv 14.02.2022 Fix to reduce query END]
        }
        return dates;
    }

    public static Datetime calculateStartDate(List<NE__OrderItem__c> ois){
        Datetime startDate;
        for(NE__OrderItem__c oi : ois){
            startDate=compareDateMinor(startDate,oi.NE__StartDate__c);
        }
        return startDate;
    }

    public static Datetime calculateEndDate(List<NE__OrderItem__c> ois){
        Datetime startDate;
        for(NE__OrderItem__c oi : ois){
            startDate=compareDateMajor(startDate,oi.NE__EndDate__c);
        }
        return startDate;
    }

    public static Datetime compareDateMinor(Datetime datetime1,Datetime datetime2){
            return datetime1 < datetime2 ? datetime1 : datetime2;
    }

    public static Datetime compareDateMajor(Datetime datetime1,Datetime datetime2){
            return datetime1 > datetime2 ? datetime1 : datetime2;
    }
}