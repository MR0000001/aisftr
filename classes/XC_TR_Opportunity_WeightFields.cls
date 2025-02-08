public with sharing class XC_TR_Opportunity_WeightFields {
    
    public static void changePipelineFields(List<Opportunity> oppToCheck,Map<Id,Opportunity> oldMap){
        List<Opportunity> listOppB2B = new List<Opportunity>();
        List<Opportunity> listStatusPermitting = new List<Opportunity>();
        List<Opportunity> listStatusCOD = new List<Opportunity>();
        List<Opportunity> listStatusLost = new List<Opportunity>();
        listOppB2B = retrieveLE(oppToCheck);
        System.debug('GS --->'  + listOppB2B);

        if(listOppB2B.isEmpty()){

            System.debug('GS lista  empty--->');
            return ;
        }
        List<Opportunity> listOppoStatus = new List<Opportunity>();

        listOppoStatus = retrieveStatus(listOppB2B,oldMap);
        if(!listOppoStatus.isEmpty()){
            updateWeight(listOppoStatus,oldMap);
            return;
        }
        listStatusPermitting = retrieveStatusPermitting(listOppB2B,oldMap);
        if(!listStatusPermitting.isEmpty()){
            updatePercentageWP(oppToCheck);
            return;
        }
        listStatusCOD= retrieveStatusCOD(listOppB2B,oldMap);
        if(!listStatusCOD.isEmpty()){
            updatePercentageWProcess(oppToCheck);
            return;
        }
        
        listStatusLost= weightToZero(listOppB2B, oldMap);
        if(!listStatusLost.isEmpty()){
            weightUpdate(oppToCheck,oldMap);
            return;
        }
        

    }   

    private static void updateWeight(List<Opportunity> oppToCheck,Map<Id,Opportunity> oldMap){
        for(Opportunity o: oppToCheck){
            if(oldMap.get(o.id).XC_WeighteCity__c!= null){
                    o.XC_WeighteCity__c = string.valueOf('100');
            }   
            else{
                o.XC_WeighteIndustry__c= string.valueOf('100');
             }
        }
    }

    

    private static List<Opportunity> retrieveLE(List<Opportunity> listOpp){
        List<Opportunity> listOppB2B = new List<Opportunity>();
        for(Opportunity o :listOpp){
            System.debug('GS --->' + o.XC_LegalEntity__c);
            //if((string.valueOf(o.XC_LegalEntity__c)=='EnelX') || (string.valueOf(o.XC_LegalEntity__c)=='Codensa') || (string.valueOf(o.XC_LegalEntity__c)=='EnelDistribucion')){
            if(o.XC_Segment__c != 'B2C'  ||  o.XC_SFMTechnicalField__c == 'SFM'){
                listOppB2B.add(o);
                System.debug('GS --->' + o.XC_LegalEntity__c);
            }
        }
        
    return listOppB2B;
    
    }

    private static List<Opportunity> retrieveStatus(List<Opportunity> listOpp,Map<Id,Opportunity> oldMap){
        List<Opportunity> listOppStatus = new List<Opportunity>();
        for(Opportunity o : listOpp){
            if(string.valueOf(o.XC_PipelineStatus__c)=='Signed Contract' && oldMap.get(o.id)!= null && oldMap.get(o.id).XC_PipelineStatus__c != 'Signed Contract'){
                listOppStatus.add(o);
           }
        }
        return listOppStatus;
    }

    private static List<Opportunity> weightToZero(List<Opportunity> listOpp, Map<Id,Opportunity>oldMap){
        List<Opportunity> listStatusLost = new List<Opportunity>();
        for(Opportunity o: listOpp){
           
               if((string.valueOf(o.XC_PipelineStatus__c)=='Abandoned' || string.valueOf(o.XC_PipelineStatus__c)=='Closed Lost') && oldMap.get(o.id)!= null && (oldMap.get(o.id).XC_PipelineStatus__c != 'Abandoned'||oldMap.get(o.id).XC_PipelineStatus__c != 'Closed Lost')){
                listStatusLost.add(o);
            }
        }
        return listStatusLost;
    }

    private static void weightUpdate (List<Opportunity> oppToCheck,Map<Id,Opportunity> oldMap){
        for(Opportunity o: oppToCheck){
            System.debug('GS Weight e-city old --> ' + oldMap.get(o.id).XC_WeighteCity__c);
            if(oldMap.get(o.id).XC_WeighteCity__c!= null){
                o.XC_WeighteCity__c= string.valueOf('0');
                System.debug('GS Weight e-city new--> ' + o.XC_WeighteCity__c );
            }
            else{
                o.XC_WeighteIndustry__c= string.valueOf('0');
                }
        }
    }
        
    

    private static List<Opportunity> retrieveStatusPermitting(List<Opportunity> listOpp,Map<Id,Opportunity> oldMap){
        List<Opportunity> listStatusPermitting = new List<Opportunity>();
        for(Opportunity o : listOpp){
            if(string.valueOf(o.XC_PipelineStatus__c)=='Permitting' && oldMap.get(o.id)!= null && oldMap.get(o.id).XC_PipelineStatus__c != 'Permitting'){
                listStatusPermitting.add(o);
           }
        }
        return listStatusPermitting;
    }

    private static List<Opportunity> retrieveStatusCOD(List<Opportunity> listOpp,Map<Id,Opportunity> oldMap){
        List<Opportunity> listStatusCOD = new List<Opportunity>();
        for(Opportunity o : listOpp){
            if(string.valueOf(o.XC_PipelineStatus__c)=='Commercial Operation Date' && oldMap.get(o.id)!= null && oldMap.get(o.id).XC_PipelineStatus__c != 'Commercial Operation Date'){
                listStatusCOD.add(o);
           }
        }
        return listStatusCOD;
    }

    private static void updatePercentageWP(List<Opportunity> oppToCheck){
        for(Opportunity o: oppToCheck){
            if(o.XC_BusinessLine__c == 'eCity'){
                    o.XC_PercentageWorkingProcess__c = 0;
            }      
        }
    }

    private static void updatePercentageWProcess(List<Opportunity> oppToCheck){
        for(Opportunity o: oppToCheck){
            if(o.XC_BusinessLine__c == 'eCity'){
                    o.XC_PercentageWorkingProcess__c = 100;
            }      
        }
    }

   public static void industrialKPIfield(List<Opportunity> oppToCheck){
        List<Opportunity> listOppB2B = new List<Opportunity>();
        listOppB2B = retrieveLE(oppToCheck);
        if(!listOppB2B.isEmpty()){
            for(Opportunity o:listOppB2B){
                if(o.XC_Lead__c == null){
             /*       if(o.XC_IndustrialKPI__c!='Work Contract' && o.XC_IndustrialKPIfullLife__c == null){
                        o.addError(Label.XC_CL_Opportunity_IndKPIfullLikeField);
                }*/
                
                    if(o.XC_IndustrialKPI__c=='Work Contract'){  
                    o.XC_IndustrialKPIfullLife__c =1;
                }
            }
            
        }
    }
}

public static void industrialKPIfieldUpdate(List<Opportunity> oppToCheck){
    List<Opportunity> listOppB2B = new List<Opportunity>();
    listOppB2B = retrieveLE(oppToCheck);
    if(!listOppB2B.isEmpty()){
        for(Opportunity o:listOppB2B){
             if(o.XC_Lead__c == null){
            /*    if(o.XC_IndustrialKPI__c!='Work Contract' && o.XC_IndustrialKPIfullLife__c == null){
                    o.addError(Label.XC_CL_Opportunity_IndKPIfullLikeField);
            }*/
            
                if(o.XC_IndustrialKPI__c=='Work Contract'){  
                o.XC_IndustrialKPIfullLife__c =1;
            }         
             }
    }
}
}
}