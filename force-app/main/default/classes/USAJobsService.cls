public class USAJobsService {
    // Static variable to store parsed job data for use across methods (or in tests)
    public static List<Map<String, String>> parsedJobs = new List<Map<String, String>>();

    // Main method to initiate an HTTP GET callout to the USAJOBS API
    public static void getJobs() {
        HttpRequest req = new HttpRequest();    // Create the request
        Http http = new Http();                // Create the HTTP client

        // Define the Named Credential endpoint (must be configured in Salesforce Setup)
        String endpoint = 'callout:USAJOBS_API/api/search?Keyword=developer&LocationName=Washington%2C%20DC&DatePosted=30&RemunerationMinimumAmount=80000&WhoMayApply=public&HiringPath=public&ResultsPerPage=5';
        req.setEndpoint(endpoint);
        req.setMethod('GET');                  // Set HTTP method to GET
        req.setHeader('Accept', 'application/json');  // Request JSON response

        try {
            HttpResponse res = http.send(req);   // Send the callout

            // Check if the response status is OK (200)
            if (res.getStatusCode() == 200) {
                parseJobData(res.getBody());     // Parse the JSON response
            } else {
                System.debug('Callout failed. Status code: ' + res.getStatusCode());
                System.debug('Response: ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());  // Log any errors
        }
    }

    // Helper method to parse the JSON response into a list of job records
    public static void parseJobData(String responseBody) {
        parsedJobs.clear();  // Clear any previous results
        Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        
        // Ensure SearchResult exists
        if (jsonResponse.containsKey('SearchResult')) {
            Map<String, Object> searchResult = (Map<String, Object>) jsonResponse.get('SearchResult');
            
            // Get list of job items
            List<Object> jobItems = (List<Object>) searchResult.get('SearchResultItems');
            
            for (Object item : jobItems) {
                Map<String, Object> jobWrapper = (Map<String, Object>) item;
                
                // Get MatchedObjectId and MatchedObjectDescriptor
                String matchedObjectId = (String) jobWrapper.get('MatchedObjectId');
                Map<String, Object> descriptor = (Map<String, Object>) jobWrapper.get('MatchedObjectDescriptor');
                
                // Get Position Title and other fields
                String positionTitle = (String) descriptor.get('PositionTitle');
                String positionURI = (String) descriptor.get('PositionURI');
                String organizationName = (String) descriptor.get('OrganizationName');
                
                // Get salary (handle if missing or null)
                Decimal minSalary = 0;
                if (descriptor.containsKey('PositionRemuneration')) {
                    List<Object> remunerationList = (List<Object>) descriptor.get('PositionRemuneration');
                    if (!remunerationList.isEmpty()) {
                        Map<String, Object> remuneration = (Map<String, Object>) remunerationList.get(0);
                        String minSalaryStr = (String) remuneration.get('MinimumRange');
                        minSalary = Decimal.valueOf(minSalaryStr);
                    }
                }
                
                // Get Location (assume first location in PositionLocation array for simplicity)
                String location = "";
                if (descriptor.containsKey('PositionLocation')) {
                    List<Object> locations = (List<Object>) descriptor.get('PositionLocation');
                    if (!locations.isEmpty()) {
                        Map<String, Object> firstLocation = (Map<String, Object>) locations.get(0);
                        location = (String) firstLocation.get('LocationName');
                    }
                }
    
                // Create jobInfo map
                Map<String, String> jobInfo = new Map<String, String>{
                    'MatchedObjectId' => matchedObjectId,
                    'JobTitle' => positionTitle,
                    'PositionURI' => positionURI,
                    'OrganizationName' => organizationName,
                    'Location' => location,
                    'Salary' => String.valueOf(minSalary)  // Convert salary to string if needed
                };
    
                parsedJobs.add(jobInfo);
            }
        } else {
            System.debug('No SearchResult key found in response.');
        }
    }
    
    public static void printRawResponse(String responseBody) {
        System.debug('--- Raw API Response ---');
        System.debug(responseBody);
    }
    

    public static void printJobInfo() {
        // Check if the parsedJobs list is empty
        if (parsedJobs.isEmpty()) {
            System.debug('No jobs to display.'); // Log message if no jobs found
            return; // Exit the method early
        }
    
        Integer index = 1; // Initialize a counter to track job number
    
        // Loop through each job map in the parsedJobs list
        for (Map<String, String> job : parsedJobs) {
            System.debug('--- Job ' + index + ' ---'); // Print a header for each job
    
            // Loop through each key in the job map
            for (String key : job.keySet()) {
                System.debug(key + ': ' + job.get(key)); // Print each key-value pair
            }
    
            index++; // Increment the job counter
        }
    }
    

    // Method to create or update Job Application records in Salesforce from parsed jobs
    public static void saveJobsToSalesforce() {
        List<Job_Application__c> jobRecords = new List<Job_Application__c>();

        // Loop through the parsed job maps and build Salesforce records
        for (Map<String, String> job : parsedJobs) {
            jobRecords.add(new Job_Application__c(
                Position_Title__c = job.get('JobTitle'),
                Company_Name__c = job.get('OrganizationName'),
                Location__c = job.get('LocationName'),
                Job_URL__c = job.get('PositionURI'),
                Hiring_Path__c = job.get('HiringPath'),
                Description__c = job.get('MajorDuties'),
                Matched_Object_Id__c = job.get('MatchedObjectId'),
                Salary__c = String.isNotBlank(job.get('MinimumRange')) ? Decimal.valueOf(job.get('MinimumRange')) : null
            ));
        }

        // Upsert records using the MatchedObjectId as an external ID to avoid duplicates
        upsert jobRecords Job_Application__c.Matched_Object_Id__c;
    }
}