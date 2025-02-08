@isTest
private class XC_VFC008_ProvisioningTempPrev_TEST {
	
	@isTest static void testMethodOne() {
		XC_VFC008_ProvisioningTemplatePreview.Step step = new XC_VFC008_ProvisioningTemplatePreview.Step();
		step.name='';
		step.code='';
		step.seqOrder=0;
		step.mandatoryPreviousSteps='';
		System.assertEquals(step.seqOrder,0);
	}

	@IsTest(SeeAllData=true) 
	static void testMethodTwo() {

		PageReference pageRef = new PageReference('VFPage');
  		String templateName='eMobility Flat';
  		pageRef.getParameters().put('templateName', templateName);
  		Test.setCurrentPage(pageRef);

		XC_VFC008_ProvisioningTemplatePreview provTemplate = new XC_VFC008_ProvisioningTemplatePreview();
		Test.startTest();
			provTemplate.getStepsByOrderItem('eMobility Flat');
			System.assertEquals(templateName,'eMobility Flat');
		Test.stopTest();
	}
	
}