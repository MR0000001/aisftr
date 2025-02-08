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
public with sharing class ActionPlanTemplateDetailController {
	
	public ActionPlanTemplates		actionPlanTemplates	   { get; set; }
	public ActionPlanTemplate__c 	actionPlanTemplate	   { get; set; }
	public String           		actionPlanTemplateId   { get; set; }
	public Document                 actionPlanExportXMLDoc { get; set; }

	/**
     * Constructor
     * If we can obtain the Id from the page parameters then we search for that template and set the variable for that template.
     * If we can't obtain the Id from the page parameters then we create a new template and obtain from the controller.
     */
    public ActionPlanTemplateDetailController ( ApexPages.StandardController stdController ){
    	
        if( System.currentPageReference().getParameters().get( 'id' ) != null ){
        	
			this.actionPlanTemplateId 	= System.currentPageReference().getParameters().get( 'id' );
			this.actionPlanTemplate 	= [ select a.Id, a.Name,a.XC_LegalEntity__c, a.Description__c, a.SkipWeekends__c, a.SkipDay__c, a.LastModifiedDate, 
												a.LastModifiedBy.Name, a.LastModifiedById, a.CreatedDate, a.CreatedBy.Name, a.CreatedById, 
												a.Owner.Name from ActionPlanTemplate__c a
												Where a.Id =: this.actionPlanTemplateId limit 1 ];
		}
		else{
			this.actionPlanTemplate = ( ActionPlanTemplate__c ) stdController.getRecord();
		}
					
        this.actionPlanTemplates = new ActionPlanTemplates( this.actionPlanTemplate );
    }
	
	/**
	 * Call method deleteTemplate() insde the class ActionPlanTemplates
	 * @return PageReference
	 */
	public PageReference deleteTemplate(){
		return actionPlanTemplates.deleteTemplate();
	} 
	
	/**
	 * Call method getTemplateTasks() insde the class ActionPlanTemplates
	 * @return List<APTTaskTemplate__c>
	 */
	public List<APTTaskTemplate__c> getTemplateTasks(){
		return actionPlanTemplates.getTemplateTasks();
	}
	
	/**
	 * Call method getActionPlanTemplate() insde the class ActionPlanTemplates
	 * @return ActionPlanTemplate__c
	 */
	public ActionPlanTemplate__c getActionPlanTemplate() {
		return actionPlanTemplates.getActionPlanTemplate();
	}
	
	/**
	* Method exports the Action Plan template into a new XML document
	*/
	public void exportTemplateToXMLDoc(){
    	ExportActionPlanTemplate utility = new ExportActionPlanTemplate( this.actionPlanTemplateId );
    	
    	this.actionPlanExportXMLDoc = utility.export();
	}

}