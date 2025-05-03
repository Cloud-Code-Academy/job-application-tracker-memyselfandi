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
                List<Map<String, Object>> jobList = convertParsedJobsToObject(parsedJobs);
                System.debug('Passing Job List to saveJobsToSalesforce(jobList)');
                saveJobsToSalesforce(jobList);    // Save jobs to Salesforce
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
                String location = '';
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

    // Convert parsed jobs to the format expected by saveJobsToSalesforce (List<Map<String, Object>>)
    public static List<Map<String, Object>> convertParsedJobsToObject(List<Map<String, String>> parsedJobs) {
        List<Map<String, Object>> jobList = new List<Map<String, Object>>();

        for (Map<String, String> job : parsedJobs) {
            Map<String, Object> jobMap = new Map<String, Object>();

            jobMap.put('MatchedObjectId', job.get('MatchedObjectId'));
            jobMap.put('MatchedObjectDescriptor', new Map<String, Object>{
                'PositionTitle' => job.get('JobTitle'),
                'PositionURI' => job.get('PositionURI'),
                'OrganizationName' => job.get('OrganizationName'),
                'PositionLocation' => new List<Object>{
                    new Map<String, Object>{'LocationName' => job.get('Location')}
                },
                'PositionRemuneration' => new List<Object>{
                    new Map<String, Object>{'MinimumRange' => job.get('Salary')}
                }
            });

            jobList.add(jobMap);
        }

        return jobList;
    }

    // Method to save jobs to Salesforce
    public static void saveJobsToSalesforce(List<Map<String, Object>> jobList) {
        List<Job_Application__c> jobsToInsert = new List<Job_Application__c>();
        List<Account> accountsToInsert = new List<Account>();
        Map<String, Id> accountMap = new Map<String, Id>();
    
        // Step 1: Gather organization names from job list
        Set<String> organizationNames = new Set<String>();
        for (Map<String, Object> job : jobList) {
            Map<String, Object> descriptor = (Map<String, Object>) job.get('MatchedObjectDescriptor');
            String orgName = (String) descriptor.get('OrganizationName');
            if (orgName != null) {
                organizationNames.add(orgName);
            }
        }
    
        // Step 2: Query existing Accounts
        for (Account acc : [SELECT Id, Name FROM Account WHERE Name IN :organizationNames]) {
            accountMap.put(acc.Name, acc.Id);
        }
    
        // Step 3: Create missing Accounts
        for (String orgName : organizationNames) {
            if (!accountMap.containsKey(orgName)) {
                Account newAcc = new Account(Name = orgName);
                accountsToInsert.add(newAcc);
            }
        }
    
        // Step 4: Insert new Accounts and update accountMap
        if (!accountsToInsert.isEmpty()) {
            insert accountsToInsert;
            for (Account acc : accountsToInsert) {
                accountMap.put(acc.Name, acc.Id);
            }
        }
    
        // Step 5: Create Job_Application__c records
        for (Map<String, Object> job : jobList) {
            Map<String, Object> descriptor = (Map<String, Object>) job.get('MatchedObjectDescriptor');
            List<Object> positionRemunerationList = (List<Object>) descriptor.get('PositionRemuneration');
            Map<String, Object> salaryInfo = (positionRemunerationList != null && !positionRemunerationList.isEmpty())
                ? (Map<String, Object>) positionRemunerationList[0]
                : null;
    
            String orgName = (String) descriptor.get('OrganizationName');
            Id accountId = accountMap.get(orgName);
    
            Job_Application__c jobRecord = new Job_Application__c(
                Matched_Object_Id__c = (String) job.get('MatchedObjectId'),
                Position_Title__c = (String) descriptor.get('PositionTitle'),
                Job_URL__c = (String) descriptor.get('PositionURI'),
                Company_Name__c = accountId,
                Salary__c = salaryInfo != null && salaryInfo.get('MinimumRange') != null 
                    ? Decimal.valueOf((String) salaryInfo.get('MinimumRange')) 
                    : null
            );
    
            jobsToInsert.add(jobRecord);
        }
    
        // Step 6: Insert Job Application records
        if (!jobsToInsert.isEmpty()) {
            try {
                insert jobsToInsert;
            } catch (DmlException e) {
                System.debug('Error inserting job applications: ' + e.getMessage());
            }
        }
    }
    
    //For testing
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
}
