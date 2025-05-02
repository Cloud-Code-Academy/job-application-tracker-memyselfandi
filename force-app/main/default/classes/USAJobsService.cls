public class USAJobsService {
    // Store parsed jobs for test validation
    public static List<Map<String, String>> parsedJobs = new List<Map<String, String>>();

    public static void getJobs() {
        HttpRequest req = new HttpRequest();
        Http http = new Http();

        String endpoint = 'callout:USAJOBS_API/api/search?Keyword=developer&LocationName=Washington%2C%20DC&DatePosted=30&RemunerationMinimumAmount=80000&WhoMayApply=public&HiringPath=public&ResultsPerPage=5';
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');

        try {
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                parseJobData(res.getBody());
            } else {
                System.debug('Callout failed. Status code: ' + res.getStatusCode());
                System.debug('Response: ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
    }

    public static void parseJobData(String responseBody) {
        parsedJobs.clear();  // Clear any previous results
        Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        if (jsonResponse.containsKey('SearchResult')) {
            List<Object> jobs = (List<Object>) jsonResponse.get('SearchResult');
            for (Object obj : jobs) {
                Map<String, Object> job = (Map<String, Object>) obj;
                Map<String, String> jobInfo = new Map<String, String>{
                    'JobTitle' => String.valueOf(job.get('JobTitle')),
                    'OrganizationName' => String.valueOf(job.get('OrganizationName')),
                    'LocationName' => String.valueOf(job.get('LocationName')),
                    'WhoMayApply' => String.valueOf(job.get('WhoMayApply')),
                    'HiringPath' => String.valueOf(job.get('HiringPath')),
                    'MajorDuties' => String.valueOf(job.get('MajorDuties')),
                    'MatchedObjectId' => String.valueOf(job.get('MatchedObjectId'))
                };
                parsedJobs.add(jobInfo);
            }
        } else {
            System.debug('No SearchResult key found in response.');
        }
    }

    public static void saveJobsToSalesforce() {
        // Create a list to hold new or updated Job Application records
        List<Job_Application__c> jobRecords = new List<Job_Application__c>();
        
        // Loop through each parsed job from the API response
        for (Map<String, String> job : parsedJobs) {
            // Create a new Job_Application__c record and set its field values
            jobRecords.add(new Job_Application__c(
                Job_Title__c = job.get('JobTitle'),                  // Set Job Title
                Organization_Name__c = job.get('OrganizationName'),  // Set Organization Name
                Location_Name__c = job.get('LocationName'),          // Set Location Name
                Who_May_Apply__c = job.get('WhoMayApply'),           // Set Who May Apply
                Hiring_Path__c = job.get('HiringPath'),              // Set Hiring Path
                Major_Duties__c = job.get('MajorDuties'),            // Set Major Duties
                Matched_Object_Id__c = job.get('MatchedObjectId')    // Set Matched Object ID (used as external ID)
            ));
        }
    
        // Upsert records: insert new ones or update existing based on external ID
        upsert jobRecords Job_Application__c.Matched_Object_Id__c;
    }
    

}
