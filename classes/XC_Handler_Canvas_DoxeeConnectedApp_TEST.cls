/**
* @author Riccardo Cossu - riccardo.cossu@nttdata.com
* @date Creation  15/05/2019
* @description  Test Class XC_Handler_Canvas_DoxeeConnectedApp
*/ 
@isTest
private class XC_Handler_Canvas_DoxeeConnectedApp_TEST {
    static testMethod void excludeContextTypesTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        test.startTest(); 
        Map<String,String> appValues = new Map<String,String>();
		appValues.put(Canvas.Test.KEY_NAMESPACE,'alternateNamespace');
		appValues.put(Canvas.Test.KEY_VERSION,'3.0');

		Map<String,String> envValues = new Map<String,String>();
		envValues.put(Canvas.Test.KEY_DISPLAY_LOCATION,'Chatter');
		envValues.put(Canvas.Test.KEY_LOCATION_URL,'https://yourInstance.salesforce.com/_ui/core/chatter/ui/ChatterPage');
        envValues.put('rebilling','test');

		Canvas.RenderContext mock = Canvas.Test.mockRenderContext(appValues,envValues);
        Set<Canvas.ContextTypeEnum> res = new XC_Handler_Canvas_DoxeeConnectedApp().excludeContextTypes();
        new XC_Handler_Canvas_DoxeeConnectedApp().onRender(mock);
        System.assertEquals(false,!res.isEmpty());

        test.stopTest();

    }

}