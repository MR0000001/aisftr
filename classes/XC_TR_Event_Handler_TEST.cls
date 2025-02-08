@isTest
public class XC_TR_Event_Handler_TEST {
	    @isTest
    static void insertTest() {
        List<Event> listZ = new List<Event>();
        Map<Id,Event> mapNew = new Map<id,Event>();
        XC_TR_Event_Handler zu = new XC_TR_Event_Handler();
        //zu.onAfterUpdate();
        zu.onBeforeInsert(listZ);
        zu.onBeforeUpdate(mapNew,mapNew);
        zu.onAfterInsert(mapNew);
        zu.onAfterUpdate(mapNew,mapNew);
        zu.onAfterDelete(mapNew);
        zu.onAfterUnDelete(mapNew);
        zu.onBeforeDelete(mapNew);
        zu.executedTrigger();
		//NA 07022021 to bring the Trigger in Prod
		  List<Event> listEvent = new List<Event>();
        Event ev = new Event();
        ev.XC_Status__c = 'In Progress';
        //ev.WhoId = l.id;
        ev.DurationInMinutes=60;
        ev.ActivityDateTime=system.now();
        listEvent.add(ev);
        insert listEvent;
    }
}