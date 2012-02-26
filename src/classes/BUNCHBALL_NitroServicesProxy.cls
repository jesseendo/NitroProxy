public class BUNCHBALL_NitroServicesProxy
{
	
	public static final String ON_POPULATE = 'On_Populate__c';
	public static final String FALSE_TO_TRUE = 'False_to_True__c';
	public static final String FIELD_UPDATE = 'Field_Update__c';
	public static final String[] VALID_ACTIONS = new String[] { ON_POPULATE, FALSE_TO_TRUE, FIELD_UPDATE };
	

    /**
    * logAction directly wraps the NitroProxy class provided in the N4SF package
    *
    * @param actionName the name of the Nitro Action to log
    * @param onBehalfOf the Bunchball User Id you want to get credit for this action
    */
    private static void logAction( String actionName, String onBehalfOf )
    {	
    	// TODO: error handling/wrap calls
    	nitro.NitroAPICall apiCall = new nitro.NitroAPICall();
        apiCall.addLogAction(actionName, onBehalfOf);
        nitro.NitroProxy.logActions(apiCall.getActionList());
    }
    
	/**
	* runCompare is the main method in this class
	*
	* @param newMap
	* @param oldMap
	* @param objectName
	* @param isNewRecord
	*/
    public static void runCompare( Map<Id, SObject> newMap, Map<Id, SObject> oldMap, Boolean isNewRecord )
    {	
    	Map<String, Bunchball_Settings__c> fieldsToCompare = Bunchball_Settings__c.getAll();
    	
    	for( Id recordId : newMap.keySet() )
    	{
    		SObject newRecord = newMap.get(recordId);
    		
    		Schema.sObjectType targetType = newRecord.getSObjectType();
    		
    		SObject oldRecord = getOldRecord( targetType, isNewRecord, recordId, oldMap );
    		
    		for( String fieldName : fieldsToCompare.keySet() )
    		{
    			if(fieldsToCompare.get(fieldName).Object_Name__c.toUpperCase() == String.valueOf( targetType ) )
    				parseNitroActions( newRecord, oldRecord, fieldName, fieldsToCompare.get(fieldName) );
    		}
    	}

    }
    
    public static SObject getOldRecord( Schema.sObjectType targetType, Boolean isNewRecord, Id recordId, Map<Id, SObject> objectMap )
    {
    	if( isNewRecord )
    			return targetType.newSObject();
			else
    		 	return objectMap.get(recordId);
    }
    
    public static Map<String, Boolean> parseNitroActions( SObject newObject, SObject oldObject, String fieldName, Bunchball_Settings__c nitroActions )
    {
    	Map<String, Boolean> actionResults = new Map<String, Boolean>();
    	
    	if( !isEmpty( nitroActions, ON_POPULATE ) )
    	{
    		actionResults.put(ON_POPULATE, false);
    		if( onPopulate( newObject, oldObject, fieldName ) )
    		{
				logAction( (String)nitroActions.get( ON_POPULATE ), getRewardedUser( newObject, nitroActions ) );
				actionResults.put(ON_POPULATE, true);
    		}
    	}
    	if( !isEmpty( nitroActions, FALSE_TO_TRUE ) )
    	{
    		actionResults.put(FALSE_TO_TRUE, false);
    		if( falseToTrue( newObject, oldObject, fieldName ) )
    		{
    			logAction( (String)nitroActions.get( FALSE_TO_TRUE ), getRewardedUser( newObject, nitroActions ) );
    			actionResults.put(FALSE_TO_TRUE, true);
    		}
    	}
    	if( !isEmpty( nitroActions, FIELD_UPDATE ) )
    	{
    		actionResults.put(FIELD_UPDATE, false);
    		if( fieldUpdate( newObject, oldObject, fieldName ) )
    		{
    			logAction( (String)nitroActions.get( FIELD_UPDATE ), getRewardedUser( newObject, nitroActions ) );
    			actionResults.put(FIELD_UPDATE, true);
    		}
    	}
    	
    	return actionResults;
    }
    
    public static Boolean onPopulate( SObject newObject, SObject oldObject, String fieldName )
    {
    	if( !isEmpty( newObject, fieldName ) && isEmpty( oldObject, fieldName ) )
    		return true;
		else
			return false;
    }
    
    public static Boolean falseToTrue( SObject newObject, SObject oldObject, String fieldName )
    {
    	if( ( oldObject.get( fieldName ) == false || oldObject.get( fieldName ) == null ) 
    			&& newObject.get( fieldName ) == true )
    		return true;
		else
			return false;
    }
    
    public static Boolean fieldUpdate( SObject newObject, SObject oldObject, String fieldName )
    {
    	if( oldObject.get( fieldName ) != newObject.get( fieldName ) )
    		return true;
		else
			return false;
    }
    
    
    public static String getRewardedUser( SObject theObject, Bunchball_Settings__c settings )
    {
    	if( settings.Credit_Record_Owner__c )
    	{
	    	Id ownerId = (Id)theObject.get( 'OwnerId' );
	    	try
	    	{
	    		return [select UserName from User where Id = :ownerId].UserName;
	    	} 
	    	catch( Exception e )
	    	{
	    		// Temporary hack - what should we do in this case?
	    		return UserInfo.getUserName();
	    	}
    	}
    	else
    		return UserInfo.getUserName();
    }
    
    public static Boolean isEmpty( SObject theObject, String fieldName )
    {
    	if( theObject.get( fieldName ) == null || theObject.get( fieldName ) == '' )
    		return true;
		else
			return false;
    }
}