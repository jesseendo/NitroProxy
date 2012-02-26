trigger BUNCHBALL_Skill_Matrix on Skill_Matrix__c (after insert, after update) 
{
	BUNCHBALL_NitroServicesProxy.runCompare( trigger.newMap, trigger.oldMap, trigger.isInsert );
}