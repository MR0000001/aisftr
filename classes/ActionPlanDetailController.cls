/*
Action Plans v3
Force.com Labs
http://appexchange.salesforce.com/listingDetail?listingId=a0N30000003HcINEA0

Copyright (c) 2011, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, 
    this list of conditions and the following disclaimer in the documentation 
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors 
    may be used to endorse or promote products derived from this software 
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
OF THE POSSIBILITY OF SUCH DAMAGE.

*/
public with sharing class ActionPlanDetailController{
    
    public ActionPlan__c            actionPlan      { get; set; }
    public ActionPlansUtilities     actionPlanUtil  { get; set; }
    public String                   actionPlanId    { get; set; }
    
    /**
    * Constructor
    */
    public ActionPlanDetailController( ApexPages.StandardController stdController ){
        
        this.actionPlan = ( ActionPlan__c ) stdController.getRecord();
        
        if( System.currentPageReference().getParameters().get( 'id' ) != null ){
            this.actionPlanId = System.currentPageReference().getParameters().get( 'id' );
            
             //Add your Custom object in the SOQL Query
            this.actionPlan = [ select a.Id, a.Name, a.CreatedById, a.StartDate__c, a.Action_Plan_Template__r.Name, 
                                    a.Action_Plan_Template__r.Id, a.Action_Plan_Template__c, a.Account__c, a.Contact__c, 
                                    a.Lead__c, a.Opportunity__c,  a.Contract__c, a.Case__c, a.Campaign__c ,
                                    a.SkipWeekends__c, a.SkipDay__c, a.Owner.Name, 
                                    a.CreatedDate, a.LastModifiedById, a.LastModifiedDate
                                    from ActionPlan__c a  
                                    Where a.Id =: this.actionPLanId limit 1 ];
        }
        
        this.actionPlanUtil = new ActionPlansUtilities( this.actionPlan );
    }
    
    /**
    * Deletes current actionplan
    */
    public Pagereference deletePlan(){
        
        return this.actionPlanUtil.deletePlan();
    }
    
    /**
    * Gets all tasks for a given ActionPlan
    */
    public List<APTaskTemplate__c> getTasks(){
        
        return this.actionPlanUtil.getTasks();
    }
    
    /**
    * Retrieves size of APT Template Tasks List.
    * @return apTasks
    */
    public Integer getTaskSize(){
        
        return this.actionPlanUtil.getTaskSize(); 
    }
    
    /**
    * Returns number of completed tasks
    */
    public Integer getCompleted(){
        
        return this.actionPlanUtil.getCompleted();
    }
    
    /**
    * Checks if Action Plan Template has been changed since the creation of the Action Plan.
    * @return Boolean
    */
    public Boolean getVersion(){
        
        return this.actionPlanUtil.getVersion();
    }
    
    public String getRelatedObjectName(){
        
        String objName='';
        
        if( this.actionPlan.Account__c != null ){
            Account a = [select Name from Account where id =: this.actionPlan.Account__c limit 1]; 
            objName = a.Name;   
        }
        else if( this.actionPlan.Campaign__c != null ){
            Campaign c = [select Name from Campaign where id =: this.actionPlan.Campaign__c limit 1];
            objName = c.Name;
        }
        else if( this.actionPlan.Case__c != null ){
            Case c = [select Subject, CaseNumber from Case where id =: this.actionPlan.Case__c limit 1];
            objName = (c.Subject != null) ?  c.CaseNumber + ': ' + c.Subject : c.CaseNumber; 
        }
        else if( this.actionPlan.Contact__c != null ){
            Contact c = [select FirstName, LastName from Contact where id =: this.actionPlan.Contact__c limit 1];
            objName = (c.FirstName != null) ? c.FirstName + ' ' + c.LastName : c.LastName;
        }
        else if( this.actionPlan.Contract__c != null ){
            Contract c = [select ContractNumber from Contract where id =: this.actionPlan.Contract__c limit 1];
            objName = 'Contract Number :'+ c.ContractNumber;
        }
        else if( this.actionPlan.Lead__c != null ){
            Lead l = [select FirstName, LastName, Company from Lead where id =: this.actionPlan.Lead__c limit 1];
            objName = (l.FirstName != null) ? l.FirstName + ' ' + l.LastName + ', ' + l.Company : l.LastName + ', ' + l.Company;
        }
        else if( this.actionPlan.Opportunity__c != null ){
            Opportunity o = [select Name from Opportunity where id =: this.actionPlan.Opportunity__c limit 1];
            objName = o.Name;
        }
        
        return objName;
    }
    
    public String getCreatedBy(){
        
        User u = [select Name from User where id =: actionPlan.CreatedById limit 1];
        return u.Name;
    }

    public String getLastModifiedBy(){
    
        User u = [select Name from User where id =: actionPlan.LastModifiedById limit 1];
        return u.Name;
    }

}