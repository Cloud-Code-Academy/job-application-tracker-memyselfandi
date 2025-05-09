public class USAJobsService {
    // Static variable to store parsed job data for use across methods (or in tests)
    public static List<Map<String, String>> parsedJobs = new List<Map<String, String>>();

    // Main method to initiate an HTTP GET callout to the USAJOBS API
    public static void getJobs() {
        System.debug('Fetching jobs from USAJOBS API...');

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
                List<Map<String, Object>> jobList = convertParsedJobsToObject();

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
    public static void parseJobData(String responseBody) {
        parsedJobs.clear();  // Clear existing job records
    
        Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
    
        if (jsonResponse.containsKey('SearchResult')) {
            Map<String, Object> searchResult = (Map<String, Object>) jsonResponse.get('SearchResult');
            List<Object> jobItems = (List<Object>) searchResult.get('SearchResultItems');
    
            for (Object item : jobItems) {
                Map<String, Object> jobWrapper = (Map<String, Object>) item;
                String matchedObjectId = (String) jobWrapper.get('MatchedObjectId');
                Map<String, Object> descriptor = (Map<String, Object>) jobWrapper.get('MatchedObjectDescriptor');
    
                String positionTitle = (String) descriptor.get('PositionTitle');
                String positionURI = (String) descriptor.get('PositionURI');
                String organizationName = (String) descriptor.get('OrganizationName');
    
                String majorDuties = '';
                if (descriptor.containsKey('UserArea')) {
                    Object userAreaObj = descriptor.get('UserArea');
                    if (userAreaObj instanceof Map<String, Object>) {
                        Map<String, Object> userArea = (Map<String, Object>) userAreaObj;
                        if (userArea.containsKey('Details')) {
                            Object detailsObj = userArea.get('Details');
                            if (detailsObj instanceof Map<String, Object>) {
                                Map<String, Object> details = (Map<String, Object>) detailsObj;
                                if (details.containsKey('MajorDuties')) {
                                    Object dutiesObj = details.get('MajorDuties');
                                    if (dutiesObj instanceof String) {
                                        majorDuties = (String) dutiesObj;  // When it's a single string
                                    } else if (dutiesObj instanceof List<Object>) {
                                        // Join list items with newline or semicolon
                                        List<Object> dutiesList = (List<Object>) dutiesObj;
                                        List<String> dutyStrings = new List<String>();
                                        for (Object duty : dutiesList) {
                                            dutyStrings.add(String.valueOf(duty));
                                        }
                                        majorDuties = String.join(dutyStrings, '\n');  // or use '; ' if preferred
                                    } else {
                                        majorDuties = 'N/A';  // Fallback for unexpected type
                                    }
                                }
                            }
                        }
                    }
                }
    
                Decimal minSalary = 0;
                if (descriptor.containsKey('PositionRemuneration')) {
                    List<Object> remunerationList = (List<Object>) descriptor.get('PositionRemuneration');
                    if (!remunerationList.isEmpty()) {
                        Map<String, Object> remuneration = (Map<String, Object>) remunerationList.get(0);
                        String minSalaryStr = (String) remuneration.get('MinimumRange');
                        minSalary = Decimal.valueOf(minSalaryStr);
                    }
                }
    
                String location = '';
                if (descriptor.containsKey('PositionLocation')) {
                    List<Object> locations = (List<Object>) descriptor.get('PositionLocation');
                    if (!locations.isEmpty()) {
                        Map<String, Object> firstLocation = (Map<String, Object>) locations.get(0);
                        location = (String) firstLocation.get('LocationName');
                    }
                }
    
                Map<String, String> jobInfo = new Map<String, String>{
                    'MatchedObjectId' => matchedObjectId,
                    'JobTitle' => positionTitle,
                    'PositionURI' => positionURI,
                    'OrganizationName' => organizationName,
                    'Location' => location,
                    'Salary' => String.valueOf(minSalary),
                    'Description' => majorDuties
                };
    
                parsedJobs.add(jobInfo);
            }
        } else {
            System.debug('No SearchResult key found in response.');
        }
    }  

    // Convert parsed jobs to the format expected by saveJobsToSalesforce (List<Map<String, Object>>)
    public static List<Map<String, Object>> convertParsedJobsToObject() {
        List<Map<String, Object>> jobList = new List<Map<String, Object>>();
    
        for (Map<String, String> job : parsedJobs) {
            Map<String, Object> descriptor = new Map<String, Object>();
            descriptor.put('PositionTitle', job.get('JobTitle'));
            descriptor.put('PositionURI', job.get('PositionURI'));
            descriptor.put('OrganizationName', job.get('OrganizationName'));
    
            // Add PositionRemuneration if Salary is present
            if (job.containsKey('Salary')) {
                Map<String, Object> remuneration = new Map<String, Object>{
                    'MinimumRange' => job.get('Salary')
                };
                descriptor.put('PositionRemuneration', new List<Object>{ remuneration });
            }
    
            // Add PositionLocation if Location is present
            if (job.containsKey('Location')) {
                Map<String, Object> location = new Map<String, Object>{
                    'LocationName' => job.get('Location')
                };
                descriptor.put('PositionLocation', new List<Object>{ location });
            }
    
            // Add Description if present (under UserArea -> Details -> MajorDuties)
            if (job.containsKey('Description')) {
                Map<String, Object> userArea = new Map<String, Object>{
                    'Details' => new Map<String, Object>{
                        'MajorDuties' => job.get('Description')
                    }
                };
                descriptor.put('UserArea', userArea);
            }
    
            Map<String, Object> jobObj = new Map<String, Object>{
                'MatchedObjectId' => job.get('MatchedObjectId'),
                'MatchedObjectDescriptor' => descriptor
            };
    
            jobList.add(jobObj);
        }
    
        return jobList;
    }      
    

    // Method to save jobs to Salesforce
    public static void saveJobsToSalesforce(List<Map<String, Object>> jobList) {
        List<Job_Application__c> jobsToInsert = new List<Job_Application__c>();
        Map<String, Account> newAccountsToInsert = new Map<String, Account>();
        Set<String> organizationNames = new Set<String>();
        Set<String> matchedIds = new Set<String>();
    
        // First, gather all organization names and matched IDs from the job list
        for (Map<String, Object> job : jobList) {
            matchedIds.add((String) job.get('MatchedObjectId'));
    
            Map<String, Object> descriptor = (Map<String, Object>) job.get('MatchedObjectDescriptor');
            String orgName = (String) descriptor.get('OrganizationName');
            if (orgName != null) {
                organizationNames.add(orgName);
            }
        }
    
        // Query existing Account records by name to avoid duplicates
        Map<String, Account> accountMap = new Map<String, Account>();
        for (Account acc : [SELECT Id, Name FROM Account WHERE Name IN :organizationNames]) {
            accountMap.put(acc.Name, acc);
        }
    
        // Query existing Job Applications by Matched_Object_Id__c to prevent duplicates
        Set<String> existingMatchedIds = new Set<String>();
        for (Job_Application__c existing : [
            SELECT Id, Matched_Object_Id__c 
            FROM Job_Application__c 
            WHERE Matched_Object_Id__c IN :matchedIds
        ]) {
            existingMatchedIds.add(existing.Matched_Object_Id__c);
        }
    
        // Loop through jobs to create Job Application records
        for (Map<String, Object> job : jobList) {
            String matchedObjectId = (String) job.get('MatchedObjectId');
    
            // Skip if this job was already inserted previously
            if (existingMatchedIds.contains(matchedObjectId)) {
                continue;
            }
    
            Map<String, Object> descriptor = (Map<String, Object>) job.get('MatchedObjectDescriptor');
            String orgName = (String) descriptor.get('OrganizationName');
            if (orgName == null) continue;
    
            // Get or prepare to insert Account
            Id accountId;
            if (accountMap.containsKey(orgName)) {
                accountId = accountMap.get(orgName).Id;
            } else {
                if (!newAccountsToInsert.containsKey(orgName)) {
                    Account newAcc = new Account(Name = orgName);
                    newAccountsToInsert.put(orgName, newAcc);
                }
            }
    
            // Extract salary safely
            Decimal salary;
            if (descriptor.containsKey('PositionRemuneration')) {
                List<Object> remunerationList = (List<Object>) descriptor.get('PositionRemuneration');
                if (!remunerationList.isEmpty()) {
                    Map<String, Object> salaryInfo = (Map<String, Object>) remunerationList[0];
                    if (salaryInfo.containsKey('MinimumRange')) {
                        String minSalaryStr = (String) salaryInfo.get('MinimumRange');
                        try {
                            salary = Decimal.valueOf(minSalaryStr);
                        } catch (Exception fe) {
                            salary = null; // Set to null if not convertible
                        }
                    }
                }
            }
    
            // Extract description safely (handle both String and List<Object>)
            String description = '';
            if (descriptor.containsKey('UserArea')) {
                Map<String, Object> userArea = (Map<String, Object>) descriptor.get('UserArea');
                if (userArea.containsKey('Details')) {
                    Map<String, Object> details = (Map<String, Object>) userArea.get('Details');
                    if (details.containsKey('MajorDuties')) {
                        Object dutiesObj = details.get('MajorDuties');
    
                        if (dutiesObj instanceof String) {
                            // Case: Single string
                            description = (String) dutiesObj;
                        } else if (dutiesObj instanceof List<Object>) {
                            // Case: List of duties
                            List<Object> dutiesList = (List<Object>) dutiesObj;
                            List<String> duties = new List<String>();
                            for (Object duty : dutiesList) {
                                duties.add(String.valueOf(duty));
                            }
                            description = String.join(duties, '\n');
                        } else {
                            description = 'N/A'; // Fallback
                        }
                    }
                }
            }
    
            // Create Job_Application__c record
            Job_Application__c jobApp = new Job_Application__c(
                Matched_Object_Id__c = matchedObjectId,
                Position_Title__c = (String) descriptor.get('PositionTitle'),
                Job_URL__c = (String) descriptor.get('PositionURI'),
                Salary__c = salary,
                Description__c = description
            );
    
            // Set temporary Account reference if needed
            if (accountId != null) {
                jobApp.Company_Name__c = accountId;
            } else {
                jobApp.Company_Name__r = new Account(Name = orgName);
            }
    
            jobsToInsert.add(jobApp);
        }
    
        // Insert new Accounts and update map with newly generated Ids
        if (!newAccountsToInsert.isEmpty()) {
            insert newAccountsToInsert.values();
            for (Account acc : newAccountsToInsert.values()) {
                accountMap.put(acc.Name, acc);
            }
        }
    
        // Reassign Account Ids to job applications if they were inserted earlier
        for (Job_Application__c jobApp : jobsToInsert) {
            if (jobApp.Company_Name__c == null && jobApp.Company_Name__r != null) {
                Account acc = accountMap.get(jobApp.Company_Name__r.Name);
                if (acc != null) {
                    jobApp.Company_Name__c = acc.Id;
                }
            }
            jobApp.Company_Name__r = null; // Clear reference field to avoid DML error
        }
    
        // Final insert of Job Applications
        if (!jobsToInsert.isEmpty()) {
            try {
                insert jobsToInsert;
            } catch (DmlException e) {
                System.debug('DML Exception while inserting Job Applications: ' + e.getMessage());
            }
        }
    }   
    
    //For testing
    public static void printJobInfo() {
        // Check if the parsedJobs list is empty
        if (parsedJobs.isEmpty()) {
            System.debug('No jobs to display, parsedJobs was Empty.'); // Log message if no jobs found
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
