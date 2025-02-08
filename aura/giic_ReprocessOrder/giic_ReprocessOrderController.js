/*
  @author GLOVIA Team
  @date Mod 06/09/2021 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
  @description	giic_ReprocessOrderController - Controller Javascript
*/

({
	doInit : function(component, event, helper) {
		console.log('|-_-| In giic_ReprocessOrder');
		helper.reprocessSO(component, event, helper);
	}
})