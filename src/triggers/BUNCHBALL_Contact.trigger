trigger BUNCHBALL_Contact on Contact ( after insert, after update ) 
{
	BUNCHBALL_NitroServicesProxy.runCompare( trigger.newMap, trigger.oldMap , trigger.isInsert );   
}