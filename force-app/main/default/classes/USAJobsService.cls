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
        parsedJobs.clear();  // Clear any existing job data

        // Deserialize the JSON string into a generic map
        Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);

        // The actual jobs list is nested under "SearchResult" > "SearchResultItems"
        if (jsonResponse.containsKey('SearchResult')) {
            Map<String, Object> searchResult = (Map<String, Object>) jsonResponse.get('SearchResult');

            if (searchResult.containsKey('SearchResultItems')) {
                List<Object> jobs = (List<Object>) searchResult.get('SearchResultItems');

                // Loop through each job item and extract fields into a map
                for (Object obj : jobs) {
                    Map<String, Object> job = (Map<String, Object>) obj;

                    Map<String, String> jobInfo = new Map<String, String>{
                        'JobTitle' => String.valueOf(job.get('JobTitle')),
                        'OrganizationName' => String.valueOf(job.get('OrganizationName')),
                        'LocationName' => String.valueOf(job.get('LocationName')),
                        'WhoMayApply' => String.valueOf(job.get('WhoMayApply')),
                        'HiringPath' => String.valueOf(job.get('HiringPath')),
                        'MajorDuties' => String.valueOf(job.get('MajorDuties')),
                        'MatchedObjectId' => String.valueOf(job.get('MatchedObjectId')),
                        'PositionURI' => String.valueOf(job.get('PositionURI')),
                        'MinimumRange' => String.valueOf(job.get('Remuneration') != null ?
                            ((Map<String, Object>) job.get('Remuneration')).get('MinimumRange') : '')
                    };

                    parsedJobs.add(jobInfo);  // Add each job map to the parsedJobs list
                }
            } else {
                System.debug('No SearchResultItems key found in SearchResult.');
            }
        } else {
            System.debug('No SearchResult key found in response.');
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
                Salary__c = job.get('MinimumRange')
            ));
        }

        // Upsert records using the MatchedObjectId as an external ID to avoid duplicates
        upsert jobRecords Job_Application__c.Matched_Object_Id__c;
    }
}