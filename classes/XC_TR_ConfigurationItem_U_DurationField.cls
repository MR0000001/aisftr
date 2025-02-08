/**
 * Created by dolombardi on 06/07/2021.
 */

public with sharing class XC_TR_ConfigurationItem_U_DurationField {
    public static void updateActionB2W(Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> mapNew){
        List<String> fieldsToCheck = new List<String>{'XC_Billing_Period_Recurring__c','XC_Effective_Start_Date_Recurring__c'};
        List<NE__OrderItem__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldsToCheck,mapOld,mapNew);
        List<NE__OrderItem__c> listChangedB2B = new List<NE__OrderItem__c>();
        for(NE__OrderItem__c ne : listChanged){
            if(ne.XC_Segment__c != 'B2C'){
                listChangedB2B.add(ne);
            }
        }
        if(listChangedB2B.isEmpty()){
            return;
        }
        for(NE__OrderItem__c ne : listChangedB2B){
            if(mapNew.get(ne.id)!= null){
                // * @ Mod CV CR.NR2044 @date 13/10/2021 @Description Set action to if Configuration item is an Adjustment Start -->
                // mapNew.get(ne.id).NE__Action__c = 'Change';
                mapNew.get(ne.id).NE__Action__c = (mapNew.get(ne.id).NE__ProdName__c == Label.XC_CL_AdjustmentProdName) ? 'Add' : 'Change';
                // * @ Mod CV CR.NR2044 @date 13/10/2021 @Description Update field XC_RecurringDuration__c when  XC_Billing_Period_Recurring__c is updated
                if(mapNew.get(ne.id).XC_Billing_Period_Recurring__c != null ){
                   mapNew.get(ne.id).XC_RecurringDuration__c = mapNew.get(ne.id).XC_Billing_Period_Recurring__c;
                }
                //<--End
            }
        }
    }

// @ Mod CV CR.NR @date 29/10/2021 add XC_Zone__c to quey Start-->
      public static void updateEndDate(Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> mapNew){
        List<String> fieldsToCheck = new List<String>{'NE__StartDate__c'};
        List<NE__OrderItem__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldsToCheck,mapOld,mapNew);
        List<NE__OrderItem__c> listChangedB2B = new List<NE__OrderItem__c>();
        for(NE__OrderItem__c ne : listChanged){
            if(ne.XC_Segment__c != 'B2C'){
                listChangedB2B.add(ne);
            }
        }
        if(listChangedB2B.isEmpty()){
            return;
        }
        for(NE__OrderItem__c ne : listChangedB2B){
            if(mapNew.get(ne.id)!= null && (mapNew.get(ne.id).XC_RecurringDuration__c != null && mapNew.get(ne.id).NE__StartDate__c != null)){
                Integer monthToAdd = getRecurringNumberOfMonths(mapNew.get(ne.id).XC_RecurringPeriodType__c)*Integer.valueOf(mapNew.get(ne.id).XC_RecurringDuration__c);
                mapNew.get(ne.id).NE__EndDate__c = mapNew.get(ne.id).NE__StartDate__c.addMonths(monthToAdd);
            }
        }
    }

  public static Integer getRecurringNumberOfMonths(String period){
        switch on period {
            when 'Monthly' {
                return 1;
            } when 'Annual' {
                return 12;
            } when 'Bi-Monthly' {
                return 2;
            } when 'Four-Monthly' {
                return 4;
            } when 'Biennial' {
                return 24;
            }when 'Biannual' {
                return 6;
            }when 'Quarter' {
                return 3;
            } when else{
                return 1;
            }
        }
    }
    
    //CR2249 - Gestione date contrattuali - federico.manni@accenture.com R1 2022
    public static void setRecurringDurationFromDate(Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> mapNew){
        List<String> fieldsToCheck = new List<String>{'NE__StartDate__c', 'NE__EndDate__c'};
        List<NE__OrderItem__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldsToCheck,mapOld,mapNew);

        List<NE__OrderItem__c> listToChange = new List<NE__OrderItem__c>();
        List<Id> consToFound = new List<Id>();
        List<Contract> contracts = new List<Contract>();
        List<Id> orders = new List<Id>();
        List<Id> ordList = new List<Id>(); 

        for(NE__OrderItem__c ne : listChanged){
            ordList.add(ne.NE__OrderId__c);
            if(ne.NE__Parent_Order_Item__c == null && ne.XC_ParentCommercialItem__c == null){
                listToChange.add(ne);
            }
        }
        if(listToChange.isEmpty()){
            return;
        }
        //[Deav 15.02.2022 INC000081657236 START]
        List<NE__OrderItem__c> allChilds = [SELECT id, NE__StartDate__c, NE__EndDate__c, NE__Parent_Order_Item__c, XC_ParentCommercialItem__c, XC_RecurringDuration__c, NE__OrderId__c, NE__OrderId__r.NE__OptyId__c, NE__OrderId__r.RecordType.DeveloperName, NE__OrderId__r.NE__OptyId__r.XC_Segment__c 
                                            FROM NE__OrderItem__c 
                                            WHERE NE__OrderId__c in : ordList]; //Deav
        List<NE__OrderItem__c> childs = new List<NE__OrderItem__c>();
        List<NE__OrderItem__c> roots = new List<NE__OrderItem__c>();
        for(NE__OrderItem__c oi : allChilds){
            for(NE__OrderItem__c oiltc : listToChange){
                if(oi.NE__Parent_Order_Item__c == oiltc.Id){
                    childs.add(oi);
                }else if(oi.NE__Parent_Order_Item__c == null && oi.XC_ParentCommercialItem__c == null && 'Order'.equalsIgnoreCase(oi.NE__OrderId__r.RecordType.DeveloperName)){
                    roots.add(oi);
                }
            }
        }
        //[Deav 15.02.2022 INC000081657236 END]
        System.debug('@@@@ childs: '+childs);
        List<Id> idsOpty = new List<Id>();
        for(NE__OrderItem__c ne : listToChange){
            Integer recurringDuration = addRecurringPeriod(ne);
            //ne.XC_RecurringDuration__c = recurringDuration;
            for(NE__OrderItem__c child : childs){
                //[Deav 15.02.2022 INC000081657236 START]
                if('B2C'.equalsIgnoreCase(child.NE__OrderId__r.NE__OptyId__r.XC_Segment__c)){
                    continue;
                }
                if(child.NE__Parent_Order_Item__c == ne.id){
                    child.NE__StartDate__c = ne.NE__StartDate__c;
                    child.NE__EndDate__c = ne.NE__EndDate__c;
                    child.XC_RecurringDuration__c = recurringDuration;
                }
                if('Order'.equalsIgnoreCase(child.NE__OrderId__r.RecordType.DeveloperName)){
                    idsOpty.add(child.NE__OrderId__r.NE__OptyId__c);

                }
                //[Deav 15.02.2022 INC000081657236 END]
            }          
        }

        if(!childs.isEmpty()){
            XC_UTIL_SObject.updateListRecords(childs);
        }
        
        System.debug('@@@@ Lista Opportunity: '+idsOpty);
        if(!idsOpty.isEmpty()){ //[Deav 15.02.2022 INC000081657236]
            contracts = [SELECT id,StartDate,EndDate,Opportunity__c FROM Contract WHERE Opportunity__c in : idsOpty];
            System.debug('@@@@ Lista Contratti: '+contracts);
        }
        Datetime startD;
        Datetime endD;
        if(!contracts.isEmpty()){
            for(Contract cont : contracts){
                for(NE__OrderItem__c ne : roots){
                    if(ne.NE__StartDate__c!=null){
                        startD = startD < ne.NE__StartDate__c ? startD : ne.NE__StartDate__c;
                    }
                    if(ne.NE__EndDate__c!=null){
                        endD = endD > ne.NE__EndDate__c ? endD : ne.NE__EndDate__c;
                    }
                    //cont.StartDate = (cont.StartDate != null && cont.StartDate < Date.newInstance(ne.NE__StartDate__c.year(), ne.NE__StartDate__c.month(), ne.NE__StartDate__c.day())) ? cont.StartDate : Date.newInstance(ne.NE__StartDate__c.year(), ne.NE__StartDate__c.month(), ne.NE__StartDate__c.day());
                    //cont.EndDate = (cont.EndDate != null && cont.EndDate > Date.newInstance(ne.NE__EndDate__c.year(), ne.NE__EndDate__c.month(), ne.NE__EndDate__c.day())) ? cont.EndDate : Date.newInstance(ne.NE__EndDate__c.year(), ne.NE__EndDate__c.month(), ne.NE__EndDate__c.day());
                    //cont.StartDate = Date.newInstance(ne.NE__StartDate__c.year(), ne.NE__StartDate__c.month(), ne.NE__StartDate__c.day());
                    //cont.EndDate = Date.newInstance(ne.NE__EndDate__c.year(), ne.NE__EndDate__c.month(), ne.NE__EndDate__c.day());
                    if(startD!=null){
                    	cont.StartDate = Date.newInstance(startD.year(), startD.month(), startD.day());
                    }
                    if(endD!=null){
                    	cont.EndDate = Date.newInstance(endD.year(), endD.month(), endD.day());
                    }
                }
            }
            XC_UTIL_SObject.updateListRecords(contracts);
        }
    }

    //CR2249 - Gestione date contrattuali - federico.manni@accenture.com R1 2022
    public static Integer addRecurringPeriod(NE__OrderItem__c oi){
        Integer duration = 0;
        
        if(oi.NE__StartDate__c != null && oi.NE__EndDate__c != null && oi.NE__RecurringChargeFrequency__c != null){
            Date startDate = Date.newInstance(oi.NE__StartDate__c.year(), oi.NE__StartDate__c.month(), oi.NE__StartDate__c.day());
            Date endDate = Date.newInstance(oi.NE__EndDate__c.year(), oi.NE__EndDate__c.month(), oi.NE__EndDate__c.day());
            String period = oi.NE__RecurringChargeFrequency__c;
			// START-CR2249 - Gestione date contrattuali - valentina.de.blasio@accenture.com R1 2022-02-10
			if(period!=null && (period.equalsIgnoreCase('Monthly') || period.equalsIgnoreCase('Bi-Monthly')|| period.equalsIgnoreCase('Four-Monthly') || period.equalsIgnoreCase('Quarter') || period.equalsIgnoreCase('Biannual') || period.equalsIgnoreCase('Quarterly') || period.equalsIgnoreCase('Semiannual'))){
                Integer add = 1;
                duration = (startDate.monthsBetween(Date.valueOf(endDate)) / getRecurringNumberOfMonths('Monthly')) + add;
            }
            
            if(period!=null && (period.equalsIgnoreCase('Biennial') || period.equalsIgnoreCase('Annual'))){
                duration = (startDate.monthsBetween(Date.valueOf(endDate)) / getRecurringNumberOfMonths('Annual'));
            }    
        }
       	 //END-CR2249 - Gestione date contrattuali - valentina.de.blasio@accenture.com R1 2022-02-10
        return duration;
    }
    
    public static void setRecurringDurationRoot(Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> mapNew){
        
        List<String> fieldsToCheck = new List<String>{'NE__StartDate__c', 'NE__EndDate__c'};
        List<NE__OrderItem__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldsToCheck,mapOld,mapNew);

        List<NE__OrderItem__c> listToChange = new List<NE__OrderItem__c>();
        
        for(NE__OrderItem__c ne : listChanged){
            if(ne.NE__Parent_Order_Item__c == null && ne.XC_ParentCommercialItem__c == null){
                listToChange.add(ne);
            }
        }
        if(listToChange.isEmpty()){
            return;
        }
        for(NE__OrderItem__c ne : listToChange){
            ne.XC_RecurringDuration__c = addRecurringPeriod(ne);
        }
	}

//<--End
}