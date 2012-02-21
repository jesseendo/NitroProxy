public class BUNCHBALL_NitroServicesProxy
{
    private static void logAction( String actionName )
    {
        nitro.NitroAPICall apiCall = new nitro.NitroAPICall();
        apiCall.addLogAction(actionName);
        nitro.NitroProxy.logActions(apiCall.getActionList());
    }
    
    public static Boolean hasFieldBeenPopulated( SObject newObject, SObject oldObject, String fieldName, String nitroAction )
    {
    	if( newObject.get( fieldName ) != null && newObject.get( fieldName ) != '' )
    	{
    		if( oldObject.get( fieldName ) == null || oldObject.get( fieldName ) == '' || 
    						( oldObject.get( fieldName ) == false && newObject.get( fieldName ) == true )
    		)
    		{
    			logAction( nitroAction );
    			return true;
    		}
    	}
    	
    	return false;
    }
    
    public static void runCompare( Map<Id, SObject> newMap, Map<Id, SObject> oldMap, String objectName )
    {
    	Map<String, Bunchball_Settings__c> fieldsToCompare = Bunchball_Settings__c.getAll();
    	
    	for( Id recordId : newMap.keySet() )
    	{
    		SObject newRecord = newMap.get(recordId);
    		SObject oldRecord = oldMap.get(recordId);
    		
    		for( String fieldName : fieldsToCompare.keySet() )
    		{
    			if(fieldsToCompare.get(fieldName).Object_Name__c.toUpperCase() == objectName )
    				hasFieldBeenPopulated( newRecord, oldRecord, fieldName, fieldsToCompare.get(fieldName).Nitro_Action_Name__c );
    		}
    	}
    }
    
}